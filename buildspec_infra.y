version: 0.2

phases:
  install:
    runtime-versions:
      java: corretto11
  pre_build:
    commands:
      - echo "Download JQ"
      - curl -qL -o jq https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 && chmod +x ./jq
      - mv jq /usr/local/bin 
      - aws --version
      - ls -lrt
      - pwd
      - ls -lrta user-data.sh
      - aws ec2 run-instances --image-id "ami-053b0d53c279acc90" --count 1 --instance-type t2.medium --key-name "Ansible" --security-group-ids "sg-00a15923a6a393d34" --subnet-id "subnet-02ff0f0e56fadc161" --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=CodeB},{Key=Environment,Value=dev}]' --user-data file://user-data.sh
      - pwd
  build:
    commands:
      - echo "Executing Build Phase"
      - ls -lrt $CODEBUILD_SRC_DIR
      - cd $CODEBUILD_SRC_DIR
      - pwd
      - ls -lrta
      - aws s3 cp s3://codebuild125/devops.war /usr/share/tomcat/webapps/ 
      - pwd
  post_build:
    commands:
      - echo "Infra Job is completed on `date`"