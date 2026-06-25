all:
	docker-compose up -d
	cobc -I src/copybooks -x \
	src/programmes/MENU.cob \
	src/programmes/SIMUPRET.cob \
	src/programmes/CALCAMOR.cob \
	src/programmes/PENALITE.cob \
	src/programmes/STATS.cob \
	src/programmes/EDITRAPP.cob \
	src/programmes/CRUDCLI.cob \
	src/programmes/CRUDPRET.cob \
	src/programmes/PAIEMENT.cob
	./MENU

re: clean all

stop:
	docker-compose down

clean:
	rm -f MENU *.o
	docker-compose down

.PHONY: all re clean stop