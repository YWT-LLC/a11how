/* a11how
 * Copyright (c) 2026 YWT. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

class ARBDir {
  final String path;
  final List<ARBFile> files;

  ARBDir({
    required this.path,
    required this.files,
  });
}

class ARBFile {
  final String path;
  final String localeCode;
  final Map<String, dynamic> entries;

  ARBFile({
    required this.path,
    required this.localeCode,
    required this.entries,
  });
}

class WorkPair {
  final ARBFile truth;
  final ARBFile compare;

  WorkPair({
    required this.truth,
    required this.compare,
  });
}

class WorkRow {
  String key;
  String truth;
  String compare;

  WorkRow({
    required this.key,
    required this.truth,
    required this.compare,
  });
}
