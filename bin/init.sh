#!/usr/bin/env bash

UPSTREAM=https://github.com/opentutor/aws-beanstalk-app.git

git remote remove upstream 2> /dev/null
git remote add upstream $UPSTREAM
git lfs install
git fetch upstream
git reset --hard upstream/main
