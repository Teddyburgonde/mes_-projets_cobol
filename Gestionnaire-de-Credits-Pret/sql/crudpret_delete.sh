#!/bin/bash
docker-compose exec prets_db psql -U prets_user -d prets_db -t -A -c "
DELETE FROM prets WHERE pret_id=$1;
"