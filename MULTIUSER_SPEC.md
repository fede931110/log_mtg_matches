# Specifiche: Migrazione Multi-Utente

## Situazione attuale

Ogni dispositivo salva le partite in `partite.json` locale. La struttura è "single-user by design":
ogni match è loggato dalla prospettiva di una sola persona (`mio_mazzo`, `avversari`).
Con più amici che installano l'APK, ogni telefono avrebbe un database separato → impossibile
confrontare le statistiche tra utenti.

---

## Obiettivo

Ogni amico installa l'APK, fa login con le proprie credenziali, vede **solo le proprie partite
e statistiche**, ma tutti i dati vivono in un backend condiviso.

---

## Stack consigliato: Firebase (Firestore + Authentication)

### Perché Firebase

| Criterio | Firebase | Alternativa (Supabase/custom) |
|---|---|---|
| API REST nativa | Sì (compatibile con `http_request()` di GameMaker) | Sì |
| Autenticazione inclusa | Sì, con email/password pronta | Sì |
| Hosting richiesto | No (serverless) | No (Supabase) / Sì (custom) |
| Free tier | Generoso (50k letture/giorno, 20k scritture) | Generoso |
| Complessità setup | Bassa | Media |

Firebase Firestore è **document-based** (JSON nativo), il che si sposa perfettamente
con la struttura dati già esistente in GameMaker.

---

## Modello dati (Firestore)

### Struttura delle collection

```
/users/{user_id}
    nome:       "Federico"
    email:      "fede931110@gmail.com"
    created_at: timestamp

/users/{user_id}/partite/{partita_id}
    data:       "23/11/2024"
    tipo:       "1v1"
    risultato:  "W"
    mio_mazzo:  "Warriors"
    avversari:  [ { nome: "Matteo", mazzo: "Death Toll" } ]
    created_at: timestamp   // aggiunto per ordinamento affidabile

/users/{user_id}/lookup
    (documento singolo per utente)
    miei_mazzi: [ "Warriors", "Merfolk", ... ]
    modalita:   [ { nome: "1v1", n_avversari: 1 }, ... ]

/shared/opponents
    (documento singolo condiviso da tutti)
    avversari:  [ { nome: "Matteo", mazzi: [...] }, ... ]
```

### Scelte progettuali

- **`/users/{uid}/partite`** → subcollection privata per utente, protetta da security rules.
- **`/users/{uid}/lookup`** → documento singolo con i mazzi personali e le modalità.
- **`/shared/opponents`** → gli avversari sono gli stessi amici per tutti; centralizzarli
  evita duplicazioni e permette in futuro di mostrare statistiche di gruppo.
  In alternativa ogni utente può avere la propria lista se preferisce più autonomia.

---

## Security Rules (Firestore)

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Ogni utente legge/scrive solo i propri dati
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null
                         && request.auth.uid == userId;
    }

    // Documento shared leggibile da tutti, scrivibile da admin
    match /shared/{document} {
      allow read: if request.auth != null;
      allow write: if false; // gestito da te manualmente per ora
    }
  }
}
```

---

## Architettura dell'app (GameMaker)

### Nuovo flusso al primo avvio

```
Avvio app
    │
    ▼
rm_auth  (nuovo)
    │── Nessun token salvato → mostra Login / Registrati
    │── Token valido in cache → auto-login
    │
    ▼
rm_menu  (esistente)
    │
    ├── rm_log      → salva partita su Firestore
    ├── rm_history  → legge partite da Firestore
    ├── rm_stats    → legge partite da Firestore
    └── rm_settings → legge/scrive lookup su Firestore
```

### Variabili globali da aggiungere

```gml
global.user_id        // Firebase UID (stringa)
global.user_nome      // nome display
global.id_token       // Firebase Auth JWT token (scade ogni ora)
global.refresh_token  // token per rinnovare id_token
global.is_loading     // bool: mostra spinner durante HTTP call
```

---

## Step di implementazione

### FASE 1 — Setup Firebase (1-2 ore, nessun codice GameMaker)

1. Creare progetto su [console.firebase.google.com](https://console.firebase.google.com)
2. Abilitare **Authentication → Email/Password**
3. Creare database **Firestore** in modalità "test" per ora
4. Aggiornare le Security Rules come sopra
5. Annotare:
   - `API_KEY` (Web API Key, nelle impostazioni progetto)
   - `PROJECT_ID`
6. Aggiungere documento `/shared/opponents` con la lista avversari attuale

### FASE 2 — Layer HTTP in GameMaker

Sostituire `scr_data_utils` con un layer asincrono.
GameMaker usa `http_request()` + evento `Async - HTTP` per le risposte.

**Costanti da aggiungere in `scr_constants`:**
```gml
#macro FIREBASE_API_KEY   "AIza..."       // dalla console Firebase
#macro FIREBASE_PROJECT   "log-mtg-xxx"  // il tuo project ID
#macro FIRESTORE_BASE     "https://firestore.googleapis.com/v1/projects/" + FIREBASE_PROJECT + "/databases/(default)/documents"
#macro FIREBASE_AUTH_BASE "https://identitytoolkit.googleapis.com/v1"
```

**Nuovo script `scr_firebase_auth`:**
```gml
/// Registra un nuovo utente
function firebase_register(email, password, nome) { ... }

