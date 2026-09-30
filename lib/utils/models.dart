/* a11how
 * Copyright (c) 2026 YWT. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

class ARBDir {
  final String path;
  final String? preselected;
  final bool local;
  final List<ARBFile> files;

  const ARBDir({
    required this.path,
    this.preselected,
    required this.local,
    required this.files,
  });
}

class ARBFile {
  final String path;
  final bool local;
  final String localeCode;
  final Map<String, dynamic> entries;

  const ARBFile({
    required this.path,
    required this.local,
    required this.localeCode,
    required this.entries,
  });
}

class WorkPair {
  final ARBFile truth;
  final ARBFile compare;

  const WorkPair({
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
