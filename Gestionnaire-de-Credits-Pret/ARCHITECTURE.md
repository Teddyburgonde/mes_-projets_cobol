# ARCHITECTURE - Gestionnaire de Crédits/Prêts

Décisions architecturales, patterns COBOL, et justifications.

---

## 🎯 Philosophie générale

**Code pour 20 ans, pas 2 semaines.**

- ✅ Mainframe-ready : standards COBOL strict, RETURN-CODE partout
- ✅ Debugging facile : logging systématique, messages clairs
- ✅ Maintenance : noms explicites, pas de magic numbers
- ✅ Robustesse : gestion d'erreurs exhaustive, edge cases couverts

---

## 🏛️ Architecture globale

### Couches

```
┌────────────────────────────┐
│   MENU Principal           │  Point d'entrée unique
│   (PERFORM UNTIL = 0)      │
└────────────────────────────┘
           │
    ┌──────┴──────────┬──────────────┐
    │                 │              │
┌───▼────┐    ┌────────▼──┐   ┌──────▼────┐
│ CRUD   │    │ Calcul    │   │ Rapports  │
│ (7 mod)│    │ Financier │   │  (2 mod)  │
└───┬────┘    └────┬──────┘   └──┬───────┘
    │              │             │
    └──────────────┼─────────────┘
                   │
         ┌─────────▼─────────┐
         │ CALL "SYSTEM"     │  (Bash script)
         └─────────┬─────────┘
                   │
         ┌─────────▼─────────┐
         │   PostgreSQL 15   │  (Docker)
         │  (Persistance)    │
         └───────────────────┘
```

### Décision : Pas d'EXEC SQL

**Pourquoi :**
- Pas de précompilateur (`EXEC SQL` demande DB2, GnuCOBOL limité)
- Plus de contrôle : SQL assemblé en texte par COBOL
- Flexible : changements schema sans recompile COBOL
- Debugging : vérifie la commande SQL générée

**Comment :**
1. COBOL accepte champs → STRING assemble requête SQL
2. Script bash reçoit la requête
3. `psql` l'exécute dans PostgreSQL
4. Résultat écrit dans `/tmp/xxx.txt` (lectures) ou confirmé (écritures)
5. COBOL vérifie RETURN-CODE

**Exemple READ :**
```cobol
STRING "./sql/crudcli_read.sh"
    INTO WS-COMMANDE
END-STRING
CALL "SYSTEM" USING WS-COMMANDE
OPEN INPUT CLIENTS-FILE
PERFORM UNTIL WS-FIN-FICHIER = "O"
    READ CLIENTS-FILE
        AT END MOVE "O" TO WS-FIN-FICHIER
        NOT AT END DISPLAY CLIENTS-RECORD
    END-READ
END-PERFORM
CLOSE CLIENTS-FILE
```

---

## 🎮 Pattern CRUD (7 modules)

Tous les modules CRUD suivent le même pattern : **sous-menu interne + 5 opérations**.

### Structure standard

```cobol
PROCEDURE DIVISION.
    PERFORM UNTIL WS-CHOIX = 0
        DISPLAY " "
        DISPLAY "=== MENU ==="
        DISPLAY "1. Créer"
        DISPLAY "2. Lister tous"
        DISPLAY "3. Chercher un"
        DISPLAY "4. Modifier"
        DISPLAY "5. Supprimer"
        DISPLAY "0. Retour"
        ACCEPT WS-CHOIX
        
        EVALUATE WS-CHOIX
            WHEN 1 PERFORM CREATE
            WHEN 2 PERFORM READ-ALL
            WHEN 3 PERFORM READ-ONE
            WHEN 4 PERFORM UPDATE
            WHEN 5 PERFORM DELETE
            WHEN 0 DISPLAY "Retour"
            WHEN OTHER DISPLAY "Invalide"
        END-EVALUATE
    END-PERFORM
    EXIT PROGRAM.
```

### Piège classique : initialisation CHOIX

