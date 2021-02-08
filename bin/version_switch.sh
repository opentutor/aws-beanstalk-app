#!/usr/bin/env bash

# Updates the repo to the a tagged/released version 
# from the authoritative upstream repo
# OR to the latest stable release if no version specified

LATEST_RELEASE_URL=https://github.com/opentutor/aws-beanstalk-app/releases/latest

function get_latest_stable_release() {
    URL=$(curl -Ls -o /dev/null -w %{url_effective} $1)
    VERSION=$(basename ${URL})
    if [[ -z $VERSION ]]; then
        exit 1;
    fi
    echo $VERSION
    exit 0;
}

TAG=${1:-$(get_latest_stable_release ${LATEST_RELEASE_URL})}
if [[ -z "$1" ]]; then
    echo "switching to latest stable release version (${TAG})"
fi
git fetch upstream --tags
git lfs fetch upstream --all
git reset --hard ${TAG}