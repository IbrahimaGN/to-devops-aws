# --- Instance Front (subnet public) ---

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical (propriétaire officiel des AMI Ubuntu)

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "front" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type_front
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.front.id]
  key_name                    = var.ssh_key_name
  associate_public_ip_address = true

  tags = {
    Name = "${var.project_name}-front"
    Role = "front"
  }
}

resource "aws_eip" "front" {
  count    = var.allocate_elastic_ip ? 1 : 0
  instance = aws_instance.front.id
  domain   = "vpc"

  tags = {
    Name = "${var.project_name}-front-eip"
  }
}

# --- Instance Back (subnet privé) ---

resource "aws_instance" "back" {
  ami                     = data.aws_ami.ubuntu.id
  instance_type           = var.instance_type_back
  subnet_id               = aws_subnet.private.id
  vpc_security_group_ids  = [aws_security_group.back.id]
  key_name                = var.ssh_key_name

  tags = {
    Name = "${var.project_name}-back"
    Role = "back"
  }
}

# --- Instance DB (subnet privé) ---

resource "aws_instance" "db" {
  ami                     = data.aws_ami.ubuntu.id
  instance_type           = var.instance_type_db
  subnet_id               = aws_subnet.private.id
  vpc_security_group_ids  = [aws_security_group.db.id]
  key_name                = var.ssh_key_name

  tags = {
    Name = "${var.project_name}-db"
    Role = "db"
  }
}