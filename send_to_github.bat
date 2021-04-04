@echo off
cd src
git add --all
git commit -am %date%_%random%
git push
cd ..
pause