Intermediate Code:
LABL                      0-getVal                  
NEWFUNC                   
RETSETUP                  
PUSHRET                   8                         
RETEND                    
NEWFUNCEND                
LABL                      0-main                    
NEWFUNC                   
CALL                      0-getVal                  
POP                       *-tmp-int-0               
PUSHARG                   0                         "%d\n"                    
PUSHARG                   1                         *-tmp-int-0               
CALL                      ffi.printf                
NEWFUNCEND                
