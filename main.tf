
provider "aws" {
    region = "us-east-1"
}

resource "aws_key_pair" "nginx-server-ssh" {
   key_name   = "nginx-server-ssh"
   public_key = file("nginx-server.key.pub")
}


resource "aws_security_group" "nginx-server-sg" {
 name        = "nginx-server-sg"
 description = "Security group allowing SSH and HTTP access"


 ingress {
   from_port   = 22
   to_port     = 22
   protocol    = "tcp"
   cidr_blocks = ["0.0.0.0/0"]
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

}


resource "aws_instance" "nginx-server" {
 ami = "ami-0453ec754f44f9a4a"  # agrega el ami Amazon Linux de acuerdo a tu region
 instance_type = "t2.micro"
 #count = 2



 tags = {
   Name        = "Upb-Nginx"
   Environment = "test"
   Owner       = "luisandypp@gmail.com" # Puedes agregar tu mail para el tag
   Team        = "DevOps"
   Project     = "webinar"
 }


 user_data = <<-EOF
             #!/bin/bash
             sudo yum install -y nginx
             sudo yum install -y openssh-server
             sudo systemctl enable sshd
             sudo systemctl start sshd
             sudo systemctl enable nginx
             sudo systemctl start nginx
             cd /var
             sudo mkdir www
             cd www
             sudo mkdir html
             sudo chown ec2-user:ec2-user /var/www/html
             EOF
 user_data_replace_on_change = true
 key_name = aws_key_pair.nginx-server-ssh.key_name
 vpc_security_group_ids = [ aws_security_group.nginx-server-sg.id ]

}

output "ec2_public_ip" {
  value = aws_instance.nginx-server.public_ip
}



