#!/bin/bash

# init
. /srv/scripts/_init.sh

# build
jekyll serve --watch --incremental --force_polling --livereload