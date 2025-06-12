#!/bin/bash
set -e

echo " Déploiement LPIC-2 - Infrastructure Réseau Sécurisée"

# Vérifications
if ! command -v ansible-playbook &> /dev/null; then
    echo "Ansible non installé"
    exit 1
fi

# Test de connectivité
echo "Test de connectivité..."
if ! ansible servers -m ping > /dev/null 2>&1; then
    echo "Impossible de se connecter à la VM"
    echo "Vérifiez le fichier 'hosts' et la connectivité SSH"
    exit 1
fi

echo "Connectivité OK"

# Vérification syntaxe
echo "Vérification de la syntaxe..."
ansible-playbook playbook.yml --syntax-check

# Dry run
echo "Simulation du déploiement..."
ansible-playbook playbook.yml --check

# Confirmation
read -p "Lancer le déploiement réel ? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "⚡ Déploiement en cours..."
    ansible-playbook playbook.yml
    
    echo ""
    echo "Déploiement terminé !"
    echo "Services configurés :"
    echo "DHCP : 192.168.20.100-200"
    echo "Samba : //$(ansible servers -m setup -a 'filter=ansible_default_ipv4' | grep address | cut -d'"' -f4)"
    echo "Firewall : Activé"
    echo ""
    echo "Tests rapides :"
    echo "ansible servers -m shell -a 'systemctl status isc-dhcp-server'"
    echo "ansible servers -m shell -a 'smbclient -L localhost -U guest%'"
    echo "ansible servers -m shell -a 'iptables -L INPUT -n | head -5'"
else
    echo "Déploiement annulé"
fi