/* a11how
 * Copyright (c) 2026 YWT. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import 'package:open_ui/open_ui.dart';

//* App config *//

/// a11How
const String appName = 'a11How';

/// llc.ywt.a11how
const String androidPackage = 'llc.ywt.a11how';

const String recentProjectsKey = 'recentProjects';

final Map<String, Object> a11HowMobile = <String, Object>{
  ...ywtMobileConfig,
  recentProjectsKey: <String>[],
};
final Map<String, Object> a11HowDesktop = <String, Object>{
  ...ywtDesktopConfig,
  darkShowBackFABKey: true,
  lightShowBackFABKey: true,
  recentProjectsKey: <String>[],
};
