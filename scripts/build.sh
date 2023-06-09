#!/bin/sh
export TARGET_ENVIRONMENT=dev
export TARGET_PROJECT_NAME=ghgc-features-api

cd wfs3-app/

aws ecr describe-repositories \
   | jq '.repositories | map(.repositoryUri)' \
   | grep $TARGET_PROJECT_NAME | grep $TARGET_ENVIRONMENT \
   | xargs -I {} bash -c "aws ecr get-login-password | docker login --username AWS --password-stdin {}"

aws ecr describe-repositories \
    | jq '.repositories | map(.repositoryUri)' \
    | grep $TARGET_PROJECT_NAME | grep $TARGET_ENVIRONMENT \
    | sed -E 's/"|,//g' \
    | xargs -I {} docker build -t {}:latest ../wfs3-app/

aws ecr describe-repositories \
    | jq '.repositories | map(.repositoryUri)' \
    | grep $TARGET_PROJECT_NAME | grep $TARGET_ENVIRONMENT \
    | sed -E 's/"|,//g' \
    | xargs -I {} docker images --format "{{json . }}" {} \
    | grep '"Tag":"latest"' \
    | jq '"\(.Repository):\(.Tag)"' \
    | xargs -I{} docker push {}