#!/bin/bash
# Script d'auto commit quotidien

# Aller dans le dépôt
cd /home/$USER/Documents/first-project || exit

# Ajouter un fichier "daily.log" qui prend la date du jour
echo "$(date)" >> daily.log

# Ajouter tous les changements
git add .

# Commit avec la date du jour
git commit -m "Daily commit: $(date)"

# Push vers GitHub (branche main)
git push origin main
