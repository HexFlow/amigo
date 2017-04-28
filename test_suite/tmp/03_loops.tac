Intermediate Code:
LABL                      0-main                    
NEWFUNC                   
DECL                      2-1-0-i                   
STOR                      0                         2-1-0-i                   
LABL                      label5                    
STOR                      2-1-0-i                   *-tmp-int-1               
CMP                       10                        *-tmp-int-1               
LT                        *-tmp-int-1               
STOR                      *-tmp-int-1               *-tmp-bool-0              
CMP                       0                         *-tmp-bool-0              
JE                        label6                    
DECL                      5-4-3-2-1-0-j             
STOR                      0                         5-4-3-2-1-0-j             
LABL                      label3                    
STOR                      5-4-3-2-1-0-j             *-tmp-int-3               
CMP                       20                        *-tmp-int-3               
LT                        *-tmp-int-3               
STOR                      *-tmp-int-3               *-tmp-bool-2              
CMP                       0                         *-tmp-bool-2              
JE                        label4                    
PUSHARG                   0                         "%d %d, "                 
PUSHARG                   1                         2-1-0-i                   
PUSHARG                   2                         5-4-3-2-1-0-j             
CALL                      ffi.printf                
ADD                       1                         5-4-3-2-1-0-j             
JMP                       label3                    
LABL                      label2                    
LABL                      label4                    
PUSHARG                   0                         "\n"                      
CALL                      ffi.printf                
ADD                       1                         2-1-0-i                   
JMP                       label5                    
LABL                      label1                    
LABL                      label6                    
NEWFUNCEND                
