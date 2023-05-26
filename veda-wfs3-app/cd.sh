#!/usr/bin/env bash
# you probably shouldn't be using this script if you don't know what you're doing
# but it's a quicker way to refresh an ECS service from local instead of using CI/CD
if [[ -z "$TARGET_ENVIRONMENT" ]]; then
    echo "you must have `TARGET_ENVIRONMENT` set as an os env var" 1>&2
    exit 1
fi
if [[ -z "$TARGET_PROJECT_NAME" ]]; then
    echo "you must have `TARGET_PROJECT_NAME` set as an os env var" 1>&2
    exit 1
fi

# build and tag local image
docker build -t "$TARGET_PROJECT_NAME-$TARGET_ENVIRONMENT":latest .

# login to ECR through docker
echo "[ LOGIN ]:..."
AWS_PROFILE=$AWS_PROFILE_NAME aws ecr describe-repositories \
  | jq '.repositories | map(.repositoryUri)' \
  | grep $TARGET_PROJECT_NAME | grep $TARGET_ENVIRONMENT \
  | sed -E 's/"|,//g' \
  | xargs -I {} bash -c "AWS_PROFILE=$AWS_PROFILE_NAME aws ecr get-login-password | docker login --username AWS --password-stdin {}"

# tag local image with remote ECR repository name:tag
echo "[ TAGGING ]:..."
AWS_PROFILE=$AWS_PROFILE_NAME aws ecr describe-repositories \
  | jq '.repositories | map(.repositoryUri)' \
  | grep $TARGET_PROJECT_NAME | grep $TARGET_ENVIRONMENT \
  | sed -E 's/"|,//g' \
  | xargs -I {} docker images --format "{{json . }}" {} \
  | grep '"Tag":"latest"' \
  | jq '"\(.Repository):\(.Tag)"' \
  | xargs -I{} docker tag "$TARGET_PROJECT_NAME-$TARGET_ENVIRONMENT":latest {}

# # push ECR tagged image to ECR
echo "[ PUSH ]:..."
AWS_PROFILE=$AWS_PROFILE_NAME aws ecr describe-repositories \
  | jq '.repositories | map(.repositoryUri)' \
  | grep $TARGET_PROJECT_NAME | grep $TARGET_ENVIRONMENT \
  | sed -E 's/"|,//g' \
  | xargs -I {} docker images --format "{{json . }}" {} \
  | grep '"Tag":"latest"' \
  | jq '"\(.Repository):\(.Tag)"' \
  | xargs -I{} docker push {}

# tell ECS to use new image (blue-green)
echo "[ RELOAD ]:..."
AWS_PROFILE=$AWS_PROFILE aws ecs list-clusters \
  | jq '.clusterArns[0]' \
  | grep $TARGET_PROJECT_NAME | grep $TARGET_ENVIRONMENT \
  | sed -E 's/"|,//g' \
  | AWS_PROFILE=$AWS_PROFILE xargs -I{}  aws ecs describe-clusters --cluster={} \
  | jq '.clusters[0].clusterName' \
  | AWS_PROFILE=$AWS_PROFILE xargs -I{}  aws ecs update-service --cluster {} --service {} --task-definition {} --force-new-deployment > /dev/null
echo "[ SUCCESS ]:..."
