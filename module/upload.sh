#!/bin/sh

filename_arch16n="english.0.properties"
filename_cookie="/tmp/cookie.txt"
filename_css="ui_styling.css"
filename_form_data="/tmp/fetched-form-data.txt"
filename_ui_logic="ui_logic.bsh"
filename_ui_schema="ui_schema.xml"
filename_validation_schema="validation.xml"
login_email="faimsadmin@intersect.org.au"
login_password="Pass.123"
module_number=300               # The number in the URL of the "Edit Module" page
prefetch_in_background=true
prefetch_silently=true
url_base="http://dev.fedarch.org"
url_edit_module="$url_base/project_modules/$module_number/edit_project_module"
url_login="$url_base/users/sign_in"
url_update_module="$url_base/project_modules/$module_number/update_project_module"

if [ "$(uname)" = "Darwin" ]  #GNU sed isn't the same as pre-2005 BSD sed (Mac's flavour)
then
	sed_flags='-E'
else
	sed_flags='-r'
fi

# Even considering I'm parsing HTML with regexes, this could be more robust...
parse_value() {
	needle="$2"
	haystack="$1"
    printf "%s\\n" "$haystack" | grep "name=\"$needle\"" | sed $sed_flags   's/.*value="([^"]*)".*/\1/'
}
parse_srid() {
    printf "%s\\n" "$1" | grep "selected=\"selected\"" | sed $sed_flags   's/.*value="([^"]*)".*/\1/'

}

contains() {
    matches=$(printf "%s\\n" "$1" | grep "$2")
    [ "$matches" != "" ]
}

is_signed_in() {
    ! contains "$1" "sign_in"
}

fetch_page() {
    curl $1 \
        --ipv4 \
        --compressed \
        -s0 \
        --cookie     "$filename_cookie" \
        --cookie-jar "$filename_cookie"
}

fetch_form_data() {
    verb=$1
    rest_of_sentence="ing form for next upload..."
    printf "%-35s" "$verb$rest_of_sentence"
    resp=$(fetch_page "$url_edit_module")
    if ! is_signed_in "$resp"
    then
        printf "                       Failed (Not signed in)\\n"
        return 1
    elif [ "$resp" = "" ]
    then
        printf "                      Failed (Unknown reason)\\n"
        return 2
    fi

    auth_token=$(                parse_value "$resp" "authenticity_token")
    tmp_dir=$(                   parse_value "$resp" "project_module\[tmpdir\]")
    module_name=$(               parse_value "$resp" "project_module\[name\]")
    module_version=$(            parse_value "$resp" "project_module\[version\]")
	module_srid=$(               parse_srid  "$resp")
	module_year=$(               parse_value "$resp" "project_module\[season\]")
	module_permit_no=$(          parse_value "$resp" "project_module\[permit_no\]")
	module_permit_issued_by=$(   parse_value "$resp" "project_module\[permit_issued_by\]")
	module_permit_type=$(        parse_value "$resp" "project_module\[permit_type\]")
	module_copyright_holder=$(   parse_value "$resp" "project_module\[copyright_holder\]")
	module_client_sponsor=$(     parse_value "$resp" "project_module\[client_sponsor\]")
	module_land_owner=$(         parse_value "$resp" "project_module\[land_owner\]")

    save_form_data
    printf "                                        Done!\\n"
    return 0
}

save_form_data() {
    printf "$auth_token\n"                  >$filename_form_data
    printf "$tmp_dir\n"                    >>$filename_form_data
    printf "$module_name\n"                >>$filename_form_data
    printf "$module_version\n"             >>$filename_form_data
    printf "$module_srid\n"                >>$filename_form_data
    printf "$module_year\n"                >>$filename_form_data
    printf "$module_permit_no\n"           >>$filename_form_data
    printf "$module_permit_issued_by\n"    >>$filename_form_data
    printf "$module_permit_type\n"         >>$filename_form_data
    printf "$module_copyright_holder\n"    >>$filename_form_data
    printf "$module_client_sponsor\n"      >>$filename_form_data
    printf "$module_land_owner\n"          >>$filename_form_data
}
load_form_data() {
    auth_token=$(              sed -n  1p $filename_form_data 2>/dev/null)
    tmp_dir=$(                 sed -n  2p $filename_form_data 2>/dev/null)
    module_name=$(             sed -n  3p $filename_form_data 2>/dev/null)
    module_version=$(          sed -n  4p $filename_form_data 2>/dev/null)
    module_srid=$(             sed -n  5p $filename_form_data 2>/dev/null)
    module_year=$(             sed -n  6p $filename_form_data 2>/dev/null)
    module_permit_no=$(        sed -n  7p $filename_form_data 2>/dev/null)
    module_permit_issued_by=$( sed -n  8p $filename_form_data 2>/dev/null)
    module_permit_type=$(      sed -n  9p $filename_form_data 2>/dev/null)
    module_copyright_holder=$( sed -n 10p $filename_form_data 2>/dev/null)
    module_client_sponsor=$(   sed -n 11p $filename_form_data 2>/dev/null)
    module_land_owner=$(       sed -n 12p $filename_form_data 2>/dev/null)
}

