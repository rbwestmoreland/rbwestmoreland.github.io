#!/usr/bin/env pwsh
$ErrorActionPreference = "Stop"
$Image = "jekyll/jekyll:4"

Push-Location $PSScriptRoot/..

docker pull $Image
docker run --rm -it -p 4000:4000 -p 35729:35729 -v ${PWD}/scripts:/srv/scripts -v ${PWD}/src:/srv/jekyll $Image /bin/bash /srv/scripts/serve.sh

Pop-Location
