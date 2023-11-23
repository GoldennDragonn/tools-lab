resource "aws_key_pair" "rke2" {
  key_name   = "yakovbe-rke2"
  public_key = file("${var.ssh_public_key}")
}

resource "aws_security_group" "rke2_sg" {
  name   = "rke2_sg"
  vpc_id = " vpc-0a1bbef550af64d2f"
  ingress {
    description = "Allow_ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow_http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow_https"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow_postgres1"
    from_port   = 30543
    to_port     = 30543
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow_postgres2"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow_minio_service_port"
    from_port   = 32000
    to_port     = 32000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow_minio_console_port"
    from_port   = 32001
    to_port     = 32001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow_argocd"
    from_port   = 30080
    to_port     = 30080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow_nfs"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow_nfs2"
    from_port   = 111
    to_port     = 111
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow_kubelet"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow_controlplane"
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow_RKE2 agent nodes"
    from_port   = 9345
    to_port     = 9345
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow_etcd client port"
    from_port   = 2379
    to_port     = 2379
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow_etcd client port"
    from_port   = 2380
    to_port     = 2380
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow_etcd metric port"
    from_port   = 2381
    to_port     = 2381
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow_Calico BGP"
    from_port   = 179
    to_port     = 179
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow_Calico CNI with VXLAN"
    from_port   = 4789
    to_port     = 4789
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow_Calico CNI with Typha"
    from_port   = 5473
    to_port     = 5473
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow_Calico Typha health checks"
    from_port   = 9098
    to_port     = 9098
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow_Calico health checks"
    from_port   = 9099
    to_port     = 9099
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow_Calico BGP"
    from_port   = 179
    to_port     = 179
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
    Name = "rke2_sg"
  }
}

# create instances
resource "aws_instance" "rke2-node1" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = aws_key_pair.rke2.id
  subnet_id              = "subnet-0afddc4eea79c7496"
  vpc_security_group_ids = ["${aws_security_group.rke2_sg.id}"]
  tenancy                = "default"
  #user_data              = file("user_data_bootstrap.sh")

  tags = {
    Name = "yakovb-rke2-node1"
  }
  # Define the block device for the instance
  root_block_device {
    volume_size = 50
    volume_type = "gp2"
  }
}


resource "aws_instance" "rke2-node2" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = aws_key_pair.rke2.id
  subnet_id              = "subnet-0afddc4eea79c7496"
  vpc_security_group_ids = ["${aws_security_group.rke2_sg.id}"]
  tenancy                = "default"
  #user_data              = file("user_data_bootstrap.sh")

  tags = {
    Name = "yakovb-rke2_node2"
  }

  # Define the block device for the instance
  root_block_device {
    volume_size = 50
    volume_type = "gp2"
  }
}

resource "aws_instance" "rke2-node3" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = aws_key_pair.rke2.id
  subnet_id              = "subnet-0afddc4eea79c7496"
  vpc_security_group_ids = ["${aws_security_group.rke2_sg.id}"]
  tenancy                = "default"
  #user_data              = file("user_data_bootstrap.sh")

  tags = {
    Name = "yakovb-rke2_node3"
  }

  # Define the block device for the instance
  root_block_device {
    volume_size = 50
    volume_type = "gp2"
  }
}
