; -------------------------------------------------------------------
; *** cal: displays a simple calendar in traditional format.
; *** If arguments are not specified, the current month is displayed.
; ***
; *** Assembled with a modified version of the A18 assembler (includes
; *** dc pseudo-op).
; ***
; *** Build #
; ***  6: Changed highlighting from bold to reverse video.
; ***  7: Expanded year limits to 1582-9999.
; ***  8: Send VT1802 style highlight/normal sequences when
; ***     that video card is in use
; ***  9: Didn't read the VT1802 doc closely enough; 2nd try.
; *** 10: Thought about VT1802 some more, came up with something more
; ***     likely to work. (Such are the perils of writing code for h/w
; ***     you don't have to test on!)
; ***     Use local stack and f_getdev
; *** 12: Use ELF-DOS for terminal output (I remember changing this
; ***     TO the kernel calls for older ELF-DOS support...)
; ***     Use interrupt proof stack maniuplation
; *******************************************************************
; *** This software is copyleft 2021 by Wayne Hortensius          ***
; *** All wrongs reserved.                                        ***
; *******************************************************************
;
; *******************************************************************
; *** Modified in 2026 for ELF-DOS by Gaston Williams             ***
; *******************************************************************

#include    include/bios.inc
#include    include/kernel_api.inc
#include    include/opcodes.def

; bits for hardware device map (K_GETDEV)
;---- IDE bit
#define     b_devIDE    $01
;---- floppy bit
#define     b_devFLPY   $02
;---- Bit-banged serial
#define     b_devBBSER  $04
;---- UART bit
#define     b_devUART   $08
;---- RTC bit
#define     b_devRTC    $10
;---- NVRAM bit
#define     b_devNVR    $20


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
            db      1                   ; program minor version
            db      0                   ; reserved

;------------------------------------------------------------------
; Program entry point - PROG_BASE + $06
;------------------------------------------------------------------
start:
            lbr     Main

Help:
            call    K_INMSG
            db      'Calendar, version 1.0',13,10
            db      '  Syntax:',13,10
            db      9,'cal -h',9,9,'- Help',13,10,0
;
            mov     rf,HasClock
            ldn     rf
            bz      Help2
            call    K_INMSG
            db      9,'cal',9,9,'- Show current month',13,10,0
Help2:
            call    K_INMSG
            db      9,'cal month year',9,'- Show specified month',13,10
            db      9,9,'month',9,'= 1-12 or Jan-Dec',13,10
            db      9,9,'year',9,'= 1-99 or 1582-9999',0
Exit:
            call    crlf                ; print new line
            ldi     1                   ; assume interrupts are enabled
            lsie                        ; skip if they are
            ldi     0                   ; mark interrupts disabled
            plo     re                  ; save IE flag
            ldi     023h                ; setup for DIS (X=2, P=3)
            str     r2
            dis                         ; disable interrupts
            dec     r2
            mov     rf,saveStack        ; restore ELF-DOS's stack
            lda     rf
            phi     r2
            ldn     rf
            plo     r2
            glo     re                  ; recover IE flag
            lbz     Exit2               ; jump if interrupts were disabled
            ldi     023h                ; setup for RET (X=2, P=3)
            str     r2
            ret                         ; re-enable interrupts
            dec     r2
Exit2:
            pop     r6                  ; restore ELF-DOS's return address
            rtn                         ; return to ELF-DOS
;-----------------------
Main:
            push    r6                  ; save ELF-DOS's return address on its stack
            ldi     1                   ; assume interrupts are enabled
            lsie                        ; skip if they are
            ldi     0                   ; mark interrupts disabled
            plo     re                  ; save IE flag
            ldi     023h                ; setup for DIS (X=2, P=3)
            str     r2
            dis                         ; disable interrupts
            dec     r2
            mov     rf,saveStack        ; save ELF-DOS's stack
            ghi     r2
            str     rf
            inc     rf
            glo     r2
            str     rf
            mov     r2,localStack       ; use our own stack
            glo     re                  ; recover IE flag
            lbz     Main2               ; jump if interrupts were disabled
            ldi     023h                ; setup for RET (X=2, P=3)
            str     r2
            ret                         ; re-enable interrupts
            dec     r2
Main2:
            call    HasRTC
            mov     rf,HasClock
            ldi     0                   ; D = 0x00 (doesn't have RTC)
            lbnf    NoClk
            smi     1                   ; D = 0xFF (has RTC)
NoClk:      str     rf
            mov     rf,Day
            ldi     0                   ; zero out day
            str     rf                  ; (so no day hilited if command tail)
            call    crlf

            glo     rc
            smi     4
            lbdf    Help                ; argc >= 4: too many args

            glo     rc
            smi     1
            lbz     NoArgs

            ; --- argv[1]: could be -h or month ---
            mov     rb, ra
            add16   rb, 2               ; RB = &argv[1]
            lda     rb
            phi     rf
            ldn     rb
            plo     rf                  ; RF = argv[1]
            ldn     rf
            xri     '-'                 ; is either -h or invalid option or month
            lbz     Help                ; so show usage
            lbr     GetMonth
NoArgs:
            mov     rf,HasClock
            ldn     rf                  ; no cmd tail, get system time if we can
            lbz     NoClkMsg            ; no system clock to check, aww!
;
            mov     rf,DateBlk          ; point to kernel date/time
            call    K_GETTOD            ; call BIOS to get current date/time from RTC
            lbnf    GotTime
NoClkMsg:
            call    K_INMSG
            db      7,'No RTC',13,10,10,0
            lbr     Help
;
GotTime:
            mov     rf,Year
            ldn     rf                  ; convert offset year to absolute
            adi     low 1972            ; binary year
            inc     rf
            str     rf                  ; store low byte of absolute year
            dec     rf
            ldi     0
            adci    high 1972
            str     rf                  ; store high byte of absolute year
            lbr     ShowCal             ; show the current month calendar

GetMonth:
            ldn     rf
            call    f_isnum             ; 1st non blank char: is it 0..9?
            lbnf    MonName             ; nope, try a month name
            call    f_atoi              ; get month #
            ldn     rf
            lbnz    Help
            ghi     rd
            lbnz    Help                ; out of range [1..12]
            glo     rd
            smi     12+1
            lbdf    Help                ; out of range [1..12]
            lbr     DoYear
MonName:
            call    MatchMonthName
            lbz     Help
            plo     rd
DoYear:
            mov     r9,Month
            glo     rd
            str     r9                  ; save month #

            glo     rc
            smi     2
            lbz     Help                ; argc == 2: needed a year

            ; --- argv[2]: should be year ---
            mov     rb, ra
            add16   rb, 4               ; RB = &argv[2]
            lda     rb
            phi     rf
            ldn     rb
            plo     rf                  ; RF = argv[2]

            ldn     rf
            call    f_isnum             ; is it a digit?
            lbnf    Help                ; nope, we're done
            call    f_atoi              ; get year
            ldn     rf                  ; extra characters after year?
            lbnz    Help                ; jump if so
            ghi     rd
            lbnz    FullYear
            glo     rd
            lbz     Help                ; year 0's no good
DoYear1:
            glo     rd
            smi     100
            lbdf    FullYear
            glo     rd
            adi     low 2000            ; 2 digit years assumed 20xx
            plo     rd
            ldi     0
            adci    high 2000
            phi     rd
FullYear:
            mov     rf,Year+1
            glo     rd
            str     rf
            smi     low 1582            ; ZCAL limited the calendar
            dec     rf                  ; to 1766..2499, though I'm
            ghi     rd                  ; not aware of any such
            str     rf                  ; limitation in Zeller's
            smbi    high 1582           ; congruence
            lbnf    Help
;
            glo     rd
            smi     low (9999+1)
            ghi     rd
            smbi    high (9999+1)
            lbdf    Help
;
ShowCal:
            ldi     ' '
            call    K_TYPE
            mov     rf,MonthNames
            mov     rd,DateBlk
            ldn     rd                  ; month #
            sdi     12                  ; D = 12-month #
            call    prtTblStr           ; print month name
;
            mov     rf,Year
            lda     rf                  ; high byte of year
            phi     rd
            ldn     rf                  ; low byte of year
            plo     rd
            mov     rf,buffer
            call    f_uintout
            ldi     0
            str     rf
            mov     rf,buffer
            call    K_MSG               ; print year
;
            call    K_INMSG
            db      13,10
            db      ' Sun Mon Tue Wed Thu Fri Sat'
            db      13,10,0
;
            mov     r7,DateBlk
            call    GetDOW              ; get the DOW of the 1st of the month
            dec     r7                  ; r7 -> DOW1st
            str     r7                  ; store DOW of 1st day of month
            inc     r7                  ; r7 -> Month
            glo     r7
            plo     rf
            ghi     r7
            phi     rf
            mov     rd,Date2Blk
            ldi     4
            plo     rc
            ldi     0
            phi     rc
            call    f_memcpy            ; copy DateBlk to Date2Blk

            dec     rd
            dec     rd
            dec     rd
            dec     rd                  ; rd -> Date2Blk

            ldn     rd
            adi     1
            str     rd                  ; store next month
            smi     13
            lbnz    NextMonth
            ldi     1
            str     rd
            inc     rd
            inc     rd                  ; rd -> high byte of year
            lda     rd                  ; rf.1 = m(rd), rf.0 = m(rd+1)
            phi     rf
            ldn     rd
            plo     rf
            inc     rf                  ; rf = next year
            glo     rf
            str     rd
            dec     rd
            ghi     rf
            str     rd
            dec     rd
            dec     rd                  ; rd -> Date2Blk
NextMonth:
            glo     rd
            plo     r7
            ghi     rd
            phi     r7
            call    GetDOW              ; get the DOW of 1st of the next month
            dec     r7
            dec     r7
            dec     r7
            dec     r7
            dec     r7                  ; r7 -> DOW1st
            adi     7
            sex     r7
            sm
            sex     r2
DaysInMonth:
            adi     7                   ; figure out how many days in the month
            phi     rb                  ; (all months have at least 28 days)
            smi     28
            ghi     rb
            lbnf    DaysInMonth
            plo     rc                  ; rc = # of days in the month
            ldi     1                   ; start with 1st day of month
            plo     r9
            ldi     0
            plo     r8                  ; reset "VT1802 esc seq used space" flag
            ldn     r7                  ; fetch DOW1st
            inc     r7
            inc     r7                  ; r7 -> day of month
            lbz     FullWeek            ; month starts on Sunday, so full week
            plo     ra
            ldi     7
            plo     rb                  ; # days remaining in first week
MoveFirst:
            call    K_INMSG             ; space over to 1st of month
            db      '    ',0
            dec     rb
            dec     ra
            glo     ra
            lbnz    MoveFirst
            lbr     WeekLoop
FullWeek:
            ldi     7
            plo     rb                  ; # of days in this week to print
WeekLoop:
            glo     r8                  ; only print 1 leading space after
            lbnz    LeadingSpace        ; highlighting the current day on the
            ldi     ' '                 ; VT1802 board (reverse/normal video
            call    K_TYPE              ; occupies a character spot afaict)
LeadingSpace:
            ldi     ' '
            call    K_TYPE
            ldi     0                   ; reset VT1802 flag
            plo     r8
;
            glo     r9
            sex     r7
            sm
            sex     r2
            lbnz    NotToday1
            mov     rf,ansi_hilite
            ghi     re                  ; check to see if the VT1802
            ani     0feh                ; video card is active, and if
            xri     0feh                ; so, use a VT52 video hilite
            lbnz    hilite_day
            mov     rf,vt52_hilite
hilite_day:
            call    K_MSG
NotToday1:
            glo     r9                  ; day of month < 10 ?
            smi     10
            lbdf    Gt10
            ldi     ' '
            call    K_TYPE              ; yes, print a leading blank
Gt10:       glo     r9
            plo     rd
            ldi     0
            phi     rd
            mov     rf,buffer
            call    f_uintout
            ldi     0
            str     rf
            mov     rf,buffer
            call    K_MSG               ; print day of month

            glo     r9
            sex     r7
            sm
            sex     r2
            lbnz    NotToday2
            mov     rf,ansi_normal
            ghi     re                  ; check to see if the VT1802
            ani     0feh                ; video card is active, and if
            xri     0feh                ; so, use a VT52 video normal string
            lbnz    normal_day
            ldi     1                   ; set "only one space" flag after VT1802
            plo     r8                  ; escape sequence
            mov     rf,vt52_normal
normal_day:
            call    K_MSG
NotToday2:
            inc     r9                  ; next day of month
            dec     rc
            glo     rc
            lbz     Exit
            dec     rb
            glo     rb
            lbnz    WeekLoop
            call    crlf
            lbr     FullWeek
;
ansi_hilite:    db  27,'[7m',0          ; ANSI hilight today
ansi_normal:    db  27,'[m',0           ; ANSI end hilight of today
vt52_hilite:    db  8,27,'NP',0         ; VT1802 hilight today
vt52_normal:    db  27,'N@',0           ; VT1802 end hilight of today
;------------------------
crlf:       call    K_INMSG
            db      13,10,0
            rtn
;------------------------
;
; Zeller's Congruence algorithm for determining
;  the day of the week of the 1st of a month
;
; IN: r7   = address of date/time block m/d/yy
; OUT D    = day of week (0-6, Sunday-Saturday)
;
; ALTERS r8,r9,ra,rb,rc,rd
;
GetDOW:     ldn     r7                  ; month
            smi     3                   ; march - december?
            inc     r7
            inc     r7                  ; R7 -> high byte of year word
            lda     r7
            phi     rf
            ldn     r7                  ; fetch low byte of year word
            plo     rf
            lbdf    GetDOW1             ; DF=1 if month >= 3
            dec     rf                  ; --year for january & february
GetDOW1:
            mov     rd,100
            call    f_div16             ; RB=year DIV 100 (century), RF=year MOD 100
            glo     rb
            plo     ra                  ; save century
            ldi     low 5
            plo     rd
            ldi     low 0
            phi     rd
            call    f_mul16             ; RB = 5 * (year MOD 100)
            ghi     rb
            shr
            phi     rb
            glo     rb
            shrc
            plo     rb
            ghi     rb
            shr
            phi     rb
            glo     rb
            shrc
            plo     rb                  ; RB = 5 * (year mod 100) DIV 4

            dec     r7                  ; R7 -> high byte of year word
            dec     r7                  ; R7 -> day
            dec     r7                  ; R7 -> month
            ldi     low (valtab-1)
            sex     r7
            add
            sex     r2
            plo     rc
            ldi     high (valtab-1)
            adci    0
            phi     rc                  ; index into valtab
            glo     rb
            sex     rc
            add                         ; result = (13 * month - 1 ) DIV 5 + 5 * year MOD 100) DIV 4
            sex     r2
            str     r2                  ; save result
            glo     ra
            shr
            shr                         ; century DIV 4
            add                         ; result += century DIV 4
            str     r2
            glo     ra
            shl                         ; century * 2
            sd                          ; D = century * 2 - result
            str     r2
            lbdf    GetDOW3             ; branch if result >= 0
GetDOW2:
            adi     7
            lbnf    GetDOW2             ; loop until result >= 0
GetDOW3:
            smi     7                   ; do MOD 7
            lbdf    GetDOW3             ; loop until result < 0
            adi     7                   ; MOD 7 done
            rtn
;
;   Precomputed (13 * month) DIV 5 values
;
valtab:     db      29,32,3,6,8,11,13,16,19,21,24,26
;------------------------
;
;  MatchMonthName: find a unique prefix match for a NUL terminated string
;      in a table of strings
;  IN: rf -> space terminated string to match
;  OUT: D -> 1 based string index (0 if not found)
;
;  ALTERS: r7, r8, r9, ra, rb, rc, rd
;
MatchMonthName:
            push    rc
            push    ra
            mov     rd,MonthNames
            ldi     0
            plo     r7                  ; R7 is longest substring matched so far
            plo     r8                  ; R8 is match # (0 means no match)
            ldi     12                  ; # month names to search
            plo     rb                  ; RB is loop counter
MonthLoop:
            glo     rf
            plo     r9
            ghi     rf
            phi     r9                  ; r9 is working cmd tail ptr
            ldi     0ffh
            plo     rc                  ; rc is working matched substring length
ChkNextChr:
            inc     rd                  ; next byte in table
            inc     rc                  ; # chars matched
            ldn     r9                  ; char from cmd tail
            smi     'a'
            lda     r9
            lbnf    NotLower
            ani     ~20h                ; clear bit to make upper case
NotLower:
            sex     rd
            xor                         ; compare to month char
            ani     ~20h                ; clear bit to make it case insensitive
            sex     r2
            lbz     ChkNextChr
            xri     80h
            lbnz    FindEoS             ; jump if wasn't last char in table entry
            inc     rc                  ; matched a complete table entry
            ldn     r9
            lbnz    FindEoS             ; end of month name?
            glo     rb                  ; complete cmd tail string matched
            plo     r8
            lbr     MonthDone
FindEoS:
            lda     rd
            shl
            lbnf    FindEoS             ; find end of string (hi bit set)
            dec     rd
            dec     r9
            ldn     r9                  ; did we get to the end of the
            lbnz    DoNextMonth 		; cmd tail word?

            glo     rc                  ; substr length
            str     r2                  ; store it for a moment
            glo     r7
            sd
            lbnf    DoNextMonth         ; jump if substring < longest substring
            str     r2
            ldi     0
            plo     r8                  ; no month name matched
            ldn     r2
            lbz     DoNextMonth         ; jump if substring = longest substring
            glo     rb
            plo     r8                  ; save month name index matched
            glo     rc
            plo     r7                  ; save longest length matched
DoNextMonth:
            dec     rb
            glo     rb
            lbnz    MonthLoop
MonthDone:
            pop     ra
            pop     rc
            glo     r8
            rtn
;----Table of Month names with last character high bit set
MonthNames:
            db      12
            db      'Decembe', 'r' | 80h
            db      'Novembe', 'r' | 80h
            db      'Octobe', 'r' | 80h
            db      'Septembe', 'r' | 80h
            db      'Augus', 't' | 80h
            db      'Jul', 'y' | 80h
            db      'Jun', 'e' | 80h
            db      'Ma', 'y' | 80h
            db      'Apri', 'l' | 80h
            db      'Marc', 'h' | 80h
            db      'Februar', 'y' | 80h
            db      'Januar', 'y' | 80h
            db      0ffh
;------------------------
; prtTblStr: print n'th string in a table (end of string marked with hi bit set)
; IN: D = string number (0..N-1)
;    RF = table (N strings with last char MSb set)
;               (table terminated by 0FFH)
;
prtTblStr:
            plo     rd
            sex     rf
            sm                          ; exceeds # of strings in table?
            sex     r2
            lbnf    prtts1
            rtn                      ; yep, we are done
prtts1:
            glo     rd
            lbz     FirstStr
NextStr:
            inc     rf
            ldn     rf
            ani     80h
            lbz     NextStr             ; not end of this string
            dec     rd
            glo     rd
            lbnz    NextStr             ; got to the string we want yet?
FirstStr:
            ldi     23                  ; total spaces
            plo     rd
StrLoop:
            inc     rf
            ldn     rf
            ani     7fh                 ; mask off hi bit
            call    K_TYPE
            dec     rd                  ; decr # spaces required
            ldn     rf
            shl                         ; put msb in DF
            lbnf    StrLoop             ; loop until last char (hi bit set)
StrSpaces:
            ldi     ' '                 ; fill out to 23 chars with spaces
            call    K_TYPE
            dec     rd
            glo     rd
            lbnz    StrSpaces
            rtn
;------------------------
HasRTC:     call    f_getdev            ; check that the BIOS thinks
            glo     rf
            ani     b_devRTC            ; we have an RTC
            bz      NoRTC
            smbi    0                   ; signal RTC present (DF=1)
            rtn                         ; and return
NoRTC:      adi     0                   ; clear DF
            rtn                         ; and return
;------------------------
;
HasClock:   ds      1
;
DOW1st:     ds      1       ;\.
DateBlk:                    ; \.
Month:      ds      1       ;  \.
Day:        ds      1       ; NB: these variables must
Year:       ds      2       ; remain together in this
Date2Blk:                   ; order!
Month2:     ds      1       ;  /.
Day2:       ds      1       ; /.
Year2:      ds      2       ;/.
;
            ds      64
localStack: ds      1
saveStack:  ds      2
;
buffer:     ds      80
;
;endrom equ $
;
;------------------------
;
end         start
