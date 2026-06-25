       IDENTIFICATION DIVISION.
       PROGRAM-ID. PAIEMENT.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT PAIEMENTS-FILE ASSIGN TO "/tmp/paiement_paiements.txt"
               ORGANIZATION IS LINE SEQUENTIAL.

       DATA DIVISION.
       FILE SECTION.
       FD PAIEMENTS-FILE.
       01 PAIEMENTS-RECORD PIC X(500).


       WORKING-STORAGE SECTION.
       01 WS-CHOIX          PIC 9 VALUE 9.

       01 WS-ECHEANCE-ID    PIC 9(9).
       01 WS-MONTANT-PAYE   PIC X(20).
       01 WS-DATE-PAIEMENT  PIC X(10).
       01 WS-JOURS-RETARD   PIC X(5).
       01 WS-PENALITE       PIC X(20).

       01 WS-COMMANDE       PIC X(500).
       01 WS-MESSAGE-ERREUR PIC X(50).
       01 WS-FIN-FICHIER    PIC X VALUE "N".

       PROCEDURE DIVISION.
           PERFORM UNTIL WS-CHOIX = 0
               DISPLAY " "
               DISPLAY "=== ENREGISTRER UN PAIEMENT ==="
               DISPLAY "1. Enregistrer paiement"
               DISPLAY "2. Voir tous les paiements"
               DISPLAY "0. Retour"
               DISPLAY "Votre choix: " WITH NO ADVANCING
               ACCEPT WS-CHOIX

               EVALUATE WS-CHOIX
                   WHEN 1 PERFORM CREATE-PAIEMENT
                   WHEN 2 PERFORM READ-PAIEMENTS
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

       CREATE-PAIEMENT.
           DISPLAY "Numero echeance : " WITH NO ADVANCING
           ACCEPT WS-ECHEANCE-ID.
           DISPLAY "Montant paye    : " WITH NO ADVANCING
           ACCEPT WS-MONTANT-PAYE.
           DISPLAY "Date paiement   : " WITH NO ADVANCING
           ACCEPT WS-DATE-PAIEMENT.
           DISPLAY "Jours retard    : " WITH NO ADVANCING
           ACCEPT WS-JOURS-RETARD.
           DISPLAY "Penalite        : " WITH NO ADVANCING
           ACCEPT WS-PENALITE.

           STRING "./sql/paiement_create.sh "
               WS-ECHEANCE-ID " "
               WS-MONTANT-PAYE " "
               '"' FUNCTION TRIM(WS-DATE-PAIEMENT) '" '
               WS-JOURS-RETARD " "
               WS-PENALITE
               DELIMITED BY SIZE
               INTO WS-COMMANDE
           END-STRING

           MOVE "Erreur : echec paiement" TO WS-MESSAGE-ERREUR
           CALL "SYSTEM" USING WS-COMMANDE
           PERFORM VERIFIER-RETOUR

           DISPLAY "Paiement enregistre.".

      *> ============================
      *>        READ PAIEMENTS
      *> ============================

       READ-PAIEMENTS.
           MOVE "N" TO WS-FIN-FICHIER
           MOVE "./sql/paiement_read.sh" TO WS-COMMANDE
           MOVE "Erreur : echec lecture paiements" TO WS-MESSAGE-ERREUR
           CALL "SYSTEM" USING WS-COMMANDE
           PERFORM VERIFIER-RETOUR

           OPEN INPUT PAIEMENTS-FILE
           PERFORM UNTIL WS-FIN-FICHIER = "O"
               READ PAIEMENTS-FILE
                   AT END
                       MOVE "O" TO WS-FIN-FICHIER
                   NOT AT END
                       DISPLAY FUNCTION TRIM(PAIEMENTS-RECORD)
               END-READ
           END-PERFORM
           CLOSE PAIEMENTS-FILE.

      *> ============================
      *>        GESTION DES ERREURS
      *> ============================

       VERIFIER-RETOUR.
           IF RETURN-CODE NOT = 0
               DISPLAY FUNCTION TRIM(WS-MESSAGE-ERREUR)
               EXIT PROGRAM
           END-IF.








