/* a11how
 * Copyright (c) 2026 YWT (Empathetech LLC). All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../utils/export.dart';

import 'package:open_ui/open_ui.dart';

// Setup //

/// a11how
const String appName = 'a11how';

/// llc.ywt.a11how
const String androidPackage = 'llc.ywt.a11how';

const String developingKey = 'developing';
const String recentDirsKey = 'recentDirs';
const String recentUrlsKey = 'recentUrls';

const String removeCaseSensitiveKey = 'removeCaseSensitive';
const String removeFilterTypeKey = 'removeFilterType';

const String workCaseSensitiveKey = 'workCaseSensitive';
const String workFilterTargetKey = 'workFilterTarget';
const String workFilterTypeKey = 'workFilterType';

const Map<String, Type> uniquePairs = <String, Type>{
  developingKey: bool,
  recentDirsKey: List<String>,
  recentUrlsKey: List<String>,
  removeCaseSensitiveKey: bool,
  removeFilterTypeKey: String,
  workCaseSensitiveKey: bool,
  workFilterTargetKey: String,
  workFilterTypeKey: String,
};

const Map<String, Type> neverResetPairs = uniquePairs;

const Map<String, Type> allA11howPairs = <String, Type>{
  ...allEzConfigPairs,
  ...uniquePairs,
};

// Runtime //

final Map<String, Object> uniqueDefaults = <String, Object>{
  developingKey: false,
  recentDirsKey: <String>[],
  recentUrlsKey: <String>[],
  removeCaseSensitiveKey: false,
  removeFilterTypeKey: FilterType.contains.value,
  workCaseSensitiveKey: false,
  workFilterTargetKey: FilterTarget.compare.value,
  workFilterTypeKey: FilterType.contains.value,
};

final Map<String, Object> a11HowMobile = <String, Object>{
  ...ywtMobileConfig,
  ...uniqueDefaults,
};

final Map<String, Object> a11HowDesktop = <String, Object>{
  ...ywtDesktopConfig,
  ...uniqueDefaults,
};
