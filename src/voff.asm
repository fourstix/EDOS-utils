; -------------------------------------------------------------------
; Turn off pixie video and disable interrupts
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
start:    glo     rc              ; check argc (1 -> no args)
          smi     1               ; if any args show message
          lbnz    bad_arg         ; jump to usage message

        ;------ turn off display
          out     1               ; first output freezes display
          dec     r2              ; output increments stack, so back up stack

          out     1               ; do it twice to blank display
          dec     r2              ; back stack up to old location

        ;------ disable interrupts
          sex     r3              ; set x = p for inline value
          dis                     ; Set x=2; p=3 and disable interrupts
          db      $23             ; Value for x=2; p=3

          return                  ; return to Elf-DOS

bad_arg:  call     K_INMSG
            db 'Usage: voiff',13,10,'Turn pixie video off and disable interrupts.',13,10,0
          fail     -1             ; return to Elf-DOS with error

        ;------ end of program
        end     start
