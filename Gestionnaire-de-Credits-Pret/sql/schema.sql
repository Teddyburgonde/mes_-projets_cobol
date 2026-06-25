-- Clients -- 
DROP TABLE IF EXISTS clients CASCADE;
CREATE TABLE clients (
	client_id SERIAL PRIMARY KEY,
	nom varchar(255) NOT NULL,
	prenom varchar(255) NOT NULL,
	date_naissance DATE NOT NULL,
	adresse varchar(255),
	telephone varchar(20),
	email varchar(255),
	date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Pret --
DROP TABLE IF EXISTS prets CASCADE;
CREATE TABLE prets (
	pret_id SERIAL PRIMARY KEY,
	client_id INTEGER REFERENCES clients(client_id) ON DELETE CASCADE,
	montant NUMERIC(12, 2) NOT NULL,
	taux_interet NUMERIC(5, 2) NOT NULL,
	duree_mois INTEGER NOT NULL,
	mensualite NUMERIC(10, 2) NOT NULL,
	date_debut DATE NOT NULL,
	statut varchar(15) DEFAULT 'ACTIF',
	date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Echeances --
DROP TABLE IF EXISTS echeances CASCADE;
CREATE TABLE echeances (
	echeance_id SERIAL PRIMARY KEY,
	pret_id INTEGER REFERENCES prets(pret_id) ON DELETE CASCADE,
	numero_mois INTEGER NOT NULL,
	date_echeance DATE NOT NULL,
	montant_principal NUMERIC (12, 2) NOT NULL,
	montant_interet NUMERIC(10, 2) NOT NULL,
	montant_total NUMERIC (12, 2) NOT NULL,
	capital_restant NUMERIC (12, 2) NOT NULL,
	statut varchar(15) DEFAULT 'A_PAYER'
);

-- Paiements --
DROP TABLE IF EXISTS paiements CASCADE;
CREATE TABLE paiements (
	paiement_id SERIAL PRIMARY KEY,
	echeance_id INTEGER REFERENCES echeances(echeance_id) ON DELETE CASCADE,
	montant_paye NUMERIC (10, 2) NOT NULL,
	date_paiement DATE NOT NULL,
	jours_retard INTEGER DEFAULT 0,
	penalite NUMERIC (10, 2) DEFAULT 0,
	date_enregistrement TIMESTAMP DEFAULT CURRENT_TIMESTAMP

);

-- Eviter les index déjà existants
DROP INDEX IF EXISTS idx_prets_client;
DROP INDEX IF EXISTS idx_echeances_pret;
DROP INDEX IF EXISTS idx_paiements_echeance;

-- Index pour optimiser les requêtes fréquentes
CREATE INDEX idx_prets_client ON prets(client_id);
CREATE INDEX idx_echeances_pret ON echeances(pret_id);
CREATE INDEX idx_paiements_echeance ON paiements(echeance_id);