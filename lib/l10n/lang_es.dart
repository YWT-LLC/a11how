// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'lang.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class LangEs extends Lang {
  LangEs([String locale = 'es']) : super(locale);

  @override
  String gARBExists(Object path) {
    return '$path.arb ya existe.';
  }

  @override
  String get gAdd => 'Añadir';

  @override
  String get gAuthFailed => 'Autenticación fallida';

  @override
  String get gCompare => 'Comparar';

  @override
  String get gContains => 'Contiene';

  @override
  String get gCopied => '¡Copiado!';

  @override
  String gDeleteFailure(Object error) {
    return 'Error al eliminar el archivo: $error';
  }

  @override
  String get gEnds => 'Termina con';

  @override
  String get gEnterPAT => 'Introducir PAT';

  @override
  String get gFailedFileStatus => 'Error al verificar el estado del archivo.';

  @override
  String get gFailedFork => 'Error al crear el fork.';

  @override
  String gFailedPR(Object error) {
    return 'Error al abrir el PR: $error';
  }

  @override
  String gFailedSave(Object error) {
    return 'Error al guardar el archivo: $error';
  }

  @override
  String get gFilter => 'Filtrar';

  @override
  String gGitError(Object error) {
    return 'Error de GitHub: $error';
  }

  @override
  String gInvalidRegex(Object regex) {
    return 'Inválido; $regex';
  }

  @override
  String get gInvalidURL => 'URL inválida';

  @override
  String get gKey => 'Clave';

  @override
  String get gNeedPAT => 'Se requiere un PAT de Git para enviar los cambios.';

  @override
  String get gNoEmpty => 'No puede estar vacío';

  @override
  String get gOpenDocs => 'Abrir documentación';

  @override
  String get gOpenRepo => 'Abrir repositorio';

  @override
  String get gPAT => 'Token de Acceso Personal';

  @override
  String get gPATPolicy =>
      'Esto no se guarda en ningún lado. Desaparece tan pronto como termina la función.';

  @override
  String gPRExists(Object error) {
    return 'El PR podría ya existir: $error';
  }

  @override
  String get gPROpened => '¡PR abierto!';

  @override
  String get gPolicyPolicy =>
      'Comparamos tu envío con lo que tenemos. Si tu envío parece claramente mejor, lo conservamos.\nSi parece más o menos igual, nos pondremos en contacto contigo para verificar que eres humano y que usaste tu cerebro.\nTal vez el/un LLM hizo un trabajo realmente bueno, pero si podemos estar seguros de que tu trabajo es humano, es mejor.\nLo sentimos, no lo sentimos, bots que extraen datos de este repositorio.\n\nSi tu envío parece incorrecto, pero de una manera competente, nos pondremos en contacto para averiguar qué pasó.\nSi tu envío es incorrecto de una manera incompetente/troll: baneo instantáneo, sin reintentos. No pases por la salida, pero puedes ir a ***...';

  @override
  String get gPolicyTitle => 'Política de contribución';

  @override
  String get gResolveIssues => 'Resuelve los problemas por favor';

  @override
  String get gSourceCode => 'Código fuente';

  @override
  String get gStarts => 'Comienza con';

  @override
  String get gSubmit => 'Enviar';

  @override
  String get gToggleCase => 'Alternar mayúsculas y minúsculas';

  @override
  String get gTruth => 'Verdad';

  @override
  String get gWhatsPAT => '¿Qué es un PAT?';

  @override
  String gWriteFailed(Object error, Object path) {
    return 'Error al escribir en $path:\n$error';
  }

  @override
  String get hsContributing => 'Contribuir';

  @override
  String get hsDeveloping => 'Desarrollar';

  @override
  String get hsFullPath =>
      'Por favor, proporciona la ruta completa al directorio .arb';

  @override
  String get hsGitTip =>
      'Necesitarás una cuenta de GitHub para contribuir.\nSi/cuando tengas una cuenta de GitHub, también necesitarás crear un Token de Acceso Personal (PAT) que a11how pueda usar.\n\nNo guardamos NADA.\n\nCódigo fuente:\nhttps://github.com/YWT-LLC/a11how';

  @override
  String get hsNothingFound => 'No se encontró nada';

  @override
  String get hsOnlyGit => 'Solo se admiten URLs de GitHub en este momento';

  @override
  String get hsOpenDir => 'Abrir directorio .arb';

  @override
  String get hsOpenGit => 'Abrir repositorio de GitHub';

  @override
  String get hsRecent => 'Proyectos recientes';

  @override
  String get hsRemovingRecent => ' - eliminando de recientes';

  @override
  String hsSkippedInvalid(Object path) {
    return 'Se omitió el archivo ARB inválido: \$$path';
  }

  @override
  String get ssAddEntries => 'Añadir entradas';

  @override
  String get ssAddLocale => 'Añadir idioma';

  @override
  String get ssAllDone => '¡Todo listo!';

  @override
  String get ssChooseService => 'Elegir servicio';

  @override
  String get ssCompare => 'Comparar idioma:';

  @override
  String get ssCopyJSON => 'Copiar .json';

  @override
  String get ssCopyPrompt => 'Copiar prompt';

  @override
  String ssFailedZIP(Object error) {
    return 'Error al crear el zip: $error';
  }

  @override
  String get ssInvalidJSON => 'Formato JSON inválido';

  @override
  String get ssKeySource => 'Origen de la clave';

  @override
  String get ssList => 'Lista';

  @override
  String get ssNewKV => '\t\"nuevaClave(s)\": \"Nuevo(s) valor(es)\",';

  @override
  String get ssNewLocale => 'Nuevo idioma:';

  @override
  String get ssPleaseComplete => 'Por favor completa el formulario';

  @override
  String get ssPreview => 'Vista previa de faltantes';

  @override
  String get ssPreviewCompare => 'Comparar (claves)';

  @override
  String get ssPreviewTruth => 'Verdad (claves y valores)';

  @override
  String get ssRemoveEntry => 'Eliminar entradas';

  @override
  String get ssRemoveLocale => 'Eliminar idioma(s)';

  @override
  String get ssRemoving => 'Eliminando';

  @override
  String get ssSaveAll => 'Guardar todo';

  @override
  String get ssSelf => 'Propio';

  @override
  String get ssSource => 'Idioma de origen:';

  @override
  String get ssTODO => 'TODO:';

  @override
  String get ssToDone => 'HECHO:';

  @override
  String get ssToRemove => 'Seleccionar claves para eliminar';

  @override
  String get ssUndo => 'Deshacer selección';

  @override
  String get ssWrap => 'Ajustar';

  @override
  String wFailedCommit(Object error) {
    return 'Error al hacer commit de los cambios: $error';
  }

  @override
  String get wsHighlight => 'Resaltar';

  @override
  String get wsShowEmpty => 'Mostrar vacíos';

  @override
  String get wsShowIdentical => 'Mostrar idénticos';
}
