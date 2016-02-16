
rmdir -rf wireframeImages/
mkdir -p wireframeImages


  ./makeElement.sh style_orientation_orientation "horizontal" input 1 false false false false false wireframeImages/
  
  ./makeElement.sh style_even_layout_weight "1" input 1 false false false false false wireframeImages/
  
  ./makeElement.sh style_large_layout_weight "3" input 1 false false false false false wireframeImages/
  
  ./makeElement.sh User_User_Select_User "Select User" list 1 false false false false false wireframeImages/
  
  ./makeElement.sh Main_Main_Project "" input 1 false false false false false wireframeImages/
  
  ./makeElement.sh Main_Main_Author "" input 1 false false false false false wireframeImages/
  
  ./makeElement.sh Main_Main_Next_Artefact_ID "" input 1 false false false true false wireframeImages/
  
  ./makeElement.sh Main_Main_Take_New_Sample "" button 1 false false false false false wireframeImages/
  
  ./makeElement.sh Main_Search_Search_Term "Search Term" input 2 false false false false false wireframeImages/
  
  ./makeElement.sh Main_Search_Search_Button "Search" button 2 false false false false false wireframeImages/
  
  ./makeElement.sh Main_Search_Entity_List "Entity List" list 1 false false false false false wireframeImages/
  
  ./makeElement.sh Sample_Sample_Project "" input 1 false false true false true wireframeImages/
  
  ./makeElement.sh Sample_Sample_Author "" input 1 false false true false false wireframeImages/
  
  ./makeElement.sh Sample_Sample_Timestamp "" input 1 false false true false false wireframeImages/
  
  ./makeElement.sh Sample_Sample_Artefact_ID "" input 1 false false true true false wireframeImages/
  
  ./makeElement.sh Sample_Sample_Artefact_Type "" dropdown 1 false false true false false wireframeImages/
  
  ./makeElement.sh Sample_Sample_Artefact_Description "" input 1 false false true false false wireframeImages/
  
  ./makeElement.sh Sample_Sample_Artefact_Barcode "" input 1 false false true false false wireframeImages/
  
  ./makeElement.sh Sample_Sample_Picture "Picture" camera 1 false false true false false wireframeImages/
  
  ./makeElement.sh Sample_Sample_Button_Picture "" button 1 false false false false false wireframeImages/
  
  ./makeElement.sh Sample_Sample_Number_Of_Joints "" input 1 false false true false false wireframeImages/
  
  ./makeElement.sh Sample_Sample_Total_Weight "" input 1 false false true false false wireframeImages/
  
  ./makeElement.sh Sample_Sample_Take_Weight "" button 1 false false false false false wireframeImages/
  