romtext -a38144 help.edos help.hex
rommerge -s32k -o32768 merged.hex boots.hex help.hex kernel-rom.hex xmodem.hex bios.hex
romcksum merged.hex -s32k -o32768 -c32764 StgEDOS.hex
