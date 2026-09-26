// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'lang.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class LangFr extends Lang {
  LangFr([String locale = 'fr']) : super(locale);

  @override
  String gARBExists(Object path) {
    return '$path.arb existe déjà.';
  }

  @override
  String get gAdd => 'Ajouter';

  @override
  String get gAuthFailed => 'Échec de l\'authentification';

  @override
  String get gCompare => 'Comparer';

  @override
  String get gContains => 'Contient';

  @override
  String get gCopied => 'Copié !';

  @override
  String gDeleteFailure(Object error) {
    return 'Échec de la suppression du fichier : $error';
  }

  @override
  String get gEnds => 'Se termine par';

  @override
  String get gEnterPAT => 'Saisir le PAT';

  @override
  String get gFailedFileStatus =>
      'Échec de la vérification de l\'état du fichier.';

  @override
  String get gFailedFork => 'Échec de la création du fork.';

  @override
  String gFailedPR(Object error) {
    return 'Échec de l\'ouverture de la PR : $error';
  }

  @override
  String gFailedSave(Object error) {
    return 'Échec de l\'enregistrement du fichier : $error';
  }

  @override
  String get gFilter => 'Filtrer';

  @override
  String gGitError(Object error) {
    return 'Erreur GitHub : $error';
  }

  @override
  String gInvalidRegex(Object regex) {
    return 'Invalide ; $regex';
  }

  @override
  String get gInvalidURL => 'URL invalide';

  @override
  String get gKey => 'Clé';

  @override
  String get gNeedPAT =>
      'Un PAT Git est requis pour soumettre les modifications.';

  @override
  String get gNoEmpty => 'Ne peut pas être vide';

  @override
  String get gOpenDocs => 'Ouvrir la documentation';

  @override
  String get gOpenRepo => 'Ouvrir le dépôt';

  @override
  String get gPAT => 'Jeton d\'accès personnel';

  @override
  String get gPATPolicy =>
      'Ceci n\'est enregistré nulle part. Il disparaît dès que la fonction se termine.';

  @override
  String gPRExists(Object error) {
    return 'La PR existe peut-être déjà : $error';
  }

  @override
  String get gPROpened => 'PR ouverte !';

  @override
  String get gPolicyPolicy =>
      'Nous comparons votre soumission à ce que nous avons. Si votre soumission semble nettement meilleure, nous la gardons.\nSi elle semble à peu près identique, nous vous contacterons pour vérifier que vous êtes un humain et que vous avez utilisé votre cerveau.\nPeut-être qu\'un LLM a fait du très bon travail, mais si nous pouvons être certains que votre travail est humain, c\'est mieux.\nDésolé pour les bots qui récupèrent ce dépôt, mais pas désolé.\n\nSi votre soumission semble incorrecte, mais d\'une manière compétente, nous vous contacterons pour comprendre ce qui s\'est passé.\nSi votre soumission est incorrecte d\'une manière incompétente/troll : bannissement instantané, aucun nouvel essai. Ne passez pas par la case départ, mais vous pouvez aller vous ***...';

  @override
  String get gPolicyTitle => 'Politique de contribution';

  @override
  String get gResolveIssues => 'Veuillez résoudre les problèmes';

  @override
  String get gSourceCode => 'Code source';

  @override
  String get gStarts => 'Commence par';

  @override
  String get gSubmit => 'Soumettre';

  @override
  String get gToggleCase => 'Basculer la sensibilité à la casse';

  @override
  String get gTruth => 'Vérité';

  @override
  String get gWhatsPAT => 'Qu\'est-ce qu\'un PAT ?';

  @override
  String gWriteFailed(Object error, Object path) {
    return 'Échec de l\'écriture dans $path :\n$error';
  }

  @override
  String get hsContributing => 'Contribution';

  @override
  String get hsDeveloping => 'Développement';

  @override
  String get hsFullPath =>
      'Veuillez fournir le chemin complet vers le répertoire .arb';

  @override
  String hsGitTip(Object link) {
    return 'Vous aurez besoin d\'un compte GitHub pour contribuer.\nSi/quand vous aurez un compte GitHub, vous devrez également créer un jeton d\'accès personnel (PAT) qu\'a11how pourra utiliser.\n\nNous n\'enregistrons RIEN.\n\nCode source :\n$link';
  }

  @override
  String get hsNothingFound => 'Aucun résultat trouvé';

  @override
  String get hsOnlyGit =>
      'Seules les URL GitHub sont prises en charge pour le moment';

  @override
  String get hsOpenDir => 'Ouvrir le répertoire .arb';

  @override
  String get hsOpenGit => 'Ouvrir le dépôt GitHub';

  @override
  String get hsRecent => 'Projets récents';

  @override
  String get hsRemovingRecent => ' - suppression des récents';

  @override
  String hsSkippedInvalid(Object path) {
    return 'Fichier ARB invalide ignoré : \$$path';
  }

  @override
  String get ssAddEntries => 'Ajouter des entrées';

  @override
  String get ssAddLocale => 'Ajouter une locale';

  @override
  String get ssAllDone => 'Terminé !';

  @override
  String get ssChooseService => 'Choisir le service';

  @override
  String get ssCompare => 'Comparer la locale :';

  @override
  String get ssCopyJSON => 'Copier le .json';

  @override
  String get ssCopyPrompt => 'Copier le prompt';

  @override
  String ssFailedZIP(Object error) {
    return 'Échec de la création du zip : $error';
  }

  @override
  String get ssInvalidJSON => 'Format JSON invalide';

  @override
  String get ssKeySource => 'Source de la clé';

  @override
  String get ssList => 'Liste';

  @override
  String get ssNewKV => '\t\"nouvelle(s)Cle(s)\": \"Nouvelle(s) valeur(s)\",';

  @override
  String get ssNewLocale => 'Nouvelle locale :';

  @override
  String get ssPleaseComplete => 'Veuillez remplir le formulaire';

  @override
  String get ssPreview => 'Aperçu des manquants';

  @override
  String get ssPreviewCompare => 'Comparer (clés)';

  @override
  String get ssPreviewTruth => 'Vérité (clés et valeurs)';

  @override
  String get ssRemoveEntry => 'Supprimer des entrées';

  @override
  String get ssRemoveLocale => 'Supprimer la/les locale(s)';

  @override
  String get ssRemoving => 'Suppression';

  @override
  String get ssSaveAll => 'Tout enregistrer';

  @override
  String get ssSelf => 'Soi-même';

  @override
  String get ssSource => 'Locale source :';

  @override
  String get ssTODO => 'À FAIRE :';

  @override
  String get ssToDone => 'FAIT :';

  @override
  String get ssToRemove => 'Sélectionner les clés à supprimer';

  @override
  String get ssUndo => 'Annuler la sélection';

  @override
  String get ssWrap => 'Retour à la ligne';

  @override
  String wFailedCommit(Object error) {
    return 'Échec du commit des modifications : $error';
  }

  @override
  String get wsHighlight => 'Mettre en surbrillance';

  @override
  String get wsShowEmpty => 'Afficher les vides';

  @override
  String get wsShowIdentical => 'Afficher les identiques';
}
