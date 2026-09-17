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

  final List<WorkRow> workData = <WorkRow>[];

  bool moving = false;

  bool keyChanges = false;
  bool saving = false;

  // Define custom functions //

  Future<void> save(EzCP config) async {
    if (saving) return;
    setState(() => saving = true);

    // Prep
    final Map<String, dynamic> updatedTruth = <String, dynamic>{};
    final Map<String, dynamic> updatedCompare = <String, dynamic>{};

    for (final WorkRow row in workData) {
      if (row.key.trim().isEmpty) continue;

      updatedTruth[row.key] = row.truth;
      updatedCompare[row.key] = row.compare;
    }

    // Save Truth
    try {
      final File file = File(widget.workPair.truth.path);
      widget.workPair.truth.entries
        ..clear()
        ..addAll(updatedTruth);

      final String jsonString =
          const JsonEncoder.withIndent('  ').convert(widget.workPair.truth.entries);
      await file.writeAsString(jsonString);
    } catch (e) {
      if (mounted) ezSnackBar(config, context: context, message: 'Failure saving truth: $e');
    }

    // Save Compare
    try {
      final File file = File(widget.workPair.compare.path);
      widget.workPair.compare.entries
        ..clear()
        ..addAll(updatedCompare);

      final String jsonString =
          const JsonEncoder.withIndent('  ').convert(widget.workPair.compare.entries);
      await file.writeAsString(jsonString);

      if (mounted) ezSnackBar(config, context: context, message: 'Success!');
    } catch (e) {
      if (mounted) ezSnackBar(config, context: context, message: 'Failure saving compare: $e');
    }

    if (mounted) setState(() => saving = false);
  }

  // Init //

  @override
  void initState() {
    super.initState();

    for (final String key in widget.workPair.truth.entries.keys) {
      workData.add(WorkRow(
        key: key,
        truth: widget.workPair.truth.entries[key]?.toString() ?? '',
        compare: widget.workPair.compare.entries[key]?.toString() ?? '',
      ));
    }
  }

  // Return the build //

  @override
  Widget build(BuildContext context) {
    return Consumer<EzCP>(
      builder: (_, EzCP config, __) {
        final BoxConstraints oneThird = BoxConstraints(maxWidth: widthOf(context) * 0.333);

        return A11howScaffold(
          config,
          body: EzScreen(
            config,
            margin: EdgeInsets.zero,
            child: EzScrollView(
              config,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: workData
                  .map((WorkRow row) => EzRow(
                        config,
                        reverseHands: false,
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          // Key
                          EzTextField(
                            constraints: oneThird,
                            hintText: row.key,
                            initialValue: row.key,
                            style: config.bodyStyle,
                            textAlign: TextAlign.start,
                            onChanged: (String val) {
                              row.key = val;
                              keyChanges = true;
                            },
                            validator: (_) => null,
                          ),

                          // Truth
                          EzTextField(
                            constraints: oneThird,
                            hintText: row.truth,
                            initialValue: row.truth,
                            style: config.bodyStyle,
                            textAlign: TextAlign.start,
                            onChanged: (String val) => row.truth = val,
                            validator: (_) => null,
                          ),

                          // Work
                          EzTextField(
                            constraints: oneThird,
                            hintText: row.compare,
                            initialValue: row.compare,
                            style: config.bodyStyle,
                            textAlign: TextAlign.start,
                            onChanged: (String val) => row.compare = val,
                            validator: (_) => null,
                          ),
                        ],
                      ))
                  .toList(),
            ),
          ),
          actions: <HybridAction>[
            HybridAction(
              icon: saving ? Icons.timer : Icons.save,
              label: config.ezL10n.gSave,
              onPressed: () => saving ? doNothing() : save(config),
            ),
            HybridAction(
              icon: moving ? Icons.text_format : Icons.control_camera,
              label: moving ? 'Edit entries' : 'Move rows',
              onPressed: () => setState(() => moving = !moving),
            ),
          ],
        );
      },
    );
  }
}
