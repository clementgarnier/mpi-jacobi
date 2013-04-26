######################################################
# Parametres pouvant etre specifies a l'appel du make
######################################################

# Nombre de processeurs
NP=8

######################################################

# Executable par defaut pour les regles generiques
EXEC=jacobi

EXECS=jacobi


######################################################
# Diverses constantes et regles.
######################################################
# Pour que les erreurs durant les tests ne fassent pas avorter l'execution.
.IGNORE:

USAGER = $(USER)

MPICH=/usr/local/mpich2-install/bin
MAKE = make
RM = rm -f
CC = $(MPICH)/mpicc
RUN = $(MPICH)/mpirun
EXIT = $(MPICH)/mpdallexit
CFLAGS = -std=c99

########################################
# Regles specifiques pour exercice 1.
########################################
compile-jacobi: jacobi

jacobi: jacobi.c
	$(CC) $(CFLAGS) -o jacobi jacobi.c -lm

.copies_effectuees1: jacobi
	@cp jacobi /home/$(USAGER)
	@./cp-sur-blades.sh /home/$(USAGER)/jacobi
	@touch .copies_effectuees1

run-jacobi: .copies_effectuees1 .mpdboot compile
	@echo "*** On lance l'execution"
	@(cd /home/$(USAGER); $(RUN) -np $(NP) jacobi 8)

######################################################
######################################################

######################################################
# Regle par defaut (compilation) et autres regles 
# (pour executable generique).
######################################################
compile: $(EXEC)

.mpdboot:
	@($(RM) .mpdboot*)
#	@($(EXIT) >& /dev/null)
	@(cp mpd.hosts /home/$(USAGER))
	@./activer-mpdboot.sh $(NP) mpd.hosts

.mpdboot1:
	@($(RM) .mpdboot*)
	@($(EXIT) >/dev/null)
	@(cp unemachine.txt /home/$(USAGER))
	@./activer-mpdboot.sh 1 unemachine.txt 1

.mpdboot2:
	@($(RM) .mpdboot*)
	@($(EXIT) >/dev/null)
	@(cp deuxmachines.txt /home/$(USAGER))
	@./activer-mpdboot.sh 2 deuxmachines.txt 2

.copies_effectuees: $(EXEC)
	@cp $(EXEC) /home/$(USAGER)
	@./cp-sur-blades.sh /home/$(USAGER)/$(EXEC)
	@touch .copies_effectuees

run: .copies_effectuees .mpdboot
	@(cd /home/$(USAGER); $(RUN) -np $(NP) $(EXEC) $(ARG1) $(ARG2))

debug_un: .copies_effectuees .mpdboot1
	@(cd /home/$(USAGER); $(RUN) -np $(NP) $(EXEC) $(ARG1) $(ARG2))

debug_deux: .copies_effectuees .mpdboot2
	@(cd /home/$(USAGER); $(RUN) -np $(NP) $(EXEC) $(ARG1) $(ARG2))


########################################
# Reconstruction totale et/ou nettoyage.
########################################

TMPFILES = $(EXECS)\
           TAGS \
           *~ *.o \

all: compile .copies_effectuees run

public: cleanxtra
	~/cmd/creer-version-etudiant.sh Labo1

clean:
	@$(RM) $(TMPFILES)
	@$(RM) /home/$(USAGER)/unemachine.txt
	@$(RM) /home/$(USAGER)/deuxmachines.txt
	@$(RM) *~
	@$(RM) .mpdboot* .copies_effectuees*

exit: clean
	@($(EXIT) >/dev/null)

cleanxtra: clean exit
	@$(RM) -r jacobi

