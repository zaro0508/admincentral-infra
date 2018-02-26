# Overview
Install, configure and manage the AWS AdminCentral account.


## Instructions to create or update CF stacks

```
# unlock repo
git-crypt unlock
# set env vars
source env_vars && source env_vars.secret
# Run commands in update_cf_stack.sh to create or update CF stacks
```

The above should setup resources for the account.  Once the infrastructure for the account has been setup
you can access and view the account using the AWS console[1].

*Note - This project depends on CF templates from other accounts.*

## VPN Gateway
This account is setup to be the VPN Gateway.  A VPC peering connection is required to
allow the VPN access to other VPCs.  To setup VPC peering from the VPN VPC to another
VPC run the following template.

```
aws --profile aws-admin --region us-east-1 cloudformation create-stack \
--stack-name peering-$PeerAccountName \
--capabilities CAPABILITY_NAMED_IAM \
--template-body file://cf_templates/VPCPeer.yml \
--parameters \
ParameterKey=PeerVPC,ParameterValue=$PeerAccountVpcId \
ParameterKey=PeerVPCOwner,ParameterValue=$PeerAccountId \
ParameterKey=PeerRoleName,ParameterValue=$VPCPeeringAuthorizerRole \
ParameterKey=PeerPublicRouteTable,ParameterValue=$PeerPublicRouteTable \
ParameterKey=PeerPrivateRouteTable,ParameterValue=$PeerPublicRouteTable
```


Example:
```
aws --profile aws-admin --region us-east-1 cloudformation create-stack \
--stack-name peering-BridgeDev \
--capabilities CAPABILITY_NAMED_IAM \
--template-body file://cf_templates/VPCPeer.yml \
--parameters \
ParameterKey=PeerVPC,ParameterValue="vpc-5678efghi" \
ParameterKey=PeerVPCOwner,ParameterValue="123456789123" \
ParameterKey=PeerRoleName,ParameterValue="essentials-VPCPeeringAuthorizerRole-UYRMWCKIO3GS" \
ParameterKey=PeerPublicRouteTable,ParameterValue="rtb-d3b64eaf" \
ParameterKey=PeerPrivateRouteTable,ParameterValue="rtb-49b14935"
```

The [VPCPeer.yml template](./cf_templates/VPCPeer.yml) should setup the VPC peering
from the VPN VPC to the *$PeerVPC* in the account identified by *$PeerAccountName*.
This template should be run for each VPC peering connection therefore a
`unique stack-name should be given` for each run of this template.

**Note** - VPCPeer.yml requires that the *$PeerVPC* be setup with [CrossAccountRoleTemplate.json](https://github.com/awslabs/aws-cloudformation-templates/blob/master/aws/solutions/VPCPeering/CrossAccountRoleTemplate.json)
template which was added to the [essentials.yml](https://github.com/Sage-Bionetworks/aws-infra/blob/master/cf_templates/essentials.yml)
template.


## Continuous Integration
We have configured Travis to deploy CF template updates.  Travis does this by running update_cf_stack.sh on every
change.


# Contributions

## Issues
* https://sagebionetworks.jira.com/projects/BRIDGE

## Builds
* https://travis-ci.org/Sage-Bionetworks/admincentral-infra

## Secrets
* We use git-crypt[3] to hide secrets.  Access to secrets is tightly controlled.  You will be required to
have your own GPG key[4] and you must request access by a maintainer of this project.



# References

[1] https://AWS-account-ID-or-alias.signin.aws.amazon.com/console

[2] https://github.com/Sage-Bionetworks/Bridge-infra

[3] https://github.com/AGWA/git-crypt

[4] https://help.github.com/articles/generating-a-new-gpg-key
