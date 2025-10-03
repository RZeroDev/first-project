#!/bin/bash
# Script auto-commit qui crée/ajoute du contenu à tous les fichiers et commit tout

cd /home/rzerodev/Documents/first-project || exit

# Liste des fichiers à vérifier/créer
FILES=("index.html" "style.css" "script.js" "app.ts" "index.php")

# Contenu par défaut à ajouter
DEFAULT_LINE="Ajout de contenu automatique"

# Boucle sur chaque fichier
for FILE in "${FILES[@]}"; do
    if [ ! -f "$FILE" ]; then
        echo "$DEFAULT_LINE" > "$FILE"
        echo "Créé $FILE"
    else
        echo "$DEFAULT_LINE" >> "$FILE"
        echo "Ajouté une ligne à $FILE"
    fi
done

# Ajouter tous les fichiers du projet (tout sera commit)
git add .

# Commit avec date
git commit -m "Auto commit: $(date)"

# Push vers GitHub
git push origin main

# --- Notification Discord ---
WEBHOOK_URL="https://discord.com/api/webhooks/TON_WEBHOOK_ICI"
LAST_COMMIT=$(git rev-parse --short HEAD)
NUM_FILES=$(git diff-tree --no-commit-id --name-only -r HEAD | wc -l)
COMMIT_URL="https://github.com/RzeroDev/First-projects/commit/$LAST_COMMIT"
COMMIT_MSG="✅ Nouveau commit automatique : [$LAST_COMMIT]($COMMIT_URL) | Fichiers modifiés : $NUM_FILES"

curl -H "Content-Type: application/json" \
     -X POST \
     -d "{\"content\": \"$COMMIT_MSG\"}" \
     $WEBHOOK_URL