sign_in () {
    printf "Signing in...\\n"

    # Download authenticity token
    printf "    - Downloading authenticity token..."
    resp=$(      fetch_page  "$url_base")
    auth_token=$(parse_value "$resp" "authenticity_token")
    if [ "$resp" = "" ]
    then
        printf "                                   Failed\\n"
        return 1
    fi
    printf "                                    Done!\\n"

    # Actually Sign in
    printf "    - Completing sign-in..."
    resp=$(
        curl --request POST $url_login \
             --ipv4 \
             --compressed \
             -s0 \
             --data-urlencode "utf8=&#x2713;" \
             --data-urlencode "authenticity_token=$auth_token" \
             --data-urlencode "user[email]=$login_email" \
             --data-urlencode "user[password]=$login_password" \
             --cookie         "$filename_cookie" \
             --cookie-jar     "$filename_cookie"
    )
    if ! is_signed_in "$resp"
    then
        printf "                                               Failed\\n"
        return 2
    fi
    printf "                                                Done!\\n"
    return 0
}

upload() {
    printf "Uploading...\\n"

    # Read the form data off-disk and into some good ol' globals
    load_form_data

    # Fill out the form with the read data and send the files to the server
    printf "    - POSTing files..."
    resp=$(
        curl --request POST $url_update_module \
             --ipv4 \
             --compressed \
             -s0 \
             -F "utf8=&#x2713;" \
             -F "authenticity_token=$auth_token" \
             -F "project_module[name]=$module_name" \
             -F "project_module[version]=$module_version" \
             -F "project_module[srid]=$module_srid" \
             -F "project_module[season]=$module_year" \
             -F "project_module[description]=" \
             -F "project_module[permit_no]=$module_permit_no" \
             -F "project_module[permit_holder]=" \
             -F "project_module[permit_issued_by]=$module_permit_issued_by" \
             -F "project_module[permit_type]=$module_permit_type" \
             -F "project_module[contact_address]=" \
             -F "project_module[participant]=" \
             -F "project_module[copyright_holder]=$module_copyright_holder" \
             -F "project_module[client_sponsor]=$module_client_sponsor" \
             -F "project_module[land_owner]=$module_land_owner" \
             -F "project_module[has_sensitive_data]=" \
             -F "project_module[tmpdir]=$tmp_dir" \
             -F "project_module[ui_schema]=@$filename_ui_schema" \
             -F "project_module[validation_schema]=@$filename_validation_schema" \
             -F "project_module[ui_logic]=@$filename_ui_logic" \
             -F "project_module[arch16n]=@$filename_arch16n" \
             -F "project_module[css_style]=@$filename_css;type=text/css" \
             --cookie     "$filename_cookie" \
             --cookie-jar "$filename_cookie"
    )
    if ! (is_signed_in "$resp")
    then
        printf "                                    Failed (Not signed in)\\n"
        return 1
    elif ! (contains "$resp" "$module_number")
    then
        printf "                                   Failed (Unknown reason)\\n"
        return 2
    fi
    printf "                                                     Done!\\n"

    # NOTE The stuff below parses and displays the errors. It assumes there can
    #      only be one error per file. If there's more, I'm guessing only the
    #      first would be displayed---but maybe nothing will! It'll be a fun
    #      surprise.
    resp=$(printf "%s\\n" "$resp" | tail -n100 | tr "\\n" " " | tr "\\r" " ")
    errors=""
    for s in "ui_schema" "validation_schema" "ui_logic" "arch16n" "css_style"
    do
        # Parses an error if one exists. Otherwise it sets $error to $resp
        error=$(printf "%s\\n" "$resp" | sed "s/.*>\([A-Za-z0-9: !]\+\)<\/label> <input id=\"project_module_$s\" name=\"project_module\[$s\]\" type=\"file\" \/> <span class=\"help-inline\">\([^<]\+\)<\/span>.*/\1 \2/g" | fold -w 80)
        if ! (contains "$error" "<")     # "<" signifies the start of a HTML tag
        then
            errors="$errors        - $error\\n"
        fi
    done
    if [ "$errors" != "" ]           # Only format and print errors if any exist
    then
        printf "    - Error(s) in files:\\n"
        printf "$errors"
    fi

    return 0
}

################################################################################
###################################   MAIN   ###################################

# TODO Confess to a priest for storing a password in this file.  In the
#      meanwhile, the following lines add this file to your .gitignore if it
#      hasn't been already.  (It creates a .gitignore if it doesn't exist yet.)
if ! grep -x "`basename $0`" .gitignore >/dev/null 2>/dev/null
then
    printf "%-75s" "Adding the line \"`basename $0`\" to your .gitignore..."
    printf "`basename $0`\\n" >> .gitignore
    printf "Done!\\n"
fi

# Stuff to modify the behaviour of fetch_form_data as desired during prefetching
if [ "$prefetch_silently" = true ]
then
    prefetch_silently=">/dev/null"
else
    prefetch_silently=
fi
if [ "$prefetch_in_background" = true ]
then
    prefetch_in_background="&"
else
    prefetch_in_background=
fi
prefetch_command="fetch_form_data 'Prefetch' \
    $prefetch_silently \
    $prefetch_in_background"

# The main, high-level tasks
upload
ret_upload=$?
if   [ "$ret_upload" = "0" ]       # Upload success
then
    eval "$prefetch_command"
elif [ "$ret_upload" = "1" ]       # Not signed in
then
    sign_in                 || exit 1
    fetch_form_data "Fetch" || exit 1
    upload                  || exit 1
    eval "$prefetch_command"
fi
