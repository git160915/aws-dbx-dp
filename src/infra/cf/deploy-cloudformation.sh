#!/bin/bash

# Set stack names
VPC_STACK_NAME="ec2-ssm-vpc-stack"
RDS_STACK_NAME="ec2-ssm-rds-stack"

# Set CloudFormation template file paths
VPC_TEMPLATE="ec2-ssm-vpc-subnet-group.yaml"
RDS_TEMPLATE="ec2-ssm-rds.yaml"

# Set parameters for RDS
MASTER_USERNAME="adminuser"
MASTER_PASSWORD="SecurePass1234"

# Check if the user provided an action (create or delete)
if [ "$#" -ne 1 ]; then
    echo "❌ Error: Missing action parameter (create or delete)"
    echo "Usage: $0 <create|delete>"
    exit 1
fi

ACTION=$1

# Function to create stacks
create_stacks() {
    echo "🚀 Deploying VPC and EC2 stack: $VPC_STACK_NAME..."
    aws cloudformation create-stack \
        --stack-name $VPC_STACK_NAME \
        --template-body file://$VPC_TEMPLATE \
        --capabilities CAPABILITY_NAMED_IAM

    # Wait until the stack is created
    echo "⏳ Waiting for VPC stack to complete..."
    aws cloudformation wait stack-create-complete --stack-name $VPC_STACK_NAME
    echo "✅ VPC and EC2 stack deployed successfully!"

    # Deploy the RDS stack, passing the VPC stack name as a parameter
    echo "🚀 Deploying RDS stack: $RDS_STACK_NAME..."
    aws cloudformation create-stack \
        --stack-name $RDS_STACK_NAME \
        --template-body file://$RDS_TEMPLATE \
        --capabilities CAPABILITY_NAMED_IAM \
        --parameters ParameterKey=VPCStackName,ParameterValue=$VPC_STACK_NAME \
                     ParameterKey=MasterUsername,ParameterValue=$MASTER_USERNAME \
                     ParameterKey=MasterUserPassword,ParameterValue=$MASTER_PASSWORD

    # Wait for RDS stack to complete
    echo "⏳ Waiting for RDS stack to complete..."
    aws cloudformation wait stack-create-complete --stack-name $RDS_STACK_NAME
    echo "✅ RDS stack deployed successfully!"

    # Retrieve the RDS endpoint
    RDS_ENDPOINT=$(aws cloudformation describe-stacks \
        --stack-name $RDS_STACK_NAME \
        --query "Stacks[0].Outputs[?OutputKey=='RDSInstanceEndpoint'].OutputValue" \
        --output text)

    if [ -z "$RDS_ENDPOINT" ]; then
        echo "❌ Error: RDS endpoint not found."
    else
        echo "🎉 Deployment complete! PostgreSQL RDS Endpoint: $RDS_ENDPOINT"
    fi
}

# Function to delete stacks
delete_stacks() {
    echo "🗑️ Deleting RDS stack: $RDS_STACK_NAME..."
    aws cloudformation delete-stack --stack-name $RDS_STACK_NAME
    aws cloudformation wait stack-delete-complete --stack-name $RDS_STACK_NAME
    echo "✅ RDS stack deleted successfully!"

    echo "🗑️ Deleting VPC stack: $VPC_STACK_NAME..."
    aws cloudformation delete-stack --stack-name $VPC_STACK_NAME
    aws cloudformation wait stack-delete-complete --stack-name $VPC_STACK_NAME
    echo "✅ VPC stack deleted successfully!"
}

case "$ACTION" in
    create)
        create_stacks
        ;;
    delete)
        delete_stacks
        ;;
    *)
        echo "❌ Error: Invalid action. Use 'create' or 'delete'."
        exit 1
        ;;
esac
