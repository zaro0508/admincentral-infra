Setup AD with LDAP
https://aws.amazon.com/blogs/security/how-to-configure-an-ldaps-endpoint-for-simple-ad/

Notes:
Start by creating a self signed certificate, FQDN should be "ad.sagebase.org".
Certificate will be passed in as LDAPSCertificateARN parameter.
AD host name should match cert FQDN, "ad.sagebase.org"

Execute template in order:

aws --profile admincentral.travis --region us-east-1 \
cloudformation create-stack --stack-name ad-pre-setup \
--capabilities CAPABILITY_NAMED_IAM \
--template-body file://cf_templates/ad-pre-setup.yml

aws --profile admincentral.travis --region us-east-1 \
cloudformation create-stack --stack-name simple-ad \
--capabilities CAPABILITY_NAMED_IAM \
--template-body file://cf_templates/simple-ad.yml \
--parameters \
ParameterKey=SimpleADPW,ParameterValue="P@ss1234"

aws --profile admincentral.travis --region us-east-1 \
cloudformation create-stack --stack-name simple-ad-secure-ldap \
--capabilities CAPABILITY_NAMED_IAM \
--template-body file://cf_templates/simple-ad-secure-ldap.yml \
--parameters \
ParameterKey=AdKeyPair,ParameterValue="sage-ad" \
ParameterKey=AdTrustedNetwork,ParameterValue="10.4.0.0/16" \
ParameterKey=LDAPSCertificateARN,ParameterValue="arn:aws:acm:us-east-1:745159704268:certificate/45d1a123-7312-440e-a0ce-077301bcb6d2" \
ParameterKey=VPCId,ParameterValue="vpc-5326f028" \
ParameterKey=SubnetId1,ParameterValue="subnet-7ef9aa51" \
ParameterKey=SubnetId2,ParameterValue="subnet-901309db" \
ParameterKey=SimpleADPriIP,ParameterValue="10.4.55.143" \
ParameterKey=SimpleADSecIP,ParameterValue="10.4.91.177"

