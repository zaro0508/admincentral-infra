#!/usr/bin/env bash

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --output text --query 'Account')
CF_BUCKET_URL="https://s3.amazonaws.com/bootstrap-awss3cloudformationbucket-19qromfd235z9"

STACK_NAME="bootstrap"
CF_TEMPLATE="$STACK_NAME.yml"
echo -e "\nDeploying CF template $CF_BUCKET_URL/$CF_TEMPLATE"
UPDATE_CMD="aws cloudformation update-stack \
--stack-name $STACK_NAME \
--capabilities CAPABILITY_NAMED_IAM \
--notification-arns $CloudformationNotifyLambdaTopicArn \
--template-url $CF_BUCKET_URL/aws-infra/master/$CF_TEMPLATE"
# Handle message that shouldn't be an error, https://github.com/hashicorp/terraform/issues/5653
message=$($UPDATE_CMD 2>&1 1>/dev/null)
error_code=$(echo $?)
if [[ $error_code -ne 0 && $message =~ .*"No updates are to be performed".* ]]; then
  echo -e "\nNo stack changes detected. An update is not required."
  error_code=0
elif [[ $error_code -ne 0 ]]; then
  echo $message
  exit $error_code
else
  echo $message
fi

STACK_NAME="essentials"
CF_TEMPLATE="$STACK_NAME.yml"
echo -e "\nDeploying CF template $CF_BUCKET_URL/$CF_TEMPLATE"
UPDATE_CMD="aws cloudformation update-stack \
--stack-name $STACK_NAME \
--capabilities CAPABILITY_NAMED_IAM \
--notification-arns $CloudformationNotifyLambdaTopicArn \
--template-url $CF_BUCKET_URL/aws-infra/master/$CF_TEMPLATE \
--parameters \
ParameterKey=FhcrcVpnCidrip,ParameterValue=\"$FhcrcVpnCidrip\" \
ParameterKey=OperatorEmail,ParameterValue=\"$OperatorEmail\" \
ParameterKey=VpcPeeringRequesterAwsAccountId,ParameterValue=\"$AWS_ACCOUNT_ID\""
message=$($UPDATE_CMD 2>&1 1>/dev/null)
error_code=$(echo $?)
if [[ $error_code -ne 0 && $message =~ .*"No updates are to be performed".* ]]; then
  echo -e "\nNo stack changes detected. An update is not required."
  error_code=0
elif [[ $error_code -ne 0 ]]; then
  echo $message
  exit $error_code
else
  echo $message
fi

STACK_NAME="accounts"
CF_TEMPLATE="$STACK_NAME.yml"
echo -e "\nDeploying CF template cf_templates/$CF_TEMPLATE"
UPDATE_CMD="aws cloudformation update-stack \
--stack-name $STACK_NAME \
--capabilities CAPABILITY_NAMED_IAM \
--notification-arns $CloudformationNotifyLambdaTopicArn \
--template-body file://cf_templates/$CF_TEMPLATE \
--parameters \
ParameterKey=InitNewUserPassword,ParameterValue=\"$InitNewUserPassword\""
message=$($UPDATE_CMD 2>&1 1>/dev/null)
error_code=$(echo $?)
if [[ $error_code -ne 0 && $message =~ .*"No updates are to be performed".* ]]; then
  echo -e "\nNo stack changes detected. An update is not required."
  error_code=0
elif [[ $error_code -ne 0 ]]; then
  echo $message
  exit $error_code
else
  echo $message
fi

STACK_NAME="it-services"
CF_TEMPLATE="vpc.yml"
echo -e "\nDeploying CF template $CF_BUCKET_URL/$CF_TEMPLATE"
UPDATE_CMD="aws cloudformation update-stack \
--stack-name $STACK_NAME \
--capabilities CAPABILITY_NAMED_IAM \
--notification-arns $CloudformationNotifyLambdaTopicArn \
--template-url $CF_BUCKET_URL/aws-infra/master/$CF_TEMPLATE \
--parameters \
ParameterKey=VpcName,ParameterValue=\"$STACK_NAME\" \
ParameterKey=VpcSubnetPrefix,ParameterValue="10.4""
message=$($UPDATE_CMD 2>&1 1>/dev/null)
error_code=$(echo $?)
if [[ $error_code -ne 0 && $message =~ .*"No updates are to be performed".* ]]; then
  echo -e "\nNo stack changes detected. An update is not required."
  error_code=0
elif [[ $error_code -ne 0 ]]; then
  echo $message
  exit $error_code
else
  echo $message
fi

STACK_NAME="peering-it-services"
CF_TEMPLATE="VPCPeer.yml"
echo -e "\nDeploying CF template cf_templates/$CF_TEMPLATE"
UPDATE_CMD="aws cloudformation update-stack \
--stack-name $STACK_NAME \
--capabilities CAPABILITY_NAMED_IAM \
--notification-arns $CloudformationNotifyLambdaTopicArn \
--template-body file://cf_templates/$CF_TEMPLATE \
--parameters \
ParameterKey=PeerVPC,ParameterValue="vpc-5326f028" \
ParameterKey=PeerVPCOwner,ParameterValue=\"$AWS_ACCOUNT_ID\" \
ParameterKey=PeerVPCCIDR,ParameterValue="10.4.0.0/16" \
ParameterKey=PeerRoleName,ParameterValue="essentials-VPCPeeringAuthorizerRole-UYRMWCKIO3GS""
message=$($UPDATE_CMD 2>&1 1>/dev/null)
error_code=$(echo $?)
if [[ $error_code -ne 0 && $message =~ .*"No updates are to be performed".* ]]; then
  echo -e "\nNo stack changes detected. An update is not required."
  error_code=0
