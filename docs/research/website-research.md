# Website-Recherche alexle135.de
Stand: 2026-09-15

Hinweis zur Methode: Alle Aussagen in diesem Dokument stammen aus dem per `firecrawl_scrape` abgerufenen Markdown-Text der jeweils angegebenen Seite. Es wurde kein CSS/HTML-Quellcode ausgewertet — Aussagen zu Hex-Farbwerten und Schriftarten sind entsprechend eingeschränkt (siehe Abschnitt 4 und 5).

## 1. URL-Inventar

| URL | Titel | erreichbar | Kurzbeschreibung |
|---|---|---|---|
| https://alexle135.de/ | Agora, DevOps & Systemintegration in Leipzig | ja | Startseite mit Schwerpunkten, Projekt-Übersicht, Blog-Teaser und Kontaktformular. |
| https://alexle135.de/blog/ | Logbuch – Architektur, Betrieb und Automation | ja | Chronologische Liste aller Blogartikel seit Dezember 2024. |
| https://alexle135.de/blog/alexle135-update-dezember-2025/ | alexle135.de Update Dezember 2025 – Was ist neu? | ja | Community-Update zu Terminal Missionen, neuem Design und Tech-Stack-Upgrade. |
| https://alexle135.de/projekte/ | Projekte – DevOps, Automation, Infrastruktur | ja | Übersichtsseite aller 10 Projekte, priorisiert nach Relevanz. |
| https://alexle135.de/projekte/agora/ | Agora | ja | Projektseite zu Agora, dem Multi-Agenten-Analysesystem. |
| https://alexle135.de/projekte/compose-builder/ | Docker Compose Builder | ja | Projektseite zum visuellen Compose-YAML-Generator. |
| https://alexle135.de/projekte/ticket-routing/ | Ticket-Routing mit KI-Agenten | ja | Projektseite zum KI-gestützten Support-Ticket-Klassifikator. |
| https://alexle135.de/projekte/terminal-missionen/ | Terminal Missionen | ja | Projektseite zur Linux/Docker/Git-Terminal-Simulation im Browser. |
| https://alexle135.de/projekte/csharp-trainer/ | CodeHack – C# lernen als Spiel | ja | Projektseite zum gamifizierten C#-Lernspiel. |
| https://alexle135.de/projekte/windows-terminal-missionen/ | Windows Terminal Missionen – CMD & PowerShell lernen | ja | Projektseite zur Windows-CMD/PowerShell-Terminalsimulation. |
| https://alexle135.de/projekte/ihk-radar/ | IHK Radar – FISI Prüfungstracker | ja | Projektseite zum Prüfungsthemen-Tracker für die FISI-Prüfung. |
| https://alexle135.de/projekte/roi-rechner/ | ROI-Rechner – Lohnt sich Automatisierung? | ja | Projektseite zum Automatisierungs-ROI-Rechner. |
| https://alexle135.de/projekte/ki-nachrichten-portal/ | KI Nachrichten Portal | ja | Projektseite zum automatisierten KI-News-Aggregator. |
| https://alexle135.de/projekte/m2-schnittstelle/ | M.2 Schnittstelle Vortrag | ja | Projektseite zur FISI-Präsentation über M.2-SSDs. |
| https://alexle135.de/ueber-mich/ | Über mich – Alexander Schneider, FISI Leipzig | ja | Werdegang, Arbeitsweise, Homelab und aktuelle KI-Projekte. |
| https://alexle135.de/kontakt/ | Kontakt – Portfolio & Kooperationen, Leipzig | ja | Kontaktformular (Name, E-Mail, Nachricht). |
| https://alexle135.de/kompetenzen/ | Kompetenzen | ja | Skill-Balken und Werkzeugliste (Systemintegration, DevOps, Sprachen). |
| https://alexle135.de/leistungen/ | Kooperationsbereiche – Infrastruktur & Automation | ja | Vier Leistungsblöcke für Kooperationsanfragen. |
| https://alexle135.de/ki-agenten-lab/ | KI-Agenten Lab | ja | Seite mit Agenten-Use-Cases und interaktivem "Agent Builder"-Formular (Meta-Tag `noindex, nofollow`). |
| https://alexle135.de/blog/agora-mirofish-fork-local-first/ | 500 Stunden Agora: vom MiroFish-Fork zur evidenzorientierten Multi-Agenten-Analyse | ja | Ausführlicher Feldbericht zu Agora-Architektur und Evidence-Gating. |
| https://alexle135.de/blog/traefik-v3-docker-reverse-proxy/ | Traefik v3 hinter Docker: HTTPS, WebContainer-Header und Auto-Rollback in der Praxis | ja | Technischer Artikel zum Betrieb von alexle135.de hinter Traefik v3.6. |
| https://alexle135.de/blog/csharp-trainer-fisi-browser/ | Wie ich ein C#-Lernspiel gebaut habe – und was dabei rausgekommen ist | ja | Entstehungsgeschichte und Technik von CodeHack. |
| https://alexle135.de/blog/windows-kommandozeile-lernen-cmd-powershell/ | Windows CMD & PowerShell lernen – Der komplette Praxisguide | ja | Ausführlicher Guide zu den Windows Terminal Missionen samt Cheat Sheets. |
| https://alexle135.de/blog/webcontainer-linux-im-browser/ | WebContainer – Wie Linux im Browser funktioniert | ja | Technischer Deep-Dive zur WebContainer-Technologie hinter den Terminal-Missionen. |
| https://alexle135.de/blog/terminal-missionen-launch-dezember-2025/ | NEU: Terminal Missionen – Linux lernen direkt im Browser | ja | Launch-Artikel zu Terminal Missionen mit Missions-Übersicht und Tech-Stack. |

