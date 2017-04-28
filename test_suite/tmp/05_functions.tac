Intermediate Code:
LABL                      0-getVal2                 
NEWFUNC                   
ARGDECL                   0                         1-0-a                     
STOR                      10                        *-tmp-int-1               
ADD                       1-0-a                     *-tmp-int-1               
STOR                      *-tmp-int-1               *-tmp-int-0               
RETSETUP                  
PUSHRET                   *-tmp-int-0               
RETEND                    
NEWFUNCEND                
LABL                      0-getVal                  
NEWFUNC                   
PUSHARG                   0                         17                        
CALL                      0-getVal2                 
POP                       *-tmp-int-2               
STOR                      8                         *-tmp-int-4               
ADD                       *-tmp-int-2               *-tmp-int-4               
STOR                      *-tmp-int-4               *-tmp-int-3               
RETSETUP                  
PUSHRET                   *-tmp-int-3               
RETEND                    
NEWFUNCEND                
LABL                      0-main                    
NEWFUNC                   
CALL                      0-getVal                  
POP                       *-tmp-int-5               
PUSHARG                   0                         "%d\n"                    
PUSHARG                   1                         *-tmp-int-5               
CALL                      ffi.printf                
NEWFUNCEND                
