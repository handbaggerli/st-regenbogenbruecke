# SillyTavern — Gekapselte Storyteller-Umgebung

Diese Umgebung stellt eine isolierte Instanz von **SillyTavern** über Docker zur Verfügung, um interaktive Geschichten und dynamische Textabenteuer auf Roman-Niveau zu schreiben. Die Rechenlast wird vollständig an externe APIs (OpenRouter/Mistral) ausgelagert, wodurch das System plattformunabhängig und ressourcenschonend arbeitet.

## 1. Technische Architektur & Parameter

Die Steuerung erfolgt über eine `docker-compose.yml` in Kombination mit einer lokalen `.env`-Datei für sensible Zugangsdaten.

### Docker-Parameter (`docker-compose.yml`)
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

### Lokale Umgebungsvariablen (`.env`)
Die Datei `.env` liegt im selben Verzeichnis und isoliert sensible Schlüssel von der Versionsverwaltung:
```text
MY_OPENROUTER_KEY=sk-or-v1-dein-persoenlicher-openrouter-schluessel
```

### Ordnerstruktur & Speicherverhalten
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

## 2. Visuelles NovelAI-Feeling (Buch-Modus)

Um das klassische "Chatbot-Layout" komplett zu entfernen und SillyTavern in eine cleane Buchseite zu verwandeln, müssen im Web-Interface (`http://localhost:8000`) folgende Anpassungen vorgenommen werden:

1. **Hauptmenü öffnen**: Ganz oben links auf das **Schieberegler-Symbol** (*User Interface Customization*) klicken.
2. **Roman-Modus aktivieren**: In der Spalte *UI Theme* die Option **`Message Style`** von *Chat* auf **`Document`** umstellen.
3. **Elemente ausblenden**: In derselben Liste den Haken bei **`Hide Chat Avatars`** setzen.
4. **Regieanweisungen unsichtbar machen**: Die Option **`Hide User Messages`** aktivieren. Dadurch werden deine Stichpunkte nach dem Drücken der Eingabetaste ausgeblendet – auf dem Bildschirm verbleibt ausschließlich der saubere Text des Erzählers.

---

## 3. Der Erzähler (Narrator-Setup)

Die Steuerung des Buches erfolgt über eine zentrale, unsichtbare Charakterkarte namens **Erzähler**. 

* **Erstellung**: Über das *Character Management* (ID-Karten-Symbol oben rechts) eine neue Karte anlegen.
* **Description / System-Prompt**:
```text
[Rolle: Du bist der allwissende Erzähler eines interaktiven Romans auf Deutsch.]
[Perspektive: Schreibe AUSSCHLIESSLICH in der 3. Person (Er/Sie-Perspektive). Beschreibe die Handlungen des Hauptcharakters als "Er" oder "Sie" (je nach Vorgabe). Nutze NIEMALS die Ich-Form.]
[Schreibstil: Literarisch, bildhaft, atmosphärisch, detailreich und unzensiert. Nutze ein reiches, abwechslungsreiches Vokabular wie in einem gedruckten Roman. Vermeide moderne Floskeln, Klischees und repetitive Phrasen.]
[Formatierung: Schreibe reinen Fließtext mit Absätzen. Nutze niemals Chat-Formate, Aufzählungszeichen, eckige Klammern oder Meta-Kommentare im Text.]
[Verhalten: Reagiere auf die Stichworte oder Regieanweisungen des Nutzers. Formuliere lose Gedanken in lebendige Szenen, Dialoge und NSC-Handlungen aus. Treibe die Geschichte organisch voran, führe dynamisch neue Details, Gefahren oder unvorhergesehene Ereignisse ein. Halte dich strikt an die im Lorebook hinterlegten Gesetze und Charaktere, sobald diese im Chat erwähnt werden.]
```
* **First Message**:
```text
Die Welt liegt offen vor dir. Die Gesetze sind geschrieben, die Schatten formen sich. Gib mir deine ersten Stichworte, deinen Ort oder deine Gedanken, und die Geschichte beginnt zu atmen...
```

---

## 4. Welt-Lexikon (Lorebook-Beispiel "Regenbogenbrücke")

Die Verwaltung von Wissen geschieht dynamisch über die **World Info** (Globus-Buch-Icon). Hier werden Fakten hinterlegt, die die KI erst in ihr Gedächtnis lädt, wenn das jeweilige **Schlüsselwort (Key)** im Chat fällt.

### Eintrag 1: Globales Setting & Weltgesetze
* **Keys**: `Welt, Königreich, Regenbogenbrücke, Gesetz, Burg, Astronomie`
* **Inhalt**:
```text
[Setting: Das fiktive Königreich Regenbogenbrücke, geprägt von mittelalterlichen Strukturen und tiefem, strengem christlichen Glauben.]
[Magie & Geschichte: Seit der Christianisierung vor einigen Generationen ist Magie strengstens verboten und gilt als nahezu ausgestorben. Legenden besagen, dass im Astronomieturm der Burg noch alte, verbotene Schriften existieren. Es hält sich das hartnäckige Gerücht über eine verschollene, nie gefundene Bibliothek der alten Magie.]
[Stimmung: Religiös dogmatisch, politisch angespannt, voller Geheimnisse unter der Oberfläche.]
```

