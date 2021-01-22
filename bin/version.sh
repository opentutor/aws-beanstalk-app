#!/usr/bin/env bash

VERSION=0.1.0-alpha.10

git fetch upstream --tags
git lfs fetch upstream --all
git reset --hard ${VERSION}