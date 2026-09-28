/* a11how
 * Copyright (c) 2026 YWT. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../utils/export.dart';

import 'package:open_ui/open_ui.dart';

//* App config *//

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

final Map<String, Object> a11HowMobile = <String, Object>{
  ...ywtMobileConfig,
  developingKey: false,
  recentDirsKey: <String>[],
  recentUrlsKey: <String>[],
  removeCaseSensitiveKey: false,
  removeFilterTypeKey: FilterType.contains.value,
  workCaseSensitiveKey: false,
  workFilterTargetKey: FilterTarget.compare.value,
  workFilterTypeKey: FilterType.contains.value,
};

final Map<String, Object> a11HowDesktop = <String, Object>{
  ...ywtDesktopConfig,
  developingKey: false,
  recentDirsKey: <String>[],
  recentUrlsKey: <String>[],
  removeCaseSensitiveKey: false,
  removeFilterTypeKey: FilterType.contains.value,
  workCaseSensitiveKey: false,
  workFilterTargetKey: FilterTarget.compare.value,
  workFilterTypeKey: FilterType.contains.value,
};

/// aka all a11how keys
const Set<String> neverResetKeys = <String>{
  developingKey,
  recentDirsKey,
  recentUrlsKey,
  removeCaseSensitiveKey,
  removeFilterTypeKey,
  workCaseSensitiveKey,
  workFilterTargetKey,
  workFilterTypeKey,
};
