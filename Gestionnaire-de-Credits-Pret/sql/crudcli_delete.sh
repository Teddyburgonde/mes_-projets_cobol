#!/bin/bash
docker-compose exec prets_db psql -U prets_user -d prets_db -t -A -c "
DELETE FROM clients WHERE client_id=$1"
