; -------------------------------------------------------------------
; Exchange the first and second values in disk map and reboot
;
; Copyright 2024 by Gaston Williams
; -------------------------------------------------------------------

; Copy this file to begin a new program (it isn't built by "make
; progs" itself -- see the Makefile's PROG_SRCS filter):
;   cp progs/template.asm progs/mynewprog.asm
;
; A program is loaded via prog_run (see kernel/loader.asm) at the
; fixed address PROG_BASE (see include/kernel_api.inc for its current
; value). Its entry point is always PROG_BASE + $06, immediately after
; the 6-byte header below.
;
; At entry:
;   RA = pointer to the argv table -- an array of RC 16-bit big-endian
;        pointers, argv[0..argc-1], each to a null-terminated string.
;        argv[0] is the program's own invocation name (matching C's
;        main(argc, argv) convention). Arguments are split by the
;        shell with quoting ("..." keeps embedded spaces in one
;        token) and backslash-escaping (\X -> literal X, inside or
;        outside quotes).
;   RC = argc (word) -- always >= 1 on a successful hand-off, since
;        argv[0] is always present.
;   R2 = kernel's stack pointer -- safe to use normally (call/rtn,
;        push/pop); the kernel restores it after the program exits
;        regardless of what happens in between.
;   D, DF, and every other register: undefined.
;
; Like any register, RA/RC are only guaranteed valid until the first
; kernel/BIOS call the program makes -- stash to memory (or another
; register) immediately if either is needed after that. To read
; argv[N] (N a small compile-time constant): compute its address as
; RA + N*2 (add16 supports a constant operand), then dereference the
; 2-byte pointer stored there with the standard lda/phi/ldn/plo
; sequence, e.g. for argv[1]:
;   mov     rb, ra
;   add16   rb, 2               ; RB = &argv[1]
;   lda     rb
;   phi     rf
;   ldn     rb
;   plo     rf                  ; RF = argv[1]
;
; To exit, just 'rtn' back to the kernel -- D = exit code by
; convention (0 = success; other values are program-defined; no
; specific non-zero codes are reserved yet).
;
; #include kernel_api.inc, not kernel.inc -- kernel.inc is for the
; kernel's own internal structures (FCB/BPB/directory-entry layout),
; which can change across kernel updates; kernel_api.inc is the
; stable, program-facing surface (K_xxx kernel/BIOS calls, PROG_BASE,
; LOADER_ARGS). See that file for the full call list and conventions.

#include    include/opcodes.def
#include    include/bios.inc
#include    include/kernel_api.inc

            org     PROG_BASE

;------------------------------------------------------------------
; 6-byte program header (mirrors the kernel's own header layout
; exactly: magic + major + minor + 1 reserved byte -- widened from a
; single version byte + 2 reserved bytes 2026-08-21, before release,
; specifically for this consistency; nothing reads this byte pair at
; load time today -- see kernel/loader.asm's prog_run, which only
; ever validates the 3 magic bytes -- so it's a labeling change with
; no effect on program size or the loader)
;------------------------------------------------------------------
            db      'E','D','F'         ; ELF-DOS program magic
            db      1                   ; program major version
            db      0                   ; program minor version
            db      0                   ; reserved

;------------------------------------------------------------------
; Program entry point - PROG_BASE + $06
;------------------------------------------------------------------
start:    glo     rc              ; check argument count
          smi     1               ; command has no arguments
          lbnz    bad_arg         ; so anything besides 1 is a bad argument

          ; Swap the drive numbers in the kernel

          load    rf, $0043       ; set rf to drive mapping
          lda     rf              ; get first drive value
          plo     rd              ; save in rd.0
          ldn     rf              ; get second drive value
          phi     rd              ; save in rd.1
          glo     rd              ; get first drive value
          str     rf              ; put in second drive location
          dec     rf              ; back up to first drive location
          ghi     rd              ; get second drive value
          str     rf              ; put in first drive location

          ; Boot Elf/OS from the card in new drive
          ; This code is taken from Mike Riley's reboot program
boot:     sex     r3              ; x=p to inline the ret data byte
          ret                     ; enable interrupts
          db      $23             ; set X=2, P=3
          lbr     f_boot          ; jump to bios boot routine


bad_arg:  load    rf, usage       ; show usage text and exit
          call    K_MSG
          return                  ; return to Elf/OS

usage:    db 'Usage: redirect',13,10
          db 'Exchange the first and second values in disk map and reboot',13,10,0
        ;------ define end of execution block
          end     start
