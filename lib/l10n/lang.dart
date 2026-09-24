import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'lang_de.dart' deferred as lang_de;
import 'lang_en.dart' deferred as lang_en;

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of Lang
/// returned by `Lang.of(context)`.
///
/// Applications need to include `Lang.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/lang.dart';
///
/// return MaterialApp(
///   localizationsDelegates: Lang.localizationsDelegates,
///   supportedLocales: Lang.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the Lang.supportedLocales
/// property.
abstract class Lang {
  Lang(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static Lang? of(BuildContext context) {
    return Localizations.of<Lang>(context, Lang);
  }

  static const LocalizationsDelegate<Lang> delegate = _LangDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('en', 'US')
  ];

  /// No description provided for @gARBExists.
  ///
  /// In en, this message translates to:
  /// **'{path}.arb already exists.'**
  String gARBExists(Object path);

  /// No description provided for @gAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get gAdd;

  /// No description provided for @gAuthFailed.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed'**
  String get gAuthFailed;

  /// No description provided for @gCompare.
  ///
  /// In en, this message translates to:
  /// **'Compare'**
  String get gCompare;

  /// No description provided for @gContains.
  ///
  /// In en, this message translates to:
  /// **'Contains'**
  String get gContains;

  /// No description provided for @gCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied!'**
  String get gCopied;

  /// No description provided for @gDeleteFailure.
  ///
  /// In en, this message translates to:
  /// **'Failure to delete file: {error}'**
  String gDeleteFailure(Object error);

  /// No description provided for @gEnds.
  ///
  /// In en, this message translates to:
  /// **'Ends with'**
  String get gEnds;

  /// No description provided for @gEnterPAT.
  ///
  /// In en, this message translates to:
  /// **'Enter PAT'**
  String get gEnterPAT;

  /// No description provided for @gFailedFileStatus.
  ///
  /// In en, this message translates to:
  /// **'Failed to verify file status.'**
  String get gFailedFileStatus;

  /// No description provided for @gFailedFork.
  ///
  /// In en, this message translates to:
  /// **'Failed to create fork.'**
  String get gFailedFork;

  /// No description provided for @gFailedPR.
  ///
  /// In en, this message translates to:
  /// **'Failed to open PR: {error}'**
  String gFailedPR(Object error);

  /// No description provided for @gFailedSave.
  ///
  /// In en, this message translates to:
  /// **'Failed to save file: {error}'**
  String gFailedSave(Object error);

  /// No description provided for @gFilter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get gFilter;

  /// No description provided for @gGitError.
  ///
  /// In en, this message translates to:
  /// **'GitHub error: {error}'**
  String gGitError(Object error);

  /// No description provided for @gInvalidRegex.
  ///
  /// In en, this message translates to:
  /// **'Invalid; {regex}'**
  String gInvalidRegex(Object regex);

  /// No description provided for @gInvalidURL.
  ///
  /// In en, this message translates to:
  /// **'Invalid URL'**
  String get gInvalidURL;

  /// No description provided for @gKey.
  ///
  /// In en, this message translates to:
  /// **'Key'**
  String get gKey;

  /// No description provided for @gNeedPAT.
  ///
  /// In en, this message translates to:
  /// **'Git PAT required to submit changes.'**
  String get gNeedPAT;

  /// No description provided for @gNoEmpty.
  ///
  /// In en, this message translates to:
  /// **'Cannot be empty'**
  String get gNoEmpty;

  /// No description provided for @gOpenDocs.
  ///
  /// In en, this message translates to:
  /// **'Open documentation'**
  String get gOpenDocs;

  /// No description provided for @gOpenRepo.
  ///
  /// In en, this message translates to:
  /// **'Open repo'**
  String get gOpenRepo;

  /// No description provided for @gPAT.
  ///
  /// In en, this message translates to:
  /// **'Personal Access Token'**
  String get gPAT;

  /// No description provided for @gPATPolicy.
  ///
  /// In en, this message translates to:
  /// **'This is not saved anywhere. It disappears as soon as the function finishes.'**
  String get gPATPolicy;

  /// No description provided for @gPRExists.
  ///
  /// In en, this message translates to:
  /// **'PR might already exist: {error}'**
  String gPRExists(Object error);

  /// No description provided for @gPROpened.
  ///
  /// In en, this message translates to:
  /// **'PR opened!'**
  String get gPROpened;

