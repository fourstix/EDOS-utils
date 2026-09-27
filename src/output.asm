; -------------------------------------------------------------------
; Output data byte to port 4
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

start:    glo     rc                  ; check argc (2 -> 1 arg)
          smi     2                   ; if no args show ussage message
          lbz     good                ; jump to process input

bad_arg:  call    K_INMSG             ; otherwise display usage msg
            db      'Usage: output hh, where hh is a hexadecimal number',13,10,0
          abend                       ; return to Elf-DOS

good:     copy    ra, rb
          add16   rb, 2               ; RB = &argv[1]
          lda     rb
          phi     rf
          ldn     rb
          plo     rf                  ; RF = argv[1]
          call    f_hexin             ; convert argv[1] to hex value

          glo     rd                  ; get the hexadecimal byte value
          str     r2                  ; put it on the stack
          out 4                       ; output to port 4, increments stack
          dec     r2                  ; back stack up to old location

          return                      ; return to Elf-DOS

        ;------ define end of execution block
        end     start