## 2. Projekte

### Agora
- **Name:** Agora
- **Quell-URL:** https://alexle135.de/projekte/agora/ (vertiefend: https://alexle135.de/blog/agora-mirofish-fork-local-first/, https://alexle135.de/ueber-mich/)
- **Was es ist:** Agora ist eine evidenzorientierte Multi-Agenten-Analyseplattform für Dokumente und Websites. Inhalte werden in einen Neo4j-Wissensgraphen überführt, daraus entstehen prüfbare Stakeholder-Personas, die über OASIS und CAMEL in einer kontrollierten Simulation interagieren; der Report trennt belegte Aussagen, Hypothesen und Datenlücken durch "Evidence-Gating" (Quelle: /projekte/agora/). Agora entstand im März 2026 als AGPL-Fork des Projekts MiroFish und wird seit April 2026 eigenständig weiterentwickelt (Quelle: Blogpost). In einem Referenzlauf vom 11. August 2026 über 20 Runden blieben 39 Claims an Quellen oder Simulationsartefakte gebunden (Quelle: /projekte/agora/).
- **Tech-Stack:** Neo4j, OASIS, CAMEL (Quelle: /projekte/agora/); zusätzlich laut Blogpost: Flask, Vue, Redis, Ollama, Python-basierte Provider Registry für lokale/OpenAI-kompatible Endpunkte.
- **Zentrale Begriffe / Fachvokabular:** Evidence-Gating, Wissensgraph, Stakeholder-Personas, Multi-Agenten-Simulation, Claims, Run-Vertrag, Provider Registry, Run-Budget, Stability Beta.
- **Zitierfähige Kernaussage:** "Agora sagt menschliches Verhalten nicht voraus." (Quelle: /projekte/agora/)
- **Status:** "Version 0.9.5 ist eine Stability Beta unter AGPL-3.0" (Quelle: /projekte/agora/); die laufende Anwendung ist laut Seite vorerst privat, öffentlich sind nur Quellcode und Produktdarstellung.

