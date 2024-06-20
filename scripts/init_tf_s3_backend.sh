#!/bin/bash

BUCKET_NAME=$1
REGION=$2

# Check if the bucket exists
if !aws s3 ls "s3://$BUCKET_NAME" 2>&1 | grep -q 'NoSuchBucket'; then
  echo "Bucket exists, proceeding..."
else
  echo "Bucket does not exist, creating now..."
  aws s3api create-bucket --bucket $BUCKET_NAME --region $REGION --create-bucket-configuration LocationConstraint=$REGION
fi