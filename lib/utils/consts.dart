/* a11how
 * Copyright (c) 2026 YWT. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

/// a11How
const String appName = 'a11How';

/// llc.ywt.a11how
const String androidPackage = 'llc.ywt.a11how';

class ARBFile {
  final String filePath;
  final String localeCode;
  final Map<String, dynamic> translations;

  ARBFile({
    required this.filePath,
    required this.localeCode,
    required this.translations,
  });
}