### Docker Compose Builder
- **Name:** Docker Compose Builder
- **Quell-URL:** https://alexle135.de/projekte/compose-builder/
- **Was es ist:** Ein visueller Generator für Docker-Compose-Stacks: Services auswählen, YAML wird live generiert (inkl. automatisch erkannter Volumes und Umgebungsvariablen), fertige Konfiguration per Klick kopieren. Verfügbare Services laut Seite: Nginx, PHP-FPM, MySQL, PostgreSQL, Redis, Traefik, Prometheus, Grafana, Adminer.
- **Tech-Stack:** Astro, TypeScript, Docker Compose (Quelle: Startseiten-Kachel /).
- **Zentrale Begriffe / Fachvokabular:** Compose-Stacks, Stack Builder, YAML-Generierung, Services, Volumes.
- **Zitierfähige Kernaussage:** "Kein Googlen mehr nach 'mysql docker compose example'." (Quelle: /projekte/compose-builder/)
- **Status:** "Live" (Quelle: Startseiten-Badge /)

### Ticket-Routing mit KI-Agenten
- **Name:** Ticket-Routing mit KI-Agenten
- **Quell-URL:** https://alexle135.de/projekte/ticket-routing/
- **Was es ist:** Ein KI-Agent-System, das eingehende Support-Tickets analysiert, nach Kategorien (Hardware/Software/Netzwerk) klassifiziert, priorisiert und automatisch an die zuständige Fachabteilung routet. Bei niedrigem Confidence Score eskaliert das System an einen menschlichen Dispatcher.
- **Tech-Stack:** Google Gemini API, Node.js & Express, Docker.
- **Zentrale Begriffe / Fachvokabular:** Classifier Workflow, Confidence Score, Rate Limiting, Prompt Engineering, Eskalation.
- **Zitierfähige Kernaussage:** "Ein funktionierender Prototyp, der 85% der Tickets korrekt kategorisiert." (Quelle: /projekte/ticket-routing/)
- **Status:** Prototyp — "Für einen Production-Einsatz müsste das System noch robuster werden." (Quelle: /projekte/ticket-routing/); die interaktive Demo ist laut Seite noch nicht öffentlich.

### Terminal Missionen
- **Name:** Terminal Missionen
- **Quell-URL:** https://alexle135.de/projekte/terminal-missionen/ (vertiefend: https://alexle135.de/blog/terminal-missionen-launch-dezember-2025/, https://alexle135.de/blog/webcontainer-linux-im-browser/)
- **Was es ist:** Ein interaktives Lernprodukt für Linux-, Docker- und Git-Befehle als geführte Terminal-Simulation direkt im Browser, ohne Installation. Es umfasst 11 Missionen in 3 Kategorien (6× Linux, 3× Docker, 3× Git) inklusive CTF-Challenges für Fortgeschrittene (Quelle: Launch-Blogpost). Das Terminal läuft technisch über die WebContainer API von StackBlitz, ergänzt um eine selbst entwickelte Custom-Node.js-Shell mit über 25 implementierten Linux-Befehlen (Quelle: WebContainer-Blogpost).
- **Tech-Stack:** React 19, TypeScript, WebContainer API, Tailwind CSS (Quelle: /projekte/terminal-missionen/); zusätzlich laut Blogposts: Astro 5, xterm.js (Terminal-Rendering).
- **Zentrale Begriffe / Fachvokabular:** WebContainer, Missionen, CTF-Challenges, Custom Node.js Shell, Cross-Origin Isolation (COEP/COOP), Mock-Modus.
- **Zitierfähige Kernaussage:** "Vergiss trockene Theorie." (Quelle: /projekte/terminal-missionen/)
- **Status:** "Live" (Quelle: Startseiten-Badge /)

