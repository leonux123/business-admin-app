#!/bin/bash

MESSAGE="0"
VERSION=$(shuf -i 1-250 -n 1)
DRAFT="false"
PRE="false"
BRANCH="master"
GITHUB_ACCESS_TOKEN="XXXX"

# get repo name and owner
REPO_REMOTE=https://github.somecorp.com/username/my_repo.git

if [ -z $REPO_REMOTE ]; then
        echo "Not a git repository"
        exit 1
fi

REPO_NAME=$(basename $REPO_REMOTE .git)
REPO_OWNER=leon-ari-muro

# get args
while getopts v:m:b:draft:pre: option
do
        case "${option}"
                in
                v) VERSION="$OPTARG";;
                m) MESSAGE="$OPTARG";;
                b) BRANCH="$OPTARG";;
                draft) DRAFT="true";;
                pre) PRE="true";;
        esac
done
if [ $VERSION == "0" ]; then
        echo "Usage: git-release -v <version> [-b <branch>] [-m <message>] [-draft] [-pre]"
        exit 1
fi

# set default message
if [ "$MESSAGE" == "0" ]; then
        MESSAGE=$(printf "This is a test release, please ignore %s" $VERSION)
fi


API_JSON=$(printf '{"tag_name": "v%s","target_commitish": "%s","name": "This is a test release, please ignore%s","body": "%s","draft": %s,"prerelease": %s}' "$VERSION" "$BRANCH" "$VERSION" "$MESSAGE" "$DRAFT" "$PRE" )
API_RESPONSE_STATUS=$(curl --data "$API_JSON" -s -i https://github.somecorp.com/api/v3/repos/$REPO_OWNER/$REPO_NAME/releases?access_token=$GITHUB_ACCESS_TOKEN)
echo "$API_RESPONSE_STATUS"
