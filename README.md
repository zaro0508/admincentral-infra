# Overview
Install, configure and manage the AWS AdminCentral account.


## Instructions to create or update CF stacks

```
# unlock repo
git-crypt unlock
# set env vars
source env_vars && source env_vars.secret
# Update CF stacks with sceptre
```

The above should setup resources for the account.  Once the infrastructure for the account has been setup
you can access and view the account using the [AWS console](https://AWS-account-ID-or-alias.signin.aws.amazon.com/console).

*Note - This project depends on CF templates from other accounts.*

## VPN Gateway
This account is setup to be the VPN Gateway.  A VPC peering connection is required to
allow the VPN access to other VPCs.  To setup VPC peering from the VPN VPC to another
VPC run the following template.

```
aws --profile admincentral.travis --region us-east-1 cloudformation create-stack \
--stack-name peering-$PeerAccountName \
--capabilities CAPABILITY_NAMED_IAM \
--template-body file://cf_templates/VPCPeer.yaml \
--parameters \
ParameterKey=PeerVPC,ParameterValue=$PeerAccountVpcId \
ParameterKey=PeerVPCOwner,ParameterValue=$PeerAccountId \
ParameterKey=PeerRoleName,ParameterValue=$VPCPeeringAuthorizerRole \
ParameterKey=PeerVPCCIDR,ParameterValue=$PeerAccountVpcCidr
```


Example:
```
aws --profile admincentral.travis --region us-east-1 cloudformation create-stack \
--stack-name peering-bridge-develop \
--capabilities CAPABILITY_NAMED_IAM \
--template-body file://cf_templates/VPCPeer.yaml \
--parameters \
ParameterKey=PeerVPC,ParameterValue="vpc-5678efghi" \
ParameterKey=PeerVPCOwner,ParameterValue="123456789123" \
ParameterKey=PeerRoleName,ParameterValue="essentials-VPCPeeringAuthorizerRole-UYRMWCKIO3GS" \
ParameterKey=PeerVPCCIDR,ParameterValue="10.4.0.0/16"
```

The [VPCPeer.yaml template](./cf_templates/VPCPeer.yaml) should setup the VPC peering
from the VPN VPC to the *$PeerVPC* in the account identified by *$PeerAccountName*.
This template should be run for each VPC peering connection therefore a
`unique stack-name should be given` for each run of this template.

**Note** - VPCPeer.yaml requires that the *$PeerVPC* be setup with [CrossAccountRoleTemplate.json](https://github.com/awslabs/aws-cloudformation-templates/blob/master/aws/solutions/VPCPeering/CrossAccountRoleTemplate.json)
template which was added to the [essentials.yaml](https://github.com/Sage-Bionetworks/aws-infra/blob/master/cf_templates/essentials.yaml)
template.  An additional configuration step is required on the PeerVPC end to
complete this setup, run the [peer-route-config.yaml](https://github.com/Sage-Bionetworks/aws-infra/blob/master/cf_templates/peer-route-config.yaml)
template to complete the configuration.


## Continuous Integration
We have configured Travis to deploy CF template updates.  Travis deploys using
[sceptre](https://sceptre.cloudreach.com/latest/about.html)


# Contributions

## Issues
* https://sagebionetworks.jira.com/projects/BRIDGE

## Builds
* https://travis-ci.org/Sage-Bionetworks/admincentral-infra

## Secrets
* We use [git-crypt](https://github.com/AGWA/git-crypt) to hide secrets.
Access to secrets is tightly controlled.  You will be required to
have your own [GPG key](https://help.github.com/articles/generating-a-new-gpg-key)
and you must request access by a maintainer of this project.
