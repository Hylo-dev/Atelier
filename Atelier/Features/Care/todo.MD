### 1. Fase di Setup Fisico (Lo Smistamento "Grossolano")

Per rendere l'app usabile, l'utente non deve impazzire. Consiglia di avere **3 Cesti Fisici** in casa. L'app saprà esattamente cosa c'è dentro ogni cesto.

* **Cesto A: "Caldi e Resistenti"** (Bianchi, asciugamani, lenzuola, intimo in cotone). *Target: Igiene alta.*
* **Cesto B: "Quotidiani Scuri/Colorati"** (Jeans, t-shirt, felpe, sintetici scuri). *Target: Protezione colore.*
* **Cesto C: "Speciali e Delicati"** (Lana, seta, abbigliamento tecnico sportivo). *Target: Integrità fibre.*

---

### 2. Fase di Registrazione (Il "Cervello" dell'App)

Quando l'utente registra un capo (`Garment`), l'app deve mappare i dati dell'etichetta. Ecco i suggerimenti per il tuo modello dati:

* **Mapping dei Simboli (`LaundrySymbol`):** Non salvare solo l'immagine, ma convertila in valori numerici (es: `maxTemp: 40`, `tumbleDryAllowed: false`).
* **Analisi Composizione:** Se `composition` ha più fibre, l'app deve dare priorità alla più delicata (es: 90% Cotone + 10% Elastan = Tratta come sintetico per non rovinare l'elasticità).
* **Assegnazione Automatica:** Appena registrato, l'app suggerisce all'utente in quale dei 3 cesti fisici (A, B o C) quel capo dovrà andare quando sarà sporco.

---

### 3. La Logica dell'Algoritmo (Creazione del Lavaggio)

Quando l'utente ha diversi capi in `state = .dirty` e vuole fare una lavatrice, l'app deve filtrare i capi seguendo questa gerarchia di vincoli:

1. **Vincolo 1: Colore (Estetica).** Separa i `color` in tre macro-gruppi: Bianchi, Scuri, Colorati accesi.
2. **Vincolo 2: Temperatura (Sicurezza).** L'algoritmo deve impostare la temperatura del ciclo sul **valore minimo** tra i capi selezionati.
* *Esempio:* 4 capi da 40°C + 1 capo da 30°C = Lavaggio a 30°C.


3. **Vincolo 3: Azione Meccanica (Ciclo).** Se un capo ha il simbolo "Delicato" (barra sotto la vaschetta), l'app deve suggerire un ciclo a bassi giri di centrifuga per tutti.
4. **Vincolo 4: Urgenza (`wearCount` & `lastWashingDate`).** L'app suggerisce di inserire i capi che l'utente usa più spesso o che sono fermi nel cesto da troppo tempo.

---

### 4. Il Caso "Intimo e Calze"

Ecco come gestire la teoria dell'intimo nella tua app:

* **Igiene vs Protezione:** L'intimo di cotone va con i bianchi a 60°C per uccidere i batteri. L'intimo in pizzo/seta va con i delicati a 30°C.
* **Suggerimento "Sacchetto":** Per i reggiseni o capi con ganci, l'app deve mostrare un alert: *"Metti questo capo in un sacchetto a rete per evitare che rovini gli altri vestiti nel cestello"*.
* **L'Intruso:** Se l'utente prova a mettere calze scure in una lavatrice di bianchi, l'app deve lanciare un **Warning Critico**.

---

### 5. Consigli Extra per l'App (Valore Aggiunto)

* **Il Primo Lavaggio:** Se un capo è nuovo (`purchaseDate` recente) e molto colorato (rosso/nero), l'app deve suggerire un lavaggio separato o l'uso di 2 foglietti acchiappacolore.
* **Manutenzione Lavatrice:** In base al numero di lavaggi effettuati, l'app può ricordare all'utente di fare un ciclo a vuoto con aceto o prodotto specifico per pulire il cestello.
* **Asciugatrice Smart:** Dopo il lavaggio, l'app filtra i capi appena lavati e dice: *"Questi 4 possono andare in asciugatrice, questo 1 (es. lana) va steso all'ombra"*.
* **Previsioni Meteo:** Se l'utente deve stendere, l'app può integrare il meteo e dire: *"Pioverà tra 2 ore, meglio non stendere adesso"*.

---

### Esempio di Output dell'App per l'utente:

> **"Lavatrice Ottimizzata Rilevata!"**
> * **Capi:** 5 (T-shirt blu, Jeans, 2 paia calze, Felpa).
> * **Programma consigliato:** Sintetici / Colorati.
> * **Temperatura:** 30°C (imposta dal capo più delicato).
> * **Centrifuga:** 800 giri.
