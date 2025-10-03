#!/bin/bash
# Script auto-commit qui crée des fichiers si inexistants et push automatiquement

cd /home/rzerodev/Documents/first-project || exit

# Charger les variables d'environnement
export $(grep -v '^#' .env | xargs)

# Configurer Git
git config --global user.name "$GIT_USER"
git config --global user.email "$GIT_EMAIL"

# Liste des fichiers à vérifier/créer
FILES=("index.html" "style.css" "script.js" "app.ts" "index.php")
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
git pull --rebase "https://$GIT_USER:$GIT_TOKEN@$GIT_REPO" main || true

# Push vers GitHub avec token
git push "https://$GIT_USER:$GIT_TOKEN@$GIT_REPO" main

# --- Notification Discord ---
LAST_COMMIT=$(git rev-parse --short HEAD)
NUM_FILES=$(git diff-tree --no-commit-id --name-only -r HEAD | wc -l)
COMMIT_URL="https://github.com/$GIT_USER/first-project/commit/$LAST_COMMIT"
COMMIT_MSG="✅ Nouveau commit automatique : [$LAST_COMMIT]($COMMIT_URL) | Fichiers modifiés : $NUM_FILES"

curl -H "Content-Type: application/json" \
     -X POST \
     -d "{\"content\": \"$COMMIT_MSG\"}" \
     $DISCORD_WEBHOOK
