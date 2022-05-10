





**Topological gift wrapping 2D**

[Link repository](https://github.com/FTocci/TGW2D)


Matteo Maraziti

Federico Tocci

Giacomo Scordino



**Indice** 

[Indice ........................................................................................................................................ 2 ](#_page1_x97.00_y85.92)[1  STUDIO PRELIMINARE ...................................................................................................... 3 ](#_page2_x97.00_y85.92)

1. [IL LINGUAGGIO JULIA ............................................................................................... 3 ](#_page2_x143.00_y351.92)
1.2 [FUNZIONAMENTO .................................................................................................... 3 ](#_page2_x143.00_y534.92)

[1.2.1  ILLUSTRAZIONE DELLO PSEUDOCODICE .......................................................... 4 ](#_page3_x97.00_y205.92)

1.3 [FUNZIONI INTERNE PRINCIPALI ................................................................................ 5 ](#_page4_x143.00_y85.92)
1.3.1 [PLANAR ARRANGEMENT .................................................................................. 5 ](#_page4_x97.00_y104.92)
1.3.2 [MERGE VERTICES .............................................................................................. 6 ](#_page5_x97.00_y85.92)
1.3.3 [FRAG EDGE ....................................................................................................... 6 ](#_page5_x97.00_y458.92)
1.4 [CONCLUSIONI PER FUTURA OTTIMIZZAZIONE ......................................................... 7 ](#_page6_x143.00_y85.92)[BIBLIOGRAFIA ........................................................................................................................... 8 ](#_page7_x97.00_y85.92)




**1 STUDIO PRELIMINARE**

Il topological gift wrapping è un algoritmo che produce un insieme di complessi di catene in 2D.

Data una qualsiasi collezione di poliedri cellulari la computazione può essere riassunta con i seguenti passaggi:

1. Estrarre i due scheletri dei poliedri;
1. Fondere in modo efficiente tutte le loro 2-celle;
1. Calcolare su ogni 2-cella il suo complesso di catene locale.

Con tali premesse, l’obiettivo del presente elaborato è stato quello di effettuare una analisi preliminare del codice a disposizione, individuando i compiti principali che l’algoritmo svolge, le dipendenze fra le varie funzione che lo compongono e determinare eventuali criticità su cui è necessario intervenire.[2]

**1.1 IL LINGUAGGIO JULIA**

L’algoritmo appena introdotto utilizza Julia come linguaggio di programmazione. Esso è stato creato con l’intento di garantire alte prestazioni, sfruttando a pieno le potenzialità del calcolo parallelo. È possibile utilizzare primitive che permettono di sfruttare a pieno i core delle macchine sulle quali viene messo in esecuzione il codice Julia, grazie al meccanismo di multi-threading.
Julia può inoltre generare codice nativo per GPU, risorsa che permette di abbattere ulteriormente i tempi di esecuzione dell’algoritmo. [1]


**1.2 FUNZIONAMENTO**

L’algoritmo è utilizzato localmente su 2-cella per essere decomposta, e invece utilizzato globalmente per generare le 3-celle della partizione dello spazio.

![EstrazioneCicloMinimale](/images/CycleExtraction.png)
Figura 1 : Estrazione di 1 ciclo minimale

Per ogni elemento (1-scheletro) calcolo *il bordo* ottenendo i due vertici, per ciascun vertice calcolo il cobordo, ovvero individuo gli altri elementi (1-scheletro) con un vertice coincidente (questo passaggio viene effettuato tramite valori matriciali). A questo punto si isolano due elementi tra quelli individuati formando così una catena e si ripete l’algoritmo sugli elementi della catena appena calcolata. L’obiettivo di ciascuna iterazione è quello di individuare una porzione nel piano (ovvero la 1-catena di bordo)Figura 1.[2]

 **1.2.1 ILLUSTRAZIONE DELLO PSEUDOCODICE**

Lo pseudocodice in Figura 2 è il riassunto dell’algoritmo TGW in uno spazio generico di D-dimensionale.

L’algoritmo prende in input una matrice sparsa di dimensioni “m×n” e restituisce una matrice dal dominio delle D-catene a quello dei (d-1) cicli orientati. [3]

![Pseudocodice](/images/Pseudocode.png)  
Figura 2: pseudocodice [3]

 **1.3 FUNZIONI INTERNE PRINCIPALI**
 
   **1.3.1 PLANAR ARRANGEMENT**

![PlanarArrangement1](/images/PlanarArrangement1.png)
![PlanarArrangement2](/images/PlanarArrangement2.png)  
Figura 3 : Codice Planar_arrangement

L’obiettivo è partizionare un complesso cellulare passato come parametro. Un complesso cellulare è partizionato quando l'intersezione di ogni possibile coppia di celle del complesso è vuota e l'unione di tutte le celle è l'intero spazio euclideo.

**1.3.2 MERGE\_VERTICES**

![MergeVertices1](/images/MergeVertices1.png)
![MergeVertices2](/images/MergeVertices2.png)  
Figura 4: codice Merge_vertices



Si occupa di fondere vertici congruenti e bordi congruenti, assegnare a coppie di indici di vertici indici di bordo e costruire una mappa dei bordi.

**1.3.3 FRAG\_EDGE**

![FragEdge](/images/FragEdge.png)  
Figura 5 : codice frag_edge

Si occupa della frammentazione dei bordi in EV usando l'indice spaziale bigPI.

**1.4 CONCLUSIONI PER FUTURA OTTIMIZZAZIONE**

Analizzando il codice nel dettaglio, è possibile evidenziare che in alcuni passi dell'algoritmo è stato implementato il calcolo parallelo e distribuito. Infatti, nella funzione "*planar\_arrangement\_1*", la frammentazione dei bordi può essere effettuata tramite il calcolo asincrono. 

Continuando l'analisi del codice ed osservando accuratamente le dipendenze presenti risulta opportuno implementare modifiche con l'obiettivo di migliorare scalabilità, modificabilità e prestazioni di porzioni dello stesso riducendo l'accoppiamento tra i moduli presenti fattorizzando il codice e continuando ad implementare forme di calcolo parallelo e distribuito. In particolare, alcune di queste modifiche dovranno coinvolgere il codice relativo alla funzione "*merge\_vertices!"*, presentata in precedenza. Infatti, ad essa sono assegnate numerose *task* che possono essere suddivise in diverse sotto funzioni.

**BIBLIOGRAFIA**
[1]: https://julialang.org/
[2]: ACM-TSAS-2020 Section on Topological gift wrapping (TGW) in 2D in particular 2.3, 2.4 
[3]: CADJ-2021.pdf Section on Chains and Arrangements in particular 2.2. and A.1. Relevant 
matters (Algorithm 5
