FROM node:18-bullseye AS root
ENV AWS_ACCESS_KEY_ID=""
ENV AWS_SECRET_ACCESS_KEY=""
ENV AWS_DEFAULT_REGION="us-west-2"

# Setup APT
RUN apt-get update -y

# Core dependencies
RUN apt-get install -y gettext
RUN apt-get install -y python3 python3-pip

# CDK stuff
RUN npm install --location=global aws-cdk

# AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip -qq awscliv2.zip
RUN ./aws/install

WORKDIR /opt

COPY requirements-cdk.txt requirements-cdk.txt

RUN python3 -m pip install requirements-cdk.txt

FROM root

COPY . .

CMD '/opt/entrypoint.sh'
