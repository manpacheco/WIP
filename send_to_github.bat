@echo off
git add --all
git commit -am %date%_%random%
git push
cd ..
pause