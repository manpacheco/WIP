@echo off
del wip.tap
cd src
pasmo --name wip --tapbas Main.asm ..\wip.tap --public
cd ..
"C:\Mis programas\Spectaculator\Spectaculator.exe" wip.tap
