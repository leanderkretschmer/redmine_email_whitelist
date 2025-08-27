# Redmine Email Whitelist Plugin

Ein Redmine 6 Plugin, das es ermöglicht, E-Mail-Domains zu whitelisten oder blacklisten für ausgehende E-Mails.

## Funktionen

- **Whitelist-Modus**: Nur E-Mails an erlaubte Domains werden versendet
- **Blacklist-Modus**: E-Mails an blockierte Domains werden nicht versendet
- **Kombinierter Modus**: Blacklist und Whitelist können gleichzeitig verwendet werden
- **Flexible Domain-Syntax**: Unterstützt verschiedene Eingabeformate
- **Logging**: Blockierte E-Mails werden im Redmine-Log protokolliert

## Installation

1. **Plugin herunterladen/klonen**
   ```bash
   cd /path/to/redmine/plugins
   git clone https://github.com/yourusername/redmine_email_whitelist.git
   ```

2. **Plugin aktivieren**
   - Gehen Sie zu **Administration** → **Plugins**
   - Aktivieren Sie das "Redmine Email Whitelist" Plugin

3. **Plugin konfigurieren**
   - Gehen Sie zu **Administration** → **Einstellungen** → **E-Mail-Benachrichtigung**
   - Scrollen Sie zum Abschnitt "E-Mail-Domain-Beschränkungen"
   - Konfigurieren Sie die erlaubten und nicht erlaubten E-Mail-Domains

4. **Redmine neu starten**
   ```bash
   sudo systemctl restart redmine
   # oder
   sudo service redmine restart
   ```

## Konfiguration

### Erlaubte E-Mail-Domains (Whitelist)

Wenn Sie E-Mail-Domains in diesem Feld angeben, werden nur E-Mails an diese Domains versendet.

**Beispiele:**
- `example.com` - Alle E-Mails an @example.com
- `*@trusted.com` - Alle E-Mails an @trusted.com
- `user@specific.com` - Nur E-Mails an diese spezifische Adresse
- `example.com, *@trusted.com, admin@company.com` - Kombination mehrerer Regeln

### Nicht erlaubte E-Mail-Domains (Blacklist)

E-Mails an diese Domains werden blockiert und nicht versendet.

**Beispiele:**
- `spam.com` - Alle E-Mails an @spam.com blockieren
- `*@blocked.com` - Alle E-Mails an @blocked.com blockieren
- `bad@example.com` - Nur diese spezifische E-Mail-Adresse blockieren

## Verwendungsmodi

### 1. Nur Whitelist
```
Erlaubte Domains: example.com, *@trusted.com
Nicht erlaubte Domains: (leer)
```
→ Nur E-Mails an @example.com und @trusted.com werden versendet

### 2. Nur Blacklist
```
Erlaubte Domains: (leer)
Nicht erlaubte Domains: spam.com, *@blocked.com
```
→ Alle E-Mails werden versendet, außer an @spam.com und @blocked.com

### 3. Kombinierter Modus
```
Erlaubte Domains: example.com, *@trusted.com
Nicht erlaubte Domains: bad@example.com, *@blocked.com
```
→ E-Mails an @example.com und @trusted.com werden versendet, aber `bad@example.com` wird trotzdem blockiert

## Domain-Syntax

Das Plugin unterstützt drei verschiedene Eingabeformate:

1. **Nur Domain**: `example.com`
   - Matcht alle E-Mails an @example.com

2. **Wildcard-Domain**: `*@example.com`
   - Matcht alle E-Mails an @example.com

3. **Spezifische E-Mail**: `user@example.com`
   - Matcht nur diese spezifische E-Mail-Adresse

## Logging

Blockierte E-Mails werden im Redmine-Log protokolliert:

```bash
tail -f /path/to/redmine/log/production.log
```

Beispiel-Log-Einträge:
```
INFO -- : Email blocked by blacklist: user@spam.com
INFO -- : Email allowed by whitelist: user@example.com
WARN -- : Email blocked by whitelist/blacklist rules: Issue Update Notification
```

## Troubleshooting

### Plugin wird nicht angezeigt
- Stellen Sie sicher, dass das Plugin im richtigen Verzeichnis installiert ist
- Überprüfen Sie die Dateiberechtigungen
- Starten Sie Redmine neu

### E-Mails werden nicht gefiltert
- Überprüfen Sie die Plugin-Konfiguration
- Stellen Sie sicher, dass die Domain-Syntax korrekt ist
- Überprüfen Sie die Logs auf Fehlermeldungen

### Performance-Probleme
- Bei vielen E-Mail-Empfängern kann die Filterung die Performance beeinträchtigen
- Erwägen Sie die Verwendung spezifischer E-Mail-Adressen statt Wildcards

## Entwicklung

### Anforderungen
- Redmine 6.x
- Ruby 2.7+

### Lokale Entwicklung
```bash
cd /path/to/redmine/plugins/redmine_email_whitelist
bundle install
```

### Tests
```bash
bundle exec rake test
```

## Lizenz

Dieses Plugin ist unter der MIT-Lizenz lizenziert.

## Support

Bei Problemen oder Fragen erstellen Sie bitte ein Issue auf GitHub oder kontaktieren Sie den Autor.

## Changelog

### Version 1.0.0
- Erste Veröffentlichung
- Whitelist- und Blacklist-Funktionalität
- Flexible Domain-Syntax
- Logging-Funktionalität
