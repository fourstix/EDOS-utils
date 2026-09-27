; -------------------------------------------------------------------
; Input a data byte from port 4
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

start:  glo     rc                 ; check argc (1 -> no args)
        smi     1                  ; if any args show message
        lbnz    bad_arg            ; jump to usage message

        inp     4                   ; input data from Port 4
        plo     rd                  ; put data byte into rd for conversion

        load    rf, buffer          ; Set up rf to point to a buffer
        call    f_hexout2           ; convert to 2 char ASCII

        load    rf, buffer          ; Set up rf to point to a buffer
        call    K_MSG               ; output text value

        return                      ; return to Elf/OS

bad_arg:  call     K_INMSG
            db 'Usage: input',13,10,'Display input data read from Port 4.',13,10,0
          abend                     ; return to Elf-DOS with error
buffer: db  0,0,13,10,0             ; 2 char hex value + crlf
        ;------ end of program
        end     start
