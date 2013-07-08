@echo off

REM find current directory
cd /d %~dp0
cd..

REM delete '_site' and build
echo deleting '_site' directory...
rmdir /S /Q _site

REM build jekyll site
call jekyll build

REM go back to '_scripts' directory
cd _scripts

pause