Intermediate Code:
LABL                      0-main                    
NEWFUNC                   
DECL                      2-1-0-a                   
STOR                      4                         2-1-0-a                   
STOR                      2-1-0-a                   *-tmp-int-1               
CMP                       10                        *-tmp-int-1               
LE                        *-tmp-int-1               
STOR                      *-tmp-int-1               *-tmp-bool-0              
JEQZ                      *-tmp-bool-0              label3                    
STOR                      2-1-0-a                   *-tmp-int-3               
CMP                       5                         *-tmp-int-3               
LE                        *-tmp-int-3               
STOR                      *-tmp-int-3               *-tmp-bool-2              
JEQZ                      *-tmp-bool-2              label1                    
PUSHARG                   0                         "A is <= 5\n"             
CALL                      ffi.printf                
JMP                       label2                    
LABL                      label1                    
PUSHARG                   0                         "A is >= 5\n"             
CALL                      ffi.printf                
LABL                      label2                    
JMP                       label4                    
LABL                      label3                    
PUSHARG                   0                         "A is non <= 10\n"        
CALL                      ffi.printf                
LABL                      label4                    
NEWFUNCEND                
