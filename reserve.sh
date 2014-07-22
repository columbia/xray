#!/bin/sh

killall jekyll
cd /home/mathias/cron/gh/xray
git pull
nohup /home/mathias/.rbenv/shims/jekyll serve &
