## Building Docker Image, Putting on ECR, Forcing a Deployment

This verbose and manual document shows show exactly how our CD pipeline works but gives more 
context by retrieving the AWS inputs from `aws-cli`. It also can be used to run deployments from local setup. 
Take note that we are using `grep` below to whittle down which project and environment 
we are targeting from all the potential output:

0. Install `jq` because it's awesome: https://formulae.brew.sh/formula/jq

1. Make sure you've built your local docker branch and it's up to date with any branch changes

    ```bash
    $ docker build -t veda-wfs3-api:latest .
    ```

2. Export some os env vars so we can use them filter. Make sure they match the environment you want to work against

   ```bash
    $ export TARGET_PROJECT_NAME=veda-wfs3
    $ export TARGET_ENVIRONMENT=dev
   ```
   
3. Make sure you have an `AWS_PROFILE` setup that matches the AWS `region` you want to work with. In the examples below `uah2` referes to the UAH account in `us-west-2`

4. List existing ECR repositories using "aws-cli" and whittle down which one we want to talk to with os env vars:

    ```bash
    $ AWS_PROFILE=uah2 aws ecr describe-repositories 
    {
        "repositories": [
            {
                "repositoryArn": "arn:aws:ecr:us-west-2:359356595137:repository/veda-wfs3-registry-dev",
                "registryId": "359356595137",
                "repositoryName": "veda-wfs3-registry-dev",
                "repositoryUri": "359356595137.dkr.ecr.us-west-2.amazonaws.com/veda-wfs3-registry-dev",
                "createdAt": "2022-12-10T13:46:05-08:00",
                "imageTagMutability": "MUTABLE",
                "imageScanningConfiguration": {
                    "scanOnPush": false
                },
                "encryptionConfiguration": {
                    "encryptionType": "AES256"
                }
            }
        ]
    }
   
    $ AWS_PROFILE=uah2 aws ecr describe-repositories \
        | jq '.repositories | map(.repositoryUri)' \
        | grep $TARGET_PROJECT_NAME | grep $TARGET_ENVIRONMENT
    "359356595137.dkr.ecr.us-west-2.amazonaws.com/veda-wfs3-registry-dev"
    ```

5. Login to ECR from awscli:

    ```bash
    $ AWS_PROFILE=uah2 aws ecr describe-repositories \
       | jq '.repositories | map(.repositoryUri)' \
       | grep $TARGET_PROJECT_NAME | grep $TARGET_ENVIRONMENT \
       | xargs -I {} bash -c "AWS_PROFILE=uah2 aws ecr get-login-password | docker login --username AWS --password-stdin {}"
    ```

6. Now re-tag the local image we built with the remote ECR repository and tag name:
 
    ```bash
     $ AWS_PROFILE=uah2 aws ecr describe-repositories \
        | jq '.repositories | map(.repositoryUri)' \
        | grep $TARGET_PROJECT_NAME | grep $TARGET_ENVIRONMENT \
        | xargs -I {} docker images --format "{{json . }}" {} \
        | grep '"Tag":"latest"' \
        | jq '"\(.Repository):\(.Tag)"' \
        | xargs -I{} docker tag veda-wfs3-api:latest {}
   
    # check your work locally
     $ AWS_PROFILE=uah2 aws ecr describe-repositories \
        | jq '.repositories | map(.repositoryUri)' \
        | grep $TARGET_PROJECT_NAME | grep $TARGET_ENVIRONMENT \
        | xargs -I {} docker images --format "{{json . }}" {} \
        | grep '"Tag":"latest"' \
        | jq '"\(.Repository):\(.Tag)"' \
        | jq
    {
      "Containers": "N/A",
      "CreatedAt": "2022-12-12 08:16:23 -0800 PST",
      "CreatedSince": "9 minutes ago",
      "Digest": "<none>",
      "ID": "a0a6c57e40e8",
      "Repository": "359356595137.dkr.ecr.us-west-2.amazonaws.com/veda-wfs3-registry-dev",
      "SharedSize": "N/A",
      "Size": "887MB",
      "Tag": "latest",
      "UniqueSize": "N/A",
      "VirtualSize": "887.2MB"
    }
    ```

7. Push the image from local to ECR:

    ```bash
      $ AWS_PROFILE=uah2 aws ecr describe-repositories \
        | jq '.repositories | map(.repositoryUri)' \
        | grep $TARGET_PROJECT_NAME | grep $TARGET_ENVIRONMENT \
        | xargs -I {} docker images --format "{{json . }}" {} \
        | grep '"Tag":"latest"' \
        | jq '"\(.Repository):\(.Tag)"' \
        | xargs -I{} docker push {}
   
    # check your remote work
      $ AWS_PROFILE=uah2 aws ecr describe-repositories \
        | jq '.repositories | map(.repositoryUri)' \
        | grep $TARGET_PROJECT_NAME | grep $TARGET_ENVIRONMENT \
        | AWS_PROFILE=uah2 xargs -I {} aws ecr describe-images --repository-name={}
    {
        "imageDetails": [
            {
                "registryId": "359356595137",
                "repositoryName": "veda-wfs3-registry-dev",
                "imageDigest": "sha256:bf83dd6027aadbf190347529a317966656d875a2aa8b64bbd2cc2589466b68e7",
                "imageTags": [
                    "latest"
                ],
                "imageSizeInBytes": 325163652,
                "imagePushedAt": "2022-12-12T08:35:14-08:00",
                "imageManifestMediaType": "application/vnd.docker.distribution.manifest.v2+json",
                "artifactMediaType": "application/vnd.docker.container.image.v1+json"
            }
        ]
    }
    ```
   
8. Show your existing clusters:

    ```bash
    $ AWS_PROFILE=uah2 aws ecs list-clusters                      
    {
        "clusterArns": [
            "arn:aws:ecs:us-west-2:359356595137:cluster/tf-veda-wfs3-service-dev"
        ]
    }
   
    $ AWS_PROFILE=uah2 aws ecs list-clusters \
      | jq '.clusterArns[0]' \
      | xargs -I{} aws ecs describe-clusters --cluster={}
    {
        "clusters": [
            {
                "clusterArn": "arn:aws:ecs:us-west-2:359356595137:cluster/tf-veda-wfs3-service-dev",
                "clusterName": "tf-veda-wfs3-service-dev",
                "status": "ACTIVE",
                "registeredContainerInstancesCount": 0,
                "runningTasksCount": 0,
                "pendingTasksCount": 0,
                "activeServicesCount": 1,
                "statistics": [],
                "tags": [],
                "settings": [],
                "capacityProviders": [],
                "defaultCapacityProviderStrategy": []
            }
        ],
        "failures": []
    }
    ```
    
9. Once it's there, we can force update the ECS cluster/service/tasks to use it with:

    ```bash
   $ AWS_PROFILE=uah2 aws ecs list-clusters \
     | jq '.clusterArns[0]' \
     | grep $TARGET_PROJECT_NAME | grep $TARGET_ENVIRONMENT \
     | AWS_PROFILE=uah2 xargs -I{}  aws ecs describe-clusters --cluster={} \
     | jq '.clusters[0].clusterName' \
     | AWS_PROFILE=uah2 xargs -I{}  aws ecs update-service --cluster {} --service {} --task-definition {} --force-new-deployment > /dev/null
    ```