❌ **MAUVAIS** :
```cobol
01 WS-CHOIX PIC 9.    ← Valeur par défaut = 0
PERFORM UNTIL WS-CHOIX = 0  ← Boucle ne tourne JAMAIS
```

✅ **BON** :
```cobol
01 WS-CHOIX PIC 9 VALUE 9.  ← Initialiser à ≠ 0
PERFORM UNTIL WS-CHOIX = 0  ← Boucle tourne au moins une fois
```

### CREATE (INSERT)

```cobol
CREATE-CLIENT.
    DISPLAY "Nom : " WITH NO ADVANCING
    ACCEPT WS-NOM.
    DISPLAY "Prenom : " WITH NO ADVANCING
    ACCEPT WS-PRENOM.
    
    STRING "./sql/crudcli_create.sh "
        '"' FUNCTION TRIM(WS-NOM) '" '
        '"' FUNCTION TRIM(WS-PRENOM) '" '
        DELIMITED BY SIZE
        INTO WS-COMMANDE
    END-STRING
    
    MOVE "Erreur : echec create" TO WS-MESSAGE-ERREUR
    CALL "SYSTEM" USING WS-COMMANDE
    PERFORM VERIFIER-RETOUR
    
    DISPLAY "Client cree.".
```

**Détails** :
- `FUNCTION TRIM` enlève le bourrage des PIC X(255)
- Guillemets Bash autour des valeurs (gère les espaces)
- Pas de guillemets autour des numériques
- Guillemets SQL à l'intérieur du script bash

### READ-ALL (SELECT tous)

```cobol
READ-ALL.
    MOVE "N" TO WS-FIN-FICHIER    ← Drapeau = non fini
    MOVE "./sql/crudcli_read.sh" TO WS-COMMANDE
    CALL "SYSTEM" USING WS-COMMANDE
    PERFORM VERIFIER-RETOUR
    
    OPEN INPUT CLIENTS-FILE
    PERFORM UNTIL WS-FIN-FICHIER = "O"
        READ CLIENTS-FILE
            AT END
                MOVE "O" TO WS-FIN-FICHIER
            NOT AT END
                DISPLAY FUNCTION TRIM(CLIENTS-RECORD)
        END-READ
    END-PERFORM
    CLOSE CLIENTS-FILE.
```

**Pourquoi le drapeau ?**
- `READ` sans drapeau → status 10 si EOF (comportement indéfini)
- Avec drapeau → boucle gracieuse, pas d'exception

### READ-ONE (SELECT WHERE id = $1)

```cobol
READ-ONE.
    DISPLAY "Numero : " WITH NO ADVANCING
    ACCEPT WS-CLIENT-ID
    
    STRING "./sql/crudcli_read_one.sh "
        WS-CLIENT-ID
        DELIMITED BY SIZE
        INTO WS-COMMANDE
    END-STRING
    
    CALL "SYSTEM" USING WS-COMMANDE
    PERFORM VERIFIER-RETOUR
    
    OPEN INPUT CLIENT-FILE
    READ CLIENT-FILE
        AT END
            DISPLAY "Client introuvable"
        NOT AT END
            DISPLAY FUNCTION TRIM(CLIENT-RECORD)
    END-READ
    CLOSE CLIENT-FILE.
```

**Différence avec READ-ALL** :
- Pas de drapeau (une seule lecture attendue)
- AT END = "introuvable" (cas normal)

### UPDATE et DELETE

Identiques à CREATE (pas de `/tmp`, juste RETURN-CODE).

```cobol
UPDATE.
    ACCEPT WS-CLIENT-ID
    ACCEPT WS-NOM
    STRING "./sql/crudcli_update.sh "
        WS-CLIENT-ID " "
        '"' FUNCTION TRIM(WS-NOM) '" '
        INTO WS-COMMANDE
    END-STRING
    CALL "SYSTEM" USING WS-COMMANDE
    PERFORM VERIFIER-RETOUR
    DISPLAY "Client modifie.".
```

---

## 🛡️ Gestion d'erreurs

