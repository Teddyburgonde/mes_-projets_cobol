#!/bin/bash

docker-compose exec prets_db psql -U prets_user -d prets_db -t -A -c "
SELECT COUNT(*) FROM prets;
SELECT SUM(montant) FROM prets;
SELECT SUM(capital_restant) FROM echeances WHERE statut = 'A_PAYER';
SELECT AVG(taux_interet) FROM prets;
SELECT AVG(montant) FROM prets;
" | awk 'NF' > /tmp/stats_results.txt