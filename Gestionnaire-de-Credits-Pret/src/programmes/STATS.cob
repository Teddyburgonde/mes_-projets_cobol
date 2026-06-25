       IDENTIFICATION DIVISION.
       PROGRAM-ID. STATS.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           *> Selectionne le fichier "stats_results.txt"
           SELECT STATS-FILE ASSIGN TO "/tmp/stats_results.txt"
               ORGANIZATION IS LINE SEQUENTIAL.

       DATA DIVISION.
       FILE SECTION.
       FD STATS-FILE.
       01 STATS-RECORD PIC X(20).

       WORKING-STORAGE SECTION.
       *> Les couleurs
       01 ESC-CYAN PIC X(10) VALUE X"1B5B313B33366D".
       01 ESC-RESET PIC X(4) VALUE X"1B5B306D".

       PROCEDURE DIVISION.
           PERFORM MAIN-PROCEDURE

           EXIT PROGRAM.

           *> ======================================
           *>        FUNCTIONS
           *> ======================================

       MAIN-PROCEDURE.
           OPEN INPUT STATS-FILE
           PERFORM HEADER-STATISTIQUES-DES-PRETS.
           PERFORM READ-STATS.
           CLOSE STATS-FILE.

       READ-STATS.
           PERFORM READ-NB-PRETS.
           PERFORM READ-MONTANT-TOTAL.
           PERFORM READ-CAPITAL-RESTANT.
           PERFORM READ-TAUX-MOYEN.
           PERFORM READ-CAPITAL-MOYEN.

       READ-NB-PRETS.
           READ STATS-FILE
               NOT AT END
                   DISPLAY "Nombre total de prets : "
                       FUNCTION TRIM(STATS-RECORD)
           END-READ.

       READ-MONTANT-TOTAL.
           READ STATS-FILE
               NOT AT END
                   DISPLAY "Montant emprunte : "
                       FUNCTION TRIM(STATS-RECORD) " EUR"
           END-READ.

       READ-CAPITAL-RESTANT.
           READ STATS-FILE
               NOT AT END
                   DISPLAY "Montant restant du : "
                       FUNCTION TRIM(STATS-RECORD) " EUR"
           END-READ.

       READ-TAUX-MOYEN.
           READ STATS-FILE
               NOT AT END
                   DISPLAY "Taux moyen : "
                       FUNCTION TRIM(STATS-RECORD) " %"
           END-READ.

       READ-CAPITAL-MOYEN.
           READ STATS-FILE
               AT END
                   DISPLAY "Fin des statistiques"
               NOT AT END
                   DISPLAY "Capital moyen : "
                       FUNCTION TRIM(STATS-RECORD) " EUR"
           END-READ.


           *> ======================================
           *>        HEADER DISPLAY
           *> ======================================

       *> Header statistique de pret
       HEADER-STATISTIQUES-DES-PRETS.
           DISPLAY ESC-CYAN
           DISPLAY " "
           DISPLAY "+=========================================+"
           DISPLAY "|         STATISTIQUES DES PRETS          |"
           DISPLAY "+=========================================+"
           DISPLAY ESC-RESET.
