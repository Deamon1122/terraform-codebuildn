
packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "ami_aws_account_id" {
  type    = string
  default = "370239019157"
}

variable "applicaiton_name" {
  type    = string
  default = "cloudbinary"
}

variable "application_version" {
  type    = string
  default = "9.1.0"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "packer_profile" {
  type    = string
  default = "packer-ec2-s3"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "source_ami" {
  type    = string
  default = "ami-092694409ab038fa6"
}

# could not parse template for following block: "template: hcl2_upgrade:2: bad character U+0060 '`'"

source "amazon-ebs" "ubuntu" {
  ami_name                    = "TomcatGoldenAMi"
  associate_public_ip_address = "true"
  force_delete_snapshot       = "true"
  force_deregister            = "true"

  instance_type = "t2.micro"
  profile       = "default"
  region        = "us-east-1"
  source_ami    = "ami-092694409ab038fa6"
  ssh_username  = "ubuntu"
  aws_access    = "AKIAVMM7XDCK3K2J37VM"
  secret_key    = "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"
  tags = {
    CreatedBy = "Packer"
    Name      = "tom"
  }
}

build {
  sources = ["source.amazon-ebs.ubuntu"]

  provisioner "shell" {
    inline = ["sudo apt-get update",
      "sudo apt-get install software-properties-common -y"
    ]
  }
  provisioner "shell" {
        execute_command = "sudo -u root /bin/bash -c '{{ .Path }}'"
        scripts         = ["awscli.sh"]
      }
  provisioner "shell" {
    inline = [
        "aws s3 cp s3://codebuildpipes3/Codebuild1/target/devops.war /usr/share/tomcat/webapps/"
    ]
}

packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "ami_aws_account_id" {
  type    = string
  default = "370239019157"
}

variable "applicaiton_name" {
  type    = string
  default = "Cloud"
}

variable "application_version" {
  type    = string
  default = "9.1.0"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "packer_profile" {
  type    = string
  default = "packer-ec2-s3"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "source_ami" {
  type    = string
  default = "ami-092694409ab038fa6"
}

# could not parse template for following block: "template: hcl2_upgrade:2: bad character U+0060 '`'"

source "amazon-ebs" "ubuntu" {
  ami_name                    = "TomcatGoldenAMi"
  associate_public_ip_address = "true"
  force_delete_snapshot       = "true"
  force_deregister            = "true"

  instance_type = "t2.micro"
  profile       = "default"
  region        = "us-east-1"
  source_ami    = "ami-092694409ab038fa6"
  ssh_username  = "ubuntu"
  aws_access    = AKIAVMM7XDCK3K2J37VM
  secret_key    = 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
  tags = {
    CreatedBy = "Packer"
    Name      = "tom"
  }
}

build {
  sources = ["source.amazon-ebs.ubuntu"]

  provisioner "shell" {
    inline = ["sudo apt-get update",
      "sudo apt-get install software-properties-common -y"
    ]
  }

  provisioner "shell" {
    inline = ["aws s3 cp s3://codebuildpipes3/Codebuild1/target/devops.war /usr/share/tomcat/webapps/"]
  }
}
