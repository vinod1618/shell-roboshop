#!/bin/bash

SG_ID="sg-0869d702361b71486"
AMI_ID="ami-0220d79f3f480ecf5"
ZONE_ID="Z0938730IPVEZU3MQ9H2"
DOMAIN_NAME="vinoddevops.online"

for instance in "$@"
do
  instance_id=$(aws ec2 run-instances \
    --image-id "$AMI_ID" \
    --instance-type t3.micro \
    --security-group-ids "$SG_ID" \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
    --query 'Instances[0].InstanceId' \
    --output text
  )

  if [ "$instance" = "frontend" ]; then
    ip=$(aws ec2 describe-instances \
      --instance-ids "$instance_id" \
      --query 'Reservations[].Instances[].PublicIpAddress' \
      --output text
    )
    RECORD_NAME="$DOMAIN_NAME"  #vinoddevops.online
  else
    ip=$(aws ec2 describe-instances \
      --instance-ids "$instance_id" \
      --query 'Reservations[].Instances[].PrivateIpAddress' \
      --output text
    )
    RECORD_NAME="$instance"."$DOMAIN_NAME" #mongodb.vinoddevops.online
  fi

  echo "IP address of $instance is: $ip"

  aws route53 change-resource-record-sets \
  --hosted-zone-id $ZONE_ID \
  --change-batch '{
    "Changes": [{
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "'$RECORD_NAME'",
        "Type": "A",
        "TTL": 1,
        "ResourceRecords": [{ "Value": "'$ip'" }]
      }
    }]
  }'

  echo "Record updated for $instance"

done
