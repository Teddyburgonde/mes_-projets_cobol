       IDENTIFICATION DIVISION.
       PROGRAM-ID. MENU.
       
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-CHOIX PIC 9.
       *> Les couleurs
       01 ESC-CYAN PIC X(10) VALUE X"1B5B313B33366D".
	   01 ESC-RESET PIC X(4) VALUE X"1B5B306D".

       PROCEDURE DIVISION.
           PERFORM UNTIL WS-CHOIX = 8
               PERFORM AFFICHAGE_HEADER_GESTION_DES_CLIENTS

               ACCEPT WS-CHOIX

               EVALUATE WS-CHOIX
                   WHEN 1
                       CALL "SIMUPRET"
                   WHEN 2
                       CALL "CRUDCLI"
                   WHEN 3
                       CALL "PENALITE"
                   WHEN 4
                       CALL "PAIEMENT"
                   WHEN 5
                       CALL "STATS"
                   WHEN 6
                       CALL "EDITRAPP"
                   WHEN 7
                       CALL "CRUDPRET"
                   WHEN 8
                       DISPLAY "Au revoir !"
                   WHEN OTHER
                       DISPLAY "Choix invalide"
               END-EVALUATE
           END-PERFORM

           STOP RUN.

       AFFICHAGE_HEADER_GESTION_DES_CLIENTS.
           DISPLAY ESC-CYAN
           DISPLAY "+==============================================+"
           DISPLAY "|         GESTION DE CREDITS - MENU            |"
           DISPLAY "+==============================================+"
           DISPLAY ESC-RESET

           DISPLAY "1. Simulation de prêt"
           DISPLAY "2. Gestion des clients"
           DISPLAY "3. Penalite de retard"
           DISPLAY "4. Enregistrer un paiement"
           DISPLAY "5. Statistiques"
           DISPLAY "6. Edition des rapports"
           DISPLAY "7. Gestion des prets"
           DISPLAY "8. Quitter"
           DISPLAY " "
           DISPLAY " "
           DISPLAY "Votre choix: "  WITH NO ADVANCING.