/// Fa login e salva id_token + refresh_token
function firebase_login(email, password) { ... }

/// Rinnova id_token usando refresh_token (ogni ora)
function firebase_refresh_token() { ... }
```

**Nuovo script `scr_firebase_db`:**
```gml
/// Carica tutte le partite dell'utente corrente
function db_load_partite() { ... }

/// Aggiunge una partita
function db_add_partita(partita) { ... }

/// Rimuove una partita per ID
function db_remove_partita(doc_id) { ... }

/// Carica lookup utente
function db_load_lookup() { ... }

/// Salva lookup utente
function db_save_lookup() { ... }
```

**Aggiornamento `obj_data_manager`:**
- Aggiungere evento `Async - HTTP` per intercettare tutte le risposte
- Dispatcher che smista le risposte in base a un `request_type` tag

### FASE 3 — rm_auth (nuova room)

UI minimale con:
- Campo email + campo password
- Bottone **Accedi** / **Registrati**
- Messaggio di errore (credenziali errate, email già usata)
- Salvataggio `refresh_token` su file locale per auto-login ai run successivi

### FASE 4 — Adattare le room esistenti

| Room | Cambiamento |
|---|---|
| `rm_log` | `aggiungi_partita()` → `db_add_partita()` + feedback visivo di salvataggio |
| `rm_history` | `load_partite()` → `db_load_partite()` + spinner di caricamento |
| `rm_stats` | stesso cambiamento di rm_history |
| `rm_settings` | `load_lookup()` / `save_lookup()` → versioni Firestore |

### FASE 5 — Offline cache (opzionale ma consigliato)

Mantenere il `partite.json` locale come cache:
- Al caricamento: mostrare dati locali subito, poi aggiornare con risposta Firestore
- Al salvataggio: scrivere prima localmente, poi su Firestore (ottimistic update)
- Se la chiamata HTTP fallisce (no connessione): accodare l'operazione e ritentare

---

## Considerazioni importanti

### Autenticazione: email/password vs nickname semplice

Due opzioni per il login:

**Opzione A — Email + Password** (raccomandato)
- Standard, sicuro, recupero password incluso
- Ogni amico crea un account con la propria email

**Opzione B — Solo nickname** (più semplice, meno sicuro)
- Firebase Auth con "Anonymous auth" + salvataggio nickname su Firestore
- Pro: zero friction per l'utente
- Contro: se si disinstalla l'app si perde l'account; non recuperabile

Raccomandazione: **Opzione A** per dati persistenti, ma con UI molto semplice.

### Gestione token

Il `id_token` Firebase scade ogni ora. Strategie:
1. All'avvio, usare `refresh_token` per ottenere un nuovo `id_token`
2. Se una richiesta HTTP restituisce `401`, rinnovare il token e riprovare automaticamente

### Migrazione dati esistenti

I dati già nel tuo `partite.json` locale devono essere migrati:
1. Al primo login (dopo aggiornamento app), rilevare se esiste un `partite.json` locale
2. Caricare quelle partite e inviarle a Firestore una per una (o in batch)
3. Marcare la migrazione come completata per non ripeterla

### Statistiche di gruppo (futuro)

Con tutti i dati su Firestore sarà possibile in futuro aggiungere:
- Classifica generale tra tutti gli amici
- Head-to-head comparison (Federico vs Matteo: chi vince di più?)
- Deck usage statistics condivise
- Sessioni di gioco (gruppo di partite della stessa serata)

Questa funzionalità non richiede modifiche al modello dati attuale —
basta una query che legge le partite di tutti gli utenti (con i permessi appropriati).

---

## Stima effort

| Fase | Stima |
|---|---|
| Setup Firebase | 1-2 ore |
| Layer HTTP + async | 4-6 ore |
| rm_auth | 2-3 ore |
| Adattare room esistenti | 3-4 ore |
| Test + debugging | 2-4 ore |
| **Totale** | **~12-20 ore di sviluppo** |

---

## Rischi e dipendenze

- **GameMaker su Android e HTTPS**: GameMaker richiede che le chiamate HTTP su Android
  usino HTTPS (già il caso con Firebase). Verificare che la build Android abbia i permessi
  `INTERNET` abilitati in Game Options.
- **Latenza**: le chiamate Firestore impiegano 100-500ms. Aggiungere sempre feedback visivo
  (spinner, testo "Salvataggio...") per non far sembrare l'app bloccata.
- **Costi Firebase**: il free tier (Spark) copre abbondantemente un gruppo di 5-10 amici.
  Monitorare dall'console se l'uso cresce.
