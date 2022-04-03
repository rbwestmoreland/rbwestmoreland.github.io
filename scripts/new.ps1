#!/usr/bin/env pwsh
$ErrorActionPreference = "Stop"
$Image = "jekyll/jekyll:4"

Push-Location $PSScriptRoot/..

docker pull $Image
docker run --rm -it -v ${PWD}/scripts:/srv/scripts -v ${PWD}:/srv/jekyll $Image /bin/bash /srv/scripts/new.sh

Pop-Location