  /// No description provided for @gPolicyPolicy.
  ///
  /// In en, this message translates to:
  /// **'We compare your submission against what we have. If your submission seems clearly better, we keep it.\nIf it seems about the same, we\'ll reach out to verify that you are a human and used your brain.\nMaybe the/an LLM did a really good job, but if we can be certain your work is human, it\'s better.\nSorry not sorry, bots scraping this repo.\n\nIf your submission seems wrong, but in a competent way, we\'ll reach out to figure out what happened.\nIf your submission is wrong in an incompetent/troll way: instant ban, no retries. Do not pass go, but you can go ***...'**
  String get gPolicyPolicy;

  /// No description provided for @gPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Contribution policy'**
  String get gPolicyTitle;

  /// No description provided for @gResolveIssues.
  ///
  /// In en, this message translates to:
  /// **'Resolve issues please'**
  String get gResolveIssues;

  /// No description provided for @gSourceCode.
  ///
  /// In en, this message translates to:
  /// **'Source code'**
  String get gSourceCode;

  /// No description provided for @gStarts.
  ///
  /// In en, this message translates to:
  /// **'Starts with'**
  String get gStarts;

  /// No description provided for @gSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get gSubmit;

  /// No description provided for @gToggleCase.
  ///
  /// In en, this message translates to:
  /// **'Toggle case sensitivity'**
  String get gToggleCase;

  /// No description provided for @gTruth.
  ///
  /// In en, this message translates to:
  /// **'Truth'**
  String get gTruth;

  /// No description provided for @gWhatsPAT.
  ///
  /// In en, this message translates to:
  /// **'What\'s a PAT?'**
  String get gWhatsPAT;

  /// No description provided for @gWriteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to write to {path}:\n{error}'**
  String gWriteFailed(Object error, Object path);

  /// No description provided for @hsContributing.
  ///
  /// In en, this message translates to:
  /// **'Contributing'**
  String get hsContributing;

  /// No description provided for @hsDeveloping.
  ///
  /// In en, this message translates to:
  /// **'Developing'**
  String get hsDeveloping;

  /// No description provided for @hsFullPath.
  ///
  /// In en, this message translates to:
  /// **'Please provide the full path to the .arb directory'**
  String get hsFullPath;

  /// No description provided for @hsGitTip.
  ///
  /// In en, this message translates to:
  /// **'You will need a GitHub account to contribute.\nIf/when you have a GitHub account, you will also need to make a Personal Access Token (PAT) a11how can use.\n\nWe save NOTHING.\n\nSource code:\nhttps://github.com/YWT-LLC/a11how'**
  String get hsGitTip;

  /// No description provided for @hsNothingFound.
  ///
  /// In en, this message translates to:
  /// **'Nothing found'**
  String get hsNothingFound;

  /// No description provided for @hsOnlyGit.
  ///
  /// In en, this message translates to:
  /// **'Only GitHub URLs are supported at this time'**
  String get hsOnlyGit;

  /// No description provided for @hsOpenDir.
  ///
  /// In en, this message translates to:
  /// **'Open .arb directory'**
  String get hsOpenDir;

  /// No description provided for @hsOpenGit.
  ///
  /// In en, this message translates to:
  /// **'Open GitHub repo'**
  String get hsOpenGit;

  /// No description provided for @hsRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent projects'**
  String get hsRecent;

  /// No description provided for @hsRemovingRecent.
  ///
  /// In en, this message translates to:
  /// **' - removing from recent'**
  String get hsRemovingRecent;

  /// No description provided for @hsSkippedInvalid.
  ///
  /// In en, this message translates to:
  /// **'Skipped invalid ARB file: \${path}'**
  String hsSkippedInvalid(Object path);

  /// No description provided for @ssAddEntries.
  ///
  /// In en, this message translates to:
  /// **'Add entries'**
  String get ssAddEntries;

  /// No description provided for @ssAddLocale.
  ///
  /// In en, this message translates to:
  /// **'Add locale'**
  String get ssAddLocale;

  /// No description provided for @ssAllDone.
  ///
  /// In en, this message translates to:
  /// **'All done!'**
  String get ssAllDone;

  /// No description provided for @ssChooseService.
  ///
  /// In en, this message translates to:
  /// **'Choose service'**
  String get ssChooseService;

  /// No description provided for @ssCompare.
  ///
  /// In en, this message translates to:
  /// **'Compare locale:'**
  String get ssCompare;

  /// No description provided for @ssCopyJSON.
  ///
  /// In en, this message translates to:
  /// **'Copy .json'**
  String get ssCopyJSON;

