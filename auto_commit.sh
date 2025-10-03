#!/bin/bash
# Script auto-commit qui crée des fichiers si inexistants et push automatiquement

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
        # Ajouter une ligne même si le fichier existe
        echo "$DEFAULT_LINE" >> "$FILE"
        echo "Ajouté une ligne à $FILE"
    fi
done

# Ajouter tous les fichiers du projet
git add .

# Vérifier si des changements sont prêts à committer
if git diff --cached --quiet; then
    echo "$(date): Aucun changement à committer"
    exit 0
fi

# Commit avec date
git commit -m "Auto commit: $(date)"

# Pull/rebase pour éviter les conflits
git pull --rebase origin main 

# Push vers GitHub
git push origin main

# --- Notification Discord ---
WEBHOOK_URL="https://discord.com/api/webhooks/1423508911402516492/Ya1KbW9u9WrTyMUsgoP4Y_erecGlpa8m7DpOHEkuDQOBsjlmvl0BXpAWU8x2fV8AeBoY"
LAST_COMMIT=$(git rev-parse --short HEAD)
NUM_FILES=$(git diff-tree --no-commit-id --name-only -r HEAD | wc -l)
COMMIT_URL="https://github.com/RzeroDev/First-projects/commit/$LAST_COMMIT"
COMMIT_MSG="✅ Nouveau commit automatique : [$LAST_COMMIT]($COMMIT_URL) | Fichiers modifiés : $NUM_FILES"

curl -H "Content-Type: application/json" \
     -X POST \
     -d "{\"content\": \"$COMMIT_MSG\"}" \
     $WEBHOOK_URL
