# Utilise une image Linux avec Git, curl et cron
FROM ubuntu:22.04

# Installer dépendances : git, curl, cron
RUN apt-get update && apt-get install -y \
    git curl cron bash \
    && rm -rf /var/lib/apt/lists/*

# Créer un dossier de travail
WORKDIR /app

# Copier ton script dans le conteneur
COPY auto_commit.sh /app/auto_commit.sh

# Rendre exécutable le script
RUN chmod +x /app/auto_commit.sh

# Ajouter la tâche cron (toutes les 30 minutes ici)
RUN echo "*/30 * * * * /app/auto_commit.sh >> /var/log/cron.log 2>&1" > /etc/cron.d/autocommit

# Appliquer les permissions et activer cron
RUN chmod 0644 /etc/cron.d/autocommit && \
    crontab /etc/cron.d/autocommit

# Lancer cron en foreground (important pour Docker)
CMD ["cron", "-f"]