elif [[ $error_code -ne 0 ]]; then
  echo $message
  exit $error_code
else
  echo $message
fi

STACK_NAME="peer-vpn-it-services"
CF_TEMPLATE="peer-route-config.yml"
echo -e "\nDeploying CF template cf_templates/$CF_TEMPLATE"
UPDATE_CMD="aws cloudformation update-stack \
--stack-name $STACK_NAME \
--capabilities CAPABILITY_NAMED_IAM \
--notification-arns $CloudformationNotifyLambdaTopicArn \
--template-url $CF_BUCKET_URL/aws-infra/master/$CF_TEMPLATE \
--parameters \
ParameterKey=PeeringConnectionId,ParameterValue="pcx-3727c65f" \
ParameterKey=VpcPrivateRouteTable,ParameterValue="rtb-49b14935" \
ParameterKey=VpcPublicRouteTable,ParameterValue="rtb-d3b64eaf" \
ParameterKey=VpnCidr,ParameterValue="10.1.0.0/16""
message=$($UPDATE_CMD 2>&1 1>/dev/null)
error_code=$(echo $?)
if [[ $error_code -ne 0 && $message =~ .*"No updates are to be performed".* ]]; then
  echo -e "\nNo stack changes detected. An update is not required."
  error_code=0
elif [[ $error_code -ne 0 ]]; then
  echo $message
  exit $error_code
else
  echo $message
fi

STACK_NAME="peering-bridge-develop"
CF_TEMPLATE="VPCPeer.yml"
echo -e "\nDeploying CF template cf_templates/$CF_TEMPLATE"
UPDATE_CMD="aws cloudformation update-stack \
--stack-name $STACK_NAME \
--capabilities CAPABILITY_NAMED_IAM \
--notification-arns $CloudformationNotifyLambdaTopicArn \
--template-body file://cf_templates/$CF_TEMPLATE \
--parameters \
ParameterKey=PeerVPC,ParameterValue="vpc-513ee12a" \
ParameterKey=PeerVPCOwner,ParameterValue=\"$BridgeDevAwsAccountId\" \
ParameterKey=PeerVPCCIDR,ParameterValue="172.15.0.0/16" \
ParameterKey=PeerRoleName,ParameterValue="bridge-VPCPeeringAuthorizerRole-13KSQX7XGYVAJ""
message=$($UPDATE_CMD 2>&1 1>/dev/null)
error_code=$(echo $?)
if [[ $error_code -ne 0 && $message =~ .*"No updates are to be performed".* ]]; then
  echo -e "\nNo stack changes detected. An update is not required."
  error_code=0
elif [[ $error_code -ne 0 ]]; then
  echo $message
  exit $error_code
else
  echo $message
fi

STACK_NAME="peering-bridge-prod"
CF_TEMPLATE="VPCPeer.yml"
echo -e "\nDeploying CF template cf_templates/$CF_TEMPLATE"
UPDATE_CMD="aws cloudformation update-stack \
--stack-name $STACK_NAME \
--capabilities CAPABILITY_NAMED_IAM \
--notification-arns $CloudformationNotifyLambdaTopicArn \
--template-body file://cf_templates/$CF_TEMPLATE \
--parameters \
ParameterKey=PeerVPC,ParameterValue="vpc-9c70bbf9" \
ParameterKey=PeerVPCOwner,ParameterValue=\"$BridgeProdAwsAccountId\" \
ParameterKey=PeerVPCCIDR,ParameterValue="172.31.0.0/16" \
ParameterKey=PeerRoleName,ParameterValue="bridge-VPCPeeringAuthorizerRole-1XKEYVXHDOYI5""
message=$($UPDATE_CMD 2>&1 1>/dev/null)
error_code=$(echo $?)
if [[ $error_code -ne 0 && $message =~ .*"No updates are to be performed".* ]]; then
  echo -e "\nNo stack changes detected. An update is not required."
  error_code=0
elif [[ $error_code -ne 0 ]]; then
  echo $message
  exit $error_code
else
  echo $message
fi

STACK_NAME="peering-scicomp"
CF_TEMPLATE="VPCPeer.yml"
echo -e "\nDeploying CF template cf_templates/$CF_TEMPLATE"
UPDATE_CMD="aws cloudformation update-stack \
--stack-name $STACK_NAME \
--capabilities CAPABILITY_NAMED_IAM \
--notification-arns $CloudformationNotifyLambdaTopicArn \
--template-body file://cf_templates/$CF_TEMPLATE \
--parameters \
ParameterKey=PeerVPC,ParameterValue="vpc-f8913983" \
ParameterKey=PeerVPCOwner,ParameterValue=\"$SciCompAwsAccountId\" \
ParameterKey=PeerVPCCIDR,ParameterValue="10.5.0.0/16" \
ParameterKey=PeerRoleName,ParameterValue="essentials-VPCPeeringAuthorizerRole-19X5D81TAK34F""
message=$($UPDATE_CMD 2>&1 1>/dev/null)
error_code=$(echo $?)
if [[ $error_code -ne 0 && $message =~ .*"No updates are to be performed".* ]]; then
  echo -e "\nNo stack changes detected. An update is not required."
  error_code=0
elif [[ $error_code -ne 0 ]]; then
  echo $message
  exit $error_code
else
  echo $message
fi
