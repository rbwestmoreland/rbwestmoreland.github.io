@echo off

REM find current directory
cd /d %~dp0
cd..

REM push to 'master'
echo pushing to 'master'...
cd _site
git init
git add .
git commit -m updating
git remote add origin https://github.com/rbwestmoreland/rbwestmoreland.github.io.git
REM git push origin master --force

REM go back to '_scripts' directory
cd..
cd _scripts

pause