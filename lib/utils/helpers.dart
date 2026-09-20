/* a11how
 * Copyright (c) 2026 YWT. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import './export.dart';

import 'dart:io';

Future<void> writeSortedJson({required File file, required ARBFile arb}) async {
  final Map<String, dynamic> entries = arb.entries;

  final List<String> keys = entries.keys.toList();
  keys.removeWhere((String key) => key.contains('@@locale'));
  keys.sort();

  await file.writeAsString('{\n\t"@@locale": "${arb.localeCode}"');
  for (final String key in keys) {
    await file.writeAsString(',\n\t"$key": "${entries[key]}"', mode: FileMode.append);
  }
  await file.writeAsString('\n}', mode: FileMode.append);
}
