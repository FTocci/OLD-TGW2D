





**Topological gift wrapping 2D**

[Link repository](https://github.com/FTocci/TGW2D)

Matteo Maraziti

Federico Tocci

Giacomo Scordino










# **Indice**

[1	STUDIO PRELIMINARE]

[1.1	Il linguaggio Julia]

[1.2	Funzionamento]

[1.2.1	Illustrazione dello pseudocodice]

[1.3	Funzioni interne principali]

[1.3.1	Planar Arrangement]

[1.3.2	Merge Vertices]

[1.3.3	Frag Edge]

[1.4	Analisi per il miglioramento del codice]

[2	STUDIO ESECUTIVO]

[2.1	Calcolo Parallelo in Julia]

[2.1.1	*Task* asincroni o coroutine]

[2.1.2	Multithreading]

[2.1.3	Elaborazione distribuita]

[2.1.4	Elaborazione su GPU]

[2.2	Analisi Codice]

[2.3	Implementazione delle modifiche]

[2.4	Re-fattorizzazione]

[BIBLIOGRAFIA]










**Indice Figure**

[Figura 1 : Estrazione di 1 ciclo minimale]

[Figura 2: pseudocodice]

[Figura 3: Codice PlanarArrangement]

[Figura 4: Codice MergeVertices]

[Figura 5: Codice FragEdge]

[Figura 6: Risultato Profiling]

[Figura 7: Risultati test iniziale]

[Figura 8: Risultati test finale]

[Figura 9: Codice mergeCongruentVertices]

[Figura 10: Codice mergeCongruentEdges]

[Figura 11: codice buildEdgeMap]

















1. # **STUDIO PRELIMINARE**
Il topological gift wrapping è un algoritmo che produce un insieme di complessi di catene in 2D.

Data una qualsiasi collezione di poliedri cellulari la computazione può essere riassunta con i seguenti passaggi:

1. Estrarre i due scheletri dei poliedri;
2. Fondere in modo efficiente tutte le loro 2-celle;
3. Calcolare su ogni 2-cella il suo complesso di catene locale.

Con tali premesse, l’obiettivo del presente elaborato è stato quello di effettuare una analisi preliminare del codice a disposizione, individuando i compiti principali che l’algoritmo svolge, le dipendenze fra le varie funzione che lo compongono e determinare eventuali criticità su cui è necessario intervenire.[2]

1.1**Il linguaggio Julia**

L’algoritmo appena introdotto utilizza Julia come linguaggio di programmazione. Esso è stato creato con l’intento di garantire alte prestazioni, sfruttando a pieno le potenzialità del calcolo parallelo. È possibile utilizzare primitive che permettono di sfruttare a pieno i *core* delle macchine sulle quali viene messo in esecuzione il codice Julia, grazie al meccanismo di multi-threading.

Julia può inoltre generare codice nativo per GPU, risorsa che permette di abbattere ulteriormente i tempi di esecuzione dell’algoritmo.[1]

1.2 **Funzionamento**

L’algoritmo è utilizzato localmente su 2-cella per essere decomposta, e invece utilizzato globalmente per generare le 3-celle della partizione dello spazio.

![EstrazioneCicloMinimale](/images/CycleExtraction.png)

Figura 1 : Estrazione di 1 ciclo minimale [2]

Per ogni elemento (1-scheletro) calcolo *il bordo* ottenendo i due vertici, per ciascun vertice calcolo il cobordo, ovvero individuo gli altri elementi (1-scheletro) con un vertice coincidente (questo passaggio viene effettuato tramite valori matriciali). A questo punto si isolano due elementi tra quelli individuati formando così una catena e si ripete l’algoritmo sugli elementi della catena appena calcolata. L’obiettivo di ciascuna iterazione è quello di individuare una porzione nel piano (ovvero la 1-catena di bordo) Figura 1. [2]

1.2.1 **Illustrazione dello pseudocodice**

Lo pseudocodice in Figura 2 è il riassunto dell’algoritmo TGW in uno spazio generico di D-dimensionale.

L’algoritmo prende in input una matrice sparsa di dimensioni “m×n” e restituisce una matrice dal dominio delle D-catene a quello dei (d-1) cicli orientati. [3]

![pseudocodice](/images/Pseudocode.png)

Figura 2: pseudocodice [3]

1.3 **Funzioni interne principali**

1.3.1 **Planar Arrangement**

![PlanarArrangement1](/images/PlanarArrangement1.png)
![PlanarArrangement2](/images/PlanarArrangement2.png)  

Figura 3 : Codice Planar_arrangement
   

L’obiettivo è partizionare un complesso cellulare passato come parametro. Un complesso cellulare è partizionato quando l'intersezione di ogni possibile coppia di celle del complesso è vuota e l'unione di tutte le celle è l'intero spazio euclideo.

1.3.2 **Merge Vertices**

![MergeVertices1](/images/MergeVertices1.png)
![MergeVertices2](/images/MergeVertices2.png)  

Figura 4: Codice MergeVertices

Si occupa di fondere vertici congruenti e bordi congruenti, assegnare a coppie di indici di vertici indici di bordo e costruire una mappa dei bordi.

1.3.3 **Frag Edge**

![FragEdge](/images/FragEdge.png)  

Figura 5: Codice FragEdge

Si occupa della frammentazione dei bordi in EV usando l'indice spaziale bigPI.

1.4 **Analisi per il miglioramento del codice** 

Analizzando il codice nel dettaglio, è possibile evidenziare che in alcuni passi dell'algoritmo è stato implementato il calcolo parallelo e distribuito. Infatti, nella funzione "*planar\_arrangement\_1*", la frammentazione dei bordi può essere effettuata tramite il calcolo asincrono. 

Continuando l'analisi del codice ed osservando accuratamente le dipendenze presenti risulta opportuno implementare modifiche con l'obiettivo di migliorare scalabilità, modificabilità e prestazioni di porzioni dello stesso, riducendo l'accoppiamento tra i moduli presenti fattorizzando il codice e continuando ad implementare forme di calcolo parallelo e distribuito. In particolare, alcune di queste modifiche dovranno coinvolgere il codice relativo alla funzione "*merge\_vertices!"*, presentata in precedenza. Infatti, ad essa sono assegnate numerose *task* che possono essere suddivise in diverse sotto funzioni.



2 # **STUDIO ESECUTIVO**
All’interno di questo capitolo verrà trattato lo sviluppo del progetto nella sua fase principale, ovvero quella riguardante la messa in atto di tutte le modifiche introdotte nel capitolo precedente.

Lo scopo principale è quello di migliorare le prestazioni dell’algoritmo preso in esame andando ad introdurre all’interno del codice porzioni che presentano la possibilità di essere eseguite in parallelo. Oltre a ciò, un secondo obiettivo è la re-fattorizzazione di alcune funzione, garantendo migliore scalabilità e modificabilità dei moduli interessati.

2.1 **Calcolo Parallelo in Julia**
Come introdotto nei paragrafi precedenti è stato deciso di migliorare le prestazioni dell’algoritmo usufruendo delle potenzialità garantite dal calcolo parallelo.
Nei prossimi paragrafi verranno illustrate le possibili implementazioni del calcolo parallelo offerta dal linguaggio di programmazione Julia.

2.1.1 ***Task* asincroni o coroutine**
I task di Julia consentono di sospendere e riprendere i calcoli per l'I/O, la gestione degli eventi e modelli simili. I task possono sincronizzarsi attraverso operazioni come *wait* e *fetch* e comunicare tramite canali. Pur non essendo di per sé un calcolo parallelo, Julia consente di programmare i *task* su più *thread*.

2.1.2 **Multithreading**
Il *multithreading* di Julia offre la possibilità di programmare task simultaneamente su più di un *thread* o core della CPU, condividendo la memoria. Questo è di solito il modo più semplice per ottenere il parallelismo sul proprio PC o su un singolo grande server *multicore*.

2.1.3 **Elaborazione distribuita**
il calcolo distribuito esegue più processi Julia con spazi di memoria separati. Questi possono trovarsi sullo stesso computer o su più computer. La libreria standard Distributed fornisce la possibilità di eseguire in remoto una funzione Julia. Con questo blocco di base, è possibile costruire molti tipi diversi di astrazioni di calcolo distribuito.

2.1.4 **Elaborazione su GPU**
Il compilatore Julia GPU offre la possibilità di eseguire codice Julia in modo nativo sulle GPU. Esiste un ricco ecosistema di pacchetti Julia che puntano alle GPU.

2.2 **Analisi Codice** 
Prima dell’attuazione delle modifiche è stata svolta un’analisi dell’algoritmo con l’obiettivo di misurarne i tempi di esecuzione e di individuare eventuali porzioni di codice che potessero rallentare notevolmente l’esecuzione dello stesso.

In tal senso, Julia offre strumenti che possono aiutare a diagnosticare i problemi e a migliorare le prestazioni del codice. Per questa fase di studio dell’algoritmo sono stati usati: 

1. Profiling: La profilazione consente di misurare le prestazioni del codice in esecuzione e di identificare le linee che fungono da colli di bottiglia. Per la visualizzazione dei risulati è stato usato il pacchetto ProfileView [4]. (Figura 6)
2. @time: Una macro che esegue un'espressione, stampando il tempo di esecuzione, il numero di allocazioni e il numero totale di byte che l'esecuzione ha causato, prima di restituire il valore dell'espressione [5]. (Figura 7)

![Profiling](/images/Figura6.png)

Figura 6: Risultato Profiling

![RisultatiTestIniziale](/images/Figura7.png)

Figura 7: Risultati test iniziale

2.3 **Implementazione delle modifiche** 
All’interno dell’algoritmo è evidente una elevata presenza di cicli. Per questo motivo è stato scelto di utilizzare la tecnica del Multi-threading e in particolare, della macro *@threads*. Julia supporta i loop paralleli utilizzando la macro Threads.@threads. Questa macro viene apposta davanti a un ciclo for per indicare a Julia che il ciclo è una regione multi-thread. 

Lo spazio di iterazione viene suddiviso tra i thread, dopodiché ogni thread scrive il proprio ID thread nelle posizioni assegnate.[6]

A seguito delle modifiche sono stati eseguiti nuovamente i test ottenendo i risultati illustrati nella Figura 8.

![RisutatiTestFinale](/images/Figura8.png)

Figura 8: Risultati test finale

Osservando i tempi misurati prima e dopo delle modifiche si evince un miglioramento della prestazione di circa il 30%.

2.4 **Re-fattorizzazione**

Come anticipato nei paragrafi sopra è stato scelto di aggiungere alcune nuove funzioni all’interno del codice così da ridurre le responsabilità di alcuni metodi già presenti nello stesso. Questa scelta implementativa ha coinvolto prevalentemente la funzione “*merge\_vertices*”. In particolare, le funzioni mergeCongruentVertices (Figura 9), mergeCongruentEdges (Figura 10), buildEdgeMap (Figura 11) sono state aggiunte al codice.  

![MergeCongruentVertices](/images/Figura9.png)

Figura 9: Codice mergeCongruentVertices

![MergeCongruentEdges](/images/Figura10.png)

Figura 10: Codice mergeCongruentEdges

![BuildEdgeMap](/images/Figura11.png)

Figura 11: codice buildEdgeMap



#
#



# **BIBLIOGRAFIA**
[1]: Julia doc: <https://julialang.org/>

[2]: ACM-TSAS-2020 Section on Topological gift wrapping (TGW) in 2D in particular 2.3, 2.4 

[3]: CADJ-2021.pdf Section on Chains and Arrangements in particular 2.2. and A.1. Relevant matters (Algorithm 5)

[4] Profiling:  <https://docs.julialang.org/en/v1/manual/profile/>

[5] <Base.@time>: <https://docs.julialang.org/en/v1/base/base/#Base.@time>

[6] MultiThreading: <https://docs.julialang.org/en/v1/manual/multi-threading/#The-@threads-Macro>


