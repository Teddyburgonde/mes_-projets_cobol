#!/bin/bash

# Tableau d'amortissement d'UN pret (etape 4) pour le module EDITRAPP.
# Plusieurs colonnes par ligne, separees par "|" (option -A de psql) :
#   numero_mois | date | principal | interet | capital_restant | statut
# Une ligne par echeance, triees par numero de mois.

docker-compose exec prets_db psql -U prets_user -d prets_db -t -A -c "
SELECT numero_mois, date_echeance, montant_principal,
       montant_interet, capital_restant, statut
FROM echeances
WHERE pret_id = $1
ORDER BY numero_mois;
" | awk 'NF' > /tmp/editrapp_amortissement.txt
