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
--stack-name peering-$PeerAccountVpcId \
--capabilities CAPABILITY_NAMED_IAM \
--template-body file://cf_templates/VPCPeer.yml \
--parameters \
ParameterKey=LocalVPC,ParameterValue=$SophosVpcId \
ParameterKey=PeerVPC,ParameterValue=$PeerAccountVpcId \
ParameterKey=PeerVPCOwner,ParameterValue=$PeerAccountId \
ParameterKey=PeerRoleName,ParameterValue=$VPCPeeringAuthorizerRole
```

```
aws --profile aws-admin --region us-east-1 cloudformation create-stack \
--stack-name peering-vpc-5678efghi \
--capabilities CAPABILITY_NAMED_IAM \
--template-body file://cf_templates/VPCPeer.yml \
--parameters \
ParameterKey=LocalVPC,ParameterValue="vpc-1234abcd" \
ParameterKey=PeerAccountName,ParameterValue="BridgeDev" \
ParameterKey=PeerVPC,ParameterValue="vpc-5678efghi" \
ParameterKey=PeerVPCOwner,ParameterValue="123456789123" \
ParameterKey=PeerRoleName,ParameterValue="essentials-VPCPeeringAuthorizerRole-UYRMWCKIO3GS"
```

The [VPCPeer.yml template](./cf_templates/VPCPeer.yml) should setup the VPC peering
from this account to the account identified by *$PeerAccountName*.  This template
should be run for each VPC peering connection therefore a `unique stack-name should
be given` for each run of this template.


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
