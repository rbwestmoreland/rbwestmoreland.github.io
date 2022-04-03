#!/bin/bash

# cd
cd /srv/jekyll

# new
jekyll new src --blank

# bundle
cd src
bundle init
echo 'gem "jekyll"' >> Gemfile