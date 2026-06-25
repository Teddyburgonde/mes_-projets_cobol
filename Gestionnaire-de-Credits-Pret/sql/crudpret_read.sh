#!/bin/bash
docker-compose exec prets_db psql -U prets_user -d prets_db -t -A -c "
SELECT pret_id, client_id, montant, taux_interet, duree_mois, mensualite, date_debut, statut
FROM prets
ORDER BY pret_id;
" | awk 'NF' > /tmp/crudpret_prets.txt