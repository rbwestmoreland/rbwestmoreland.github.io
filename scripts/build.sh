#!/bin/bash

# init
. /srv/scripts/_init.sh

# env
JEKYLL_ENV=production
NODE_ENV=production bundle

# build
jekyll build