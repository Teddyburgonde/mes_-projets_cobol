#!/bin/bash

# Detail d'UN seul pret (etape 3) pour le module EDITRAPP.
# 1 valeur par ligne (pas de "|") -> pattern STATS, lecture champ par champ.
# Ordre des lignes : montant, taux, duree, mensualite, date_debut, statut

docker-compose exec prets_db psql -U prets_user -d prets_db -t -A -c "
SELECT montant FROM prets WHERE pret_id = $1;
SELECT taux_interet FROM prets WHERE pret_id = $1;
SELECT duree_mois FROM prets WHERE pret_id = $1;
SELECT mensualite FROM prets WHERE pret_id = $1;
SELECT date_debut FROM prets WHERE pret_id = $1;
SELECT statut FROM prets WHERE pret_id = $1;
" | awk 'NF' > /tmp/editrapp_detail.txt
