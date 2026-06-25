# Gestionnaire de Crédits/Prêts

**Application COBOL + PostgreSQL pour la gestion complète des prêts bancaires.**

Démonstration de conception logicielle : CRUD robustes, gestion d'erreurs systématique, patterns COBOL production-grade.

---

## 🎯 Fonctionnalités

| Module | Description |
|--------|-------------|
| **Simulation de prêt** | Calcul amortissement, taux, mensualités |
| **Gestion des clients** | CRUD complet (créer, lire, modifier, supprimer) |
| **Gestion des prêts** | CRUD complet sur la table prets |
| **Enregistrer paiement** | Enregistrement paiements clients + historique |
| **Pénalité de retard** | Calcul automatique des pénalités (jours + montant) |
| **Édition des rapports** | Détail prêt + tableau d'amortissement formaté |
| **Statistiques** | Totaux clients, prêts, paiements, soldes |

---

## 🏗️ Architecture

```
┌─────────────────────────────────────┐
│        MENU PRINCIPAL (COBOL)       │  8 choix navigables
└────────────────────────────────────┬┘
                 │
        ┌────────┼────────┐
        │        │        │
    ┌─CRUDCLI  CRUDPRET  PAIEMENT
    │   │        │        │
    │   └─────┬──┴───┬────┘
    │         │      │
┌───▼──────────▼──────▼──────┐
│   CALL "SYSTEM"            │
│   (Bash scripts via /tmp)   │
└────────────────────────────┘
          │
    ┌─────▼─────┐
    │   PostgreSQL 15
    │   (Docker)
    └───────────┘
```

**Pattern : Pas d'EXEC SQL**
- COBOL assemble les commandes SQL en texte
- Script bash (sql/*.sh) exécute via `psql`
- Lectures : résultat écrit dans `/tmp`, COBOL lit séquentiellement
- Écritures : INSERT/UPDATE/DELETE via script, RETURN-CODE vérifié

---

## 📊 Schéma des tables

```sql
clients (id, nom, prenom, date_naissance, adresse, telephone, email)
prets (id, client_id, montant, taux_interet, duree_mois, mensualite, date_debut, statut)
echeances (id, pret_id, numero_mois, date, principal, interet, total, capital_restant, statut)
paiements (id, echeance_id, montant_paye, date_paiement, jours_retard, penalite)
```

---

## 🚀 Démarrage

### Prérequis
- GnuCOBOL
- Docker + Docker Compose
- Bash

### Installation et lancement

```bash
# Clone et installe la base de données + compile tout
make

# Lance l'application
./MENU

# Quitter
make stop
```

### Structure du projet

```
.
├── src/
│   ├── programmes/          # Modules COBOL (.cob)
│   │   ├── MENU.cob
│   │   ├── SIMUPRET.cob
│   │   ├── CRUDCLI.cob
│   │   ├── CRUDPRET.cob
│   │   ├── PAIEMENT.cob
│   │   ├── PENALITE.cob
│   │   ├── STATS.cob
│   │   ├── EDITRAPP.cob
│   │   └── CALCAMOR.cob
│   └── copybooks/           # Includes COBOL (réutilisables)
├── sql/
│   ├── schema.sql           # Schéma PostgreSQL
│   ├── seed.sql             # Données de départ
│   └── *.sh                 # Scripts shell (CREATE, READ, UPDATE, DELETE)
├── Makefile
├── docker-compose.yml
└── README.md
```

---

## 💡 Approche technique

### Error Handling systématique

Chaque opération CALL "SYSTEM" est suivi d'un :
```cobol
PERFORM VERIFIER-RETOUR
IF RETURN-CODE NOT = 0
    DISPLAY "Message erreur"
    EXIT PROGRAM
END-IF
```

### Sous-menus internes

Chaque module CRUD implémente son propre sous-menu :
```cobol
PERFORM UNTIL WS-CHOIX = 0
    DISPLAY "Menu..."
    EVALUATE WS-CHOIX
        WHEN 1 PERFORM CREATE
        WHEN 2 PERFORM READ
        WHEN 0 DISPLAY "Retour"
    END-EVALUATE
END-PERFORM
```

### Conventions COBOL (mainframe-ready)

- **Nommage** : KEBAB-CASE explicite (`CLIENT-ID`, `MONTANT-PAYE`)
- **Paragraphes** : VERBE-NOM (`CALCULER-AMORTISSEMENT`, `VERIFIER-RETOUR`)
- **Logging** : tous les messages affichés (traçabilité)
- **Copie conditionnelle** : pas de magic numbers, champs nommés

---

## 🧪 Tests manuels

### 1. Simuler un prêt
```
Choix 1 → entrer montant 50000, taux 3.5, durée 240 mois
→ calcule mensualité (354.89)
```

### 2. Créer un client et un prêt
```
Choix 2 → créer client
Choix 7 → créer prêt associé
```

### 3. Enregistrer un paiement
```
Choix 4 → enregistrer montant 100 pour échéance 1
Choix 4 → choix 2 → voir tous les paiements
```

### 4. Voir un rapport
```
Choix 6 → choisir prêt 1
→ détail (montant, taux, durée, statut)
→ tableau d'amortissement (mois, date, principal, intérêt, capital restant)
```

---

## 📈 Données de test

**Seed initial (3 clients, 3 prêts) :**
- Client 1 : 50k€ @ 3.5% / 240 mois (354.89 €/mois)
- Client 2 : 100k€ @ 4.0% / 180 mois (739.69 €/mois)
- Client 3 : 75k€ @ 3.75% / 200 mois (445.13 €/mois)

**Écheances et paiements** : échéancier complet, 2 paiements enregistrés, calcul pénalités.

---

## 🔧 Commandes utiles

```bash
# Compiler seul module
cobc -I src/copybooks -x src/programmes/MONMODULE.cob -o /tmp/MONMODULE

# Vérifier base de données
docker exec gestionnaire-de-credits-pret-prets_db-1 psql -U prets_user -d prets_db \
  -c "SELECT * FROM clients;"

# Réinitialiser la base
make stop
make

# Arrêter sans réinitialiser
docker-compose down    # (sans -v pour garder les données)
```

---

## 📋 Standards appliqués

✅ **RETURN-CODE** vérifié partout (sécurité)  
✅ **Gestion d'erreurs** systématique (EXIT PROGRAM sur erreur)  
✅ **Logging explicite** (tous les messages affichés)  
✅ **TRIM, UNSTRING** pour données robustes  
✅ **Drapeau de fin fichier** (WS-FIN-FICHIER) pour boucles sûres  
✅ **Pas de variables globales** inutiles (scope clair)  

---

## 🎓 Lessons learned

1. **Pas d'EXEC SQL** = plus de contrôle, pas de précompilateur
2. **Scripts bash** comme intermédiaires = flexibilité (ajout colonnes, triggers)
3. **Sous-menus internes** = meilleure UX que ligne de commande
4. **PERFORM UNTIL = 0** = piège : initialiser VALUE ≠ 0
5. **Docker + PostgreSQL** = reproduction identique en production

---

## 📄 Licence

Projet éducatif. Code libre d'usage.

---

**Voir aussi :** [ARCHITECTURE.md](ARCHITECTURE.md) pour détails techniques.
