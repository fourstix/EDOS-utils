; -------------------------------------------------------------------
; Simple program to show the status of the IE flag.
; Copyright 2026 by Gaston Williams
; -------------------------------------------------------------------

#include    include/opcodes.def
#include    include/bios.inc
#include    include/kernel_api.inc

            org     PROG_BASE

;------------------------------------------------------------------
; 6-byte program header (mirrors the kernel's own header convention)
;------------------------------------------------------------------
            db      'E','D','F'         ; ELF-DOS program magic
            db      1                   ; program major version
            db      0                   ; program minor version
            db      0                   ; reserved

;------------------------------------------------------------------
; Program entry point - PROG_BASE + $06
;------------------------------------------------------------------
start:    glo     rc              ; check argc (for 2 or 1)
          smi     1               ; if no args
          lbz     status          ; show status of interupt

          smi     1               ; only one arg is allowed (argc = 2)
          lbnz    bad_arg         ; anything else shows a usage message

          ; --- argv[1]: can be -d or -e ---
          copy    ra, rb
          add16   rb, 2           ; RB = &argv[1]
          lda     rb
          phi     rd
          ldn     rb
          plo     rd              ; RD = argv[1]
          lda     rd
          xri     '-'             ; valid options start with dash
          lbnz    bad_arg

          ldn     rd              ; check for option d
          smi     'd'             ; to disable interrupts
          bz      int_off

          smi     1               ; check for option e ('e' - 'd' = 1)
          bz      int_on          ; to enable interrupts

bad_arg:  load    rf, usage       ; anything else is a bad argument
          call    K_MSG           ; show usage message
          load    rf, info1
          call    K_MSG
          load    rf, info2
          call    K_MSG
          load    rf, info3
          call    K_MSG
          lbr     done

int_on:   sex     r3              ; x = p for ret instruction
          ret                     ; Turn interrupts on
            db      23H           ; with x=2, p=3
          lbr     status

int_off:  sex     r3              ; x = p for dis instruction
          dis                     ; Turn interrupts off
            db      23H           ; with x=2, p=3

status:   call    K_INMSG         ; status message
            db      'Interrupts ', 0
          ldi     0FFh            ; load true value as default
          lsie                    ; only instruction that checks IE flag!
          ldi     00h             ; D = false, skipped over if IE true
          lbnz    ie_on           ; show enabled message if true
          call    K_INMSG         ; IE = 0 message
            db      'disabled. (IE = 0)', 10, 13, 0
          lbr     done
ie_on:    call    K_INMSG         ; IE = 1 message
            db     'enabled. (IE = 1)', 10, 13, 0
done:     return

usage:      db 'Usage: int [-d|-e]',13,10,0
info1:      db 'Display interrupt status.',13,10,0
info2:      db 'Use option -d to disable interrupts',13,10,0
info3:      db 'or option -e to enable interrupts.',13,10,0

        ;------ end of program
        end     start
