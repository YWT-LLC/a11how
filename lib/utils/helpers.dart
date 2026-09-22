/* a11how
 * Copyright (c) 2026 YWT. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import './export.dart';

import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:open_ui/open_ui.dart';
import 'package:flutter/material.dart';

Future<String?> getPAT(EzCP config, BuildContext context) async => await showDialog<String?>(
    context: context,
    builder: (BuildContext dCon) {
      final TextEditingController patController = TextEditingController();

      return EzAlertDialog(
        config,
        title: const Text('Enter PAT', textAlign: TextAlign.center),
        contents: <Widget>[
          const Text(
            'This is not saved anywhere. It disappears as soon as the function finishes.',
            textAlign: TextAlign.center,
          ),
          EzLink(
            config,
            text: 'Source code',
            hint: 'Open repo',
            url: Uri.parse('https://github.com/YWT-LLC/a11how/blob/main/lib/screens/work.dart'),
          ),
          config.spacer,
          EzTextField(
            constraints: ezTextFieldConstraints(dCon),
            hintText: 'Personal Access Token',
            controller: patController,
            onFieldSubmitted: (String pat) => Navigator.of(dCon).pop(pat.trim()),
            validator: (_) => null,
          ),
          config.spacer,
          EzLink(
            config,
            text: "What's a PAT?",
            hint: 'Open documentation',
            url: Uri.parse(
                'https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens'),
          ),
        ],
        actions: <EzAction>[
          EzAction(
            config,
            text: 'Submit',
            onPressed: () => Navigator.of(dCon).pop(patController.text.trim()),
          )
        ],
      );
    });

const JsonEncoder a11howEncoder = JsonEncoder.withIndent('  ');

Future<void> writeSortedJson(EzCP config, {required File file, required ARBFile arb}) async {
  try {
    final List<String> sortedKeys = arb.entries.keys.toList()
      ..remove('@@locale')
      ..sort();

    final Map<String, dynamic> sortedMap = <String, dynamic>{'@@locale': arb.localeCode};
    for (final String key in sortedKeys) {
      sortedMap[key] = arb.entries[key];
    }

    await file.writeAsString(a11howEncoder.convert(sortedMap));
  } catch (e) {
    if (ezRootIsMounted) {
      ezLogAlert(
        config,
        // Handled above, dart doesn't realize though
        // ignore: use_build_context_synchronously
        context: ezRootContext,
        message: 'Failed to write to ${arb.path}:\n$e',
      );
    }
  }
}
