# Define variables
variable "name_ec2" {
  description = "Name of the EC2 instance"
  default     = "web-server"
}

variable "environment" {
  description = "Environment of the EC2 instance"
  default     = "production"
}

variable "ami_id" {
  description = "AMI ID for Amazon Linux 2"
  default     = "ami-0c55b159cbfafe1f0"
}

variable "instance_type" {
  description = "Instance type for the EC2 instance"
  default     = "t2.micro"
}

variable "ssh_key_name" {
  description = "Name of the SSH key pair"
  default     = "ssm-role"
}

variable "vpc_id" {
  description = "ID of the VPC"
  default     = "vpc-0181038d7977a2276"
}

variable "subnet_id" {
  description = "ID of the subnet"
  default     = "subnet-08c687e6115d45706"
}

# Provision EC2 instance with Apache deployed
resource "aws_instance" "example_instance" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  key_name      = var.ssh_key_name
  tags = {
    Name = "${var.name_ec2}-${var.environment}"
  }

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              EOF
}

# Create security group allowing SSH access and open port 80
resource "aws_security_group" "example_sg" {
  vpc_id = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/32"]  # Replace with your IP address
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "example-security-group"
  }
}

# Provision Elastic IP address
resource "aws_eip" "example_eip" {}

# Associate Elastic IP address with EC2 instance
resource "aws_eip_association" "example_eip_assoc" {
  instance_id   = aws_instance.example_instance.id
  allocation_id = aws_eip.example_eip.id
}

# Output values
output "instance_id" {
  value = aws_instance.example_instance.id
}

output "public_ip" {
  value = aws_instance.example_instance.public_ip
}

output "elastic_ip" {
  value = aws_eip.example_eip.public_ip
}
