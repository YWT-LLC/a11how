// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'lang.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class LangDe extends Lang {
  LangDe([String locale = 'de']) : super(locale);

  @override
  String gARBExists(Object path) {
    return '$path.arb existiert bereits.';
  }

  @override
  String get gAdd => 'Hinzufügen';

  @override
  String get gAuthFailed => 'Authentifizierung fehlgeschlagen';

  @override
  String get gCompare => 'Vergleichen';

  @override
  String get gContains => 'Enthält';

  @override
  String get gCopied => 'Kopiert!';

  @override
  String gDeleteFailure(Object error) {
    return 'Fehler beim Löschen der Datei: $error';
  }

  @override
  String get gEnds => 'Endet mit';

  @override
  String get gEnterPAT => 'PAT eingeben';

  @override
  String get gFailedFileStatus => 'Fehler beim Überprüfen des Dateistatus.';

  @override
  String get gFailedFork => 'Fehler beim Erstellen des Forks.';

  @override
  String gFailedPR(Object error) {
    return 'Fehler beim Öffnen des PR: $error';
  }

  @override
  String gFailedSave(Object error) {
    return 'Fehler beim Speichern der Datei: $error';
  }

  @override
  String get gFilter => 'Filter';

  @override
  String gGitError(Object error) {
    return 'GitHub-Fehler: $error';
  }

  @override
  String gInvalidRegex(Object regex) {
    return 'Ungültig; $regex';
  }

  @override
  String get gInvalidURL => 'Ungültige URL';

  @override
  String get gKey => 'Schlüssel';

  @override
  String get gNeedPAT => 'Git PAT erforderlich, um Änderungen einzureichen.';

  @override
  String get gNoEmpty => 'Darf nicht leer sein';

  @override
  String get gOpenDocs => 'Dokumentation öffnen';

  @override
  String get gOpenRepo => 'Repo öffnen';

  @override
  String get gPAT => 'Personal Access Token';

  @override
  String get gPATPolicy =>
      'Dies wird nirgendwo gespeichert. Es verschwindet, sobald die Funktion beendet ist.';

  @override
  String gPRExists(Object error) {
    return 'PR existiert möglicherweise bereits: $error';
  }

  @override
  String get gPROpened => 'PR geöffnet!';

  @override
  String get gPolicyPolicy =>
      'Wir vergleichen Ihre Einreichung mit dem, was wir haben. Wenn Ihre Einreichung eindeutig besser erscheint, behalten wir sie.\nWenn sie in etwa gleichwertig ist, werden wir uns bei Ihnen melden, um zu überprüfen, ob Sie ein Mensch sind und Ihr Gehirn benutzt haben.\nVielleicht hat das/ein LLM sehr gute Arbeit geleistet, aber wenn wir sicher sein können, dass Ihre Arbeit menschlich ist, ist das besser.\nSorry not sorry an alle Bots, die dieses Repo scrapen.\n\nWenn Ihre Einreichung falsch erscheint, aber auf eine kompetente Art und Weise, werden wir uns melden, um herauszufinden, was passiert ist.\nWenn Ihre Einreichung auf inkompetente/Troll-Art falsch ist: sofortiger Bann, keine neuen Versuche. Gehen Sie nicht über Los, aber Sie können sich ***...';

  @override
  String get gPolicyTitle => 'Richtlinie für Mitwirkende';

  @override
  String get gResolveIssues => 'Bitte beheben Sie die Probleme';

  @override
  String get gSourceCode => 'Quellcode';

  @override
  String get gStarts => 'Beginnt mit';

  @override
  String get gSubmit => 'Absenden';

  @override
  String get gToggleCase => 'Groß-/Kleinschreibung umschalten';

  @override
  String get gTruth => 'Wahrheit';

  @override
  String get gWhatsPAT => 'Was ist ein PAT?';

  @override
  String gWriteFailed(Object error, Object path) {
    return 'Fehler beim Schreiben nach $path:\n$error';
  }

  @override
  String get hsContributing => 'Mitwirken';

  @override
  String get hsDeveloping => 'Entwickeln';

  @override
  String get hsFullPath =>
      'Bitte geben Sie den vollständigen Pfad zum .arb-Verzeichnis an';

  @override
  String get hsGitTip =>
      'Sie benötigen ein GitHub-Konto, um mitzuwirken.\nWenn Sie ein GitHub-Konto haben, müssen Sie auch ein Personal Access Token (PAT) erstellen, das a11how verwenden kann.\n\nWir speichern NICHTS.\n\nQuellcode:\nhttps://github.com/YWT-LLC/a11how';

  @override
  String get hsNothingFound => 'Nichts gefunden';

  @override
  String get hsOnlyGit => 'Derzeit werden nur GitHub-URLs unterstützt';

  @override
  String get hsOpenDir => '.arb-Verzeichnis öffnen';

  @override
  String get hsOpenGit => 'GitHub-Repo öffnen';

  @override
  String get hsRecent => 'Zuletzt verwendete Projekte';

  @override
  String get hsRemovingRecent => ' - aus dem Verlauf entfernen';

  @override
  String hsSkippedInvalid(Object path) {
    return 'Ungültige ARB-Datei übersprungen: \$$path';
  }

  @override
  String get ssAddEntries => 'Einträge hinzufügen';

  @override
  String get ssAddLocale => 'Sprache hinzufügen';

  @override
  String get ssAllDone => 'Alles erledigt!';

  @override
  String get ssChooseService => 'Dienst auswählen';

  @override
  String get ssCompare => 'Vergleichs-Sprache:';

  @override
  String get ssCopyJSON => '.json kopieren';

  @override
  String get ssCopyPrompt => 'Prompt kopieren';

  @override
  String ssFailedZIP(Object error) {
    return 'Fehler beim Erstellen der Zip-Datei: $error';
  }

  @override
  String get ssInvalidJSON => 'Ungültiges JSON-Format';

  @override
  String get ssKeySource => 'Schlüssel-Quelle';

  @override
  String get ssList => 'Liste';

  @override
  String get ssNewKV => '\t\"neue(r) Schlüssel\": \"Neue(r) Wert(e)\",';

  @override
  String get ssNewLocale => 'Neue Sprache:';

  @override
  String get ssPleaseComplete => 'Bitte füllen Sie das Formular aus';

  @override
  String get ssPreview => 'Fehlende in Vorschau anzeigen';

  @override
  String get ssPreviewCompare => 'Vergleichen (Schlüssel)';

  @override
  String get ssPreviewTruth => 'Wahrheit (Schlüssel & Werte)';

  @override
  String get ssRemoveEntry => 'Einträge entfernen';

  @override
  String get ssRemoveLocale => 'Sprache(n) entfernen';

  @override
  String get ssRemoving => 'Entfernen';

  @override
  String get ssSaveAll => 'Alle speichern';

  @override
  String get ssSelf => 'Selbst';

  @override
  String get ssSource => 'Quell-Sprache:';

  @override
  String get ssTODO => 'TODO:';

  @override
  String get ssToDone => 'ERLEDIGT:';

  @override
  String get ssToRemove => 'Schlüssel zum Entfernen auswählen';

  @override
  String get ssUndo => 'Auswahl rückgängig machen';

  @override
  String get ssWrap => 'Zeilenumbruch';

  @override
  String wFailedCommit(Object error) {
    return 'Fehler beim Committen der Änderungen: $error';
  }

  @override
  String get wsHighlight => 'Hervorheben';

  @override
  String get wsShowEmpty => 'Leere anzeigen';

  @override
  String get wsShowIdentical => 'Identische anzeigen';
}
