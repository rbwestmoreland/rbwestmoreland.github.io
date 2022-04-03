#!/usr/bin/env pwsh
$ErrorActionPreference = "Stop"

Push-Location $PSScriptRoot/../src/_site

git init
git add .
git commit -m updating
git remote add origin https://github.com/rbwestmoreland/rbwestmoreland.github.io.git
git push origin master --force

Pop-Location
