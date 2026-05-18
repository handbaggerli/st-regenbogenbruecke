# SillyTavern — Dynamische Story-Umgebung

Diese Umgebung stellt eine gekapselte Instanz von **SillyTavern** über Docker zur Verfügung, um interaktive Geschichten, Charakterinteraktionen und dynamische Textabenteuer auf Roman-Niveau zu schreiben. Die Rechenlast wird vollständig an externe APIs ausgelagert.

## Technische Architektur & Parameter

Die Steuerung erfolgt über eine `docker-compose.yml` in Kombination mit einer lokalen `.env`-Datei für sensible Zugangsdaten.

### 1. Docker-Parameter (`docker-compose.yml`)

```yaml
services:
  sillytavern:
    image: ghcr.io/sillytavern/sillytavern:latest
    container_name: sillytavern-app
    ports:
      - "8000:8000"
    environment:
      # Erlaubt den Zugriff aus dem internen Docker-Netzwerk (Gateway-IP-Blockade umgehen)
      - SILLYTAVERN_WHITELIST=["127.0.0.1", "::1", "172.16.0.0/12"]
      # Injiziert den OpenRouter-Schlüssel dynamisch aus der .env-Datei
      - OPENROUTER_API_KEY=${MY_OPENROUTER_KEY}
    volumes:
      - ./config:/home/node/app/config
      - ./data:/home/node/app/data
    restart: unless-stopped
```

### 2. Lokale Parameter (`.env`)

Die Datei `.env` liegt im selben Verzeichnis und isoliert sensible Schlüssel von der Versionsverwaltung:

```text
MY_OPENROUTER_KEY=sk-or-v1-dein-persoenlicher-openrouter-schluessel
```

---

## Ordnerstruktur & Speicherverhalten

SillyTavern teilt Konfigurationen und Story-Daten strikt auf. Nur die inhaltsrelevanten Ordner werden persistent getrackt:

```text
├── config/                  # [Ignoriert] Lokale UI-Einstellungen, Layouts und Sitzungen
└── data/                    # [Teilweise Getrackt] Die eigentliche Welt
    ├── characters/          # Charakterkarten (PNG-Bilder mit JSON-Metadaten)
    ├── chats/               # Deine Geschichten (Reine Textdateien im .jsonl-Format)
    ├── worlds/              # Lorebooks / Welt-Lexika für dynamisches Wissen (.json)
    ├── default-user/        # [Ignoriert] Verschlüsselte Secrets und API-Tokens
    └── cache/ / tmp/        # [Ignoriert] Temporäre Systemdaten
```

---

## Empfohlenes KI-Setup im Interface

Um SillyTavern von einem reinen Chatbot in ein mächtiges **Storyteller-Werkzeug im NovelAI-Stil** zu verwandeln, werden folgende Parameter im Web-Interface (`http://localhost:8000`) empfohlen:

### API-Verbindung (Stecker-Symbol)
* **API**: `Chat Completion`
* **Source**: `OpenRouter` (Der Key wird durch die Docker-Umgebung automatisch geladen)
* **Context Size (Tokens)**: `8000` bis `16000` (Bestimmt das Gedächtnisvolumen für Charakterkarten + Lorebook + Chatverlauf)

### Empfohlene deutsche Sprachmodelle (LLMs)
* **`mistralai/mistral-large`**: Hervorragender deutscher Wortschatz, extrem neutral/unzensiert, ideal für komplexe Handlungen, Wendungen und tiefgründige Dialoge.
* **`cohere/command-r-plus`**: Sehr literarischer und ausschweifender Schreibstil auf Deutsch. Reagiert exzellent auf Formatierungsvorgaben.

### Visuelles NovelAI-Feeling (Auge/Sprechblasen-Symbol)
* **Interface-Modus**: Von `Chat-Bubble` auf **`Novel-Mode`** umstellen.
* **Effekt**: Avatare, Boxen und Namen verschwinden. Der geschriebene Text des Nutzers und die Antworten der KI verschmelzen nahtlos zu einem fortlaufenden Buch-Fliesstext. Die "Swipe"-Geste (Wischen nach links) generiert Absätze bei Bedarf völlig neu.
