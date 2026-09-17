/* a11how
 * Copyright (c) 2026 YWT. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../utils/export.dart';
import '../widgets/export.dart';

import 'dart:io';
import 'dart:convert';
import 'package:open_ui/open_ui.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WorkScreen extends StatefulWidget {
  final WorkPair workPair;

  const WorkScreen(this.workPair, {super.key});

  @override
  State<WorkScreen> createState() => _WorkScreenState();
}

class _WorkScreenState extends State<WorkScreen> {
  // Define the build data //

  bool keyChanges = false;
  bool saving = false;

  // Define custom functions //

  Future<void> save(EzCP config) async {
    if (saving) return;
    setState(() => saving = true);

    // Truth
    try {
      final File file = File(widget.workPair.truth.path);

      final String jsonString =
          const JsonEncoder.withIndent('  ').convert(widget.workPair.truth.entries);
      await file.writeAsString(jsonString);
    } catch (e) {
      if (mounted) ezSnackBar(config, context: context, message: 'Failure saving truth: $e');
    }

    // Compare
    try {
      final File file = File(widget.workPair.compare.path);

      final String jsonString =
          const JsonEncoder.withIndent('  ').convert(widget.workPair.compare.entries);
      await file.writeAsString(jsonString);

      if (mounted) ezSnackBar(config, context: context, message: 'Success!');
    } catch (e) {
      if (mounted) ezSnackBar(config, context: context, message: 'Failure saving compare: $e');
    }

    if (mounted) setState(() => saving = false);
  }

  // Return the build //

  @override
  Widget build(BuildContext context) {
    return Consumer<EzCP>(
      builder: (_, EzCP config, __) {
        final BoxConstraints oneThird = BoxConstraints(maxWidth: widthOf(context) * 0.333);

        return A11howScaffold(config,
            body: EzScreen(
              config,
              margin: EdgeInsets.zero,
              child: EzScrollView(config, children: <Widget>[
                EzRow(
                  config,
                  reverseHands: false,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Keys
                    EzCol(
                      children: widget.workPair.truth.entries.keys
                          .map((String key) => EzTextField(
                                constraints: oneThird,
                                hintText: key,
                                style: config.bodyStyle,
                                textAlign: TextAlign.start,
                                validator: (_) => null,
                              ))
                          .toList(),
                    ),

                    // Truth
                    EzCol(
                      children: widget.workPair.truth.entries.entries
                          .map((MapEntry<String, dynamic> entry) => EzTextField(
                                constraints: oneThird,
                                hintText: entry.value as String,
                                style: config.bodyStyle,
                                textAlign: TextAlign.start,
                                validator: (_) => null,
                              ))
                          .toList(),
                    ),

                    // Work
                    EzCol(
                      children: widget.workPair.compare.entries.entries
                          .map((MapEntry<String, dynamic> entry) => EzTextField(
                                constraints: oneThird,
                                hintText: entry.value as String,
                                style: config.bodyStyle,
                                textAlign: TextAlign.start,
                                onChanged: (String newValue) =>
                                    widget.workPair.compare.entries[entry.key] = newValue,
                                validator: (_) => null,
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ]),
            ),
            fabs: <Widget>[
              FloatingActionButton(
                heroTag: 'save_FAB',
                onPressed: saving ? null : () => save(config),
                tooltip: config.ezL10n.gSave,
                child: saving ? const CircularProgressIndicator() : EzIcon(config, Icons.save),
              ),
            ]);
      },
    );
  }
}
