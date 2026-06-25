#!/bin/bash

docker-compose exec prets_db psql -U prets_user -d prets_db -t -A -c "
SELECT paiement_id, echeance_id, montant_paye, date_paiement, jours_retard, penalite
FROM paiements
ORDER BY paiement_id;
" | awk 'NF' > /tmp/paiement_paiements.txt