  /// No description provided for @ssCopyPrompt.
  ///
  /// In en, this message translates to:
  /// **'Copy prompt'**
  String get ssCopyPrompt;

  /// No description provided for @ssFailedZIP.
  ///
  /// In en, this message translates to:
  /// **'Failed to create zip: {error}'**
  String ssFailedZIP(Object error);

  /// No description provided for @ssInvalidJSON.
  ///
  /// In en, this message translates to:
  /// **'Invalid JSON format'**
  String get ssInvalidJSON;

  /// No description provided for @ssKeySource.
  ///
  /// In en, this message translates to:
  /// **'Key source'**
  String get ssKeySource;

  /// No description provided for @ssList.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get ssList;

  /// No description provided for @ssNewKV.
  ///
  /// In en, this message translates to:
  /// **'\t\"newKey(s)\": \"New value(s)\",'**
  String get ssNewKV;

  /// No description provided for @ssNewLocale.
  ///
  /// In en, this message translates to:
  /// **'New locale:'**
  String get ssNewLocale;

  /// No description provided for @ssPleaseComplete.
  ///
  /// In en, this message translates to:
  /// **'Please complete the form'**
  String get ssPleaseComplete;

  /// No description provided for @ssPreview.
  ///
  /// In en, this message translates to:
  /// **'Preview missing'**
  String get ssPreview;

  /// No description provided for @ssPreviewCompare.
  ///
  /// In en, this message translates to:
  /// **'Compare (keys)'**
  String get ssPreviewCompare;

  /// No description provided for @ssPreviewTruth.
  ///
  /// In en, this message translates to:
  /// **'Truth (keys & values)'**
  String get ssPreviewTruth;

  /// No description provided for @ssRemoveEntry.
  ///
  /// In en, this message translates to:
  /// **'Remove entries'**
  String get ssRemoveEntry;

  /// No description provided for @ssRemoveLocale.
  ///
  /// In en, this message translates to:
  /// **'Remove locale(s)'**
  String get ssRemoveLocale;

  /// No description provided for @ssRemoving.
  ///
  /// In en, this message translates to:
  /// **'Removing'**
  String get ssRemoving;

  /// No description provided for @ssSaveAll.
  ///
  /// In en, this message translates to:
  /// **'Save all'**
  String get ssSaveAll;

  /// No description provided for @ssSelf.
  ///
  /// In en, this message translates to:
  /// **'Self'**
  String get ssSelf;

  /// No description provided for @ssSource.
  ///
  /// In en, this message translates to:
  /// **'Source locale:'**
  String get ssSource;

  /// No description provided for @ssTODO.
  ///
  /// In en, this message translates to:
  /// **'TODO:'**
  String get ssTODO;

  /// No description provided for @ssToDone.
  ///
  /// In en, this message translates to:
  /// **'toDONE:'**
  String get ssToDone;

  /// No description provided for @ssToRemove.
  ///
  /// In en, this message translates to:
  /// **'Select keys to remove'**
  String get ssToRemove;

  /// No description provided for @ssUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo select'**
  String get ssUndo;

  /// No description provided for @ssWrap.
  ///
  /// In en, this message translates to:
  /// **'Wrap'**
  String get ssWrap;

  /// No description provided for @wFailedCommit.
  ///
  /// In en, this message translates to:
  /// **'Failed to commit changes: {error}'**
  String wFailedCommit(Object error);

  /// No description provided for @wsHighlight.
  ///
  /// In en, this message translates to:
  /// **'Highlight'**
  String get wsHighlight;

  /// No description provided for @wsShowEmpty.
  ///
  /// In en, this message translates to:
  /// **'Show empty'**
  String get wsShowEmpty;

  /// No description provided for @wsShowIdentical.
  ///
  /// In en, this message translates to:
  /// **'Show identical'**
  String get wsShowIdentical;
}

class _LangDelegate extends LocalizationsDelegate<Lang> {
  const _LangDelegate();

  @override
  Future<Lang> load(Locale locale) {
    return lookupLang(locale);
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_LangDelegate old) => false;
}

Future<Lang> lookupLang(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'en':
      {
        switch (locale.countryCode) {
          case 'US':
            return lang_en
                .loadLibrary()
                .then((dynamic _) => lang_en.LangEnUs());
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return lang_de.loadLibrary().then((dynamic _) => lang_de.LangDe());
    case 'en':
      return lang_en.loadLibrary().then((dynamic _) => lang_en.LangEn());
  }

  throw FlutterError(
      'Lang.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
