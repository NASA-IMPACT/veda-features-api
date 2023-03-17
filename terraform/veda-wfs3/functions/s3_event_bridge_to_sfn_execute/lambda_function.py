import boto3
import os
import json
from botocore.config import Config


def lambda_handler(event, context):
    print(f"[ EVENT ]: {event}")
    west1_config = Config(region_name='us-west-1')
    sfn = boto3.client("stepfunctions", config=west1_config)
    for record in event['Records']:
        print(f"[ RECORD ]: {record}")
        s3_event_key = record['s3']['object']['key']
        print(f"[ S3 EVENT KEY ]: {s3_event_key}")
        s3_filename_target = os.path.split(s3_event_key)[-1]
        print(f"[ S3 FILENAME TARGET ]: {s3_filename_target}")
        s3_filename_no_ext = os.path.splitext(s3_filename_target)[0]
        print(f"[ S3 FILENAME NO EXT ]: {s3_filename_no_ext}")
        response = sfn.start_execution(
            stateMachineArn="arn:aws:states:us-west-1:853558080719:stateMachine:veda-data-pipelines-dev-vector-stepfunction-discover",
            input=json.dumps({
                "discovery": "s3",
                "collection": s3_filename_no_ext,
                "prefix": "EIS/FEDSoutput/Snapshot/",
                "bucket": "veda-data-store-staging",
                "filename_regex": f"^(.*){s3_filename_target}$",
                "vector": True
            }),
        )
        print(f"[ SFN RESPONSE ]: {response}")
    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }