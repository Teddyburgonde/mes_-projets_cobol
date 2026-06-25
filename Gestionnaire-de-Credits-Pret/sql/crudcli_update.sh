#!/bin/bash
docker-compose exec prets_db psql -U prets_user -d prets_db -t -A -c "
UPDATE clients SET nom='$2', prenom='$3', date_naissance='$4', adresse='$5', telephone='$6', email='$7'
WHERE client_id=$1;
"