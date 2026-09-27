; -------------------------------------------------------------------
; Reset the Q bit and return to Elf-DOS
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

          req		                  ; reset the q bit
	        return                  ; return to Elf-DOS

bad_arg:  call     K_INMSG
            db 'Usage: req',13,10,'Reset the Q bit.',13,10,0
          abend                   ; return to Elf-DOS with error

        ;------ end of program block
        end     start
