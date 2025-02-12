**Hallo Welt,**

ich verbrachte den Sommer 2024 größtenteils damit, zwei Anwendungen in Powershell zu schreiben. Die Ideen zu diesem Projekt begleiteten mich schon eine Weile, doch erst zu dieser Zeit fand ich den passenden Einstieg. Eine Anwendung sollte die Verschlüsselung von Login-Daten zum Gegenstand haben, die andere sollte inkrementelle Backups erstellen. Ich merkte relativ bald, dass es sich bei diesen Projekten um mehr als um Skripte handelte, ganz unverhofft betrat ich das Feld der Anwendungsentwicklung. Von den Ergebnissen bin ich gänzlich überzeugt und ich persönlich nutze meine Programme seitdem täglich. Aus diesem Grund würde ich meine Arbeiten gerne mit sovielen Nutzern wie möglich teilen. Darüberhinaus können die Skripte als Referenzwerke für Powershell-Lernende dienen, sind sie doch sehr geradeaus geschrieben.

Nochmal zu den Anwendungen...

Der Login-Manager generiert und nutzt eine json-Datei für die Datenspeicherung. Die Daten selbst sind AES-verschlüsselt. Der Zugriff erfolgt mittels Master-Passwort. Einmal in den Arbeitsspeicher geladen besteht die größte Schwachstelle des Programms darin, dass eben dieser Speicher ausgelesen und die darin befindlichen Daten, inklusive Passwörter, gestohlen werden können - etwas was viele Verschlüsselungsprogramme gemeinsam haben. Ich durchforstete den Arbeitsspeicher nach dem Schließen des Hauptfensters und konnte keine Überbleibsel von Datensätzen mehr finden. Wer also auf Nummer sicher gehen und keine Spuren hinterlassen möchte, sollte das Programm nach Gebrauch stets schließen.

Der Backup-Maker erzeugt, wie der Name vermuten lässt, Backups, und zwar inkrementell. Diese Methode spart viel Zeit gegenüber einem Voll-Backup, vor allem auf langsamen USB-Geräten. Wichtig: Derzeit ist Backup-Maker nur in der Lage, Ordner zu sichern, nicht ganze Laufwerke. Eventuell wird dieses Feature irgendwann ergänzt. Hervorzuheben ist noch, dass der Backup-Prozess in einem separaten runspace läuft, was der allgemeinen Performance recht gut tut.

Beide Anwendungen erfordern eine gewisse Dateistruktur um zu laufen, weshalb ich Installationsprogramme dafür geschrieben habe. Es werden keine Änderungen an der Registry durchgeführt, lediglich Dateien und Ordner erstellt bzw. kopiert und, je nach Wunsch, Verknüpfungen erstellt. Am Ende findet sich eine Liste mit den vorgenommenen Änderungen.

Um dem Ganzen einen etwas moderneren Look zu verpassen, habe ich optionale Icons beigefügt, die nach Wunsch manuell in das entsprechende Icon-Verzeichnis kopiert werden können. Dieses findet sich standardmäßig unter

`C:\Program Files\PowerShellTools\Login-Manager\Icons`\
`C:\Program Files\PowerShellTools\Backup-Maker\Icons`

**Installationsanleitung:**

Das komplette Archiv unter `Zip/ALL/` herunterladen und entpacken, so dass die Datei `Install.ps1` sowie das dazugehörige Zip-Archiv vorhanden sind. Anschließend die Datei `Install.ps1` mittels rechter Maustaste und *Mit PowerShell ausführen* starten.

Noch eine technische Bemerkung: In meinen Skripten mache ich exzessiven Gebrauch von der `+=` Methode! Mir ist die fortlaufende Diskussion um dieses Thema bewusst. Nur soviel dazu: Ich benutze Windows Powershell 5.1 und konnte beim Programmieren keinerlei Performance-Einbrüche aufgrund dieser Methode feststellen. Es verhielt sich vielmehr so, dass andere, teils hochgelobte Alternativen zu messbaren Einbrüchen der Performance geführt haben. Wer sich also von der `+=` Methode auf den Schlips getreten fühlt, sollte meine Skripte meiden (oder Fliege tragen).

Abschließend noch ein Hinweis in eigener Sache: Ich bin lediglich ein autodidaktischer Hobby-Programmierer und kein professioneller Anwendungsentwickler. Aus diesem Grund bitte ich darum, mich mit Nachsicht zu behandeln.

---

Folgende Dateien werden beim Installationsvorgang erstellt bzw. kopiert:

Ini-Dateien:

`C:\Users\%username%\AppData\Local\PowerShellTools\Login-Manager\Settings.ini`\
`C:\Users\%username%\AppData\Local\PowerShellTools\Backup-Maker\Settings.ini`

Verknüpfungen (optional):

`C:\Users\%username%\Desktop\Backup-Maker.lnk`\
`C:\Users\%username%\Desktop\Login-Manager.lnk`

`C:\Users\%username%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\PowerShellTools\Login-Manager\Login-Manager.lnk`\
`C:\Users\%username%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\PowerShellTools\Login-Manager\Uninstall (Login-Manager).lnk`

`C:\Users\%username%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\PowerShellTools\Backup-Maker\Backup-Maker.lnk`\
`C:\Users\%username%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\PowerShellTools\Backup-Maker\Uninstall (Backup-Maker).lnk`

Ordner mit Icons und Skript-Dateien:

`C:\Program Files\PowerShellTools\Login-Manager`\
`C:\Program Files\PowerShellTools\Login-Manager\Icons`\
`C:\Program Files\PowerShellTools\Backup-Maker`\
`C:\Program Files\PowerShellTools\Backup-Maker\Icons`