### CodeHack – C# lernen als Spiel
- **Name:** CodeHack – C# lernen als Spiel
- **Quell-URL:** https://alexle135.de/projekte/csharp-trainer/ (vertiefend: https://alexle135.de/blog/csharp-trainer-fisi-browser/)
- **Was es ist:** Ein gamifiziertes C#-Lernspiel mit 45 Aufgaben in 9 Tracks, 8 Boss-Battles mit Timer, XP-/Level-System, Achievements und einem Cosmetics-Shop für Editor-Themes. Läuft komplett im Browser mit echter C#-Kompilation, kostenlos und ohne Account nötig (Quelle: /projekte/csharp-trainer/). Laut Blogpost begann das Projekt als schlichter "C# Trainer" mit 30 Aufgaben und wurde nach Erkenntnissen zu fehlender Motivation zu CodeHack mit Gamification-Mechaniken ausgebaut.
- **Tech-Stack:** Laut Startseite: C#, Gamification, Interaktives Lernen, FiSi. Laut Blogpost technisch: Vanilla JS (16 Module, kein Framework/Bundler), Ace-Editor, Wandbox API (Online-Compiler), Supabase (Accounts/Leaderboard), nginx:alpine, Traefik, Let's Encrypt.
- **Zentrale Begriffe / Fachvokabular:** Boss-Battles, XP/Level/Bytes, Skill-Tree, Daily Challenge, Hacker Bootcamp, Cosmetics-Shop.
- **Zitierfähige Kernaussage:** "Programmieren lernen, das sich anfuehlt wie ein Spiel." (Quelle: /projekte/csharp-trainer/)
- **Status:** "Stable" (Quelle: Startseiten-Badge /)

### Windows Terminal Missionen – CMD & PowerShell lernen
- **Name:** Windows Terminal Missionen – CMD & PowerShell lernen
- **Quell-URL:** https://alexle135.de/projekte/windows-terminal-missionen/ (vertiefend: https://alexle135.de/blog/windows-kommandozeile-lernen-cmd-powershell/)
- **Was es ist:** Ein sicheres Windows-Terminal im Browser mit 6 interaktiven Missionen (Gesamtdauer 78 Minuten) von CMD-Grundlagen bis PowerShell-Experte, inklusive Diskpart, WMIC, Netzwerk-Diagnose und Scheduled Tasks, mit Echtzeit-Validierung und Hints (Quelle: /projekte/windows-terminal-missionen/).
- **Tech-Stack:** Auf der Projektseite nicht separat genannt; laut zugehörigem Blogpost technisch identisch zu Terminal Missionen (WebContainer-Technologie).
- **Zentrale Begriffe / Fachvokabular:** CMD, PowerShell, Diskpart, WMIC, Scheduled Tasks, Echtzeit-Validierung.
- **Zitierfähige Kernaussage:** "Auf meinem Laptop? Zu riskant." (Quelle: /projekte/windows-terminal-missionen/)
- **Status:** "Stable" (Quelle: Startseiten-Badge /)

### IHK Radar – FISI Prüfungstracker
- **Name:** IHK Radar – FISI Prüfungstracker
- **Quell-URL:** https://alexle135.de/projekte/ihk-radar/
- **Was es ist:** Ein Fortschritts-Tracker für 60 IHK-Prüfungsthemen in 6 Kategorien (Netzwerk, Server & OS, Sicherheit, Programmierung, Projektmanagement, Wirtschaft & Recht). Der Fortschritt wird lokal auf dem Gerät gespeichert, keine Anmeldung nötig.
- **Tech-Stack:** Nicht genannt.
- **Zentrale Begriffe / Fachvokabular:** Prüfungsthemen, Progress-Bars, Kategorien, lokale Speicherung.
- **Zitierfähige Kernaussage:** "Behalte den Überblick, was du kannst und was noch fehlt." (Quelle: /projekte/ihk-radar/)
- **Status:** "Stable" (Quelle: Startseiten-Badge /)

### ROI-Rechner – Lohnt sich Automatisierung?
- **Name:** ROI-Rechner – Lohnt sich Automatisierung?
- **Quell-URL:** https://alexle135.de/projekte/roi-rechner/
- **Was es ist:** Ein Rechner, der aus manueller Bearbeitungsdauer, Häufigkeit, Stundensatz und einmaligem Setup-Aufwand die jährliche Zeitersparnis, den Geldwert und den ROI-Zeitraum einer Automatisierung berechnet und eine Empfehlung ausgibt. Genannte Anwendungsfälle: Server-Backups, Deployments, Reports.
- **Tech-Stack:** Nicht genannt.
- **Zentrale Begriffe / Fachvokabular:** ROI-Zeitraum, Zeitersparnis, Setup-Aufwand.
- **Zitierfähige Kernaussage:** "Mit konkreten Zahlen statt Bauchgefühl." (Quelle: /projekte/roi-rechner/)
- **Status:** "Stable" (Quelle: Startseiten-Badge /)

