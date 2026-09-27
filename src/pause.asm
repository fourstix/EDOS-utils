; -------------------------------------------------------------------
; Display a prompt message and wait for input
; Copyright 2026 by Gaston Williams
; -------------------------------------------------------------------

#include    include/bios.inc
#include    include/kernel_api.inc
#include    include/opcodes.def

          org     PROG_BASE
;------------------------------------------------------------------
; 6-byte program header (mirrors the kernel's own header layout
; exactly: magic + major + minor + 1 reserved byte
;------------------------------------------------------------------
db      'E','D','F'         ; ELF-DOS program magic
db      1                   ; program major version
db      1                   ; program minor version
db      0                   ; reserved

;------------------------------------------------------------------
; Program entry point - PROG_BASE + $06
;------------------------------------------------------------------
start:    load    rf, prompt      ; set rf to default message

chk_arg:  glo     rc              ; check argc (for 2 or 1)
          smi     1               ; if no args use default
          lbz     wait4           ; jump to default input on /ef4

          smi     1               ; only one arg is allowed (argc = 2)
          lbnz    bad_arg         ; anything else shows a usage message

          ; --- argv[1]: can be -0, -1, -2, -3 or -4 ---
          copy    ra, rb
          add16   rb, 2           ; RB = &argv[1]
          lda     rb
          phi     rd
          ldn     rb
          plo     rd              ; RD = argv[1]
          lda     rd
          xri     '-'             ; valid options start with dash
          lbnz    bad_arg

          load    rf, prompt      ; set up message for prompt
          ldn     rd              ; check for option 0
          smi     '0'             ; to wait for input on serial data
          lbz     waits

          smi     1               ; check for option 1 ('1' - '0' = 1)
          lbz     wait1           ; to wait for input on /ef1

          smi     1               ; check for option 2 ('2' - '1' = 1)
          lbz     wait2           ; to wait for input of /ef2

          smi     1               ; check for option 3 ('3' - '2' = 1)
          lbz     wait3           ; to wait for input of /ef4

          smi     1               ; check for option 4 ('4' - '3' = 1)
          lbz     wait4           ; to wait for input of /ef4

          lbr     bad_arg         ; anything else is a bad argument

waits:    call    K_MSG           ; display prompt
          call    f_input         ; wait here for serial input
          lbr     goodbye         ; exit

wait1:    call    K_MSG           ; display prompt
          bn1     $               ; wait here for input press on /ef1
          lbr     goodbye         ; exit

wait2:    call    K_MSG           ; display prompt
          bn2     $               ; wait here for input press on /ef2
          lbr     goodbye         ; exit

wait3:    call    K_MSG           ; display prompt
          bn3     $               ; wait here for input press on /ef3
          lbr     goodbye         ; exit

wait4:    call    K_MSG           ; display prompt
          bn4     $               ; wait here for input press on /ef4

goodbye:  call    K_INMSG         ; send crlf to console
            db 13,10,0
          return                  ; return to Elf-DOS

bad_arg:  load    rf, usage       ; show usage text and exit
          call    K_MSG
          load    rf, info1
          call    K_MSG
          load    rf, info2
          call    K_MSG
          load    rf, info3
          call    K_MSG
          load    rf, info4
          call    K_MSG
          abend                   ; return to Elf-DOS with error code

prompt:   db 'Press Input to continue...',0
usage:    db 'Usage: pause [-0|-1|-2|-3|-4, default = -4]',13,10,0
info1:    db 'Display a prompt message and wait for input.',13,10,0
info2:    db 'Use option -1,-2,-3 or -4 to wait for /EFn line input.',13,10,0
info3:    db 'Use option -0 to wait for serial input.',13,10,0
info4:    db 'Waiting for input on the /EF4 line is the default.',13,10,0
        ;------ define end of execution block
        end     start
