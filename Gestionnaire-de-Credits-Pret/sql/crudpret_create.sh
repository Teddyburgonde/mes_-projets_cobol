#!/bin/bash

docker-compose exec prets_db psql -U prets_user -d prets_db -t -A -c "
INSERT INTO prets(client_id, montant, taux_interet, duree_mois, mensualite, date_debut, statut)
VALUES ($1, $2, $3, $4, $5, '$6', '$7');
"