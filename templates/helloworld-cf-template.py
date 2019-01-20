#!/usr/bin/python3

from troposphere import (
    Base64, ec2, GetAtt, Join, Output, Parameter, Ref, Template
)

# Common variables used to create the template
ApplicationPort = "3000"

# Prepare the script to start nodejs on start
ud = Base64(Join('\n', [
        "#!/bin/bash",
        "sudo yum install --enablerepo=epel -y nodejs",
        "wget http://bit.ly/2vESNuc -O /home/ec2-user/helloworld.js",
        "wget http://bit.ly/2vVvT18 -O /etc/init/helloworld.conf",
        "start helloworld"
    ]
))

# The template used to generate CloudFormation
t = Template()
t.add_description("Effective DevOps: HelloWorld stack")

# Add the parameters and resources needed to build on CloudFormation
t.add_parameter(Parameter(
    "KeyPair",
    Description="Name of an existing ec2 keypair to use",
    Type="AWS::EC2::KeyPair::KeyName",
    ConstraintDescription="Must be name of an existing ec2 keypair"))
t.add_resource(ec2.SecurityGroup(
    "SecurityGroup",   
    GroupDescription="Allow SSH/TCP {} Access".format(ApplicationPort),
    SecurityGroupIngress=[
        ec2.SecurityGroupRule(
            IpProtocol="tcp",
            FromPort="22",
            ToPort="22",
            CidrIp="0.0.0.0/0"
        ),
        ec2.SecurityGroupRule(
            IpProtocol="tcp",
            FromPort=ApplicationPort,
            ToPort=ApplicationPort,
            CidrIp="0.0.0.0/0"
        )
    ]
))
t.add_resource(ec2.Instance(
    "instance",
    ImageId="ami-cfe4b2b0",
    InstanceType="t2.micro",
    SecurityGroups=[Ref("SecurityGroup")],
    KeyName=Ref("KeyPair"),
    UserData=ud
))

# Add the ouputs from our template
t.add_output(Output(
    "InstancePublicIp",
    Description="Public IP of our instance",
    Value=GetAtt("instance", "PublicIp")
))
t.add_output(Output(
    "WebUrl",
    Description="Application Endpoint",
    Value=Join("", [
        "http://", GetAtt("instance", "PublicDnsName"), ":", ApplicationPort
    ])
))

# Now we can print the cloudformation from our template
print(t.to_json())