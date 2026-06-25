#!/bin/bash
set -e

# Conteneur/credentials reels (cf docker-compose.yml a la racine).
CONTAINER="gestionnaire-de-credits-pret-prets_db-1"
DB_USER="prets_user"
DB_NAME="prets_db"

# Demarre PostgreSQL (compose racine, service prets_db).
docker-compose up -d
sleep 5

# (Re)cree les tables puis charge les donnees de test.
# schema.sql fait DROP + CREATE -> pas de doublons si on relance.
docker exec -i "$CONTAINER" psql -U "$DB_USER" -d "$DB_NAME" < sql/schema.sql
docker exec -i "$CONTAINER" psql -U "$DB_USER" -d "$DB_NAME" < sql/seed.sql

echo "✅ Base initialisée !"
