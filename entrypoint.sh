#!/bin/sh

cdk bootstrap --qualifier ${QUALIFIER} --toolkit-stack-name ${QUALIFIER}

cdk synth --qualifier ${QUALIFIER} --toolkit-stack-name ${QUALIFIER}

cdk deploy --qualifier ${QUALIFIER} --toolkit-stack-name ${QUALIFIER}
