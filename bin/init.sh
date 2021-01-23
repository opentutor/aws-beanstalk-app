#!/usr/bin/env bash

UPSTREAM=https://github.com/opentutor/beanstalk-deployment.git

git remote add upstream $UPSTREAM
git lfs install
git fetch upstream
git reset --hard upstream/main