### KI Nachrichten Portal
- **Name:** KI Nachrichten Portal
- **Quell-URL:** https://alexle135.de/projekte/ki-nachrichten-portal/
- **Was es ist:** Ein automatisiertes News-Portal für KI-Entwicklungen. Ein Cron-Job sammelt täglich News aus diversen RSS-Feeds (u. a. OpenAI, Anthropic, Hugging Face), Google Gemini 2.5 erstellt deutsche Zusammenfassungen und bewertet die Wichtigkeit, die aufbereiteten News werden als statische HTML-Seite generiert und auf dem VPS deployt.
- **Tech-Stack:** GitHub Actions, Node.js, Gemini API, Tailwind CSS.
- **Zentrale Begriffe / Fachvokabular:** RSS-Aggregation, Dubletten-Erkennung, Cron-Job, KI-Zusammenfassungen.
- **Zitierfähige Kernaussage:** "Das Projekt befindet sich aktuell in Überarbeitung." (Quelle: /projekte/ki-nachrichten-portal/)
- **Status:** Laut Projektseite in Wartung ("Wartungsarbeiten", "die automatische Update-Funktion wird optimiert"); Startseiten-Badge zeigt dennoch "Stable".

### M.2 Schnittstelle Vortrag
- **Name:** M.2 Schnittstelle Vortrag
- **Quell-URL:** https://alexle135.de/projekte/m2-schnittstelle/
- **Was es ist:** Eine im Rahmen der FISI-Ausbildung gehaltene technische Präsentation über die M.2-Schnittstelle: Formfaktoren und Key-Typen (B-Key/M-Key), NVMe- vs. SATA-Protokolle, praktische Installationstipps und Performance-Vergleiche (SATA SSD ca. 550 MB/s vs. M.2 NVMe Gen4 ca. 7.000 MB/s). Die Präsentation wurde programmatisch mit Python erstellt, um Dark-Mode-/Glassmorphism-Design konsistent auf alle Folien anzuwenden.
- **Tech-Stack:** Python, python-pptx, PowerPoint.
- **Zentrale Begriffe / Fachvokabular:** Formfaktoren, B-Key/M-Key, NVMe, SATA, Performance-Benchmarks.
- **Zitierfähige Kernaussage:** "Ein gewaltiger Sprung." (Quelle: /projekte/m2-schnittstelle/, bezogen auf den Performance-Unterschied)
- **Status:** Unklar — die Seite nennt kein Live/Prototyp/Konzept-Label; die vollständigen Folien sind laut Seite "noch nicht separat veröffentlicht".

## 3. Person / Kontext

