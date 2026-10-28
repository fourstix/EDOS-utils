# EDOS-utils
A set of simple utility commands and batch files for the Elf-DOS operating system. These commands were assembled into 1802 binary files using the [Asm/02 1802 Assembler](https://github.com/fourstix/Asm-02), the [Link/02 1802 Linker](https://github.com/fourstix/Link-02).

Platform
--------
These commands were written to run on a [1802-Mini](https://github.com/dmadole/1802-Mini) by David Madole and the [AVI Elf-II](https://github.com/awasson/AVI-ELF-II) by Andrew Wasson, Josh Bensadon *et al*.

A lot of information and software for Elf-DOS and the 1802-Mini can be found in the [COSMAC ELF Group](https://groups.io/g/cosmacelf) at groups.io.

These commands were written to run under [Elf-DOS](https://github.com/arhefner/ELF-DOS) written by Tony Hefner.

Elf-DOS Utility Commands
--------------------------
## cal
**Usage:** cal [month year]<br/>
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
**Usage:** halt<br/>
Halt the system by idling the processor.

## input
**Usage:** input<br/>
Input and display data read from Port 4

## int
**Usage:** int [-d|-e]<br/>
Display the interrupt status and value of the IE flag.  The option -d will disable interrupts by
setting the IE flag false.  The option -e will enable interrupts by setting the IE flag true.

## nop
**Usage:** nop<br/>
No Operation, a simple program that does nothing.

## output
**Usage:** output *hh*<br/>
Send the hex value *hh* out to Port 4 *(where hh ranges in value from 00 to FF)*

## pause
**Usage:** pause [-0|-1|-2|-3|-4, default = -4]<br/>
Display a prompt *Press Input to continue...* and wait for Input to return.  The options -1,-2,-3 or -4 will wait for input on the /EFn line.  The option -0 will wait for serial input. The default is to wait for Input on /EF4.

## req
**Usage:** req<br/>
Reset Q.  This command turns the Q bit off. (Q = 0)

## seq
**Usage:** seq<br/>
Set Q.  This command turns the Q bit on. (Q = 1)

Elf-DOS Batch Files
--------------------------
## about
**Usage:** about<br/>
Show information about the disk contained in the file */cfg/about.nfo*

## help
**Usage:** help *cmd*
Show information about the command *cmd* contained in the file */hlp/cmd.txt*. Type `help` alone for more information.

Elf-DOS Help Text Files
--------------------------

These are text files used by the `help` batch file.  The should all be copied to a directory named `/hlp`. To view a file for a command type  `help` followed by the name of the command, for example `help dir` will show the contents of */hlp/dir.txt* and give infomration about the `dir` command.

Other Elf-DOS Programs
------------------------
## kilo
**Usage:** kilo *filename*

Kilo is a full screen editor for the Elf-DOS written in 1802 Assembly language and based loosely on the Kilo editor by Salvatore Sanfilippo aka antirez and the Elfos-Edit editor by Mike Riley.

The kilo editor was ported to Elf-DOS by Tony Hefner and is available at [EDOS-kilo](https://github.com/arhefner/EDOS-kilo).

## stg_edos.hex

A hex file containing a version of the [STG Elf2K](https://github.com/SpareTimeGizmos/Elf2K) ROM containing the EDOS ROM kernel.  This hex file can be used to burn a EPROM for the Pico/Elf v2 or Elf2K system that enables EDOS to run on a system with only 32k RAM memory.  This hex file was built with the [STG Tools](https://github.com/SpareTimeGizmos/tools) and the [Elf-DOS](https://github.com/arhefner/ELF-DOS) ROM kernel.


Repository Contents
-------------------

* **/src/**  -- Source files for Elf-DOS utilities.
  * build.bat - Windows batch file to assemble source file with Asm/02 to create binary file. Use the command *build xxx* to assemble the xxx.asm file into a binary file.
* **/src/include/**  -- Include files for Elf/OS file utilities.
  * opcodes.def - Opcode definitions for Asm/02.
  * bios.inc - Bios definitions from Elf-DOS.
  * kernel_api.inc - Kernel API definitions from Elf-OS.
* **/bin/**  -- Binary files for Elf-DOS utilities.
* **/bin/other/**  -- Binary files for Other Elf-DOS programs.
  * kilo -- Binary file for kilo text editor
  * stg_edos.hex -- Hex file for STG EDOS ROM.
* **/bat/**  -- Batch utility files for Elf-DOS.
* **/hlp/**  -- Help text files for Elf-DOS help batch utility.

License Information
-------------------

This code is public domain under the MIT License, but please buy me a beverage if you use this and we meet someday (Beerware).

References to any products, programs or services do not imply
that they will be available in all countries in which their respective owner operates.

Any company, product, or services names may be trademarks or services marks of others.

All libraries used in this code are copyright their respective authors.

This code is based on a Elf-DOS code libraries written by Tony Hefner and assembled with the Asm/02 assembler written by Mike Riley.


Elf-DOS
Copyright (c) 2026 by Tony Hefner

Asm/02 1802 Assembler
Copyright (c) 2004-2026 by Mike Riley

The Pico/Elf Microcomputer Hardware
Copyright (c) 2020-2026 by Mike Riley

The STG Pico/Elf EPROM
Copyright (c) 2004-2026 by Spare Time Gizmos.

STG NVR/RTC/UART Pico/Elf Expansion Card hardware
Copyright (c) 2020-2026 by Spare Time Gizmos.

The 1802-Mini Microcomputer Hardware
Copyright (c) 2020-2026 by David Madole

Many thanks to the original authors for making their designs and code available as open source.

This code, firmware, and software is released under the [MIT License](http://opensource.org/licenses/MIT).

The MIT License (MIT)

Copyright (c) 2026 by Gaston Williams

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

**THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.**
