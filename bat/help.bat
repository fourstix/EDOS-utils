@echo OFF
IF NOT EXIST C:/hlp/%1.txt GOTO missing
less C:/hlp/%1.txt
GOTO exit
:missing
echo Help for {%1} is not available.
less C:/hlp/help.txt
:exit
