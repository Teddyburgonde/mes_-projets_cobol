       IDENTIFICATION DIVISION.
       PROGRAM-ID. EDITRAPP.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
      *> Fichier 1 : liste des prets (genere par editrapp.sh)
           SELECT EDITRAPP-FILE 
               ASSIGN TO "/tmp/editrapp_prets.txt"
               ORGANIZATION IS LINE SEQUENTIAL.
      *> Fichier 2 : detail d'un pret (genere par editrapp_detail.sh)
           SELECT EDITRAPP-DETAIL-FILE
               ASSIGN TO "/tmp/editrapp_detail.txt"
               ORGANIZATION IS LINE SEQUENTIAL.
      *> Fichier 3 : amortissement (genere par editrapp_amortissement.sh)
           SELECT EDITRAPP-AMOR-FILE
               ASSIGN TO "/tmp/editrapp_amortissement.txt"
               ORGANIZATION IS LINE SEQUENTIAL.

       DATA DIVISION.
       FILE SECTION.
       FD EDITRAPP-FILE.
      *> Une ligne : pret_id|nom|prenom|montant|taux
       01 EDITRAPP-RECORD PIC X(100).

       FD EDITRAPP-DETAIL-FILE.
      *> Une ligne = une valeur (montant, taux, duree, ...)
       01 DETAIL-RECORD PIC X(100).

       FD EDITRAPP-AMOR-FILE.
      *> Une ligne = une echeance : mois|date|principal|interet|reste|statut
       01 AMOR-RECORD PIC X(100).

       WORKING-STORAGE SECTION.
      *> Drapeaux de fin de fichier (un par boucle de lecture)
       01 WS-FIN-FICHIER PIC X VALUE "N".
       01 WS-FIN-AMORTISSEMENT PIC X VALUE "N".
      *> "O" = pret trouve, "N" = pret introuvable (fichier detail vide)
       01 WS-PRET-TROUVE PIC X VALUE "O".

       01 WS-PRET-CHOISI PIC 9(9).
       01 WS-COMMANDE PIC X(100).
      *> Message d'erreur passe a VERIFIER-RETOUR avant chaque CALL
       01 WS-MESSAGE-ERREUR PIC X(50).

       *> Colonnes du tableau d'amortissement (largeur fixe = alignement)
       01 WS-COL-MOIS      PIC X(5).
       01 WS-COL-DATE      PIC X(12).
       01 WS-COL-PRINCIPAL PIC X(12).
       01 WS-COL-INTERET   PIC X(10).
       01 WS-COL-CAPITAL   PIC X(16).
       01 WS-COL-STATUT    PIC X(10).
	   
      *> Les couleurs
       01 ESC-CYAN PIC X(10) VALUE X"1B5B313B33366D".
       01 ESC-RESET PIC X(4) VALUE X"1B5B306D".

       PROCEDURE DIVISION.

           PERFORM HEADER-EDITION-DES-RAPPORTS.
           PERFORM LISTER-LES-PRETS.
           PERFORM AFFICHER-DETAIL-PRET.
           PERFORM AFFICHER-AMORTISSEMENT.

           EXIT PROGRAM.

      *> ======================================
      *>        FUNCTIONS
      *> ======================================

      *> ======================================
      *>        LISTE DES PRETS
      *> ======================================

      *> Lit le fichier ligne par ligne et affiche chaque pret
       LISTER-LES-PRETS.
      *> Reset du drapeau : EDITRAPP est rappele en boucle par le MENU
           MOVE "N" TO WS-FIN-FICHIER
           MOVE "./sql/editrapp.sh" TO WS-COMMANDE
           MOVE "Erreur : echec liste des prets" TO WS-MESSAGE-ERREUR
           CALL "SYSTEM" USING WS-COMMANDE
           PERFORM VERIFIER-RETOUR
           OPEN INPUT EDITRAPP-FILE
           PERFORM UNTIL WS-FIN-FICHIER = "O"
               READ EDITRAPP-FILE
                   AT END
                       MOVE "O" TO WS-FIN-FICHIER
                   NOT AT END
                       DISPLAY FUNCTION TRIM(EDITRAPP-RECORD)
               END-READ
           END-PERFORM
           CLOSE EDITRAPP-FILE.

      *> ======================================
      *>        DETAIL D'UN PRET
      *> ======================================

      *> Lit /tmp/editrapp_detail.txt : 1 valeur par ligne,
      *> dans l'ordre montant, taux, duree, mensualite, date, statut.
       AFFICHER-DETAIL-PRET.
           DISPLAY "Numero du pret: " WITH NO ADVANCING
           ACCEPT WS-PRET-CHOISI.

           STRING "./sql/editrapp_detail.sh "
               WS-PRET-CHOISI
               DELIMITED BY SIZE
               INTO WS-COMMANDE
           END-STRING
           MOVE "Erreur : echec detail du pret" TO WS-MESSAGE-ERREUR
           CALL "SYSTEM" USING WS-COMMANDE
           PERFORM VERIFIER-RETOUR

      *> Reset du drapeau a chaque appel (EDITRAPP rappele par le MENU)
           MOVE "O" TO WS-PRET-TROUVE

           OPEN INPUT EDITRAPP-DETAIL-FILE

      *> 1ere lecture : si fichier vide -> pret introuvable, on baisse
      *> le drapeau pour sauter les 5 lectures suivantes (evite status 46).
           READ EDITRAPP-DETAIL-FILE
               AT END
                   DISPLAY "Pret introuvable"
                   MOVE "N" TO WS-PRET-TROUVE
               NOT AT END
                   DISPLAY "Montant     : "
                       FUNCTION TRIM(DETAIL-RECORD) " EUR"
           END-READ

           IF WS-PRET-TROUVE = "O"
               READ EDITRAPP-DETAIL-FILE
                   NOT AT END
                       DISPLAY "Taux        : "
                           FUNCTION TRIM(DETAIL-RECORD) " %"
               END-READ

               READ EDITRAPP-DETAIL-FILE
                   NOT AT END
                       DISPLAY "Duree       : "
                           FUNCTION TRIM(DETAIL-RECORD) " mois"
               END-READ

               READ EDITRAPP-DETAIL-FILE
                   NOT AT END
                       DISPLAY "Mensualite  : "
                           FUNCTION TRIM(DETAIL-RECORD) " EUR"
               END-READ

               READ EDITRAPP-DETAIL-FILE
                   NOT AT END
                       DISPLAY "Date debut  : "
                           FUNCTION TRIM(DETAIL-RECORD)
               END-READ

               READ EDITRAPP-DETAIL-FILE
                   NOT AT END
                       DISPLAY "Statut      : "
                           FUNCTION TRIM(DETAIL-RECORD)
               END-READ
           END-IF

           CLOSE EDITRAPP-DETAIL-FILE.

      *> ======================================
      *>        TABLEAU D'AMORTISSEMENT
      *> ======================================

      *> Relance le script pour le pret deja choisi, puis lit
      *> /tmp/editrapp_amortissement.txt ligne par ligne (1 echeance/ligne).
       AFFICHER-AMORTISSEMENT.
      *> Reset du drapeau : EDITRAPP est rappele en boucle par le MENU
           MOVE "N" TO WS-FIN-AMORTISSEMENT
           MOVE SPACES TO WS-COMMANDE
           STRING "./sql/editrapp_amortissement.sh "
               WS-PRET-CHOISI
               DELIMITED BY SIZE
               INTO WS-COMMANDE
           END-STRING
           MOVE "Erreur : echec amortissement" TO WS-MESSAGE-ERREUR
           CALL "SYSTEM" USING WS-COMMANDE
           PERFORM VERIFIER-RETOUR

           DISPLAY " "
           DISPLAY "Mois " "Date        " "Principal   "
                   "Interet   " "Capital restant " "Statut"

           OPEN INPUT EDITRAPP-AMOR-FILE
           PERFORM UNTIL WS-FIN-AMORTISSEMENT = "O"
               READ EDITRAPP-AMOR-FILE
                   AT END
                       MOVE "O" TO WS-FIN-AMORTISSEMENT
                   NOT AT END
                       UNSTRING AMOR-RECORD DELIMITED BY '|'
                           INTO WS-COL-MOIS WS-COL-DATE 
                           WS-COL-PRINCIPAL WS-COL-INTERET
                           WS-COL-CAPITAL WS-COL-STATUT
                        END-UNSTRING   
                    DISPLAY WS-COL-MOIS WS-COL-DATE WS-COL-PRINCIPAL
                       WS-COL-INTERET WS-COL-CAPITAL WS-COL-STATUT
               END-READ
           END-PERFORM
           CLOSE EDITRAPP-AMOR-FILE.

      *> ======================================
      *>        GESTION DES ERREURS
      *> ======================================

      *> Verifie le code retour du dernier CALL "SYSTEM".
      *> Si echec (RETURN-CODE != 0), affiche le message prepare
      *> dans WS-MESSAGE-ERREUR et abandonne le rapport (retour MENU).
       VERIFIER-RETOUR.
           IF RETURN-CODE NOT = 0
               DISPLAY FUNCTION TRIM(WS-MESSAGE-ERREUR)
               EXIT PROGRAM
           END-IF.

      *> ======================================
      *>        HEADER DISPLAY
      *> ======================================

      *> Header edition des rapports
       HEADER-EDITION-DES-RAPPORTS.
           DISPLAY ESC-CYAN
           DISPLAY " "
           DISPLAY "+=========================================+"
           DISPLAY "|           EDITION DES RAPPORTS          |"
           DISPLAY "+=========================================+"
           DISPLAY ESC-RESET.
