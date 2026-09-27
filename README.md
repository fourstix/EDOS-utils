# EDOS-utils
A set of simple utility commands and batch files for the Elf-DOS operating system. These commands were assembled into 1802 binary files using the [Asm/02 1802 Assembler](https://github.com/fourstix/Asm-02), the [Link/02 1802 Linker](https://github.com/fourstix/Link-02).

Platform
--------
These commands were written to run on a [1802-Mini](https://github.com/dmadole/1802-Mini) by David Madole and the [AVI Elf-II](https://github.com/awasson/AVI-ELF-II) by Andrew Wasson, Josh Bensadon *et al*.

A lot of information and software for the Pico/Elf and the 1802-Mini can be found on the [Elf-Emulation](http://www.elf-emulation.com/) website and in the [COSMAC ELF Group](https://groups.io/g/cosmacelf) at groups.io.

These commands were written to run under [Elf-DOS](https://github.com/arhefner/ELF-DOS) written by Tony Hefner.

Elf-DOS Utility Commands
--------------------------
## cal
**Usage:** cal [-d|-e]
A Linux-style calendar utility originally written for Elf/OS by [Wayne Hortensius](https://github.com/mecparts/Elf-Elfos-cal) and adapted for Elf-DOS.

If your Elf system includes an RTC, typing `cal` on the command line will show a calendar of the current month, with the current date highlighted. (The highlighting assumes a VT100/ANSI style terminal.)

Even without an RTC, you can use `cal` to display a calendar of any month between the year 1766 and 2499 by typing commands such as:

```
   cal February 2021
   cal feb 2021
   cal 2 21
```

The month name can be abbreviated to any unique month name prefix. `ja` will get you January. `f` will retun February. `ju` won't work, but `jun` will return June and `jul` will return July.

Two digit year numbers between 01 and 99 are interpreted as 2001 to 2099.

## halt
**Usage:** halt
Halt the system by idling the processor.

## input
**Usage:** input
Input and display data read from Port 4

## int
**Usage:** int [-d|-e]
Display the interrupt status and value of the IE flag.  The option -d will disable interrupts by
setting the IE flag false.  The option -e will enable interrupts by setting the IE flag true.

## nop
**Usage:** nop
No Operation, a simple program that does nothing.

## output
**Usage:** output *hh*
Send the hex value *hh* out to Port 4 *(where hh ranges in value from 00 to FF)*

## pause
**Usage:** pause [-0|-1|-2|-3|-4, default = -4]
Display a prompt *Press Input to continue...* and wait for Input to return.  The options -1,-2,-3 or -4 will wait for input on the /EFn line.  The option -0 will wait for serial input. The default is to wait for Input on /EF4.

## req
**Usage:** req
Reset Q.  This command turns the Q bit off. (Q = 0)

## seq
**Usage:** seq
Set Q.  This command turns the Q bit on. (Q = 1)

Elf-DOS Batch Files
--------------------------


Elf-DOS Help Text Files
--------------------------
