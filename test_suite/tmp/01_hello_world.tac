Intermediate Code:
LABL                      0-main                    
NEWFUNC                   
DECL                      2-1-0-a                   
STOR                      9                         2-1-0-a                   
STOR                      2-1-0-a                   *-tmp-int-1               
ADD                       2                         *-tmp-int-1               
STOR                      *-tmp-int-1               *-tmp-int-0               
STOR                      *-tmp-int-0               2-1-0-a                   
DECL                      2-1-0-c                   
STOR                      "%d %d %d %d %d %d %d %d %d %d\n" 2-1-0-c                   
DECL                      2-1-0-d                   
STOR                      5                         2-1-0-d                   
DECL                      2-1-0-e                   
STOR                      8                         2-1-0-e                   
DECL                      2-1-0-f                   
STOR                      4                         2-1-0-f                   
DECL                      2-1-0-g                   
STOR                      3                         2-1-0-g                   
DECL                      2-1-0-h                   
STOR                      2                         2-1-0-h                   
DECL                      2-1-0-i                   
STOR                      12                        2-1-0-i                   
DECL                      2-1-0-j                   
STOR                      14                        2-1-0-j                   
DECL                      2-1-0-k                   
STOR                      15                        2-1-0-k                   
DECL                      2-1-0-l                   
STOR                      16                        2-1-0-l                   
DECL                      2-1-0-m                   
STOR                      17                        2-1-0-m                   
PUSHARG                   0                         2-1-0-c                   
PUSHARG                   1                         2-1-0-d                   
PUSHARG                   2                         2-1-0-e                   
PUSHARG                   3                         2-1-0-f                   
PUSHARG                   4                         2-1-0-g                   
PUSHARG                   5                         2-1-0-h                   
PUSHARG                   6                         2-1-0-i                   
PUSHARG                   7                         2-1-0-j                   
PUSHARG                   8                         2-1-0-k                   
PUSHARG                   9                         2-1-0-l                   
PUSHARG                   10                        2-1-0-m                   
CALL                      ffi.printf                
NEWFUNCEND                
