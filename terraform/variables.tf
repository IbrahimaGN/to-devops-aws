variable "aws_region" {
  description = "Région AWS où déployer l'infrastructure"
  type        = string
  default     = "eu-west-3" # Paris
}

variable "project_name" {
  description = "Nom du projet, utilisé comme préfixe pour taguer les ressources"
  type        = string
  default     = "todo-medishop"
}

variable "environment" {
  description = "Environnement de déploiement (dev, staging, prod)"
  type        = string
  default     = "dev"
}

# --- Réseau ---

variable "vpc_cidr" {
  description = "Bloc CIDR du VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "Bloc CIDR du sous-réseau public (Front)"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "Bloc CIDR du sous-réseau privé (Back + DB)"
  type        = string
  default     = "10.0.2.0/24"
}

variable "availability_zone" {
  description = "Zone de disponibilité utilisée pour les subnets"
  type        = string
  default     = "eu-west-3a"
}

# --- Sécurité / accès ---

variable "admin_ip_cidr" {
  description = "Adresse IP publique de l'administrateur autorisée en SSH sur le Front (format CIDR, ex: 41.82.x.x/32)"
  type        = string
  # Pas de valeur par défaut volontairement : doit être fourni via terraform.tfvars
}

variable "ssh_key_name" {
  description = "Nom de la paire de clés SSH AWS (déjà créée dans la console EC2) à associer aux instances"
  type        = string
}

# --- Instances ---

variable "instance_type_front" {
  description = "Type d'instance EC2 pour le Front"
  type        = string
  default     = "t2.micro"
}

variable "instance_type_back" {
  description = "Type d'instance EC2 pour le Back"
  type        = string
  default     = "t2.micro"
}

variable "instance_type_db" {
  description = "Type d'instance EC2 pour la DB"
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "AMI Ubuntu 24.04 LTS (à adapter selon la région choisie)"
  type        = string
  default     = "ami-0e0f9dd0c866d6b78" # Ubuntu 24.04 LTS - eu-west-3, à vérifier au moment du déploiement
}

variable "allocate_elastic_ip" {
  description = "Si true, alloue une Elastic IP pour l'instance Front (optionnel selon le TP)"
  type        = bool
  default     = false
}

variable "ports" {
  description = "Ports applicatifs utilisés entre les couches"
  type = object({
    ssh   = number
    http  = number
    https = number
    back  = number # port de l'API Node.js/Express
    db    = number # port PostgreSQL
  })
  default = {
    ssh   = 22
    http  = 80
    https = 443
    back  = 3000
    db    = 5432
  }
}
