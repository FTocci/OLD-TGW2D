---
**Topological gift wrapping 2D**
---

*Identificazione del problema*

Il *topological gift wrapping* è un algoritmo che produce un insieme di
complessi di catene in 2D.

Data una qualsiasi collezione di poliedri cellulari la computazione può
essere riassunta con i seguenti passaggi:

1.  Estrarre i due-scheletri dei poliedri;

2.  Fondere in modo efficiente tutte le loro 2-celle;

3.  Calcolare su ogni 2-cella il suo complesso di catene locale.

L'algoritmo è utilizzato localmente su 2-cella per essere decomposta;
invece, è utilizzato globalmente per generare le 3-celle della
partizione dello spazio.

Per ogni elemento (1-scheletro) calcolo il bordo ottenendo i due
vertici, per ciascun vertice calcolo il cobordo, ovvero individuo gli
altri elementi (1-scheletro) con un vertice coincidente (questo
passaggio viene effettuato tramite operazioni elementari fra matrici). A
questo punto si isolano due elementi tra quelli individuati formando
così una catena e si ripete l'algoritmo sugli elementi della catena
appena calcolata. L'obiettivo di ciascuna iterazione è quello di
individuare una porzione nel piano (ovvero la 1-catena di bordo).

Analizzando il codice nel dettaglio, è possibile evidenziare che in
alcuni passi dell'algoritmo è stato implementato il calcolo parallelo e
distribuito. Infatti, nella funzione "*planar_arrangement_1*", il cui
obiettivo è partizionare un complesso cellulare passato come parametro,
la frammentazione dei bordi può essere effettuata tramite il calcolo
asincrono. Un complesso cellulare è partizionato quando l\'intersezione
di ogni possibile coppia di celle del complesso è vuota e l\'unione di
tutte le celle è l\'intero spazio euclideo. Continuando l'analisi del
codice ed osservando accuratamente le dipendenze presenti risulta
opportuno implementare modifiche con l'obiettivo di migliorare
scalabilità, modificabilità e prestazioni di porzioni dello stesso
riducendo l'accoppiamento tra i moduli presenti fattorizzando il codice
e continuando ad implementare forme di calcolo parallelo e distribuito.
In particolare, alcune di queste modifiche dovranno coinvolgere il
codice relativo alla funzione *"merge_vertices!"* che si occupa di
fondere vertici congruenti e bordi congruenti, assegnare a coppie di
indici di vertici indici di bordo e costruire una mappa dei bordi.
