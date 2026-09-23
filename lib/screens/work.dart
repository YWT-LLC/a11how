/* a11how
 * Copyright (c) 2026 YWT. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../utils/export.dart';
import '../widgets/export.dart';

import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart';
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
  late final bool selfCompare = widget.workPair.truth == widget.workPair.compare;

  final MenuController highlightMC = MenuController();
  bool showEmpty = true;
  late bool showIdentical = !selfCompare;

  String filterString = '';
  FilterTarget filterTarget = FTargetCon.safeLookup(EzCM.get(workFilterTypeKey));
  final MenuController fTargetMC = MenuController();
  FilterType filterType = FTypeCon.safeLookup(EzCM.get(workFilterTypeKey));
  final MenuController fTypeMC = MenuController();

  bool caseSensitive = false;

  bool saving = false;

  // Define custom functions //

  String? validateField(String? check) =>
      (check == null || check.isEmpty) ? 'Cannot be empty' : null;

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
    if (!selfCompare && widget.workPair.truth.local) {
      try {
        final File file = File(widget.workPair.truth.path);
        widget.workPair.truth.entries
          ..clear()
          ..addAll(updatedTruth);

        await writeSortedJson(config, file: file, arb: widget.workPair.truth);
      } catch (e) {
        if (mounted) ezSnackBar(config, context: context, message: 'Failure saving truth: $e');
      }
    }

    // Save Compare
    if (widget.workPair.truth.local) {
      try {
        final File file = File(widget.workPair.compare.path);
        widget.workPair.compare.entries
          ..clear()
          ..addAll(updatedCompare);

        await writeSortedJson(config, file: file, arb: widget.workPair.compare);
        if (mounted) ezSnackBar(config, context: context, message: 'Success!');
      } catch (e) {
        if (mounted) ezSnackBar(config, context: context, message: 'Failure saving compare: $e');
      }
    } else {
      await _openPR(config, updatedCompare);
    }

    if (mounted) setState(() => saving = false);
  }

  Future<void> _openPR(EzCP config, Map<String, dynamic> updatedCompare) async {
    final String? token = await getPAT(config, context);
    if (token == null || token.isEmpty) {
      if (mounted) {
        ezSnackBar(config, context: context, message: 'Git PAT required to submit changes.');
      }
      return;
    }

    // Parse Url
    final Uri url = Uri.parse(widget.workPair.compare.path);
    final List<String> segments = url.pathSegments;

    final String owner = segments[0];
    final String repo = segments[1];
    final String branch = segments[3];
    final String filePath = segments.sublist(4).join('/');

    // Build the request
    final Map<String, String> headers = <String, String>{
      'Authorization': 'Bearer $token',
      'Accept': 'application/vnd.github.v3+json',
      'X-GitHub-Api-Version': '2022-11-28',
    };

    try {
      // Get user info
      final Response userRes = await get(
        Uri.parse('https://api.github.com/user'),
        headers: headers,
      );
      if (userRes.statusCode != 200) throw Exception('Authentication failed.');
      final String forkOwner = jsonDecode(userRes.body)['login'];

      // Make fork
      final Response forkRes = await post(
        Uri.parse('https://api.github.com/repos/$owner/$repo/forks'),
        headers: headers,
      );
      if (forkRes.statusCode != 202 && forkRes.statusCode != 200) {
        throw Exception('Failed to create fork.');
      }

      // Wait a bit
      await wait(3);

      // SHA-tay
      final Response fileRes = await get(
        Uri.parse('https://api.github.com/repos/$forkOwner/$repo/contents/$filePath?ref=$branch'),
        headers: headers,
      );

      String? sha;
      if (fileRes.statusCode == 200) {
        sha = jsonDecode(fileRes.body)['sha'];
      } else if (fileRes.statusCode != 404) {
        throw Exception('Failed to fetch file status.');
      }

      // Commit changes
      final List<String> sortedKeys = updatedCompare.keys.toList()
        ..remove('@@locale')
        ..sort();

      final Map<String, dynamic> sortedMap = <String, dynamic>{
        '@@locale': widget.workPair.compare.localeCode
      };
      for (final String key in sortedKeys) {
        sortedMap[key] = updatedCompare[key] ?? '';
      }

      final String newContent = base64Encode(utf8.encode(a11howEncoder.convert(sortedMap)));
      final Response updateRes = await put(
        Uri.parse('https://api.github.com/repos/$forkOwner/$repo/contents/$filePath'),
        headers: headers,
        body: jsonEncode(<String, dynamic>{
          'message': 'Update localization for $filePath',
          'content': newContent,
          'branch': branch,
          if (sha != null) 'sha': sha,
        }),
      );

      if (updateRes.statusCode != 200 && updateRes.statusCode != 201) {
        throw Exception('Failed to commit changes: ${updateRes.body}');
      }

      // Open PR
      final Response prRes = await post(
        Uri.parse('https://api.github.com/repos/$owner/$repo/pulls'),
        headers: headers,
        body: jsonEncode(<String, dynamic>{
          'title': 'Localization update: $filePath',
          'head': '$forkOwner:$branch',
          'base': branch,
          'body': 'Submitted via a11how.',
        }),
      );

      if (prRes.statusCode == 201) {
        if (mounted) {
          ezSnackBar(config, context: context, message: 'PR opened!');
        }
      } else {
        // HTTP 422 usually means a PR for this branch already exists.
        final String errorMsg = jsonDecode(prRes.body)['errors']?[0]?['message'] ?? prRes.body;
        throw Exception(prRes.statusCode == 422
            ? 'PR might already exist: $errorMsg'
            : 'Failed to open PR: $errorMsg');
      }
    } catch (e) {
      if (mounted) ezSnackBar(config, context: context, message: 'GitHub Error: $e');
    }
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

        return A11howScaffold(
          config,
          body: InputDecorationTheme(
            filled: false,
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
                color: config.colors.onSurface.withValues(alpha: focusOpacity),
                width: config.borderWidth / 2,
              ),
              borderRadius: BorderRadius.zero,
              gapPadding: 0,
            ),
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.transparent,
                width: config.borderWidth / 2,
              ),
              borderRadius: BorderRadius.zero,
              gapPadding: 0,
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: config.colors.onSurface.withValues(alpha: focusOpacity),
                width: config.borderWidth / 2,
              ),
              borderRadius: BorderRadius.zero,
              gapPadding: 0,
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: config.colors.error.withValues(alpha: focusOpacity),
                width: config.borderWidth / 2,
              ),
              borderRadius: BorderRadius.zero,
              gapPadding: 0,
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: config.colors.primary.withValues(alpha: focusOpacity * 2),
                width: config.borderWidth / 2,
              ),
              borderRadius: BorderRadius.zero,
              gapPadding: 0,
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: config.colors.error.withValues(alpha: focusOpacity * 3),
                width: config.borderWidth / 2,
              ),
              borderRadius: BorderRadius.zero,
              gapPadding: 0,
            ),
            child: EzScreen(
              config,
              safeArea: true,
              margin: EdgeInsets.zero,
              child: EzCol(children: <Widget>[
                EzRow(config, children: <Widget>[
                  config.rowMargin,
                  MenuAnchor(
                    controller: highlightMC,
                    menuChildren: <Widget>[
                      EzMenuButton(
                        config,
                        label: 'Show empty',
                        textAlign: TextAlign.start,
                        icon: Icon(
                          Icons.circle,
                          size: config.iconSize / 2,
                          color: config.colors.secondary,
                        ),
                        onPressed: () => setState(() => showEmpty = !showEmpty),
                      ),
                      EzMenuButton(
                        config,
                        label: 'Show identical',
                        textAlign: TextAlign.start,
                        icon: Icon(
                          Icons.circle,
                          size: config.iconSize / 2,
                          color: config.colors.tertiary,
                        ),
                        onPressed: () => setState(() => showIdentical = !showIdentical),
                      ),
                    ],
                    child: EzTextIconButton(
                      config,
                      label: 'Highlight',
                      icon: EzRow(config, children: <Widget>[
                        if (!showEmpty && !showIdentical)
                          Icon(
                            Icons.circle_outlined,
                            size: config.iconSize / 2,
                            color: config.colors.outline,
                          ),
                        if (showEmpty)
                          Icon(
                            Icons.circle,
                            size: config.iconSize / 2,
                            color: config.colors.secondary,
                          ),
                        if (showIdentical)
                          Icon(
                            Icons.circle,
                            size: config.iconSize / 2,
                            color: config.colors.tertiary,
                          ),
                      ]),
                      onPressed: () => toggleMenu(highlightMC),
                    ),
                  ),
                  config.rowMargin,
                  Expanded(
                    child: EzTextField(
                      constraints: const BoxConstraints(),
                      hintText: 'Filter...\t>>',
                      onChanged: (String entry) => setState(() => filterString = entry),
                      validator: (_) => null,
                    ),
                  ),
                  config.rowMargin,
                  MenuAnchor(
                    controller: fTargetMC,
                    menuChildren: FilterTarget.values
                        .map((FilterTarget ft) => EzMenuButton(
                              config,
                              label: ft.name(config),
                              icon: ft.icon(config),
                              textAlign: TextAlign.start,
                              onPressed: () => setState(() => filterTarget = ft),
                            ))
                        .toList(),
                    child: EzIconButton(
                      config,
                      tooltip: filterTarget.name(config),
                      icon: filterTarget.icon(config),
                      onPressed: () => toggleMenu(fTargetMC),
                    ),
                  ),
                  config.rowMargin,
                  MenuAnchor(
                    controller: fTypeMC,
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
                      icon: EzIcon(config, Icons.filter_list),
                      onPressed: () => toggleMenu(fTypeMC),
                    ),
                  ),
                  config.rowMargin,
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
                        .where((WorkRow row) => filterString.isEmpty
                            ? true
                            : checkFilter(switch (filterTarget) {
                                FilterTarget.key => row.key,
                                FilterTarget.truth => row.truth,
                                FilterTarget.compare => row.compare,
                              }))
                        .map((WorkRow row) => EzRow(
                              config,
                              key: ValueKey<String>(row.key),
                              reverseHands: false,
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                // Key
                                Container(
                                  decoration: BoxDecoration(
                                    color: (showEmpty && row.key.isEmpty)
                                        ? config.colors.secondary.withValues(alpha: focusOpacity)
                                        : config.colors.surfaceContainer,
                                  ),
                                  child: EzTextField(
                                    constraints: BoxConstraints.tightFor(width: editMax * 0.15),
                                    readOnly: true,
                                    hintText: row.key,
                                    initialValue: row.key,
                                    style: config.bodyStyle,
                                    textAlign: TextAlign.start,
                                    validator: (_) => null,
                                  ),
                                ),

                                // Truth
                                Container(
                                  decoration: BoxDecoration(
                                    color: (showEmpty && row.key.isEmpty)
                                        ? config.colors.secondary.withValues(alpha: focusOpacity)
                                        : (selfCompare
                                            ? config.colors.surfaceContainer
                                            : config.colors.surface),
                                  ),
                                  child: EzTextField(
                                    constraints: BoxConstraints.tightFor(width: editMax * 0.425),
                                    readOnly: selfCompare,
                                    hintText: row.truth,
                                    initialValue: row.truth,
                                    style: config.bodyStyle,
                                    textAlign: TextAlign.start,
                                    onChanged: (String val) => row.truth = val,
                                    validator: validateField,
                                  ),
                                ),

                                // Work
                                Container(
                                  decoration: BoxDecoration(
                                    color: (showIdentical && row.compare == row.truth)
                                        ? config.colors.tertiary.withValues(alpha: focusOpacity)
                                        : ((showEmpty && row.key.isEmpty)
                                            ? config.colors.secondary
                                                .withValues(alpha: focusOpacity)
                                            : config.colors.surface),
                                  ),
                                  child: EzTextField(
                                    constraints: BoxConstraints.tightFor(width: editMax * 0.425),
                                    hintText: row.compare,
                                    initialValue: row.compare,
                                    style: config.bodyStyle,
                                    textAlign: TextAlign.start,
                                    onChanged: (String val) => row.compare = val,
                                    validator: validateField,
                                  ),
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
              onPressed: () async =>
                  saving ? doNothing() : await ezNoTouch(() async => await save(config)),
            ),
          ],
        );
      },
    );
  }
}
