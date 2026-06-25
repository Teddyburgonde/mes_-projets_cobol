       IDENTIFICATION DIVISION.
       PROGRAM-ID. CRUDPRET.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT PRETS-FILE ASSIGN TO "/tmp/crudpret_prets.txt"
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT PRET-FILE ASSIGN TO "/tmp/crudpret_pret.txt"
               ORGANIZATION IS LINE SEQUENTIAL.

       DATA DIVISION.
       FILE SECTION.
       FD PRETS-FILE.
       01 PRETS-RECORD PIC X(500).

       FD PRET-FILE.
       01 PRET-RECORD PIC X(500).

       WORKING-STORAGE SECTION.
       01 WS-CHOIX          PIC 9 VALUE 9.

       01 WS-CLIENT-ID      PIC 9(9).
       01 WS-MONTANT        PIC X(20).
       01 WS-TAUX-INTERET   PIC X(10).
       01 WS-DUREE-MOIS     PIC X(10).
       01 WS-MENSUALITE     PIC X(20).
       01 WS-DATE-DEBUT     PIC X(10).
       01 WS-STATUT         PIC X(15).

       01 WS-COMMANDE       PIC X(500).
       01 WS-MESSAGE-ERREUR PIC X(50).
       01 WS-FIN-FICHIER    PIC X VALUE "N".
       01 WS-PRET-ID        PIC 9(9).

       PROCEDURE DIVISION.
           PERFORM UNTIL WS-CHOIX = 0
               DISPLAY " "
               DISPLAY "=== GESTION DES PRETS ==="
               DISPLAY "1. Creer"
               DISPLAY "2. Lister tous"
               DISPLAY "3. Chercher un pret"
               DISPLAY "4. Modifier"
               DISPLAY "5. Supprimer"
               DISPLAY "0. Retour"
               DISPLAY "Votre choix: " WITH NO ADVANCING
               ACCEPT WS-CHOIX

               EVALUATE WS-CHOIX
                   WHEN 1 PERFORM CREATE-PRET
                   WHEN 2 PERFORM READ-PRETS
                   WHEN 3 PERFORM READ-ONE-PRET
                   WHEN 4 PERFORM UPDATE-PRET
                   WHEN 5 PERFORM DELETE-PRET
                   WHEN 0 DISPLAY "Retour au menu principal"
                   WHEN OTHER DISPLAY "Choix invalide"
               END-EVALUATE
           END-PERFORM

           EXIT PROGRAM.

      *> ============================
      *>        FUNCTIONS
      *> ============================

      *> ============================
      *>        CREATE PRET
      *> ============================

       CREATE-PRET.
           DISPLAY "Client ID      : " WITH NO ADVANCING
           ACCEPT WS-CLIENT-ID.
           DISPLAY "Montant        : " WITH NO ADVANCING
           ACCEPT WS-MONTANT.
           DISPLAY "Taux interet   : " WITH NO ADVANCING
           ACCEPT WS-TAUX-INTERET.
           DISPLAY "Duree (mois)   : " WITH NO ADVANCING
           ACCEPT WS-DUREE-MOIS.
           DISPLAY "Mensualite     : " WITH NO ADVANCING
           ACCEPT WS-MENSUALITE.
           DISPLAY "Date debut     : " WITH NO ADVANCING
           ACCEPT WS-DATE-DEBUT.
           DISPLAY "Statut         : " WITH NO ADVANCING
           ACCEPT WS-STATUT.

           STRING "./sql/crudpret_create.sh "
               WS-CLIENT-ID " "
               '"' FUNCTION TRIM(WS-MONTANT)      '" '
               '"' FUNCTION TRIM(WS-TAUX-INTERET) '" '
               '"' FUNCTION TRIM(WS-DUREE-MOIS)   '" '
               '"' FUNCTION TRIM(WS-MENSUALITE)   '" '
               '"' FUNCTION TRIM(WS-DATE-DEBUT)   '" '
               '"' FUNCTION TRIM(WS-STATUT)       '"'
               DELIMITED BY SIZE
               INTO WS-COMMANDE
           END-STRING

           MOVE "Erreur : echec create pret" TO WS-MESSAGE-ERREUR
           CALL "SYSTEM" USING WS-COMMANDE
           PERFORM VERIFIER-RETOUR

           DISPLAY "Pret cree.".

      *> ============================
      *>        READ PRETS
      *> ============================

       READ-PRETS.
           MOVE "N" TO WS-FIN-FICHIER
           MOVE "./sql/crudpret_read.sh" TO WS-COMMANDE
           MOVE "Erreur : echec read prets" TO WS-MESSAGE-ERREUR
           CALL "SYSTEM" USING WS-COMMANDE
           PERFORM VERIFIER-RETOUR

           OPEN INPUT PRETS-FILE
           PERFORM UNTIL WS-FIN-FICHIER = "O"
               READ PRETS-FILE
                   AT END
                       MOVE "O" TO WS-FIN-FICHIER
                   NOT AT END
                       DISPLAY FUNCTION TRIM(PRETS-RECORD)
               END-READ
           END-PERFORM
           CLOSE PRETS-FILE.

      *> ============================
      *>        READ ONE PRET
      *> ============================

       READ-ONE-PRET.
           DISPLAY "Numero du pret : " WITH NO ADVANCING
           ACCEPT WS-PRET-ID

           STRING "./sql/crudpret_read_one.sh "
               WS-PRET-ID
               DELIMITED BY SIZE
               INTO WS-COMMANDE
           END-STRING
           MOVE "Erreur : echec read pret" TO WS-MESSAGE-ERREUR
           CALL "SYSTEM" USING WS-COMMANDE
           PERFORM VERIFIER-RETOUR

           OPEN INPUT PRET-FILE
           READ PRET-FILE
               AT END
                   DISPLAY "Pret introuvable"
               NOT AT END
                   DISPLAY FUNCTION TRIM(PRET-RECORD)
           END-READ
           CLOSE PRET-FILE.

      *> ============================
      *>        UPDATE PRET
      *> ============================

       UPDATE-PRET.
           DISPLAY "Numero pret    : " WITH NO ADVANCING
           ACCEPT WS-PRET-ID
           DISPLAY "Nouveau montant        : " WITH NO ADVANCING
           ACCEPT WS-MONTANT.
           DISPLAY "Nouveau taux interet   : " WITH NO ADVANCING
           ACCEPT WS-TAUX-INTERET.
           DISPLAY "Nouvelle duree (mois)  : " WITH NO ADVANCING
           ACCEPT WS-DUREE-MOIS.
           DISPLAY "Nouvelle mensualite    : " WITH NO ADVANCING
           ACCEPT WS-MENSUALITE.
           DISPLAY "Nouvelle date debut    : " WITH NO ADVANCING
           ACCEPT WS-DATE-DEBUT.
           DISPLAY "Nouveau statut         : " WITH NO ADVANCING
           ACCEPT WS-STATUT.

           STRING "./sql/crudpret_update.sh "
               WS-PRET-ID " "
               '"' FUNCTION TRIM(WS-MONTANT)      '" '
               '"' FUNCTION TRIM(WS-TAUX-INTERET) '" '
               '"' FUNCTION TRIM(WS-DUREE-MOIS)   '" '
               '"' FUNCTION TRIM(WS-MENSUALITE)   '" '
               '"' FUNCTION TRIM(WS-DATE-DEBUT)   '" '
               '"' FUNCTION TRIM(WS-STATUT)       '"'
               DELIMITED BY SIZE
               INTO WS-COMMANDE
           END-STRING

           MOVE "Erreur : echec update pret" TO WS-MESSAGE-ERREUR
           CALL "SYSTEM" USING WS-COMMANDE
           PERFORM VERIFIER-RETOUR

           DISPLAY "Pret modifie.".

      *> ============================
      *>        DELETE PRET
      *> ============================

       DELETE-PRET.
           DISPLAY "Numero pret    : " WITH NO ADVANCING
           ACCEPT WS-PRET-ID

           STRING "./sql/crudpret_delete.sh "
               WS-PRET-ID
               DELIMITED BY SIZE
               INTO WS-COMMANDE
           END-STRING

           MOVE "Erreur : echec delete pret" TO WS-MESSAGE-ERREUR
           CALL "SYSTEM" USING WS-COMMANDE
           PERFORM VERIFIER-RETOUR

           DISPLAY "Pret supprime.".

      *> ============================
      *>        GESTION DES ERREURS
      *> ============================

       VERIFIER-RETOUR.
           IF RETURN-CODE NOT = 0
               DISPLAY FUNCTION TRIM(WS-MESSAGE-ERREUR)
               EXIT PROGRAM
           END-IF.
