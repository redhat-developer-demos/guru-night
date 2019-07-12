#!/bin/bash 

[[ -d gh-pages ]] && rm -rf gh-pages

[[ -d .cache ]] && rm -rf .cache

docker run -it --rm -v `pwd`:/antora  antora/antora site.yml --stacktrace
