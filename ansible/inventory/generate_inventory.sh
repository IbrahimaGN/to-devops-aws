#!/usr/bin/env bash
#
# Génère ansible/inventory/hosts.ini à partir des outputs Terraform.
# À exécuter depuis la racine du projet, après un `terraform apply` réussi.
#
# Usage : ./inventory/generate_inventory.sh

set -euo pipefail

TERRAFORM_DIR="../terraform"
INVENTORY_FILE="./hosts.ini"
SSH_KEY_PATH="${SSH_KEY_PATH:-~/.ssh/todo-medishop-key.pem}"

if ! command -v terraform &> /dev/null; then
  echo "Erreur : terraform n'est pas installé ou pas dans le PATH." >&2
  exit 1
fi

if ! command -v jq &> /dev/null; then
  echo "Erreur : jq est requis (sudo apt install jq)." >&2
  exit 1
fi

echo "Lecture des outputs Terraform depuis ${TERRAFORM_DIR}..."
OUTPUT_JSON=$(cd "${TERRAFORM_DIR}" && terraform output -json ansible_inventory)

FRONT_PUBLIC_IP=$(echo "${OUTPUT_JSON}" | jq -r '.front.public_ip')
FRONT_PRIVATE_IP=$(echo "${OUTPUT_JSON}" | jq -r '.front.private_ip')
BACK_PRIVATE_IP=$(echo "${OUTPUT_JSON}" | jq -r '.back.private_ip')
DB_PRIVATE_IP=$(echo "${OUTPUT_JSON}" | jq -r '.db.private_ip')

if [[ -z "${FRONT_PUBLIC_IP}" || "${FRONT_PUBLIC_IP}" == "null" ]]; then
  echo "Erreur : impossible de récupérer les IPs. As-tu bien fait 'terraform apply' ?" >&2
  exit 1
fi

cat > "${INVENTORY_FILE}" <<EOF
# Fichier généré automatiquement par generate_inventory.sh — NE PAS ÉDITER À LA MAIN
# Régénérer avec : ./generate_inventory.sh

[front]
front ansible_host=${FRONT_PUBLIC_IP} ansible_user=ubuntu ansible_ssh_private_key_file=${SSH_KEY_PATH}

[back]
back ansible_host=${BACK_PRIVATE_IP} ansible_user=ubuntu ansible_ssh_private_key_file=${SSH_KEY_PATH}

[db]
db ansible_host=${DB_PRIVATE_IP} ansible_user=ubuntu ansible_ssh_private_key_file=${SSH_KEY_PATH}

[front_private_ip]
front_ip=${FRONT_PRIVATE_IP}

[all:vars]
ansible_python_interpreter=/usr/bin/python3
bastion_host=${FRONT_PUBLIC_IP}
EOF

echo "Inventaire généré : ${INVENTORY_FILE}"
cat "${INVENTORY_FILE}"