# Mitmachen

Fehler im Skript, in einer Lösung oder im Aufbau? Issues und Pull Requests sind
willkommen. Für inhaltliche Korrekturen reicht ein Issue mit Kapitel und Stelle
völlig aus — der Rest hier betrifft nur, wer selbst am LaTeX-Code arbeitet.

## Ablauf

`main` ist geschützt: direkt dorthin pushen geht nicht, auch mit Schreibrechten
nicht. Jede Änderung läuft über einen Pull Request.

1. Repository forken (oder, mit Schreibrechten, einen Branch anlegen).
2. Branch von `main` abzweigen — ein Branch pro Thema, der Name ist frei.
3. Ändern, `./build.sh` laufen lassen, committen.
4. Pull Request gegen `main` aufmachen.

**Angenommen wird grundsätzlich jeder Pull Request.** Es gibt keine Vorauswahl
nach Thema, Umfang oder Stil und keinen Anspruch darauf, dass jemand vorher
gefragt hat. Was nicht passt, wird im Pull Request besprochen und angepasst,
nicht zugemacht. Zwei Bedingungen bleiben:

- Die CI muss grün sein — `build.yml` (alle Dokumente übersetzen) und
  `checks.yml` (Hygiene, siehe unten). Beide laufen automatisch am Pull
  Request, `chktex` ist reine Information und blockiert nie.
- Beigetragenes steht unter der Lizenz des Repositories
  ([CC BY-NC-SA 4.0](LICENSE)). Fremdes Material — Aufgaben, Grafiken, Texte
  aus anderen Quellen — gehört nicht hierher, auch nicht umformuliert.

Commit-Nachrichten dürfen deutsch oder englisch sein; eine Zeile, die sagt was
sich ändert, genügt.

## Bauen

```bash
./build.sh                                   # alles
./build.sh dokumente/skript/numprog_skript.tex  # ein Dokument
```

Gebraucht wird TeX Live (2021 oder neuer) bzw. MiKTeX mit `latexmk`, am besten
als vollständige Installation.

## Konventionen

Die CI (`.github/workflows/checks.yml`) prüft diese Punkte automatisch:

- **Keine Build-Artefakte und keine PDFs einchecken.** PDFs sind Build-Ergebnis
  und kommen aus den Releases bzw. den Actions-Artefakten, nicht aus git.
- **Dateinamen ASCII, ohne Leerzeichen.** `Stabilitaet.tex`, nicht
  `stabilitaet.tex`; `probeklausuren/alt_ss17/`, nicht `Probeklausur_Alt SS17/`.
  Umlaute und Leerzeichen in Pfaden brechen je nach Plattform `\input`,
  `latexmk -outdir` oder Links.
- **UTF-8 mit LF-Zeilenenden.** `.gitattributes` sorgt beim Checkout dafür.
- **Jedes `\input`-Ziel muss existieren.**
- **Autorangaben nur in `gemeinsam/preamble/metadata.tex`** — im Text stehen
  `\npauthor{}`, `\npauthorurl{}` und `\npauthormail{}`, nie der Klartext.
- **Keine `http://`-Links**, immer `https://`.

Dazu, was sich schlecht automatisch prüfen lässt:

- **Pfade über `\npbase`**, nicht mit gezählten `../`:
  `\input{\npbase gemeinsam/titelseiten/skript}`. Jedes Dokument setzt `\npbase` einmal
  oben auf seinen Abstand zur Repository-Wurzel.
- **Neue Pakete nach `gemeinsam/preamble/packages.tex`**, nicht in einzelne
  Dokumente —
  sonst laufen die Dokumente wieder auseinander.
- **Neue Makros nach `gemeinsam/preamble/commands.tex`**; für die Folien des
  Trainers nach `gemeinsam/preamble/beamer.tex`.
- **Farbe darf keine Information tragen.** Alles, was farbig ist, muss die
  Druckvariante (`\npstyle{print}`, Graustufen) überstehen. Deshalb gibt es
  `\npboxcolor` und die Fettdruck-Rückfallebene von `\red{…}` & Co.
- **Keine auskommentierten Code-Leichen.** Alte Varianten stehen in der
  git-Historie; im Quelltext stören sie nur. Kommentare, die etwas *erklären*,
  sind ausdrücklich erwünscht.

## Ein Kapitel hinzufügen

1. Datei nach `dokumente/skript/kapitel/` legen.
2. In `dokumente/skript/kapitel/inhalt.tex` an der passenden Stelle einhängen.
3. `./build.sh dokumente/skript` — beide Fassungen (Bildschirm und Druck)
   müssen bauen.

## Ein Dokument hinzufügen

Ordner unter dem passenden `dokumente/`-Zweig anlegen, ein bestehendes Dokument
als Vorlage kopieren, `\npbase` auf die neue Tiefe anpassen. Build-Skript und CI finden neue Dokumente selbstständig; es gibt
keine Liste zu pflegen.

Braucht das Dokument eine zweite, druckoptimierte Fassung, genügt eine
`\ifdefined\npprint`-Abfrage im Dokument (siehe
`dokumente/skript/numprog_skript.tex`) — Build-Skript und CI bauen dann von selbst
zusätzlich `<name>_print.pdf`.
