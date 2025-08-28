##################################################
# SSM Components
##################################################

resource "aws_iam_role" "ssm_role" {
  name = "k8s-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "k8s-ssm-profile"
  role = aws_iam_role.ssm_role.name
}

##################################################
# Security Groups
##################################################

resource "aws_security_group" "k8s_sg" {
  name        = "k8s-learning-sg"
  description = "Open access for K8s ports"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "K8s API Server"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "NodePort services"
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Kubelet API"
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ICMP ping"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "k8s-public-access"
  }
}


##################################################
# EC2
##################################################

resource "aws_instance" "k8s_node" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.medium"
  vpc_security_group_ids = [aws_security_group.k8s_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ssm_profile.name
  subnet_id              = data.aws_subnet.default.id

  tags = {
    Name = "platform-playground-master-node"
  }
}

resource "aws_eip" "k8s_ip" {
  instance = aws_instance.k8s_node.id
  domain   = "vpc"
}
