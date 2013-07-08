@echo off

REM find current directory
cd /d %~dp0
cd..

REM serve jekyll site and watch for changes
jekyll serve --watch