# Observability and Monitorinq for VEDA WFS3

---

## Dashboard

https://us-west-2.console.aws.amazon.com/cloudwatch/home?region=us-west-2#dashboards:name=veda-wfs3-west2-staging

## Tracing

https://us-west-2.console.aws.amazon.com/cloudwatch/home?region=us-west-2#xray:traces/query?~(query~(expression~'service*28id*28name*3a*20*22veda-wfs3-west2-staging*22*20*20*29*29)~context~())

## Alarms

https://us-west-2.console.aws.amazon.com/cloudwatch/home?region=us-west-2#alarmsV2:alarm/FireAtlas_MWAA_VectorTaskFailed?
https://us-west-2.console.aws.amazon.com/cloudwatch/home?region=us-west-2#alarmsV2:alarm/FireAtlas_ALB_5xx?

---

## How to Setup AWS Distro for OpenTelemetry (ADOT) on ECS Fargate

### Prior Art

https://aws-otel.github.io/docs/setup/ecs

https://opentelemetry-python-contrib.readthedocs.io/en/latest/

https://opentelemetry.io/docs/instrumentation/python/manual/

### Installing the ADOT Collector/Emitter

The [default set up instructions over here](https://aws-otel.github.io/docs/setup/ecs) are not very clear. The verbosity below should add
some clarity to the decision-making process

###  ECS Networking

Setting up ADOT in ECS means that we have to choose a pattern for how the application we want to monitor should communicate with ADOT containers that host all the magic:

* ADOT containers can run as their own ECS service and can be reached: 
  * through private IPs (via network mode ["awsvpc"](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-networking-awsvpc.html))
  * through ALB domains (more $$$)
* ADOT containers run "sidecar" to the monitored application in the same ECS service and can be reached:
  * through localhost:<port> communication 

Some things to consider:

* In situations where the application you want to monitor is a single ECS service that might not need to scale (such as this project), the "sidecar" option
present a decent workaround. 

* However, if your monitored ECS service plans to autoscale then you might want to consider hosting your own ADOT ECS service. In "sidecar",
the ADOT containers are one-to-one with the monitored ECS task definition and that means we'd be autoscaling 
all the ADOT containers if we are autoscaling our application. It's not that using the "sidecar" setup wouldn't work with autoscaling, but that
it's slightly wasteful.

* Also note that it's unclear which ADOT emitters speak TCP (seems ike `etol`) and UDP (seems like `statsd`). So setting up an ADOT service in ECS 
could get tricky with which service ports need to be open for your monitored application to speak to.

* Therefore, setting up ADOT containers as an ECS service
is an exercise left to the reader. Below we show how to set up the "sidecar" situation

---

**1)** This document assumes you already have an ECS cluster provisioned with an ECS service 
and task definition. 

