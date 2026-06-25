	   IDENTIFICATION DIVISION.
	   PROGRAM-ID. PENALITE.
	   
	   DATA DIVISION.
	   WORKING-STORAGE SECTION.
		   01 WS-ID-PRET PIC 9(5).
           01 WS-MONTANT-IMPAYE PIC 9(8)V99.
		   01 WS-DATE-ECHEANCE PIC 9(8).
		   01 WS-DATE-ACTUELLE PIC 9(8).
           01 WS-TAUX-PENALITE PIC 9(3)V99.
		   01 WS-JOURS-RETARD PIC 9(3).
		   01 WS-PENALITE-CALCULEE PIC 9(8)V99.
           
		   *> Variables d'affichage
		   01 WS-ID-PRET-AFFICHAGE PIC Z(4)9.
           01 WS-MONTANT-IMPAYE-AFFICHAGE PIC Z(7)9.99.
           01 WS-TAUX-PENALITE-AFFICHAGE PIC Z(2)9.99.
           01 WS-JOURS-RETARD-AFFICHAGE PIC ZZ9.
           01 WS-PENALITE-CALCULEE-AFFICHAGE PIC Z(7)9.99.

		   *> Les couleurs
		   01 ESC-CYAN PIC X(10) VALUE X"1B5B313B33366D".
		   01 ESC-RESET PIC X(4) VALUE X"1B5B306D".

		   01 ESC-RED PIC X(10) VALUE X"1B5B313B33316D".

	   PROCEDURE DIVISION.

           PERFORM HEADER-PENALITE-DE-RETARD.

		   PERFORM SAISIE-DONNEES.

		   PERFORM CALCUL-JOURS-RETARD.
           
           *> Move dans variables d'affichages 
           MOVE WS-ID-PRET TO WS-ID-PRET-AFFICHAGE
           MOVE WS-MONTANT-IMPAYE TO WS-MONTANT-IMPAYE-AFFICHAGE
           MOVE WS-JOURS-RETARD TO WS-JOURS-RETARD-AFFICHAGE.
           MOVE WS-TAUX-PENALITE TO WS-TAUX-PENALITE-AFFICHAGE.
           MOVE WS-PENALITE-CALCULEE TO WS-PENALITE-CALCULEE-AFFICHAGE.

           IF WS-JOURS-RETARD > 5 THEN
               *> Calcul de la penalite 
               COMPUTE WS-PENALITE-CALCULEE = 
                   WS-MONTANT-IMPAYE * WS-TAUX-PENALITE / 100
               
			   MOVE WS-PENALITE-CALCULEE TO
			   WS-PENALITE-CALCULEE-AFFICHAGE
			   PERFORM  HEADER-RESULTAT-DE-PENALITE
               DISPLAY "ID du pret : " WS-ID-PRET-AFFICHAGE
               DISPLAY "Jours de retard: " WS-JOURS-RETARD-AFFICHAGE
               " jours"
               DISPLAY "Montant impayé: " WS-MONTANT-IMPAYE-AFFICHAGE
			   " EUR"
               DISPLAY "Taux appliqué : " WS-TAUX-PENALITE-AFFICHAGE
			   " %"
			   DISPLAY ESC-RED
               DISPLAY "PENALITE CALCULEE " WITH NO ADVANCING
               DISPLAY WS-PENALITE-CALCULEE-AFFICHAGE WITH NO ADVANCING
			   DISPLAY "EUR" ESC-RESET
               DISPLAY "+==========================================+"

           ELSE
               *> Pas de penalite
               PERFORM HEADER-RESULTAT-DE-PENALITE
               DISPLAY "ID du pret : " WS-ID-PRET-AFFICHAGE
               DISPLAY "Jours de retard: " WS-JOURS-RETARD-AFFICHAGE
			   " jours"
			   DISPLAY "Montant impayé: " WS-MONTANT-IMPAYE-AFFICHAGE
			   " EUR"
               DISPLAY "Taux appliqué : " WS-TAUX-PENALITE-AFFICHAGE
			   " %"
               DISPLAY "+===========================================+"

           END-IF


		   EXIT PROGRAM.


		   *> ======================================
		   *>        HEADER DISPLAY
		   *> ======================================
           
		   *> Header calcul de penalite de retard
		   HEADER-PENALITE-DE-RETARD.
			   DISPLAY ESC-CYAN
			   DISPLAY " "
               DISPLAY "+=========================================+"
               DISPLAY "|         CALCUL DE PENALITE DE RETARD    |"     
               DISPLAY "+=========================================+"
               DISPLAY ESC-RESET.
           
		   *> Header resultat de penalite
		   HEADER-RESULTAT-DE-PENALITE.
               DISPLAY ESC-CYAN
               DISPLAY " "
               DISPLAY "+==========================================+"
               DISPLAY "|         RESULTAT DE LA PENALITE          |"
               DISPLAY "+==========================================+"
			   DISPLAY ESC-RESET.


		   *> ======================================
		   *>        FONCTIONS
		   *> ======================================
           
		   *> Fonction saisie de donnees
		   SAISIE-DONNEES.
			   DISPLAY "ID du prêt ?"
			   DISPLAY "> " WITH NO ADVANCING
			   ACCEPT WS-ID-PRET

			   DISPLAY "Montant impayé (EUR) ?"
			   DISPLAY "> " WITH NO ADVANCING
			   ACCEPT WS-MONTANT-IMPAYE

			   DISPLAY "Date d'échéance (YYYYMMDD"
			   DISPLAY " - ex: 20261001) ?"
			   DISPLAY "> " WITH NO ADVANCING
			   ACCEPT WS-DATE-ECHEANCE
		   
			   DISPLAY "Date actuelle (YYYYMMDD"
			   DISPLAY " - ex: 20261001) ?"
			   DISPLAY "> " WITH NO ADVANCING
			   ACCEPT WS-DATE-ACTUELLE

			   DISPLAY "Taux de pénalité (%) ?"
			   DISPLAY "> " WITH NO ADVANCING
			   ACCEPT WS-TAUX-PENALITE.

		   *> Fonction calcul de jours de retards
           CALCUL-JOURS-RETARD.
			   COMPUTE WS-JOURS-RETARD =
               FUNCTION INTEGER-OF-DATE(WS-DATE-ACTUELLE) -
               FUNCTION INTEGER-OF-DATE(WS-DATE-ECHEANCE).
		   


