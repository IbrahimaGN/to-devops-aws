# --- SG Front : accessible depuis Internet (HTTP/HTTPS) + SSH depuis l'IP admin uniquement ---

resource "aws_security_group" "front" {
  name        = "${var.project_name}-front-sg"
  description = "Autorise HTTP HTTPS depuis Internet et SSH depuis l IP admin uniquement"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH depuis l IP de l administrateur uniquement"
    from_port   = var.ports.ssh
    to_port     = var.ports.ssh
    protocol    = "tcp"
    cidr_blocks = [var.admin_ip_cidr]
  }

  ingress {
    description = "HTTP depuis Internet"
    from_port   = var.ports.http
    to_port     = var.ports.http
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS depuis Internet"
    from_port   = var.ports.https
    to_port     = var.ports.https
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Tout trafic sortant autorise (necessaire pour appeler le Back, pull Docker, etc.)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-front-sg"
  }
}

# --- SG Back : accessible uniquement depuis le Front (API) et en SSH depuis le Front (bastion) ---

resource "aws_security_group" "back" {
  name        = "${var.project_name}-back-sg"
  description = "Autorise le trafic applicatif et SSH uniquement depuis le SG Front"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "API Node.js/Express accessible uniquement depuis le Front"
    from_port       = var.ports.back
    to_port         = var.ports.back
    protocol        = "tcp"
    security_groups = [aws_security_group.front.id]
  }

  ingress {
    description     = "SSH depuis le Front uniquement (bastion pour Ansible)"
    from_port       = var.ports.ssh
    to_port         = var.ports.ssh
    protocol        = "tcp"
    security_groups = [aws_security_group.front.id]
  }

  egress {
    description = "Tout trafic sortant autorise (pull Docker via NAT, acces DB)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-back-sg"
  }
}

# --- SG DB : accessible uniquement depuis le Back ---

resource "aws_security_group" "db" {
  name        = "${var.project_name}-db-sg"
  description = "Autorise PostgreSQL et SSH uniquement depuis le SG Back"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "PostgreSQL accessible uniquement depuis le Back"
    from_port       = var.ports.db
    to_port         = var.ports.db
    protocol        = "tcp"
    security_groups = [aws_security_group.back.id]
  }

  ingress {
    description     = "SSH depuis le Back uniquement (relais bastion Front vers DB)"
    from_port       = var.ports.ssh
    to_port         = var.ports.ssh
    protocol        = "tcp"
    security_groups = [aws_security_group.back.id]
  }

  egress {
    description = "Sortant autorise (pull image postgres via NAT)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-db-sg"
  }
}