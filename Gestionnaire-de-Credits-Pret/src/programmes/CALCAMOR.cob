       IDENTIFICATION DIVISION.
       PROGRAM-ID. CALCAMOR.
       
       DATA DIVISION.
       WORKING-STORAGE SECTION.
           *> Copybook partagé
           COPY "../copybooks/SIMULATION.cpy".
           
           *> Variables d'affichage pour header
           01 WS-MONTANT-AFFICHAGE PIC Z(9)9.99.
           01 WS-DUREE-AFFICHAGE PIC ZZ9.
           01 WS-TAUX-AFFICHAGE PIC Z(2)9.99.
           01 WS-MENSUALITE-AFFICHAGE PIC Z(8)9.99.
           01 WS-CAPITAL-RESTANT PIC 9(10)V99.
           01 WS-TAUX-MENSUEL PIC 9V9(8).
           01 WS-INTERETS PIC 9(8)V99.
           01 WS-CAPITAL-AMORTI PIC 9(8)V99.
           
           *> Variable de calcul
           01 WS-MOIS PIC 9(3).

           *> Variables d'affichage pour le tableau
           01 WS-MOIS-AFFICHAGE PIC ZZ9.
           01 WS-ANNEE PIC 9(4).
           01 WS-MOIS-CALENDRIER PIC 99.
           01 WS-CAPITAL-RESTANT-AFFICHAGE PIC Z(9)9.99.
           01 WS-INTERETS-AFFICHAGE PIC Z(7)9.99.
           01 WS-CAPITAL-AMORTI-AFFICHAGE PIC Z(7)9.99.




       PROCEDURE DIVISION.

           IF SIM-ACTIVE = "O" THEN
               PERFORM HEADER_TABLEAU_AMORTISSEMENT
               PERFORM AFFICHAGE_INFO_PRET
           END-IF.
           EXIT PROGRAM.


           *> ============================
           *>        HEADER DISPLAY
           *> ============================
           HEADER_TABLEAU_AMORTISSEMENT.
           
           DISPLAY " "
           DISPLAY "+==============================================+"
           DISPLAY "|         TABLEAU D'AMORTISSEMENT              |"
           DISPLAY "+==============================================+".
           
           AFFICHAGE_SIGNATURE.

           DISPLAY "+=============================" WITH NO ADVANCING
           DISPLAY "======================+"
           DISPLAY "|         DOCUMENT CONTRACTUEL " WITH NO ADVANCING
           DISPLAY "                     |"
           DISPLAY "+===============================" WITH NO ADVANCING
           DISPLAY "====================+"

           DISPLAY "Lu et approuvé le tableau " WITH NO ADVANCING
           DISPLAY "d'amortissement ci-dessus."
           DISPLAY " "
           DISPLAY "Fait à ________________," WITH NO ADVANCING
           DISPLAY " "
           DISPLAY "le __/__/____" 
           DISPLAY "Signature de l'emprunteur: _____________"
           DISPLAY " "
           DISPLAY "Signature du conseiller: _______________"
           DISPLAY " "
           DISPLAY "+-------------------------------" WITH NO ADVANCING
           DISPLAY "--------------------+".
      

           AFFICHAGE_INFO_PRET.
           MOVE  SIM-MONTANT-PRET TO WS-MONTANT-AFFICHAGE
           MOVE SIM-DUREE-MOIS TO WS-DUREE-AFFICHAGE
           MOVE SIM-TAUX-INTERET TO WS-TAUX-AFFICHAGE
           MOVE SIM-MENSUALITE TO WS-MENSUALITE-AFFICHAGE

           DISPLAY "Prêt de " WS-MONTANT-AFFICHAGE WITH NO ADVANCING
           DISPLAY "EUR sur " WITH NO ADVANCING
           DISPLAY WS-DUREE-AFFICHAGE " mois"
           DISPLAY "Taux: " WS-TAUX-AFFICHAGE " %" WITH NO ADVANCING
           DISPLAY "   Mensualité: " WS-MENSUALITE-AFFICHAGE " EUR"

           DISPLAY "+------+------------+" WITH NO ADVANCING
           DISPLAY "------------+-------------+" WITH NO ADVANCING
           DISPLAY "--------------+------------------+"
           DISPLAY "| Mois | Date       |" WITH NO ADVANCING
           DISPLAY " Mensualité | Intérêts    |" WITH NO ADVANCING
           DISPLAY "Capital       | Reste dû         |"
           
           *> Calculs préparatoires avant la boucle
           COMPUTE WS-TAUX-MENSUEL = SIM-TAUX-INTERET / 12 / 100
           
           MOVE SIM-MONTANT-PRET TO WS-CAPITAL-RESTANT



           *> Boucle d'affichage contenu du tableau
           MOVE 2026 TO WS-ANNEE.
           MOVE 1 TO WS-MOIS-CALENDRIER.

           PERFORM VARYING WS-MOIS FROM 1 BY 1 
               UNTIL WS-MOIS > SIM-DUREE-MOIS
               IF WS-MOIS-CALENDRIER > 12 THEN 
                   MOVE 1 TO WS-MOIS-CALENDRIER
                   ADD 1 TO WS-ANNEE 
               END-IF
               COMPUTE WS-INTERETS = - 
                   (WS-CAPITAL-RESTANT * WS-TAUX-MENSUEL)
               COMPUTE WS-CAPITAL-AMORTI = -
                   (SIM-MENSUALITE - WS-INTERETS)
               COMPUTE WS-CAPITAL-RESTANT = - 
                   (WS-CAPITAL-RESTANT - WS-CAPITAL-AMORTI)
               
               MOVE WS-MOIS TO WS-MOIS-AFFICHAGE
               MOVE WS-INTERETS TO WS-INTERETS-AFFICHAGE
               MOVE WS-CAPITAL-AMORTI TO WS-CAPITAL-AMORTI-AFFICHAGE
               MOVE WS-CAPITAL-RESTANT TO WS-CAPITAL-RESTANT-AFFICHAGE
               DISPLAY "|   " WS-MOIS-AFFICHAGE "|  " WITH NO ADVANCING
               DISPLAY WS-MOIS-CALENDRIER "/" WS-ANNEE 
               "   |" WITH NO ADVANCING
               DISPLAY WS-MENSUALITE-AFFICHAGE 
               " | " WITH NO ADVANCING
               DISPLAY WS-INTERETS-AFFICHAGE "| " WITH NO ADVANCING
               DISPLAY
               WS-CAPITAL-AMORTI-AFFICHAGE "  |  " WITH NO ADVANCING
               DISPLAY WS-CAPITAL-RESTANT-AFFICHAGE "   |"
           
           ADD 1 TO WS-MOIS-CALENDRIER
           END-PERFORM
           DISPLAY "--------------------" WITH NO ADVANCING
           DISPLAY "---------------------------"  WITH NO ADVANCING
           DISPLAY "-----------------------------------"

           DISPLAY " "
           DISPLAY " "

           PERFORM AFFICHAGE_SIGNATURE.

