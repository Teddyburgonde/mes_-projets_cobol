#!/bin/bash

docker-compose exec prets_db psql -U prets_user -d prets_db -t -A -c "
SELECT client_id, nom, prenom, date_naissance, adresse, telephone, email
FROM clients
ORDER BY client_id;
" | awk 'NF' > /tmp/crudcli_clients.txt