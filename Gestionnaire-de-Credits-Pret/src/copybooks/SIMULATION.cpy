       *> Copyboook SIMUMATION.cpy
       *> Données partagées pour simulation de prêt
       01 SIMULATION-DATA EXTERNAL.
           05 SIM-MONTANT-PRET PIC 9(10)V99.
           05 SIM-TAUX-INTERET PIC 9(3)V99.
           05 SIM-DUREE-MOIS PIC 9(3).
           05 SIM-MENSUALITE PIC 9(8)V99.
           05 SIM-ACTIVE PIC X VALUE 'N'.
           