#!/bin/bash

docker-compose exec prets_db psql -U prets_user -d prets_db -t -A -c "
SELECT client_id, nom, prenom, date_naissance, adresse, telephone, email
FROM clients
WHERE client_id = $1;
" | awk 'NF' > /tmp/crudcli_client.txt