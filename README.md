# Numerisches Programmieren — Tutorienmaterial (LaTeX)

Lehrmaterial für die Vorlesung **Numerisches Programmieren** (TUM, Informatik),
entstanden zwischen 2017 und 2021 in den Tutorien von Hendrik Möller: ein
ausführliches Skript, ein Übungstrainer, Probeklausuren mit Lösungen und
Trainingsblätter — alles als LaTeX-Quelltext.

> **Kein offizielles Material.** Dieses Repository wurde von einem Tutor
> erstellt und steht in keiner Verbindung zu einem Lehrstuhl oder dessen
> Mitarbeitenden. Es gibt **keine Garantie auf Vollständigkeit oder
> Korrektheit**.

## Die PDFs

Im Repository liegen **keine PDFs** — sie sind Build-Ergebnis, nicht Inhalt.
Fertige Dokumente gibt es an zwei Stellen:

- **[Releases](../../releases)** — die veröffentlichten Fassungen, pro Tag ein
  vollständiger Satz aller Dokumente.
- **[Actions](../../actions)** — jeder Build hängt die frisch übersetzten PDFs
  als Artefakte an seinen Lauf, auch für Zwischenstände.

Selbst bauen geht mit `./build.sh` (siehe unten).

---

## Was ist drin

Auf oberster Ebene stehen genau zwei Ordner: `dokumente/` ist der Inhalt,
`gemeinsam/` das, was sich mehrere Dokumente teilen. Alles andere ist
Repo-Maschinerie.

```
dokumente/
  skript/                 Das komplette Skript — eine Quelle, zwei Ausgaben
    kapitel/                seine Kapitel, Reihenfolge in kapitel/inhalt.tex
  trainer/                Übungstrainer als Beamer-Präsentation
    kapitel/                seine Kapitel
  trainingsblaetter/      blatt_01 … blatt_04
    gemeinsam/              Titelmakro und Kopfzeile nur für die Blätter
  probeklausuren/         ein Ordner je Semester, darin angabe.tex + loesung.tex
    ss17/ ws17/ ws18/ ws19/          die Probeklausuren der Tutorien
    alt_ss17/ … alt_ws17/           ältere Klausuren
    _vorlage/                        leeres Gerüst für eine neue Probeklausur
  infoblaetter/           kurze Einzelblätter
    themenuebersicht/       Themenübersicht auf zwei Seiten
    tipps/                  Klausurtipps
    quellen/                kommentierte Linksammlung zu den Themen
    willkommen/             Begrüßungsblatt für die erste Tutoriumsstunde
    klausurstatistik/       welches Thema kam in welcher Altklausur wie oft vor

gemeinsam/
  preamble/               Pakete, Seitenlayout, Makros, Autorangaben
  titelseiten/            Titelseiten der einzelnen Dokumente
  bilder/                 Bilder
```

---

## Bauen

Gebraucht wird eine TeX-Distribution mit `latexmk` — TeX Live 2021 oder neuer
bzw. MiKTeX. Die Dokumente nutzen unter anderem `pgfplots`, `tikzsymbols`,
`nccfoots` und `catchfilebetweentags`, also am besten eine vollständige
Installation (`scheme-full`).

```bash
./build.sh                                   # alles bauen
./build.sh dokumente/probeklausuren          # nur einen Ordner
./build.sh dokumente/skript/numprog_skript.tex   # nur ein Dokument
```

Die PDFs landen neben ihrer `.tex`-Datei, die Zwischendateien in `.build/`;
beides ist gitignoriert.

Einzeln geht es genauso gut von Hand — wichtig ist nur, **im Ordner des
Dokuments** zu übersetzen, weil alle Pfade relativ dazu aufgelöst werden:

```bash
cd dokumente/skript
latexmk -pdf numprog_skript.tex
```

In einem Editor (TeXstudio, VS Code, Overleaf) einfach das gewünschte
Hauptdokument öffnen und übersetzen.

---

## Wie die Dokumente aufgebaut sind

Jedes Dokument beginnt gleich: es sagt, wo es relativ zur Repository-Wurzel
liegt, und lädt dann die geteilte Präambel.

```latex
\documentclass{scrartcl}

\newcommand{\npbase}{../../}       % Pfad von hier zur Repository-Wurzel
\input{\npbase gemeinsam/preamble/preamble}
```

`\npbase` ist das Einzige, was ein Dokument über seinen eigenen Ort wissen
muss. Alle weiteren Pfade hängen sich daran:

```latex
\input{kapitel/fourier}              % ein Kapitel neben dem Dokument
\picS{fft.jpg}{0.7}                  % ein Bild aus gemeinsam/bilder/
```

Dokumente zwei Ebenen unter der Wurzel (`dokumente/skript/`) setzen `{../../}`,
tiefer liegende (`dokumente/probeklausuren/ss17/`) `{../../../}`. Kapitel liegen
neben ihrem Dokument und brauchen deshalb gar kein `\npbase`.

### Layout-Varianten

Vor dem `\input` der Präambel lässt sich das Layout umschalten:

