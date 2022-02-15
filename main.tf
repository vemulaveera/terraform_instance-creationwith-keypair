variable "public_key_path" {
    description = "Public key path"
    type = string
    default = "~/.ssh/id_rsa.pub"
}
variable "name" {
  type = string
  default = "allow_all"
}
provider "aws" {
  region                  = "us-east-1"
  profile                 = "default"
}
resource "aws_instance" "rhel" {
  ami                    = "ami-0b0af3577fe5e3532"
  instance_type          = "t2.micro"
  key_name               = "${aws_key_pair.ec2key.key_name}"
  vpc_security_group_ids = ["${aws_security_group.allow_all.id}"]
  user_data =  <<-EOF
  #!/bin/bash
  yum update -y
  mkdir vvr
  cd vvr
  echo "hi veera:" > /vvr/sri  
  yum install httpd -y
  echo "welcome to my first instance got successed" > /var/www/html/index.html
  service httpd start
  service httpd enable
  EOF
}
resource "aws_security_group" "allow_all" {
  name = "${var.name}"
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_key_pair" "ec2key" {
  key_name   = "terraformkey"
  public_key = file("${var.public_key_path}")
}