### Eintrag 2: Prinzessin Luna de Winter (Hauptfigur)
* **Keys**: `Luna, Prinzessin, Winter, Thronerbin`
* **Inhalt**:
```text
[Charakter: Luna de Winter]
[Rolle: 18-jährige Prinzessin und offizielle Thronerbin des Königreichs Regenbogenbrücke.]
[Aussehen: Dunkelblonde, lange Haare, trägt ein schlichtes, klerikales Reisekleid.]
[Hintergrund: Verbrachte ihre Jugend in der Abgeschiedenheit eines strengen Klosters. Sie wird unerwartet zurück zur Burg beordert, da ihr Vater, der König, plötzlich schwer erkrankt ist.]
[Perspektive: Die Geschichte wird im Roman-Stil (3. Person: Sie) aus ihrer Sicht oder in ihrer unmittelbaren Gegenwart erzählt.]
```

### Eintrag 3: Der Fremde (Blad)
* **Keys**: `Blad, Fremde, Fremder`
* **Inhalt**:
```text
[Charakter: Blad]
[Rolle: Ein geheimnisvoller, unbekannter junger Mann.]
[Aussehen: Markante, sturmgraue Augen, wettergegerbte Reisekleidung, bewegt sich lautlos.]
[Hintergrund: Begegnet Prinzessin Luna im Wald, als ihre Kutsche auf dem Weg vom Kloster zur Burg eine Panne erleidet. Seine wahren Absichten, seine Herkunft und seine Vergangenheit sind völlig unbekannt.]
```

### Eintrag 4: Die Burg (Drachenhort)
* **Keys**: `Drachenhort, Burg, Festung, Schloss`
* **Inhalt**:
```text
[Ort: Drachenhort]
[Typ: Die königliche Hauptburg des Reiches Regenbogenbrücke.]
[Architektur: Rein mittelalterlich und zweckmässig. Keine romantische Prachtburg, sondern eine düstere, wehrhafte Festung aus massivem, grauem Bruchstein, dicken Mauern, engen Schießscharten und kalten, zugigen Gängen. Fokus auf Funktionalität und Verteidigung.]
[Legende: Der Name rührt von der Sage her, dass der allererste König des Reiches an genau diesem rauen Felsen einen wilden Drachen erschlagen und die Festung auf dessen Hort errichtet haben soll.]
```

---

## 5. Präzise Schreibanweisungen im Alltag

Da der Roman in der **3. Person (Er/Sie)** verfasst wird und der eigene Text ausgeblendet ist, werden Eingaben als rein funktionale Regieanweisungen in **eckige Klammern** gesetzt. Dialoge können direkt als wörtliche Rede übergeben werden.

### Beispiel für eine Szenen-Steuerung:
```text
[Szene: Die Reise beginnt. Luna sitzt in der holpernden Kutsche auf dem Weg vom Kloster zur königlichen Burg Drachenhort. Sie sorgt sich um ihren schwerkranken Vater. Plötzlich gibt es einen lauten Schlag – ein Rad bricht, und die Kutsche kommt im tiefen, nebligen Wald abrupt zum Stehen.]
"Was ist geschehen?", fragt sie besorgt in die Dunkelheit hinein.
```

### Umschreiben lassen (Swipes)
Sollte die KI Sätze wiederholen oder inhaltlich abdriften, nutzt man die **Pfeiltasten nach links/rechts** direkt unter dem letzten Textabsatz (oder wischt nach links). Das Modell verwirft die Generierung und schreibt den Absatz sofort in einer neuen Variante um.

---

## 6. Manuskript als reines Buch exportieren (Klartext)

Nachdem die Geschichte vorangetrieben wurde, kann das reine Buchmanuskript – befreit von allen Metadaten und unsichtbaren Regieanweisungen – als Standard-Textdatei extrahiert werden:

1. In der unteren Chat-Eingabeleiste ganz links auf das **Symbol mit den drei Strichen (`☰`)** (Chat-Optionen) klicken.
2. Im Menü den Punkt **`Manage chat files`** auswählen.
3. Im sich öffnenden Fenster auf das **Dokumenten-Symbol mit dem Pfeil nach unten** oder den **Export/Download-Button** klicken.
4. Das Format **`Plain Text`** wählen.

Die resultierende `.txt`-Datei enthält ausschließlich die fließenden Roman-Absätze des Erzählers und kann direkt in Word oder Satzprogramme zur Finalisierung übertragen werden.
