	   IDENTIFICATION DIVISION.
	   PROGRAM-ID. SIMUPRET.

	   ENVIRONMENT DIVISION.

	   DATA DIVISION.
       WORKING-STORAGE SECTION.
           *> Copybook partagé
           COPY "../copybooks/SIMULATION.cpy".
 
           *> Variables SIMUPRET
		   01 ESC-CYAN PIC X(10) VALUE X"1B5B313B33366D".
		   01 ESC-RESET PIC X(4) VALUE X"1B5B306D".
		   01 WS-MONTANT-PRET PIC 9(10)V99.
		   01 WS-TAUX-INTERET PIC 9(10)V99.
		   01 WS-DUREE-MOIS PIC 9(3).
		   01 WS-CHOIX-TABLEAU PIC X.
		   01 WS-MONTANT-PRET-VALIDE PIC X VALUE 'N'.
		   01 WS-TAUX-INTERET-VALIDE PIC X VALUE 'N'.
		   01 WS-DUREE-MOIS-VALIDE PIC X VALUE 'N'.
		   01 WS-MONTANT-AFFICHAGE PIC Z(9)9.99.
		   01 WS-TAUX-AFFICHAGE PIC Z(9)9.99.
		   01 WS-DUREE-AFFICHAGE PIC ZZ9.

		   01 WS-TAUX-MENSUEL PIC 9V9(8).
		   01 WS-MENSUALITE PIC 9(8)V99.
		   01 WS-COUT-TOTAL PIC 9(10)V99.
		   01 WS-COUT-INTERETS PIC 9(10)V99.
           
		   01 WS-MENSUALITE-AFFICHAGE PIC Z(8)9.99.
		   01 WS-COUT-TOTAL-AFFICHAGE PIC Z(9)9.99.
		   01 WS-COUT-INTERETS-AFFICHAGE PIC Z(9)9.99.

	   PROCEDURE DIVISION.
           
		   PERFORM HEADER_SUMULATEUR_PRET_DISPLAY.

           *> Boucle 1: Saisie du montant de prêt 
           *> et sa validation
		   PERFORM UNTIL WS-MONTANT-PRET-VALIDE = 'O'
			   DISPLAY "Montant du prêt (EUR) ?"
			   DISPLAY "(Min: 1 000 EUR - Max: 500 000 EUR)"

               DISPLAY "> " WITH NO ADVANCING
			   ACCEPT WS-MONTANT-PRET

			   IF WS-MONTANT-PRET > 500000 
				   OR WS-MONTANT-PRET < 1000 THEN
				   DISPLAY "Erreur: " WITH NO ADVANCING
                   DISPLAY "(Min: 1 000 EUR - Max: 500 000 EUR)"
			   ELSE
				   MOVE 'O' TO WS-MONTANT-PRET-VALIDE
                   MOVE WS-MONTANT-PRET TO WS-MONTANT-AFFICHAGE
                   DISPLAY "Montant souhaité: " WS-MONTANT-AFFICHAGE
			   END-IF
		   END-PERFORM.
		   
		   *> Boucle 2: Saisie du taux d'intérêt 
		   *> et sa validation.
		   PERFORM UNTIL WS-TAUX-INTERET-VALIDE = 'O'
			   DISPLAY "Taux d'interêt annuel (%) ?"
			   DISPLAY "(Min: 0,1 % - Max: 20,0 %)"
			   ACCEPT WS-TAUX-INTERET

			   IF WS-TAUX-INTERET > 20.0 
				   OR WS-TAUX-INTERET < 0.1 THEN
				   DISPLAY "Erreur: " WITH NO ADVANCING 
				   DISPLAY "(Min: 0,1 % - Max: 20,0 %)"
			   ELSE
				   MOVE 'O' TO WS-TAUX-INTERET-VALIDE
                   MOVE WS-TAUX-INTERET TO WS-TAUX-AFFICHAGE
				   DISPLAY "Taux d'interêt " 
				   WITH NO ADVANCING
				   DISPLAY "annuel (%): " 
				   WITH NO ADVANCING
				   DISPLAY WS-TAUX-AFFICHAGE
			   END-IF
		   END-PERFORM.

           *> Boucle 3: Saisie de la durée de mois
		   *> et sa validation.
		   PERFORM UNTIL WS-DUREE-MOIS-VALIDE = 'O'
			   DISPLAY "Durée (en mois) ?"
			   DISPLAY "(Min 12 mois, max 360 mois)"
		   
			   ACCEPT WS-DUREE-MOIS

			   IF WS-DUREE-MOIS < 12 OR WS-DUREE-MOIS > 360 THEN
				   DISPLAY "Erreur: (Min: 12 - Max 360)"
			   ELSE
				   MOVE 'O' TO WS-DUREE-MOIS-VALIDE
                   MOVE WS-DUREE-MOIS TO WS-DUREE-AFFICHAGE
				   DISPLAY "Durée: " WS-DUREE-AFFICHAGE " mois"
				   WITH NO ADVANCING
			   END-IF
		   END-PERFORM.
           
           *> =======================================================
           *> CALCULS FINANCIERS
           *> =======================================================

		   *> Calcul du taux mensuel
           COMPUTE WS-TAUX-MENSUEL = WS-TAUX-INTERET / 12 / 100.
           
           *> Calcul de la mensualité - Formule standard bancaire
           *> Conforme Art. L314-1 Code consommation 
		   *> (TEG/TAEG obligatoire)
           COMPUTE WS-MENSUALITE ROUNDED = 
               WS-MONTANT-PRET * WS-TAUX-MENSUEL /
               (1 - ((1 + WS-TAUX-MENSUEL) ** (- WS-DUREE-MOIS))).

           *> Calcul du total
		   COMPUTE WS-COUT-TOTAL = WS-MENSUALITE * WS-DUREE-MOIS.

		   *> Calcul du coût intérêts
           COMPUTE WS-COUT-INTERETS = WS-COUT-TOTAL - WS-MONTANT-PRET.
           
           
           *> Préparation des valeurs pour affichage
		   MOVE WS-MENSUALITE TO WS-MENSUALITE-AFFICHAGE.
		   MOVE WS-COUT-TOTAL TO WS-COUT-TOTAL-AFFICHAGE.
           MOVE WS-COUT-INTERETS TO WS-COUT-INTERETS-AFFICHAGE.


		   *> Affichage header résultat
           DISPLAY " "
           DISPLAY ESC-CYAN 
                   "+---------------------------------+" 
                   ESC-RESET
           DISPLAY ESC-CYAN
                   "|  RESULTAT DE LA SIMULATION      |" 
                   ESC-RESET
           DISPLAY ESC-CYAN
                   "+---------------------------------+" 
                   ESC-RESET

           *> Affichage des données
           DISPLAY "Montant emprunte  : "WS-MONTANT-AFFICHAGE " EUR"
           DISPLAY "Taux annuel : "WS-TAUX-AFFICHAGE "  %"
		   DISPLAY "Durée : "WS-DUREE-AFFICHAGE " mois"
		   DISPLAY "---------------------------------"
           DISPLAY "Mensualite : "WS-MENSUALITE-AFFICHAGE " EUR"
           DISPLAY "Coût total :  "WS-COUT-TOTAL-AFFICHAGE " EUR"
           DISPLAY "Coût des intérêts : " WS-COUT-INTERETS-AFFICHAGE -
		   " EUR"

           
           MOVE WS-MONTANT-PRET TO SIM-MONTANT-PRET.
           MOVE WS-TAUX-INTERET TO SIM-TAUX-INTERET.
           MOVE WS-DUREE-MOIS TO SIM-DUREE-MOIS.
           MOVE WS-MENSUALITE TO SIM-MENSUALITE.
           MOVE 'O' TO SIM-ACTIVE.
           

           DISPLAY "Voir tableau ? (O/N)"
           ACCEPT WS-CHOIX-TABLEAU
           MOVE FUNCTION UPPER-CASE(WS-CHOIX-TABLEAU) 
		     TO WS-CHOIX-TABLEAU
		   
           IF WS-CHOIX-TABLEAU = "O" THEN
               CALL "CALCAMOR"
           END-IF


               EXIT PROGRAM.

           *> ============================
           *>        HEADER DISPLAY
           *> ============================
           
		   HEADER_SUMULATEUR_PRET_DISPLAY.

           DISPLAY ESC-CYAN
                   "+---------------------------------+" 
				   ESC-RESET.
           DISPLAY ESC-CYAN 
				   "|      SIMULATEUR DE PRET         |" 
				   ESC-RESET.
           DISPLAY ESC-CYAN 
				   "+---------------------------------+" 
				   ESC-RESET.


	

