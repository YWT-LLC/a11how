// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'lang.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class LangDe extends Lang {
  LangDe([String locale = 'de']) : super(locale);

  @override
  String get hsNothingFound => 'Nothing found';

  @override
  String get hsRemovingRecent => ' - removing from recent';

  @override
  String get gNoEmpty => 'Cannot be empty';

  @override
  String get gInvalidURL => 'Invalid URL';

  @override
  String get hsOnlyGit => 'Only GitHub URLs are supported at this time';

  @override
  String get hsFullPath => 'Please provide the full path to the .arb directory';

  @override
  String get hsDeveloping => 'Developing';

  @override
  String get hsContributing => 'Contributing';

  @override
  String get hsOpenDir => 'Open .arb directory';

  @override
  String get hsOpenGit => 'Open GitHub repo';

  @override
  String get hsGitTip =>
      'You will need a GitHub account to contribute.\nIf/when you have a GitHub account, you will also need to make a Personal Access Token (PAT) a11how can use.\n\nWe save NOTHING.\n\nSource code:\nhttps://github.com/YWT-LLC/a11how';

  @override
  String get hsRecent => 'Recent projects';

  @override
  String gDeleteFailure(Object error) {
    return 'Failure to delete file: $error';
  }

  @override
  String get ssSelf => 'Self';

  @override
  String get ssSource => 'Source locale:';

  @override
  String get ssCompare => 'Compare locale:';

  @override
  String get ssWrap => 'Wrap';

  @override
  String get ssList => 'List';

  @override
  String get gFilter => 'Filter';

  @override
  String get ssRemoving => 'Removing';

  @override
  String get ssSaveAll => 'Save all';

  @override
  String get ssAllDone => 'All done!';

  @override
  String get ssRemoveLocale => 'Remove locale(s)';

  @override
  String get ssUndo => 'Undo select';

  @override
  String get ssAddEntries => 'Add entries';

  @override
  String get ssAddLocale => 'Add locale';

  @override
  String get ssInvalidJSON => 'Invalid JSON format';

  @override
  String get gAdd => 'Add';

  @override
  String get gResolveIssues => 'Resolve issues please';

  @override
  String get ssTODO => 'TODO:';

  @override
  String get ssToDone => 'toDONE:';

  @override
  String get ssPreview => 'Preview missing';

  @override
  String get ssPreviewTruth => 'Truth (keys & values)';

  @override
  String get ssPreviewCompare => 'Compare (keys)';

  @override
  String get ssCopyJSON => 'Copy .json';

  @override
  String get gCopied => 'Copied!';

  @override
  String get ssNewKV => '\t\"newKey(s)\": \"New value(s)\",';

  @override
  String get ssRemoveEntry => 'Remove entries';

  @override
  String get ssKeySource => 'Key source';

  @override
  String get ssToRemove => 'Select keys to remove';

  @override
  String get gToggleCase => 'Toggle case sensitivity';

  @override
  String gInvalidRegex(Object regex) {
    return 'Invalid; $regex';
  }

  @override
  String get gNeedPAT => 'Git PAT required to submit changes.';

  @override
  String get gAuthFailed => 'Authentication failed';

  @override
  String gFailedFileStatus(Object error) {
    return 'Failed to verify file status: $error';
  }

  @override
  String get ssNewLocale => 'New locale:';

  @override
  String get ssChooseService => 'Choose service';

  @override
  String get ssCopyPrompt => 'Copy prompt';

  @override
  String get ssPleaseComplete => 'Please complete the form';

  @override
  String ssFailedZIP(Object error) {
    return 'Failed to create zip: $error';
  }

  @override
  String gFailedSave(Object error) {
    return 'Failed to save file: $error';
  }

  @override
  String get gFailedFork => 'Failed to create fork.';

  @override
  String get wsHighlight => 'Highlight';

  @override
  String get wsShowEmpty => 'Show empty';

  @override
  String get wsShowIdentical => 'Show identical';

  @override
  String gFailedPR(Object error) {
    return 'Failed to open PR: $error';
  }

  @override
  String gPRExists(Object error) {
    return 'PR might already exist: $error';
  }

  @override
  String gGitError(Object error) {
    return 'GitHub error: $error';
  }

  @override
  String get gPROpened => 'PR opened!';

  @override
  String hsSkippedInvalid(Object path) {
    return 'Skipped invalid ARB file: \$$path';
  }
}