### VERIFIER-RETOUR (systématique)

```cobol
VERIFIER-RETOUR.
    IF RETURN-CODE NOT = 0
        DISPLAY FUNCTION TRIM(WS-MESSAGE-ERREUR)
        EXIT PROGRAM
    END-IF.
```

**Pattern appliqué** :
- Après **chaque** `CALL "SYSTEM"`
- Message d'erreur préparé avant l'appel
- EXIT PROGRAM (sort du module, retour au MENU)

### Logging

Tous les messages affichés (tracés) :
- ✅ "Client cree."
- ✅ "Client modifie."
- ✅ "Erreur : echec create" (si RETURN-CODE != 0)
- ✅ "Client introuvable" (cas normal du READ)

---

## 📊 Modules spécialisés

### SIMUPRET + CALCAMOR (Calcul financier)

```cobol
CALCULER-AMORTISSEMENT.
    ACCEPT WS-MONTANT, WS-TAUX, WS-DUREE
    
    COMPUTE WS-TAUX-MENSUEL = WS-TAUX / 12 / 100
    COMPUTE WS-COEFF = (1 + WS-TAUX-MENSUEL) ** WS-DUREE
    COMPUTE WS-MENSUALITE = 
        WS-MONTANT * WS-TAUX-MENSUEL * WS-COEFF
        / (WS-COEFF - 1)
    
    DISPLAY "Mensualite : " WS-MENSUALITE.
```

**Justification** :
- Formule actuarielle standard (pas de magic numbers)
- COMPUTE avec parenthèses explicites (lisibilité)
- Calculs en décimal (PIC 9(10)V99) pour précision

### EDITRAPP (Rapports)

Deux fichiers `/tmp` :
1. `editrapp_prets.txt` → liste des prêts (JOIN clients)
2. `editrapp_detail.txt` → une valeur par ligne (montant, taux, duree, etc.)
3. `editrapp_amortissement.txt` → échéancier (mois|date|principal|interet|reste|statut)

```cobol
AFFICHER-AMORTISSEMENT.
    DISPLAY "Mois | Date | Principal | Interet | Reste | Statut"
    OPEN INPUT AMOR-FILE
    PERFORM UNTIL WS-FIN = "O"
        READ AMOR-FILE
            AT END MOVE "O" TO WS-FIN
            NOT AT END
                UNSTRING RECORD DELIMITED BY '|'
                    INTO WS-MOIS WS-DATE WS-PRINCIPAL ...
                DISPLAY WS-MOIS WS-DATE ...
        END-READ
    END-PERFORM
    CLOSE AMOR-FILE.
```

**UNSTRING** : sépare les colonnes délimitées par `|`.

### PENALITE (Calcul pénalité)

```cobol
CALCULER-PENALITE.
    ACCEPT WS-JOURS-RETARD, WS-MONTANT-PAYE
    
    COMPUTE WS-TAUX-JOUR = 0.001    ← 0.1% par jour
    COMPUTE WS-PENALITE = 
        WS-MONTANT-PAYE * WS-TAUX-JOUR * WS-JOURS-RETARD.
    
    DISPLAY "Penalite : " WS-PENALITE.
```

### STATS (Agrégation)

Via PostgreSQL (SELECT COUNT, SUM) → affichage en COBOL.

```cobol
STATS.
    MOVE "./sql/stats.sh" TO WS-COMMANDE
    CALL "SYSTEM" USING WS-COMMANDE
    
    OPEN INPUT STATS-FILE
    READ STATS-FILE NOT AT END
        UNSTRING RECORD DELIMITED BY '|'
            INTO WS-NB-CLIENTS WS-NB-PRETS WS-MONTANT-TOTAL
    END-READ
    CLOSE STATS-FILE
    
    DISPLAY "Clients : " WS-NB-CLIENTS
    DISPLAY "Prets : " WS-NB-PRETS
    DISPLAY "Total : " WS-MONTANT-TOTAL " EUR".
```

---

## 📋 Conventions COBOL