Task definitions point to an [execution_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition#execution_role_arn)
that can talk to AWS on behalf of the ECS container agent and docker daemon. This same execution role can be
used to publish container ADOT metrics to CloudWatch with the following additional IAM permissions:

```json
{
  "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:PutLogEvents",
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:DescribeLogStreams",
                "logs:DescribeLogGroups",
                "logs:PutRetentionPolicy",
                "xray:PutTraceSegments",
                "xray:PutTelemetryRecords",
                "xray:GetSamplingRules",
                "xray:GetSamplingTargets",
                "xray:GetSamplingStatisticSummaries",
                "cloudwatch:PutMetricData",
                "ec2:DescribeVolumes",
                "ec2:DescribeTags",
                "ssm:GetParameters"
            ],
            "Resource": "*"
        }
    ]
}
```

Examples of how this is set up in TF can be found in this repository. 

First, take note of the entrypoint `module "ecs_cluster"` declaration in the following TF file: `../terraform/veda-wfs3/ecs_api.tf`

This entrypoint talks to the `../terraform/modules/aws_ecs_service` module. Inside `../terraform/modules/aws_ecs_service/main.tf`
we see that the ECS task execution role for the application we want to monitor also includes the extra policies we need for it to run the ADOT containers:

```hcl
resource "aws_iam_role" "ecs_execution_role" {
  name               = "${var.service_name}-${var.environment}_ecs_task_execution_role"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role_policy.json
  tags               = var.tags
}

#######################################################################
# AWS Distro Open Telemetry (ADOT) Permissions
#######################################################################
# give access for AWS OTEL for observability
# https:aws-otel.github.io/docs/setup/ecs
# note that all the logging policies were already attached above
data "aws_iam_policy_document" "api_ecs_to_otel_access" {
  statement {
    actions = [
        "xray:PutTraceSegments",
        "xray:PutTelemetryRecords",
        "xray:GetSamplingRules",
        "xray:GetSamplingTargets",
        "xray:GetSamplingStatisticSummaries",
        "cloudwatch:PutMetricData",
        "ec2:DescribeVolumes",
        "ec2:DescribeTags",
        "ssm:GetParameters"
    ]

    resources = [
       "*",
    ]
  }
}
#######################################################################
# LOGGING
#######################################################################
resource "aws_iam_role_policy" "api_ecs_execution_role_policy_attach_otel" {
  name   = "${var.service_name}-${var.environment}-api-access-otel"
  role   = aws_iam_role.ecs_execution_role.id
  policy = data.aws_iam_policy_document.api_ecs_to_otel_access.json
}


data "aws_iam_policy_document" "ecs_execution_attachment" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams",
      "logs:DescribeLogGroups",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_role_policy" "ecs_execution_role_policy" {
  name   = "${var.service_name}-${var.environment}_ecs_execution_role_policy"
  role   = aws_iam_role.ecs_execution_role.id
  policy = data.aws_iam_policy_document.ecs_execution_attachment.json
}
```

---

**2)** Next you'll want to install the ADOT Collector containers as "sidecars" to the application you are trying to monitor. These all live in the same task definition.

