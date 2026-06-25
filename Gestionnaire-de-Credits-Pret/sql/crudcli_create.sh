#!/bin/bash

docker-compose exec prets_db psql -U prets_user -d prets_db -t -A -c "
INSERT INTO clients(nom, prenom, date_naissance, adresse, telephone, email)
VALUES ('$1', '$2', '$3', '$4', '$5', '$6');"