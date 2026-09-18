/* a11how
 * Copyright (c) 2026 YWT. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../utils/export.dart';
import '../widgets/export.dart';

import 'dart:io';
import 'dart:math';
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

  String filterString = '';
  FilterType filterType = FTConfig.safeLookup(EzCM.get(filterTypeKey));
  MenuController filterMC = MenuController();
  bool caseSensitive = true;

  bool moving = false;

  bool keyChanges = false;
  bool saving = false;

  // Define custom functions //

  bool checkFilter(String check) => switch (filterType) {
        FilterType.startsWith => caseSensitive
            ? check.startsWith(filterString)
            : check.toLowerCase().startsWith(filterString.toLowerCase()),
        FilterType.contains => caseSensitive
            ? check.contains(filterString)
            : check.toLowerCase().contains(filterString.toLowerCase()),
        FilterType.endsWith => caseSensitive
            ? check.endsWith(filterString)
            : check.toLowerCase().endsWith(filterString.toLowerCase()),
      };

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

  // Define custom Widgets //

  Widget dragHandle(EzCP config, int index) => ReorderableDragStartListener(
        index: index,
        child: MouseRegion(
          cursor: SystemMouseCursors.grab,
          child: EzIcon(
            config,
            Icons.drag_handle,
            color: config.colors.outline,
          ),
        ),
      );

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
        final double editMax = widthOf(context) - (config.marginVal * 2);
        final double moveMax = widthOf(context) - ((config.marginVal + config.iconSize) * 2);

        return A11howScaffold(
          config,
          body: InputDecorationTheme(
            filled: true,
            contentPadding: EdgeInsets.all(config.marginVal),
            fillColor: config.colors.surface.withValues(
              alpha: max(config.colors.surface.a, focusOpacity),
            ),
            prefixIconColor: config.colors.primary,
            iconColor: config.colors.primary,
            suffixIconColor: config.colors.primary,
            hintStyle: config.bodyStyle?.copyWith(color: config.colors.outline),
            labelStyle: config.labelStyle,
            helperStyle: config.labelStyle,
            errorStyle: config.labelStyle?.copyWith(color: config.colors.error),
            errorMaxLines: 1,
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: config.colors.outline,
                width: config.borderWidth / 2,
              ),
              borderRadius: BorderRadius.zero,
              gapPadding: 0,
            ),
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: config.colors.outlineVariant,
                width: config.borderWidth / 2,
              ),
              borderRadius: BorderRadius.zero,
              gapPadding: 0,
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: config.colors.outline,
                width: config.borderWidth / 2,
              ),
              borderRadius: BorderRadius.zero,
              gapPadding: 0,
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: config.colors.errorContainer,
                width: config.borderWidth / 2,
              ),
              borderRadius: BorderRadius.zero,
              gapPadding: 0,
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: config.colors.primaryContainer,
                width: config.borderWidth / 2,
              ),
              borderRadius: BorderRadius.zero,
              gapPadding: 0,
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: config.colors.error,
                width: config.borderWidth / 2,
              ),
              borderRadius: BorderRadius.zero,
              gapPadding: 0,
            ),
            child: EzScreen(
              config,
              margin: EdgeInsets.zero,
              child: moving
                  ? ReorderableListView(
                      buildDefaultDragHandles: false,
                      onReorderItem: (int oldIndex, int newIndex) {
                        if (oldIndex == newIndex) return;

                        final WorkRow item = workData.removeAt(oldIndex);
                        workData.insert(newIndex, item);
                        keyChanges = true;

                        setState(() {});
                      },
                      children: workData.asMap().entries.map((MapEntry<int, WorkRow> entry) {
                        final int index = entry.key;
                        final WorkRow row = entry.value;

                        return EzRow(
                          config,
                          key: ValueKey<String>(row.key),
                          reverseHands: false,
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            dragHandle(config, index),
                            config.rowMargin,

                            // Key
                            EzTextField(
                              constraints: BoxConstraints.tightFor(width: moveMax * 0.2),
                              hintText: row.key,
                              initialValue: row.key,
                              style: config.bodyStyle,
                              textAlign: TextAlign.start,
                              readOnly: true,
                              validator: (_) => null,
                            ),

                            // Truth
                            EzTextField(
                              constraints: BoxConstraints.tightFor(width: moveMax * 0.4),
                              hintText: row.truth,
                              initialValue: row.truth,
                              style: config.bodyStyle,
                              textAlign: TextAlign.start,
                              readOnly: true,
                              validator: (_) => null,
                            ),

                            // Work
                            EzTextField(
                              constraints: BoxConstraints.tightFor(width: moveMax * 0.4),
                              hintText: row.compare,
                              initialValue: row.compare,
                              style: config.bodyStyle,
                              textAlign: TextAlign.start,
                              readOnly: true,
                              validator: (_) => null,
                            ),

                            config.rowMargin,
                            dragHandle(config, index),
                          ],
                        );
                      }).toList(),
                    )
                  : EzCol(children: <Widget>[
                      EzRow(config, children: <Widget>[
                        config.rowMargin,
                        Expanded(
                          child: EzTextField(
                            constraints: const BoxConstraints(),
                            hintText: 'Filter (key)',
                            onChanged: (String entry) => setState(() => filterString = entry),
                            validator: (_) => null,
                          ),
                        ),
                        config.rowMargin,
                        MenuAnchor(
                          controller: filterMC,
                          menuChildren: FilterType.values
                              .map((FilterType ft) => EzMenuButton(
                                    config,
                                    label: ft.name(config),
                                    textAlign: TextAlign.start,
                                    onPressed: () => setState(() => filterType = ft),
                                  ))
                              .toList(),
                          child: EzTextIconButton(
                            config,
                            label: filterType.name(config),
                            textAlign: TextAlign.start,
                            icon: EzIcon(config, Icons.sort),
                            onPressed: () => toggleMenu(filterMC),
                          ),
                        ),
                        config.rowSpacer,
                        EzIconButton(
                          config,
                          fauxDisabled: !caseSensitive,
                          tooltip: 'Toggle case sensitivity',
                          icon: EzIcon(config, Icons.abc),
                          onPressed: () => setState(() => caseSensitive = !caseSensitive),
                        ),
                        config.rowMargin,
                      ]),
                      Expanded(
                        child: EzScrollView(
                          config,
                          mainAxisSize: MainAxisSize.max,
                          children: workData
                              .where(// TODO: options
                                  (WorkRow row) =>
                                      filterString.isEmpty ? true : checkFilter(row.key))
                              .map((WorkRow row) => EzRow(
                                    config,
                                    key: ValueKey<String>(row.key),
                                    reverseHands: false,
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      // Key
                                      EzTextField(
                                        constraints: BoxConstraints.tightFor(width: editMax * 0.2),
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
                                        constraints: BoxConstraints.tightFor(width: editMax * 0.4),
                                        hintText: row.truth,
                                        initialValue: row.truth,
                                        style: config.bodyStyle,
                                        textAlign: TextAlign.start,
                                        onChanged: (String val) => row.truth = val,
                                        validator: (_) => null,
                                      ),

                                      // Work
                                      EzTextField(
                                        constraints: BoxConstraints.tightFor(width: editMax * 0.4),
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
                    ]),
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
