#!/bin/bash
docker-compose exec prets_db psql -U prets_user -d prets_db -t -A -c "
UPDATE prets SET montant=$2, taux_interet=$3, duree_mois=$4, mensualite=$5, date_debut='$6', statut='$7'
WHERE pret_id=$1;
"
