#!/bin/sh

killall jekyll
cd /home/mathias/gh/cron/xray
git pull
nohup /home/mathias/.rbenv/shims/jekyll serve &
