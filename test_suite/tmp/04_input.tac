Intermediate Code:
LABL                      0-main                    
NEWFUNC                   
DECL                      2-1-0-a                   
STOR                      0                         2-1-0-a                   
ADDR                      2-1-0-a                   *-tmp-Pointer-int-0       
PUSHARG                   0                         "%d"                      
PUSHARG                   1                         *-tmp-Pointer-int-0       
CALL                      ffi.scanf                 
STOR                      2-1-0-a                   *-tmp-int-2               
ADD                       10                        *-tmp-int-2               
STOR                      *-tmp-int-2               *-tmp-int-1               
PUSHARG                   0                         "%d\n"                    
PUSHARG                   1                         *-tmp-int-1               
CALL                      ffi.printf                
NEWFUNCEND                