This JSON snippet provides an example of the [ADOT ECS task definition JSON in entirety](https://github.com/aws-observability/aws-otel-collector/blob/main/examples/ecs/aws-cloudwatch/ecs-fargate-sidecar.json)

The TF in this repoistory at `../terraform/modules/aws_ecs_service/main.tf` renders out a JSON template from `../terraform/modules/aws_ecs_service/container_definition.json` that also
includes the containers for the application we want to monitor.

Here is that template:

```hcl
[
  {
    "name": "tf-${service_name}-${environment}",
    "cpu": 512,
    "memory": 2048,
    "image": "${image}",
%{ if container_command != "" }
    "command": ${container_command},
%{ endif }
%{ if working_directory != "" }
    "workingDirectory": "${working_directory}",
%{ endif }
    "secrets": ${container_secrets},
    "environment": ${container_environment},
    "entryPoint": null,
    "essential": true,
    "portMappings": [
       {
         "protocol": "${service_protocol}",
         "containerPort": ${service_port},
         "hostPort": ${service_port}
       }
    ],
    "volumesFrom": [],
    "mountPoints": [],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${log_group}",
        "awslogs-region": "${region}",
        "awslogs-stream-prefix": "ecs"
      }
    }
%{ if use_adot_as_sidecar != "" }
  },
%{ else }
  }
%{ endif }
%{ if use_adot_as_sidecar != "" }
  {
      "name": "aws-otel-collector-${environment}",
      "cpu": 256,
      "memory": 512,
      "image": "amazon/aws-otel-collector",
      "command":["--config=/etc/ecs/container-insights/otel-task-metrics-config.yaml"],
      "essential": true,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${log_group}",
          "awslogs-region": "${region}",
          "awslogs-stream-prefix": "ecs",
          "awslogs-create-group": "True"
        }
      },
      "healthCheck": {
        "command": [ "/healthcheck" ],
        "interval": 5,
        "timeout": 6,
        "retries": 5,
        "startPeriod": 1
      },
      "environment": [],
      "portMappings": [],
      "volumesFrom": [],
      "mountPoints": []
    },
    {
      "name": "aws-otel-emitter-${environment}",
      "cpu": 256,
      "memory": 512,
      "image": "public.ecr.aws/aws-otel-test/aws-otel-goxray-sample-app:latest",
      "essential": false,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/ecs-aws-otel-sidecar-app-${environment}",
          "awslogs-region": "${region}",
          "awslogs-stream-prefix": "ecs",
          "awslogs-create-group": "True"
        }
      },
      "dependsOn": [
        {
          "containerName": "aws-otel-collector-${environment}",
          "condition": "START"
        }
      ],
      "environment": [],
      "portMappings": [],
      "volumesFrom": [],
      "mountPoints": []
    },
    {
      "name": "nginx-${environment}",
      "cpu": 256,
      "memory": 256,
      "image": "nginx:latest",
      "essential": false,
      "dependsOn": [
        {
          "containerName": "aws-otel-collector-${environment}",
          "condition": "START"
        }
      ],
      "environment": [],
      "portMappings": [],
      "volumesFrom": [],
      "mountPoints": []
    },
    {
      "name": "aoc-statsd-emitter-${environment}",
      "cpu": 256,
      "memory": 512,
      "image": "alpine/socat:latest",
      "dependsOn": [
        {
          "containerName": "aws-otel-collector-${environment}",
          "condition": "START"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-create-group": "True",
          "awslogs-region": "${region}",
          "awslogs-stream-prefix": "ecs",
          "awslogs-group": "/ecs/statsd-emitter-${environment}"
        }
      },
      "entryPoint": [
        "/bin/sh",
        "-c",
        "while true; do echo 'statsdTestMetric:1|c' | socat -v -t 0 - UDP:127.0.0.1:8125; sleep 1; done"
      ],
      "environment": [],
      "portMappings": [],
      "volumesFrom": [],
      "mountPoints": [],
      "essential": false
    }
%{ endif }
]

```

---

**3)** Next [read about which OpenTelemetry (OTEL) instrumentation packages](https://opentelemetry-python-contrib.readthedocs.io/en/latest/) you might need to install for the python packages in your project.

This project uses `fastapi` and `postgres` so you can grok what we've installed for this project here at `../veda-wfs3-app/requirements.txt` 

It helps to read about what hooks and middlewares each instrumentation package has available for setup. The [fastapi](https://github.com/open-telemetry/opentelemetry-python-contrib/tree/main/instrumentation/opentelemetry-instrumentation-fastapi)
docs show some examples that are unfortunately out of date. The source code is pretty clean and easy to read though.

---

**4)** Finally, choose if you want to "auto" instrument or "manually" instrument your application. This project first tried to use "auto" instrumentation but has slowly been manually putting in hooks and OS environment variables over time
to get what it wants.

Configuration can be done through a single file or OS environment variables. Read more about the configuration differences and [which os env vars](https://aws-otel.github.io/docs/getting-started/python-sdk/trace-auto-instr)
you'll want to set up to export your metrics to CloudWatch and traces to AWS xray. The TF in this repo adds these os environment vars to the container in `../terraform/veda-wfs3/ecs_api.tf`. And our fastapi startup
script in `../veda-wfs3-app/startup.sh` bootstraps `uvicorn` with the `opentelemetry` patcher

The TF entrypoint `module "ecs_cluster"` declaration in the following TF file: `../terraform/veda-wfs3/ecs_api.tf` declares the OS environment variables we'll need to set on the container for the application we are going to monitor:

```hcl
  container_environment = [
    {
      name  = "ENVIRONMENT"
      value = var.env
    },
    {
      name  = "IS_ECS"
      value = "True"
    },
    {
      name = "OTEL_PROPAGATORS"
      value = "xray"
    },
    {
      name = "OTEL_PYTHON_ID_GENERATOR"
      value = "xray"
    },
    {
      name = "OTEL_RESOURCE_ATTRIBUTES"
      value = "service.name=veda-wfs3-${var.env}"
    },
    {
      name = "OTEL_RESOURCE_ATTRIBUTES"
      value = "service.name=veda-wfs3-${var.env}"
    },
    {
      name = "FORWARDED_ALLOW_IPS"
      value = "*"
    },
    {
      // stupid hack b/c of FastAPI and Starlette bug
      name = "FAST_API_SCHEME"
      value = var.env == "west2-staging" ? "https" : "http"
    }
  ]
```