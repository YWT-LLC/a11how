/* a11how
 * Copyright (c) 2026 YWT. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import './export.dart';

import 'dart:io';

// TODO: redo... just switch data types then use a print for that. don't re-invent
Future<void> writeSortedJson({
  required File file,
  required WorkPair workPair,
  required bool truth,
}) async {
  final Map<String, dynamic> entries = truth ? workPair.truth.entries : workPair.compare.entries;

  final List<String> keys = entries.keys.toList();
  keys.removeWhere((String key) => key.contains('@@locale'));
  keys.sort();

  await file.writeAsString(
      '{\n\t"@@locale": "${truth ? workPair.truth.localeCode : workPair.compare.localeCode}"');
  for (final String key in keys) {
    await file.writeAsString(',\n\t"$key": "${entries[key]}"', mode: FileMode.append);
  }
  await file.writeAsString('\n}', mode: FileMode.append);
}
