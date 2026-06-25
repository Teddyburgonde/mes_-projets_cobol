#!/bin/bash

# Liste de tous les prets pour le module EDITRAPP (etape 2).
# Une ligne par pret, colonnes separees par "|" (option -A de psql) :
#   pret_id | nom | prenom | montant | taux_interet
# Le COBOL lira ce fichier et separera les colonnes avec UNSTRING.

docker-compose exec prets_db psql -U prets_user -d prets_db -t -A -c "
SELECT p.pret_id, c.nom, c.prenom, p.montant, p.taux_interet
FROM prets p
JOIN clients c ON c.client_id = p.client_id
ORDER BY p.pret_id;

" | awk 'NF' > /tmp/editrapp_prets.txt # Enlève les lignes vides du résultat