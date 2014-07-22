#!/bin/sh

killall jekyll
cd /home/mathias/gh/xray
git pull
nohup /home/mathias/.rbenv/shims/jekyll serve &
