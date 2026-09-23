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

const String removeKeyFilterTypeKey = 'removeKeyFilterType';
const String workFilterTypeKey = 'workFilterType';

final Map<String, Object> a11HowMobile = <String, Object>{
  ...ywtMobileConfig,
  developingKey: false,
  recentDirsKey: <String>[],
  recentUrlsKey: <String>[],
  removeKeyFilterTypeKey: FilterType.contains.value,
  workFilterTypeKey: FilterType.startsWith.value,
};

final Map<String, Object> a11HowDesktop = <String, Object>{
  ...ywtDesktopConfig,
  developingKey: false,
  recentDirsKey: <String>[],
  recentUrlsKey: <String>[],
  removeKeyFilterTypeKey: FilterType.contains.value,
  workFilterTypeKey: FilterType.startsWith.value,
};

const Set<String> neverResetKeys = <String>{
  developingKey,
  recentDirsKey,
  recentUrlsKey,
};
