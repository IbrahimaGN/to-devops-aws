output "front_public_ip" {
  description = "IP publique de l'instance Front (point d'entrée de l'application)"
  value       = var.allocate_elastic_ip ? aws_eip.front[0].public_ip : aws_instance.front.public_ip
}

output "front_private_ip" {
  description = "IP privée de l'instance Front (utile pour Ansible/débogage interne)"
  value       = aws_instance.front.private_ip
}

output "back_private_ip" {
  description = "IP privée de l'instance Back"
  value       = aws_instance.back.private_ip
}

output "db_private_ip" {
  description = "IP privée de l'instance DB"
  value       = aws_instance.db.private_ip
}

output "vpc_id" {
  description = "ID du VPC créé"
  value       = aws_vpc.main.id
}

# Utile pour générer automatiquement l'inventaire Ansible (étape suivante)
output "ansible_inventory" {
  description = "Résumé structuré des IPs pour génération d'inventaire Ansible"
  value = {
    front = {
      public_ip  = var.allocate_elastic_ip ? aws_eip.front[0].public_ip : aws_instance.front.public_ip
      private_ip = aws_instance.front.private_ip
    }
    back = {
      private_ip = aws_instance.back.private_ip
    }
    db = {
      private_ip = aws_instance.db.private_ip
    }
  }
}