```latex
\newcommand{\npstyle}{print}   % Graustufen, zweiseitig — für den Druck
\newcommand{\npstyle}{plain}   % ohne Kopf- und Fußzeile — für kurze Handouts
```

Ohne Angabe gilt `screen`: farbige Links und Infoboxen, Kopfzeile mit dem
aktuellen Abschnitt. In der `print`-Variante werden alle Infoboxen schwarz und
`\red{…}`, `\green{…}` & Co. fallen auf Fettdruck zurück, damit keine
Information verloren geht, die vorher nur die Farbe getragen hat.

### Ein Dokument, zwei Fassungen

Das Skript gibt es als Bildschirm- und als Druckfassung — aus **einer** Quelle.
`dokumente/skript/numprog_skript.tex` fragt an drei Stellen `\ifdefined\npprint`
ab (Dokumentklasse, Seitenränder, Titelseite); definiert wird das Makro erst
beim Übersetzen:

```bash
latexmk -pdf numprog_skript.tex                      # numprog_skript.pdf
latexmk -pdf -usepretex='\def\npprint{}' \
        -jobname=numprog_skript_print numprog_skript.tex   # ..._print.pdf
```

`./build.sh` und die CI erkennen `\ifdefined\npprint` selbst und bauen beide
Fassungen. Wer für ein anderes Dokument eine zweite Fassung braucht, macht es
genauso — es ist nichts zu registrieren.

### Autorangaben

Name, Webseite und Mailadresse stehen **ausschließlich** in
`gemeinsam/preamble/metadata.tex`:

```latex
\providecommand{\npauthor}{…}
\providecommand{\npauthorurl}{…}
\providecommand{\npauthormail}{…}
```

Überall sonst — Titelseiten, Kopf- und Fußzeilen, Fließtext — stehen nur die
Makros `\npauthor{}`, `\npauthorurl{}` und `\npauthormail{}`. Wer das Material
übernimmt, ändert die drei Zeilen und ist fertig; die CI prüft, dass nirgendwo
sonst wieder ein Klartextname auftaucht.

### Die wichtigsten Makros

Definiert in `gemeinsam/preamble/commands.tex`:

| Makro | Wirkung |
| --- | --- |
| `\defi{…}` | Grüne Box „Erklärung“ — eine Definition |
| `\methode{…}` | Blaue Box „Vorgehen“ — ein Rechenweg Schritt für Schritt |
| `\bsp{…}` | Orange Box „Beispiel“ |
| `\wichtig{…}` | Rote Box „Wichtig“ |
| `\vertief{…}` | Braune Box „Vertiefung“ — optionaler Hintergrund |
| `\pic{f}` / `\picS{f}{b}` / `\picC{f}{b}{Titel}` | Bild aus `gemeinsam/bilder/`, Breite relativ zu `\linewidth` |
| `\n`, `\sbreak`, `\lbreak` | Vertikaler Abstand |
| `\fat{…}`, `\qu{…}` | Fett, deutsche Anführungszeichen |

---

## Ein neues Dokument anlegen

1. Ordner unter dem passenden `dokumente/`-Zweig anlegen und
   `dokumente/probeklausuren/_vorlage/angabe.tex` als Vorlage kopieren (oder
   eines der bestehenden Dokumente).
2. `\npbase` auf die eigene Tiefe setzen.
3. Fertig — CI und Build-Skript finden neue Dokumente von selbst, es gibt keine
   Liste, die gepflegt werden müsste.

Ein neues Kapitel im Skript kommt nach `dokumente/skript/kapitel/` und wird in
`dokumente/skript/kapitel/inhalt.tex` an der passenden Stelle eingehängt.

---

## Automatische Prüfungen

Drei GitHub-Actions-Workflows in `.github/workflows/`:

- **`build.yml`** – übersetzt bei jedem Push und jedem Pull Request *jedes*
  Dokument einzeln (inklusive Druckfassungen) und hängt die PDFs als Artefakte
  an den Lauf. Schlägt ein Dokument fehl, wird sein `.log` mit hochgeladen.
- **`checks.yml`** – Hygiene ohne TeX-Installation: keine eingecheckten
  Build-Artefakte oder PDFs, keine Leerzeichen oder Umlaute in Dateinamen, alle
  Quellen in UTF-8, alle `\input`-Ziele existieren, Autorangaben nur in
  `gemeinsam/preamble/metadata.tex`, keine `http://`-Links. Dazu `chktex` als reine
  Stil-Information (blockiert nie).
- **`release.yml`** – bei einem Git-Tag werden alle PDFs frisch gebaut und an
  ein GitHub-Release gehängt.

---

## Mitmachen

Fehler gefunden? Gerne ein Issue oder einen Pull Request — für inhaltliche
Korrekturen reicht Kapitel und Stelle. Wer am LaTeX-Code arbeitet, findet die
Konventionen in [CONTRIBUTING.md](CONTRIBUTING.md). Vor dem Push kurz
`./build.sh` laufen lassen.

---

## Lizenz

[CC BY-NC-SA 4.0](LICENSE) — Weitergabe und Bearbeitung erlaubt, mit
Namensnennung, nicht kommerziell, und Bearbeitungen unter derselben Lizenz.
