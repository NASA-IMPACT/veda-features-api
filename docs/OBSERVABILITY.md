# Observability and Monitorinq for VEDA WFS3

---

## Dashboard

to be written

## Tracing

to be written

## Alarms

to be written

---

## How to Setup AWS Distro for OpenTelemetry (ADOT) on ECS Fargate

### Prior Art
https://aws-otel.github.io/docs/setup/ecs

https://opentelemetry-python-contrib.readthedocs.io/en/latest/

https://opentelemetry.io/docs/instrumentation/python/manual/

### Installing the ADOT Collector/Emitter

The [instructions here](https://aws-otel.github.io/docs/setup/ecs) are not very clear. The steps below should add
some clarity.

**1)** We assume you already have an ECS cluster provisioned with an ECS service 
and task definition. Task definitions point to an [execution_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition#execution_role_arn)
that can talk to AWS on behalf of the ECS container agent and docker daemon. This same execution role can be
used to publish container ADOT metrics to CloudWatch with the following additional IAM permissions:

```json
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

Examples of how this is set up in TF can be found in this repository. We have TF at `../terraform/veda-wfs3/ecs_api.tf`
that leverages the [aws_ecs_service module](https://github.com/developmentseed/tf-seed/tree/main/modules/aws_ecs_service). In that
module you can grok the [ADOT policy attachments](https://github.com/developmentseed/tf-seed/blob/main/modules/aws_ecs_service/main.tf#L248-L266)

---

**2)** Next you'll want to install the ADOT Collector containers as "sidecars" to the application you are trying to monitor inside the same task definition.

Here is an example of the [ADOT ECS task definition JSON in entirety](https://github.com/aws-observability/aws-otel-collector/blob/main/examples/ecs/aws-cloudwatch/ecs-fargate-sidecar.json)

The TF in the repoistory at `../terraform/veda-wfs3/ecs_api.tf` passes an `use_adot_as_sidecar` arg 
to the [aws_ecs_service module](https://github.com/developmentseed/tf-seed/tree/main/modules/aws_ecs_service) that adds those [containers conditionally
to the task definition](https://github.com/developmentseed/tf-seed/blob/main/modules/aws_ecs_service/container_definition.json#L34-L142)

NOTE: This "sidecar" pattern doesn't seem like a good setup b/c we tend to auto-scale the ECS service. Since services are one-to-one with the ECS task definition
that means we'd be autoscaling all the ADOT containers if we are gonna scale our application. A better setup would be to have the ADOT containers
live in a separate ECS service. Currently it's unclear which ADOT emitters speak TCP (seems like `etol`) and UDP (seems like `statsd`). So setting up a service in ECS either means
you need to create a separate ALB(s) and point the OTEL traffic there or figure out how containers between ECS services [can discover/talk without the extra DNS hops](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/interconnecting-services.html).
More investigation will be done on this in the future.

---

**3)** Next [read about which OpenTelemetry (OTEL) instrumentation packages](https://opentelemetry-python-contrib.readthedocs.io/en/latest/) you might need to install for the python packages in your project. 

This project uses `fastapi` and `postgres` so you can grok what we've installed for this project here at `../veda-wfs3-app/requirements.txt` 

It helps to read about what hooks and middlewares each instrumentation package has available for setup. The [fastapi](https://github.com/open-telemetry/opentelemetry-python-contrib/tree/main/instrumentation/opentelemetry-instrumentation-fastapi)
docs show some examples that are unfortunately out of date. The source code is pretty clean and easy to read though.

---

**4)** Finally, choose to "auto" instrument or "manually" instrument your application. This project uses "auto" instrumentation. Read more about the configuration differences and [which os env vars](https://aws-otel.github.io/docs/getting-started/python-sdk/trace-auto-instr)
you'll want to set up to export your metrics to CloudWatch and traces to AWS xray. The TF in this repo adds these os environment vars to the container in `../terraform/veda-wfs3/ecs_api.tf`. And our fastapi startup
script in `../veda-wfs3-app/startup.sh` bootstraps `uvicorn` with the `opentelemetry` patcher