- Alexander Schneider macht seit Juni 2025 die Umschulung zum Fachinformatiker Systemintegration (FISI) am BFW Leipzig; Abschluss ist laut Seite für Juni 2027 geplant. (Quelle: https://alexle135.de/ueber-mich/, bestätigt durch Datum "Im Juni 2025 startete meine FISI-Umschulung am BFW Leipzig" in https://alexle135.de/blog/windows-kommandozeile-lernen-cmd-powershell/)
- Vor der IT-Laufbahn: laut /ueber-mich/ "Erst Bundeswehr, dann ein paar Jahre bei der Post, später Handel und ein Stück Selbstständigkeit." Ein Blogpost formuliert es abweichend als "Bundeswehr, Post, Handwerk" (Quelle: https://alexle135.de/blog/csharp-trainer-fisi-browser/). Beide Quellen werden hier unverändert wiedergegeben, da sie leicht different formulieren.
- Standort: Leipzig (mehrfach in Meta-Beschreibungen und Blogposts genannt, u. a. Titel "Über mich – Alexander Schneider, FISI Leipzig", https://alexle135.de/ueber-mich/).
- Geschäftliche Kontakt-E-Mail, die die Website selbst prominent als Kontakt ausweist: <geschäftliche Kontaktadresse, bewusst nicht im Repo gespeichert> (Quelle: https://alexle135.de/blog/alexle135-update-dezember-2025/, Abschnitt "Feedback erwünscht").
- GitHub-Profil: github.com/arn0ld87 (Quelle: https://alexle135.de/blog/alexle135-update-dezember-2025/).
- Homelab laut /ueber-mich/: Contabo-VPS mit rund 48 Docker-Containern hinter Traefik (Portfolio, Self-Hosted-Services, Supabase, eigene Tools); Tailscale-Tailnet; AdGuard Home als DNS-Filter; CachyOS als Daily Driver, MacBook Air M3 für unterwegs, ein iMac 2017 mit OCLP.
- Aktuelle KI-Projekte laut /ueber-mich/: Hermes (self-hosted Agent-Framework, "Status: Aktiv in Entwicklung", ersetzt laut Seite ein "früheres Projekt, das ich inzwischen eingestellt habe") und Agora ("Status: v0.9.0 Stability Beta · AGPL-3.0" — Hinweis: auf der Projektseite /projekte/agora/ wird abweichend Version 0.9.5 genannt; beide Versionsangaben werden hier unverändert wiedergegeben).
- Dank an "die Mitlernenden am BFW Leipzig" für Feedback (Quelle: https://alexle135.de/blog/alexle135-update-dezember-2025/).

## 4. Visuelle Identität

- **Farbwerte (Hex):** Nicht ermittelbar. Es wurde ausschließlich der gerenderte Markdown-Text der Seiten ausgewertet, kein CSS/HTML-Quellcode; im Textinhalt selbst sind keine Hex-Codes genannt.
- **Schriftarten:** Nicht genannt. Auf keiner der abgerufenen Seiten wird ein konkreter Font-Name im Text erwähnt.
- **Wiederkehrende visuelle Motive:**
  - Glassmorphism: mehrfach explizit genannt als Design-Ansatz, u. a. "Neues Glassmorphism Design" mit "Glaseffekt-Cards, also semi-transparente Panels" (Quelle: https://alexle135.de/blog/alexle135-update-dezember-2025/), "Tailwind CSS + Glassmorphism" als Styling-Stack der Terminal Missionen (Quelle: https://alexle135.de/blog/webcontainer-linux-im-browser/), sowie "Corporate Design (Dark Mode, Glassmorphism)" für die M.2-Präsentation (Quelle: https://alexle135.de/projekte/m2-schnittstelle/).
  - Dunkles Farbschema mit Blau-Akzenten: "Dunkler Hintergrund mit Blau-Akzenten" (Quelle: https://alexle135.de/blog/alexle135-update-dezember-2025/).
  - Terminal-Ästhetik: Die Startseite bindet einen simulierten Terminal-Screenshot ein ("mission · rechteverwaltung", `user@mission:~$ ls -l deploy.sh` usw., Quelle: https://alexle135.de/), Blogeinträge sind mit Terminal-artigen Codezeilen wie `$ open post.md` versehen (Quelle: https://alexle135.de/blog/).
  - Karten-/Case-Entry-Layout: Die Projektübersicht ist als nummerierte Liste von "Case Entries" mit Bild, Badge (z. B. "Live", "Stable", "Beta") und "$ proves:"-Zeile gestaltet (Quelle: https://alexle135.de/projekte/).
- **Tonalität der Texte (3–5 Stichpunkte mit Belegzitat):**
  1. Direkt, aus eigener Alltagserfahrung heraus formuliert — Zitat: "Irgendwann nervig." (https://alexle135.de/projekte/compose-builder/)
  2. Selbstironisch/informell, auch auf eigene Kosten — Zitat: "Oder kommentier direkt… okay, Kommentare gibt's noch nicht." (https://alexle135.de/blog/alexle135-update-dezember-2025/)
  3. Technisch präzise mit erklärten Fachbegriffen statt Buzzwords — Zitat: "Middleware-Reihenfolge zählt." (https://alexle135.de/blog/traefik-v3-docker-reverse-proxy/)
  4. Selbstkritisch/reflektiert gegenüber eigenen Projekten, explizite Abgrenzung von Übertreibung — Zitat: "500 Stunden sind kein Qualitätszertifikat." (https://alexle135.de/blog/agora-mirofish-fork-local-first/)
  5. Problem-zuerst, pragmatisch statt portfolio-getrieben — Zitat: "Erst Problem, dann Tool." (https://alexle135.de/ueber-mich/)

## 5. Nicht auffindbar

- Eine dedizierte "Tech-Stack"-Seite unter eigener URL wurde nicht gefunden. Tech-Stack-Informationen sind stattdessen verteilt auf https://alexle135.de/kompetenzen/, den Dezember-2025-Update-Post (Tabelle Astro 5/React 19/Tailwind 4/Node 20) und einzelne Projekt-/Blogseiten.
- Exakte Hex-Farbwerte: nicht auffindbar, da nur Textinhalt (Markdown) ausgewertet wurde, kein CSS.
- Konkrete Schriftart-Namen: nicht genannt/nicht auffindbar im Textinhalt.
- https://alexle135.de/apps/ (Tools-&-Apps-Übersicht, mehrfach verlinkt) wurde nicht separat abgerufen — außerhalb des priorisierten Seitensets der Aufgabe.
- https://alexle135.de/legal/datenschutz/ (Datenschutzerklärung, auf jeder Seite verlinkt) wurde nicht abgerufen — nicht Teil des Rechercheauftrags.
- Private Kontaktdaten (Telefonnummer, Postadresse, private IP-Adressen): bewusst ausgelassen. Auf den abgerufenen Seiten wurden keine solchen Angaben gefunden; das Kontaktformular fragt nur Name, E-Mail und Nachricht ab (Quelle: https://alexle135.de/kontakt/).
- https://alexle135.de/ki-agenten-lab/ wurde abgerufen, aber nicht als eigener Projekt-Abschnitt geführt, da es sich laut Seite um eine Lab-/Formular-Seite ("Agent Builder", Meta-Tag `noindex, nofollow`) und nicht um eines der 10 in der Projekte-Übersicht gelisteten Projekte handelt.
- Widerspruch nicht auflösbar: Agora-Version wird auf /ueber-mich/ als "v0.9.0" und auf /projekte/agora/ sowie im Feldbericht als "0.9.5" bezeichnet — beide Angaben werden in Abschnitt 3 bzw. 2 unverändert dokumentiert, keine Interpretation/Korrektur vorgenommen.

## 6. Quellenliste

Alle Seiten wurden am 15.09.2026 per firecrawl_scrape (Format: markdown) abgerufen.

1. https://alexle135.de/
2. https://alexle135.de/blog/
3. https://alexle135.de/blog/alexle135-update-dezember-2025/
4. https://alexle135.de/projekte/
5. https://alexle135.de/projekte/agora/
6. https://alexle135.de/projekte/compose-builder/
7. https://alexle135.de/projekte/ticket-routing/
8. https://alexle135.de/projekte/terminal-missionen/
9. https://alexle135.de/projekte/csharp-trainer/
10. https://alexle135.de/projekte/windows-terminal-missionen/
11. https://alexle135.de/projekte/ihk-radar/
12. https://alexle135.de/projekte/roi-rechner/
13. https://alexle135.de/projekte/ki-nachrichten-portal/
14. https://alexle135.de/projekte/m2-schnittstelle/
15. https://alexle135.de/ueber-mich/
16. https://alexle135.de/kontakt/
17. https://alexle135.de/kompetenzen/
18. https://alexle135.de/leistungen/
19. https://alexle135.de/ki-agenten-lab/
20. https://alexle135.de/blog/agora-mirofish-fork-local-first/
21. https://alexle135.de/blog/traefik-v3-docker-reverse-proxy/
22. https://alexle135.de/blog/csharp-trainer-fisi-browser/
23. https://alexle135.de/blog/windows-kommandozeile-lernen-cmd-powershell/
24. https://alexle135.de/blog/webcontainer-linux-im-browser/
25. https://alexle135.de/blog/terminal-missionen-launch-dezember-2025/
