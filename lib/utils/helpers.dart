/* a11how
 * Copyright (c) 2026 YWT. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import './export.dart';
import 'package:ywt_private/ywt_private.dart' as ywt;

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
        title: Text(l10n(config).gEnterPAT, textAlign: TextAlign.center),
        contents: <Widget>[
          Text(
            l10n(config).gPATPolicy,
            textAlign: TextAlign.center,
            style: config.bodyStyle,
          ),
          EzLink(
            config,
            text: l10n(config).gSourceCode,
            style: config.bodyStyle,
            hint: l10n(config).gOpenRepo,
            url: Uri.parse('${ywt.a11howGitHub}/blob/main/lib/utils/helpers.dart'),
          ),
          config.spacer,
          EzTextField(
            constraints: ezTextFieldConstraints(dCon),
            obscureText: true,
            hintText: l10n(config).gPAT,
            style: config.bodyStyle,
            controller: patController,
            onFieldSubmitted: (String pat) => Navigator.of(dCon).pop(pat.trim()),
            validator: (_) => null,
          ),
          config.margin,
          EzLink(
            config,
            text: l10n(config).gWhatsPAT,
            style: config.labelStyle,
            hint: l10n(config).gOpenDocs,
            url: Uri.parse(
                'https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens'),
          ),
          EzTitledDivider(
            config,
            title: Text(
              l10n(config).gPolicyTitle,
              textAlign: TextAlign.center,
              style: config.titleStyle,
            ),
            height: config.spacing * 2,
          ),
          Text(
            l10n(config).gPolicyPolicy,
            textAlign: TextAlign.center,
            style: config.bodyStyle,
          ),
        ],
        actions: <EzAction>[
          EzAction(
            config,
            text: l10n(config).gSubmit,
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

    final Map<String, dynamic> sortedMap = <String, dynamic>{'@@locale': arb.localeCode};
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
        message: l10n(config).gWriteFailed(arb.path, e.toString()),
      );
    }
  }
}