### Nommage

| Type | Convention | Exemple |
|------|-----------|---------|
| Variables | KEBAB-CASE | `CLIENT-ID`, `MONTANT-PAYE` |
| Paragraphes | VERBE-NOM | `CALCULER-AMORTISSEMENT`, `VERIFIER-RETOUR` |
| Fichiers | -FILE suffix | `CLIENTS-FILE`, `PAIEMENT-FILE` |
| Drapeaux | descriptif | `WS-FIN-FICHIER`, `WS-PRET-TROUVE` |

### Structure obligatoire

```cobol
IDENTIFICATION DIVISION.
    PROGRAM-ID. [NOM].

ENVIRONMENT DIVISION.
    FILE-CONTROL.
        SELECT [FILE] ASSIGN TO "[path]"...

DATA DIVISION.
    FILE SECTION.
        FD [FILE].
        01 [RECORD]...
    
    WORKING-STORAGE SECTION.
        01 WS-[VAR]...

PROCEDURE DIVISION.
    PERFORM [INIT]
    PERFORM [MAIN]
    PERFORM [CLEANUP]
    STOP RUN.
```

### Pas de magic numbers

❌ **MAUVAIS** :
```cobol
COMPUTE WS-MENSUALITE = WS-MONTANT * 0.00427
```

✅ **BON** :
```cobol
01 TAUX-MENSUEL PIC 9V99999 VALUE 0.00427.
COMPUTE WS-MENSUALITE = WS-MONTANT * TAUX-MENSUEL.
```

---

## 🔗 Flux de données

### Écriture (CREATE)

```
COBOL (ACCEPT)
  ↓
COBOL (STRING assemble commande)
  ↓
CALL "SYSTEM" (exécute script bash)
  ↓
Script bash (construit requête SQL)
  ↓
psql (INSERT INTO)
  ↓
PostgreSQL (sauvegarde)
  ↓
RETURN-CODE (0 = OK, != 0 = erreur)
  ↓
COBOL (PERFORM VERIFIER-RETOUR)
```

### Lecture (READ)

```
COBOL (STRING assemble commande)
  ↓
CALL "SYSTEM"
  ↓
Script bash (SELECT)
  ↓
psql (résultat)
  ↓
Redirect > /tmp/xxx.txt
  ↓
COBOL (OPEN INPUT, READ loop)
  ↓
DISPLAY (affiche lignes)
```

---

## 🧪 Testing strategy

### Cas de test systématiques

1. **Happy path** : CREATE → READ → UPDATE → DELETE
2. **Edge cases** :
   - Valeur zéro (montant = 0)
   - Données max (nom 255 chars)
   - Caractères spéciaux (apostrophes, espaces)
   - Recordintrouvable (READ WHERE id = 999)
3. **Error cases** :
   - RETURN-CODE != 0 simulé
   - Fichier manquant
   - Connexion DB échouée

### Reproduction locale

```bash
make clean              # Réinitialise la base
./MENU                  # Lance l'app
```

---

## 📈 Scalabilité et maintenance

### Limites actuelles

- Max 255 chars par champ texte (limite COBOL)
- Une seule instance MENU (pas multi-user)
- Fichiers `/tmp` non thread-safe (batch-only)

### Évolutions futures

- Paramètres de longueur configurables
- Multiplexage requêtes (queue FIFO)
- Stockage résultats en base (pas `/tmp`)

---

## 🎓 Décisions justifiées

| Décision | Avantage | Tradeoff |
|----------|----------|----------|
| Pas EXEC SQL | Flexible, pas dépendance compiler | Assemblage SQL manuel |
| Sous-menus internes | UX claire, code réutilisable | Plus de COBOL par module |
| `/tmp` pour lectures | Simple, debugging facile | Pas thread-safe |
| RETURN-CODE partout | Sécurité, erreurs détectées | Verbeux |
| Drapeau fin fichier | Évite status 10 | Code plus long |

---

**Voir aussi :** [README.md](README.md) pour mode d'emploi.
