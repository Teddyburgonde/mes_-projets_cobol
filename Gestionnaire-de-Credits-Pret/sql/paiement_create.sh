#!/bin/bash
docker-compose exec prets_db psql -U prets_user -d prets_db -t -A -c "
INSERT INTO paiements(echeance_id, montant_paye, date_paiement, jours_retard, penalite)
VALUES ($1, $2, '$3', $4, $5);
"