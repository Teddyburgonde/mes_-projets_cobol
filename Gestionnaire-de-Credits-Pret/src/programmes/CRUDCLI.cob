       IDENTIFICATION DIVISION.
       PROGRAM-ID. CRUDCLI.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
      *> Fichier genere par crudcli_read.sh : 1 client par ligne
           SELECT CLIENTS-FILE ASSIGN TO "/tmp/crudcli_clients.txt"
               ORGANIZATION IS LINE SEQUENTIAL.
      *> Fichier genere par crudcli_read_one.sh : 1 seul client
           SELECT CLIENT-FILE ASSIGN TO "/tmp/crudcli_client.txt"
               ORGANIZATION IS LINE SEQUENTIAL.

       DATA DIVISION.
       FILE SECTION.
       FD CLIENTS-FILE.
      *> Une ligne : id|nom|prenom|date|adresse|telephone|email
       01 CLIENTS-RECORD PIC X(500).

       FD CLIENT-FILE.
      *> Une seule ligne (le client recherche), meme format
       01 CLIENT-RECORD PIC X(500).

       WORKING-STORAGE SECTION.
      *> Choix du sous-menu (VALUE 9 != 0 pour que la boucle tourne au moins
      *> une fois ; 0 = retour au menu principal).
       01 WS-CHOIX          PIC 9 VALUE 9.

      *> Tailles alignees sur le schema de la table clients
       01 WS-NOM            PIC X(255).
       01 WS-PRENOM         PIC X(255).
       01 WS-DATE-NAISSANCE PIC X(10).
       01 WS-ADRESSE        PIC X(255).
       01 WS-TELEPHONE      PIC X(20).
       01 WS-EMAIL          PIC X(255).

      *> Commande shell assemblee + message d'erreur pour VERIFIER-RETOUR
       01 WS-COMMANDE       PIC X(500).
       01 WS-MESSAGE-ERREUR PIC X(50).

      *> Drapeau de fin de fichier pour la boucle de lecture (READ)
       01 WS-FIN-FICHIER    PIC X VALUE "N".

      *> Id du client a rechercher (READONE)
       01 WS-CLIENT-ID      PIC 9(9).

       PROCEDURE DIVISION.
      *> Sous-menu interne : l'utilisateur choisit l'operation CRUD.
      *> (appele par le MENU principal via CALL "CRUDCLI")
           PERFORM UNTIL WS-CHOIX = 0
               DISPLAY " "
               DISPLAY "=== GESTION DES CLIENTS ==="
               DISPLAY "1. Creer"
               DISPLAY "2. Lister tous"
               DISPLAY "3. Chercher un client"
               DISPLAY "4. Modifier"
               DISPLAY "5. Supprimer"
               DISPLAY "0. Retour"
               DISPLAY "Votre choix: " WITH NO ADVANCING
               ACCEPT WS-CHOIX

               EVALUATE WS-CHOIX
                   WHEN 1 PERFORM CREATE-CLIENT
                   WHEN 2 PERFORM READ-CLIENTS
                   WHEN 3 PERFORM READ-ONE-CLIENT
                   WHEN 4 PERFORM UPDATE-CLIENT
                   WHEN 5 PERFORM DELETE-CLIENT
                   WHEN 0 DISPLAY "Retour au menu principal"
                   WHEN OTHER DISPLAY "Choix invalide"
               END-EVALUATE
           END-PERFORM

           EXIT PROGRAM.

      *> ============================
      *>        FUNCTIONS
      *> ============================

      *> ============================
      *>        CREATE CLIENT
      *> ============================

      *> Saisit les 6 champs, assemble la commande
      *> ./sql/crudcli_create.sh "nom" "prenom" ... et la lance.
       CREATE-CLIENT.
           DISPLAY "Nom            : " WITH NO ADVANCING
           ACCEPT WS-NOM.
           DISPLAY "Prenom         : " WITH NO ADVANCING
           ACCEPT WS-PRENOM.
           DISPLAY "Date naissance : " WITH NO ADVANCING
           ACCEPT WS-DATE-NAISSANCE.
           DISPLAY "Adresse        : " WITH NO ADVANCING
           ACCEPT WS-ADRESSE.
           DISPLAY "Telephone      : " WITH NO ADVANCING
           ACCEPT WS-TELEPHONE.
           DISPLAY "Email          : " WITH NO ADVANCING
           ACCEPT WS-EMAIL.

      *> Chaque champ entoure de " car certains contiennent des espaces.
      *> FUNCTION TRIM enleve le bourrage des PIC X(255).
           STRING "./sql/crudcli_create.sh "
               '"' FUNCTION TRIM(WS-NOM)            '" '
               '"' FUNCTION TRIM(WS-PRENOM)         '" '
               '"' FUNCTION TRIM(WS-DATE-NAISSANCE) '" '
               '"' FUNCTION TRIM(WS-ADRESSE)        '" '
               '"' FUNCTION TRIM(WS-TELEPHONE)      '" '
               '"' FUNCTION TRIM(WS-EMAIL)          '"'
               DELIMITED BY SIZE
               INTO WS-COMMANDE
           END-STRING

           MOVE "Erreur : echec create client" TO WS-MESSAGE-ERREUR
           CALL "SYSTEM" USING WS-COMMANDE
           PERFORM VERIFIER-RETOUR

           DISPLAY "Client cree.".

      *> ============================
      *>        READ CLIENTS
      *> ============================

      *> Lance crudcli_read.sh, puis lit /tmp/crudcli_clients.txt
      *> ligne par ligne et affiche chaque client.
       READ-CLIENTS.
           MOVE "N" TO WS-FIN-FICHIER
           MOVE "./sql/crudcli_read.sh" TO WS-COMMANDE
           MOVE "Erreur : echec read clients" TO WS-MESSAGE-ERREUR
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

      *> ============================
      *>        READ ONE CLIENT
      *> ============================

      *> Demande un id, lance crudcli_read_one.sh <id>, puis lit
      *> /tmp/crudcli_client.txt (une seule ligne). Gere l'introuvable.
       READ-ONE-CLIENT.
           DISPLAY "Numero du client: " WITH NO ADVANCING
           ACCEPT WS-CLIENT-ID

           STRING "./sql/crudcli_read_one.sh "
               WS-CLIENT-ID
               DELIMITED BY SIZE
               INTO WS-COMMANDE
           END-STRING
           MOVE "Erreur : echec read client" TO WS-MESSAGE-ERREUR
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

      *> ============================
      *>        UPDATE CLIENT
      *> ============================

      *> Demande l'id du client a modifier, puis les 6 nouveaux champs.
      *> Assemble la commande ./sql/crudcli_update.sh et la lance.
       UPDATE-CLIENT.
           DISPLAY "Numero client  : " WITH NO ADVANCING
           ACCEPT WS-CLIENT-ID
           DISPLAY "Nouveau nom            : " WITH NO ADVANCING
           ACCEPT WS-NOM.
           DISPLAY "Nouveau prenom         : " WITH NO ADVANCING
           ACCEPT WS-PRENOM.
           DISPLAY "Nouvelle date naissance: " WITH NO ADVANCING
           ACCEPT WS-DATE-NAISSANCE.
           DISPLAY "Nouvelle adresse       : " WITH NO ADVANCING
           ACCEPT WS-ADRESSE.
           DISPLAY "Nouveau telephone      : " WITH NO ADVANCING
           ACCEPT WS-TELEPHONE.
           DISPLAY "Nouveau email          : " WITH NO ADVANCING
           ACCEPT WS-EMAIL.

      *> id en 1er argument, puis les 6 champs avec guillemets (comme CREATE).
           STRING "./sql/crudcli_update.sh "
               WS-CLIENT-ID " "
               '"' FUNCTION TRIM(WS-NOM)            '" '
               '"' FUNCTION TRIM(WS-PRENOM)         '" '
               '"' FUNCTION TRIM(WS-DATE-NAISSANCE) '" '
               '"' FUNCTION TRIM(WS-ADRESSE)        '" '
               '"' FUNCTION TRIM(WS-TELEPHONE)      '" '
               '"' FUNCTION TRIM(WS-EMAIL)          '"'
               DELIMITED BY SIZE
               INTO WS-COMMANDE
           END-STRING

           MOVE "Erreur : echec update client" TO WS-MESSAGE-ERREUR
           CALL "SYSTEM" USING WS-COMMANDE
           PERFORM VERIFIER-RETOUR

           DISPLAY "Client modifie.".

      *> ============================
      *>        DELETE CLIENT
      *> ============================

      *> Demande l'id du client a supprimer, puis lance
      *> ./sql/crudcli_delete.sh <id>.
       DELETE-CLIENT.
           DISPLAY "Numero client  : " WITH NO ADVANCING
           ACCEPT WS-CLIENT-ID

           STRING "./sql/crudcli_delete.sh "
               WS-CLIENT-ID
               DELIMITED BY SIZE
               INTO WS-COMMANDE
           END-STRING

           MOVE "Erreur : echec delete client" TO WS-MESSAGE-ERREUR
           CALL "SYSTEM" USING WS-COMMANDE
           PERFORM VERIFIER-RETOUR

           DISPLAY "Client supprime.".

      *> ============================
      *>        GESTION DES ERREURS
      *> ============================

      *> Verifie le code retour du dernier CALL "SYSTEM".
      *> Si echec (RETURN-CODE != 0), affiche le message et abandonne.
       VERIFIER-RETOUR.
           IF RETURN-CODE NOT = 0
               DISPLAY FUNCTION TRIM(WS-MESSAGE-ERREUR)
               EXIT PROGRAM
           END-IF.
