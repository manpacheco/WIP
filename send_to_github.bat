@echo off
cd src
git add --all
if [%1]==[] goto :blank
git commit -am %date%_%random%
goto :continuar
:blank
git commit -am %date%_%random%
:continuar
git push
cd ..
pause