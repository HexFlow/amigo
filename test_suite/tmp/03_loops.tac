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
STOR                      5-4-3-2-1-0-j             *-tmp-int-5               
CMP                       20                        *-tmp-int-5               
LT                        *-tmp-int-5               
STOR                      *-tmp-int-5               *-tmp-bool-4              
CMP                       0                         *-tmp-bool-4              
JE                        label4                    
PUSHARG                   0                         "%d %d, "                 
PUSHARG                   1                         2-1-0-i                   
PUSHARG                   2                         5-4-3-2-1-0-j             
CALL                      ffi.printf                
STOR                      5-4-3-2-1-0-j             *-tmp-int-7               
ADD                       1                         *-tmp-int-7               
STOR                      *-tmp-int-7               *-tmp-int-6               
STOR                      *-tmp-int-6               5-4-3-2-1-0-j             
JMP                       label3                    
LABL                      label2                    
LABL                      label4                    
PUSHARG                   0                         "\n"                      
CALL                      ffi.printf                
STOR                      2-1-0-i                   *-tmp-int-3               
ADD                       1                         *-tmp-int-3               
STOR                      *-tmp-int-3               *-tmp-int-2               
STOR                      *-tmp-int-2               2-1-0-i                   
JMP                       label5                    
LABL                      label1                    
LABL                      label6                    
NEWFUNCEND                
