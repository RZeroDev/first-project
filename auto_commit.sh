#!/bin/bash
# Script auto-commit qui crée des fichiers si inexistants et push automatiquement

cd /home/rzerodev/Documents/first-project || exit

# Charger les variables d'environnement
export $(grep -v '^#' .env | xargs)

# Configurer Git
git config --global user.name "$GIT_USER"
git config --global user.email "$GIT_EMAIL"

# IMPORTANT: Synchroniser AVANT de modifier les fichiers pour éviter les conflits
# Récupérer les dernières modifications depuis GitHub
git fetch "https://$GIT_USER:$GIT_TOKEN@$GIT_REPO" main

# Nettoyer le working directory (stash les modifications non commitées si nécessaire)
if ! git diff --quiet || ! git diff --cached --quiet; then
    echo "$(date): Modifications non commitées détectées, stash..."
    git stash push -m "Auto-stash avant auto-commit: $(date)" || true
fi

# Mettre à jour la branche locale avec rebase pour éviter les conflits
git pull --rebase "https://$GIT_USER:$GIT_TOKEN@$GIT_REPO" main || {
    echo "$(date): Erreur lors du pull, tentative de récupération..."
    git rebase --abort 2>/dev/null || true
    git reset --hard "origin/main" 2>/dev/null || true
    git pull --rebase "https://$GIT_USER:$GIT_TOKEN@$GIT_REPO" main || {
        echo "$(date): Échec du pull, abandon de cette exécution"
        exit 1
    }
}

# Restaurer les modifications stashées si elles existent
git stash pop 2>/dev/null || true

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

# Push vers GitHub avec token (avec retry en cas d'échec)
PUSH_ATTEMPTS=0
MAX_PUSH_ATTEMPTS=3
while [ $PUSH_ATTEMPTS -lt $MAX_PUSH_ATTEMPTS ]; do
    if git push "https://$GIT_USER:$GIT_TOKEN@$GIT_REPO" main; then
        echo "$(date): Push réussi"
        break
    else
        PUSH_ATTEMPTS=$((PUSH_ATTEMPTS + 1))
        echo "$(date): Échec du push (tentative $PUSH_ATTEMPTS/$MAX_PUSH_ATTEMPTS), pull et retry..."
        git pull --rebase "https://$GIT_USER:$GIT_TOKEN@$GIT_REPO" main || {
            echo "$(date): Échec du pull lors du retry"
            exit 1
        }
        if [ $PUSH_ATTEMPTS -eq $MAX_PUSH_ATTEMPTS ]; then
            echo "$(date): Échec du push après $MAX_PUSH_ATTEMPTS tentatives"
            exit 1
        fi
    fi
done

# --- Notification Discord ---
LAST_COMMIT=$(git rev-parse --short HEAD)
NUM_FILES=$(git diff-tree --no-commit-id --name-only -r HEAD | wc -l)
COMMIT_URL="https://github.com/$GIT_USER/first-project/commit/$LAST_COMMIT"
COMMIT_MSG="✅ Nouveau commit automatique : [$LAST_COMMIT]($COMMIT_URL) | Fichiers modifiés : $NUM_FILES"

curl -H "Content-Type: application/json" \
     -X POST \
     -d "{\"content\": \"$COMMIT_MSG\"}" \
     $DISCORD_WEBHOOK
