Intermediate Code:
LABL                      0-getVal2                 
NEWFUNC                   
ARGDECL                   0                         1-0-a                     
ARGDECL                   1                         1-0-b                     
STOR                      10                        *-tmp-int-1               
ADD                       1-0-a                     *-tmp-int-1               
STOR                      *-tmp-int-1               *-tmp-int-0               
STOR                      *-tmp-int-0               *-tmp-int-3               
ADD                       1-0-b                     *-tmp-int-3               
STOR                      *-tmp-int-3               *-tmp-int-2               
RETSETUP                  
PUSHRET                   *-tmp-int-2               
RETEND                    
NEWFUNCEND                
LABL                      0-getVal                  
NEWFUNC                   
PUSHARG                   0                         17                        
PUSHARG                   1                         45                        
CALL                      0-getVal2                 
POP                       *-tmp-int-4               
STOR                      8                         *-tmp-int-6               
ADD                       *-tmp-int-4               *-tmp-int-6               
STOR                      *-tmp-int-6               *-tmp-int-5               
RETSETUP                  
PUSHRET                   *-tmp-int-5               
RETEND                    
NEWFUNCEND                
LABL                      0-main                    
NEWFUNC                   
CALL                      0-getVal                  
POP                       *-tmp-int-7               
PUSHARG                   0                         "%d\n"                    
PUSHARG                   1                         *-tmp-int-7               
CALL                      ffi.printf                
NEWFUNCEND                
