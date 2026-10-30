;-------------------------------------------------------------------
; Original Elf Pixie Graphic Program by Joseph A Weisbecker
; Published in Popular Electronics, July 1979, pages 41-46
; Copyright Joseph A Weisbecker 1976-1979
;
; Modified to run under Elf-DOS on system with Pixie Video
; Copyright 2026 by Gaston Williams
;-------------------------------------------------------------------

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


start:     ghi     r3            ; P=3, X=2 in Elf/OS
           phi     r1            ; Set up interrupt register
           ldi     low interrupt ; set interrupt address
           plo     r1            ; to point to interrupt handler

           sex     r3            ; set x = p
           ret                   ; Keep x=2; p=3 and enable interrupts
           db $23                ; Value for x=2; p=3
           br      main          ; go to main routine and wait for interrupt

exit:      ldxa                  ; restore D,
           ret                   ; return point X, P back to original locations
interrupt: dec     r2            ; move stack pointer
           sav                   ; save T register
           dec     r2            ; move stack pointer
           str     r2            ; Store D onto stack
           nop                   ; 3 nops = 9 cycles to make interrupt
           nop                   ; routine exactly the 29 instruction cycles
           nop                   ; required for 1861 timing
           ldi     PROG_BASE.1   ; point dma register at code page
           phi     r0            ;
           ldi     00h           ; point dma register at code page
           plo     r0
refresh:   glo     r0            ; D = r0.0
           sex     r2            ; X = 2
                     ; <----- 8 DMA cycles occur here (R0+8)
           sex     r2    ; there is time for exactly 6 instruction cycles
           dec     r0    ; utilized here by 3 two-cycle instructions
           plo     r0    ; in between dma requests
                     ; <----- 8 DMA cycles occur here (R0+8)
           sex     r2
           dec     r0
           plo     r0
                     ; <----- 8 DMA cycles occur here (R0+8)
           sex     r2
           dec     r0
           plo     r0
                     ; <----- 8 DMA cycles occur here (R0+8)
           bn1     refresh   ; go to refresh if EF1 false
           br      exit      ; return if EF1 true (end of frame)

main:      inp 1             ; Turn on Video
wait:      bn4     wait      ; wait for Input pressed to exit
           sex     r3        ; set x = p
           dis               ; x=2, p=3 and disable interrupts
           db $23            ; value for x=2, p=3
           out 1             ; turn off Video, increments stack
           dec 2             ; put stack pointer back to original
           return            ; return to Elf-DOS

; ***************************************
; Data for spaceship graphic image
; ***************************************

           org     (PROG_BASE + $40)

spaceship: db 00h, 00h,  00h,  00h,  00h,  00h,  00h,  00h
           db 00h, 00h,  00h,  00h,  00h,  00h,  00h,  00h
           db 7Bh, 0DEh, 0DBh, 0DEh, 00h,  00h,  00h,  00h
           db 4Ah, 50h,  0DAh, 52h,  00h,  00h,  00h,  00h
           db 42h, 5Eh,  0ABh, 0D0h, 00h,  00h,  00h,  00h
           db 4Ah, 42h,  8Ah,  52h,  00h,  00h,  00h,  00h
           db 7Bh, 0DEh, 8Ah,  5Eh,  00h,  00h,  00h,  00h
           db 00h, 00h,  00h,  00h,  00h,  00h,  00h,  00h
           db 00h, 00h,  00h,  00h,  00h,  00h,  07h,  0E0h
           db 00h, 00h,  00h,  00h,  0FFh, 0FFh, 0FFh, 0FFh
           db 00h, 06h,  00h,  01h,  00h,  00h,  00h,  01h
           db 00h, 7Fh,  0E0h, 01h,  00h,  00h,  00h,  02h
           db 7Fh, 0C0h, 3Fh,  0E0h, 0FCh, 0FFh, 0FFh, 0FEh
           db 40h, 0Fh,  00h,  10h,  04h,  80h,  00h,  00h
           db 7Fh, 0C0h, 3Fh,  0E0h, 04h,  80h,  00h,  00h
           db 00h, 3Fh,  0D0h, 40h,  04h,  80h,  00h,  00h
           db 00h, 0Fh,  08h,  20h,  04h,  80h,  7Ah,  1Eh
           db 00h, 00h,  07h,  90h,  04h,  80h,  42h,  10h
           db 00h, 00h,  18h,  7Fh,  0FCh, 0F0h, 72h,  1Ch
           db 00h, 00h,  30h,  00h,  00h,  10h,  42h,  10h
           db 00h, 00h,  73h,  0FCh, 00h,  10h,  7Bh,  0D0h
           db 00h, 00h,  30h,  00h,  3Fh,  0F0h, 00h,  00h
           db 00h, 00h,  18h,  0Fh,  0C0h, 00h,  00h,  00h
           db 00h, 00h,  07h,  0F0h, 00h,  00h,  00h,  00h

           ;------ end of program
           end     start
