#!/bin/bash

set -e  # Arrête le script en cas d'erreur

echo "============================================"
echo          "Infrastructure Complète"
echo "============================================"
echo ""

# Étape 1: Terraform
echo  "Étape 1/2: Provisionnement avec Terraform"
echo "--------------------------------------------"
cd terraform

echo "  → Initialisation Terraform..."
terraform init

echo "  → Application de la configuration..."
terraform apply -auto-approve

# Récupérer les IPs depuis Terraform
echo "  → Récupération des IPs depuis Terraform..."
WEB_IP=$(terraform output -raw web_server_ip)
DB_IP=$(terraform output -raw db_server_ip)

cd ..
echo ""

# Génération dynamique de l'inventory Ansible
echo "   Génération de l'inventory Ansible..."
cat > ansible/inventory.yml <<EOF
---
all:
  children:
    web:
      hosts:
        web-server:
          ansible_host: $WEB_IP
          ansible_user: jordan
    db:
      hosts:
        db-server:
          ansible_host: $DB_IP
          ansible_user: jordan
  vars:
    ansible_python_interpreter: /usr/bin/python3
    ansible_ssh_private_key_file: ~/.ssh/id_ed25519
    ansible_ssh_common_args: '-o StrictHostKeyChecking=no'
EOF

echo "  ✓ Inventory généré avec Web=$WEB_IP et DB=$DB_IP"
echo ""

# Étape 2: Ansible
echo "   Étape 2/2: Configuration avec Ansible"
echo "--------------------------------------------"
cd ansible

echo "  → Attente du démarrage des VMs (30s)..."
sleep 30

echo "  → Test de connectivité..."
ansible all -i inventory.yml -m ping

echo "  → Exécution du playbook..."
ansible-playbook -i inventory.yml site.yml

cd ..
echo ""

echo "============================================"
echo     "Déploiement terminé avec succès !"
echo "============================================"
echo ""
echo "Accès web: http://$WEB_IP"
echo "Serveur DB: $DB_IP"
echo ""
