/* a11how
 * Copyright (c) 2026 YWT. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import './export.dart';

import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:open_ui/open_ui.dart';

const JsonEncoder _encoder = JsonEncoder.withIndent('\t');

Future<void> writeSortedJson(EzCP config, {required File file, required ARBFile arb}) async {
  try {
    final List<String> keys = arb.entries.keys.toList()
      ..remove('@@locale')
      ..sort();

    final Map<String, dynamic> sortedMap = <String, dynamic>{'@@locale': arb.localeCode};
    for (final String key in keys) {
      sortedMap[key] = arb.entries[key];
    }

    await file.writeAsString(_encoder.convert(sortedMap));
  } catch (e) {
    if (ezRootIsMounted) {
      unawaited(ezLogAlert(
        config,
        // Handled above, dart doesn't realize though
        // ignore: use_build_context_synchronously
        context: ezRootContext,
        message: 'Failed to write to ${arb.path}:\n$e',
      ));
    }
  }
}
