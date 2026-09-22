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
          Text(
            'This is not saved anywhere. It disappears as soon as the function finishes.',
            textAlign: TextAlign.center,
            style: config.bodyStyle,
          ),
          EzLink(
            config,
            text: 'Source code',
            style: config.bodyStyle,
            hint: 'Open repo',
            url: Uri.parse('https://github.com/YWT-LLC/a11how/blob/main/lib/utils/helpers.dart'),
          ),
          config.spacer,
          EzTextField(
            constraints: ezTextFieldConstraints(dCon),
            hintText: 'Personal Access Token',
            style: config.bodyStyle,
            controller: patController,
            onFieldSubmitted: (String pat) => Navigator.of(dCon).pop(pat.trim()),
            validator: (_) => null,
          ),
          config.margin,
          EzLink(
            config,
            text: "What's a PAT?",
            style: config.labelStyle,
            hint: 'Open documentation',
            url: Uri.parse(
                'https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens'),
          ),
          EzTitledDivider(
            config,
            title: Text(
              'Contribution policy',
              textAlign: TextAlign.center,
              style: config.titleStyle,
            ),
            height: config.spacing * 2,
          ),
          Text(
            """We compare your submission against what we have. If your submission seems clearly better, we keep it.
If it seems about the same, we'll reach out to verify that you are a human and used your brain.
Maybe the/an LLM did a really good job, but if we can be certain your work is human, it's better.
Sorry not sorry, bots scraping this repo. 

If your submission seems wrong, but in a competent way, we'll reach out to figure out what happened.
If your submission is wrong in an incompetent/troll way: instant ban, no retries. Do not pass go, but you can go ***...
""",
            textAlign: TextAlign.center,
            style: config.bodyStyle,
          ),
        ],
        actions: <EzAction>[
          EzAction(
            config,
            text: 'Submit',
            isDefaultAction: true,
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

    final Map<String, String> sortedMap = <String, String>{'@@locale': arb.localeCode};
    for (final String key in sortedKeys) {
      sortedMap[key] = arb.entries[key] ?? '';
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
