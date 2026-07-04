# Étape 1 : Construction du site statique avec Python
FROM python:3.14-slim AS builder

WORKDIR /app

# Copie et installation des dépendances nécessaires pour MkDocs
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copie de toute l'architecture (mkdocs.yml, docs/, libs/)
COPY . .

# Génération du site (génère les fichiers HTML/CSS/JS dans le dossier /app/site)
RUN mkdocs build

# Étape 2 : Serveur web de production ultra-léger
FROM nginx:alpine

# Récupération du site généré à l'étape précédente pour le mettre dans Nginx
COPY --from=builder /app/site /usr/share/nginx/html

# Exposition du port par défaut de Nginx
EXPOSE 80