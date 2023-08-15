provider "aws" {
  region = "eu-north-1"  
}

resource "aws_instance" "web_server" {
  ami           = "ami-0989fb15ce71ba39e"
  instance_type = "t3.medium"
  key_name      = "Teraform-key"
  vpc_security_group_ids = [aws_security_group.web_server.id] # add new SG
  user_data = <<-EOF

              #!/bin/bash
              apt update -y
              apt install -y docker.io 
              systemctl enable docker
              systemctl start docker
              sudo apt-get install -y docker-compose
              mkdir docker
              cd docker/
              git clone https://github.com/caas/docker-elk.git
              cd docker-elk/
              docker-compose up -d
              EOF

  tags = {
    Name = "Monitoring Server"
      Environment = "Production"
    }
  }

resource "aws_security_group" "monitoring_server" {
  name_prefix = "monitoring_server"
  
  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

   ingress {
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

   ingress {
    from_port   = 9300
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

   ingress {
    from_port   = 5601
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
