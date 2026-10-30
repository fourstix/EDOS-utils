;--------------------------------------------------------------------
;  DMA Video Test
;  Based on Tom Pittman's original Video DMA Program
;  Published in A Short Course in Computer Programming by Tom Pittman
;  Copyright 1979 Netronics Research & Development Ltd.
;
;  Modified to run under Elf-DOS on a system with Pixie Video
;  Copyright 2026 by Gaston Williams
;--------------------------------------------------------------------

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

           ;------ stack pointer r2 is already set by OS
start:     sex r3   ; set x = p
           dis      ; Set x=2; p=3 and disable interrupts
           db $23   ; value for x=2; p=3
           ghi r3   ; P = 3
           phi r0   ; set up DMA pointer
           ldi 080H ; point to video Data
           glo r0   ; set up DMA pointer

Video:     inp 1    ; turn video on

           ;------------ DMA occurs here ------------

loop:      ldi 080H ; fix r0
           plo r0
           bn4 loop ; continue until input pressed

           ; Leave interrupts disabled
           out 1    ; turn off Video
           dec r2   ; sex r2 back to original location
           return   ; return to Elf-DOS

  org (PROG_BASE + $80)
; data for video dma
buffer: db 080H, 081H, 082H, 083H, 084H, 085H, 086H, 087H
        db 088H, 089H, 08AH, 08BH, 08CH, 08DH, 08EH, 08FH

        ;------ end of program
        end     start
