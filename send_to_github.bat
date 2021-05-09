@echo off
cd src
git add --all
if [%1]==[] goto :blank
git commit -am %date%_%random%_%1%
goto :continuar
:blank
git commit -am %date%_%random%
:continuar
git push
cd ..
pause