#!/usr/bin/env bash
if [[ -z "$TARGET_ENVIRONMENT" ]]; then
    echo "you must have `TARGET_ENVIRONMENT` set as an os env var" 1>&2
    exit 1
fi
if [[ -z "$TARGET_PROJECT_NAME" ]]; then
    echo "you must have `TARGET_PROJECT_NAME` set as an os env var" 1>&2
    exit 1
fi

# build and tag local image
docker build -t veda-wfs3-api:latest .

# login to ECR through docker
echo "[ LOGIN ]:..."
AWS_PROFILE=uah1 aws ecr describe-repositories \
  | jq '.repositories | map(.repositoryUri)' \
  | grep $TARGET_PROJECT_NAME | grep $TARGET_ENVIRONMENT \
  | xargs -I {} bash -c "AWS_PROFILE=uah1 aws ecr get-login-password | docker login --username AWS --password-stdin {}"

# tag local image with remote ECR repository name:tag
echo "[ TAGGING ]:..."
AWS_PROFILE=uah1 aws ecr describe-repositories \
  | jq '.repositories | map(.repositoryUri)' \
  | grep $TARGET_PROJECT_NAME | grep $TARGET_ENVIRONMENT \
  | xargs -I {} docker images --format "{{json . }}" {} \
  | grep '"Tag":"latest"' \
  | jq '"\(.Repository):\(.Tag)"' \
  | xargs -I{} docker tag veda-wfs3-api:latest {}

# push ECR tagged image to ECR
echo "[ PUSH ]:..."
AWS_PROFILE=uah1 aws ecr describe-repositories \
  | jq '.repositories | map(.repositoryUri)' \
  | grep $TARGET_PROJECT_NAME | grep $TARGET_ENVIRONMENT \
  | xargs -I {} docker images --format "{{json . }}" {} \
  | grep '"Tag":"latest"' \
  | jq '"\(.Repository):\(.Tag)"' \
  | xargs -I{} docker push {}

# tell ECS to use new image (blue-green)
echo "[ RELOAD ]:..."
AWS_PROFILE=uah1 aws ecs list-clusters \
  | jq '.clusterArns[0]' \
  | grep $TARGET_PROJECT_NAME | grep $TARGET_ENVIRONMENT \
  | AWS_PROFILE=uah1 xargs -I{}  aws ecs describe-clusters --cluster={} \
  | jq '.clusters[0].clusterName' \
  | AWS_PROFILE=uah1 xargs -I{}  aws ecs update-service --cluster {} --service {} --task-definition {} --force-new-deployment > /dev/null
echo "[ SUCCESS ]:..."
