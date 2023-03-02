## Building Docker Image, Putting on ECR, Forcing a Deployment

This verbose and manual document show show exactly how our CI/CD deployment pipeline works. Take note that we 
are using `grep` below to whittle down which project and environment we are targeting from all the potential output

0. Install `jq` because it's awesome: https://formulae.brew.sh/formula/jq

1. Make sure you've built your local docker branch and it's up to date with any branch changes

    ```bash
    $ docker build -t veda-wfs3-api:latest .
    ```

2. List existing ECR repositories using "aws-cli":

    ```bash
    $ AWS_PROFILE=<region> aws ecr describe-repositories 
    {
        "repositories": [
            {
                "repositoryArn": "arn:aws:ecr:us-west-2:359356595137:repository/veda-wfs3-registry-production",
                "registryId": "359356595137",
                "repositoryName": "veda-wfs3-registry-production",
                "repositoryUri": "359356595137.dkr.ecr.us-west-2.amazonaws.com/veda-wfs3-registry-production",
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
   
    $ AWS_PROFILE=<region> aws ecr describe-repositories \
        | jq '.repositories | map(.repositoryUri)' \
        | grep 'veda-wfs3' | grep 'production'
    "359356595137.dkr.ecr.us-west-2.amazonaws.com/veda-wfs3-registry-production"
    ```

3. Login to ECR from awscli:

    ```bash
    AWS_PROFILE=<region> aws ecr describe-repositories \
        | jq '.repositories[0].repositoryUri' \
        | AWS_PROFILE=<region> xargs -I {} bash -c "aws ecr get-login-password | docker login --username AWS --password-stdin {}"
    ```

4. Now re-tag the local image with the remote ECR repository and tag name:
 
    ```bash
    $ aws ecr describe-repositories | jq '.repositories[0].repositoryUri' | xargs -I {} docker images --format "{{json . }}" {} | grep '"Tag":"latest"' | jq '"\(.Repository):\(.Tag)"' | xargs -I{} docker tag veda-wfs3-api:latest {}
   
    # check your work locally
    $ aws ecr describe-repositories | jq '.repositories[0].repositoryUri' | xargs -I {} docker images --format "{{json . }}" {} | grep '"Tag":"latest"' | jq
    {
      "Containers": "N/A",
      "CreatedAt": "2022-12-12 08:16:23 -0800 PST",
      "CreatedSince": "9 minutes ago",
      "Digest": "<none>",
      "ID": "a0a6c57e40e8",
      "Repository": "359356595137.dkr.ecr.us-west-2.amazonaws.com/veda-wfs3-registry-production",
      "SharedSize": "N/A",
      "Size": "887MB",
      "Tag": "latest",
      "UniqueSize": "N/A",
      "VirtualSize": "887.2MB"
    }
    ```

5. Push the image from local to ECR:

    ```bash
    $ aws ecr describe-repositories | jq '.repositories[0].repositoryUri' | xargs -I {} docker images --format "{{json . }}" {} | grep '"Tag":"latest"' | jq '"\(.Repository):\(.Tag)"' | xargs -I{} docker push {} 
   
    # check your remote work
    $ aws ecr describe-repositories | jq '.repositories[0].repositoryName' | xargs -I {} aws ecr describe-images --repository-name={}
    {
        "imageDetails": [
            {
                "registryId": "359356595137",
                "repositoryName": "veda-wfs3-registry-production",
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
   
6. Show your existing clusters:

    ```bash
    $ aws ecs list-clusters                      
    {
        "clusterArns": [
            "arn:aws:ecs:us-west-2:359356595137:cluster/tf-veda-wfs3-service-production"
        ]
    }
   
    $ aws ecs list-clusters | jq '.clusterArns[0]' | xargs -I{} aws ecs describe-clusters --cluster={}
    {
        "clusters": [
            {
                "clusterArn": "arn:aws:ecs:us-west-2:359356595137:cluster/tf-veda-wfs3-service-production",
                "clusterName": "tf-veda-wfs3-service-production",
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
    
7. Once it's there, we can force update the ECS cluster/service/tasks to use it with:

    ```bash
    $ aws ecs list-clusters | jq '.clusterArns[0]' | xargs -I{} aws ecs describe-clusters --cluster={} | jq '.clusters[0].clusterName' | xargs -I{} aws ecs update-service --cluster {} --service {} --task-definition {} --force-new-deployment
    ```

