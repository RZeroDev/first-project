#!/bin/bash
# Script auto-commit avec notification Discord

cd /home/rzerodev/Documents/first-project || exit

# Ajouter la date au fichier daily.log
echo "$(date)" >> daily.log

# Commit et push
git add .
git commit -m "Daily commit: $(date)"
git push origin main

# --- Notification Discord ---
WEBHOOK_URL="https://discordapp.com/api/webhooks/1423508911402516492/Ya1KbW9u9WrTyMUsgoP4Y_erecGlpa8m7DpOHEkuDQOBsjlmvl0BXpAWU8x2fV8AeBoY"

# Message à envoyer
COMMIT_MSG="✅ Nouveau commit automatique sur First-projects : $(date)"

# Envoi du message avec curl
curl -H "Content-Type: application/json" \
     -X POST \
     -d "{\"content\": \"$COMMIT_MSG\"}" \
     $WEBHOOK_URL
