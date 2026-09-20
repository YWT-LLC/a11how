/* a11how
 * Copyright (c) 2026 YWT. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import './export.dart';

import 'dart:io';
import 'dart:convert';

const JsonEncoder _encoder = JsonEncoder.withIndent('\t');

Future<void> writeSortedJson({required File file, required ARBFile arb}) async {
  final List<String> keys = arb.entries.keys.toList()
    ..remove('@@locale')
    ..sort();

  final Map<String, dynamic> sortedMap = <String, dynamic>{'@@locale': arb.localeCode};
  for (final String key in keys) {
    sortedMap[key] = arb.entries[key];
  }

  await file.writeAsString(_encoder.convert(sortedMap));
}
