/* a11how
 * Copyright (c) 2026 YWT. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../screens/export.dart';
import '../utils/export.dart';
import '../widgets/export.dart';

import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:path/path.dart' as p;
import 'package:archive/archive.dart';
import 'package:open_ui/open_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';

class SelectScreen extends StatefulWidget {
  final ARBDir workDir;

  const SelectScreen(this.workDir, {super.key});

  @override
  State<SelectScreen> createState() => _SelectScreenState();
}

class _SelectScreenState extends State<SelectScreen> {
  // Define the build data //

  late final List<ARBFile> files = widget.workDir.files;
  late final bool local = widget.workDir.local;

  bool wrap = true;
  String filter = '';

  ARBFile? truth;
  String truthPreview = '';

  ARBFile? compare;
  String comparePreview = '';

  bool removing = false;

  // Define custom functions //

  void hoverOption(ARBFile arb) => setState(
      () => (truth == null) ? truthPreview = arb.localeCode : comparePreview = arb.localeCode);

  Future<void> chooseOption(EzCP config, ARBFile arb) async {
    if (removing) {
      try {
        final File file = File(arb.path);
        await file.delete();
        files.remove(arb);
        setState(() {});
      } catch (e) {
        if (mounted) ezSnackBar(config, context: context, message: 'Failure to delete file: $e');
      }
    } else {
      (truth == null)
          ? setState(() => truth = arb)
          : context.pushNamed(workPath, extra: WorkPair(truth: truth!, compare: arb));
    }
  }

  Widget buildOptions(EzCP config) => Expanded(
        child: wrap
            ? EzScrollView(
                config,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: widthOf(context) * 0.8),
                  child: EzWrap(
                    children: files
                        .where((ARBFile arb) =>
                            filter.isEmpty ? true : arb.localeCode.contains(filter))
                        .map((ARBFile arb) => Padding(
                              padding: EzInsets.wrap(config.spacing),
                              child: MouseRegion(
                                onHover: (_) => hoverOption(arb),
                                child: EzElevatedIconButton(
                                  config,
                                  label: (arb.localeCode == truth?.localeCode)
                                      ? 'Self'
                                      : arb.localeCode,
                                  icon: Text(
                                    local
                                        ? arb.entries.length.toString()
                                        : ezLocaleName(ezLocale(arb.localeCode), context),
                                    style: config.labelStyle?.copyWith(
                                      color: config.colors.outline,
                                    ),
                                  ),
                                  onPressed: () async => await chooseOption(config, arb),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
              )
            : EzScrollView(
                config,
                children: files
                    .where((ARBFile arb) => filter.isEmpty ? true : arb.localeCode.contains(filter))
                    .map((ARBFile arb) => Padding(
                          padding: EdgeInsets.symmetric(vertical: config.spacing / 2),
                          child: MouseRegion(
                            onHover: (_) => hoverOption(arb),
                            child: EzTextButton(
                              config,
                              text: (arb.localeCode == truth?.localeCode) ? 'Self' : arb.localeCode,
                              onPressed: () async => await chooseOption(config, arb),
                            ),
                          ),
                        ))
                    .toList(),
              ),
      );

  // Init //

  @override
  void initState() {
    super.initState();
    if (!local) {
      truth = files.firstWhere((ARBFile arb) => arb.localeCode == 'en_US');
      // No or else, we know it exists
      setState(() {});
    }
  }

  // Return the build //

  @override
  Widget build(BuildContext context) => Consumer<EzCP>(
        builder: (_, EzCP config, __) {
          final Widget halfSpacer = EzSpacer(config.spacing / 2);

          final BoxConstraints filterConstraints = BoxConstraints.tightFor(
            width: ezTextSize(
              config,
              text: '\txx(_YY?)\t',
              style: config.bodyStyle,
              textScaler: MediaQuery.of(context).textScaler,
            ).width,
          );

          return A11howScaffold(
            config,
            body: EzScreen(
              config,
              child: EzCol(children: <Widget>[
                // Header
                EzText(
                  config,
                  text: widget.workDir.path,
                  style: config.labelStyle?.copyWith(color: config.colors.outline),
                  textAlign: TextAlign.center,
                ),

                EzAnimVis(
                  config,
                  mod: 0.667,
                  reverse: true,
                  forceFade: true,
                  forceType: EzTransitionType.slideY,
                  visible: !removing,
                  kid: EzCol(children: <Widget>[
                    config.spacer,
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: config.marginVal),
                      child: EzCol(children: <Widget>[
                        // Curr truth
                        EzAnimSwitch(
                          config,
                          mod: 0.5,
                          forceFade: true,
                          forceType: EzTransitionType.none,
                          child: truth == null
                              ? EzRichText(config, children: <InlineSpan>[
                                  EzPlainText(
                                    text: 'Source locale:',
                                    style: config.titleStyle?.copyWith(
                                      decoration: TextDecoration.underline,
                                      decorationColor: config.colors.primary,
                                    ),
                                  ),
                                  EzPlainText(
                                    text: ' $truthPreview',
                                    style: config.bodyStyle?.copyWith(color: config.colors.outline),
                                  ),
                                ])
                              : EzRichText(config, children: <InlineSpan>[
                                  EzPlainText(text: 'Source locale:', style: config.bodyStyle),
                                  EzPlainText(
                                      text: ' ${truth!.localeCode}', style: config.bodyStyle),
                                ]),
                        ),
                        config.spacer,

                        // Curr compare
                        EzAnimSwitch(
                          config,
                          mod: 0.5,
                          forceFade: true,
                          forceType: EzTransitionType.none,
                          child: truth == null
                              ? EzRichText(config, children: <InlineSpan>[
                                  EzPlainText(text: 'Compare locale:', style: config.labelStyle),
                                  EzPlainText(text: comparePreview, style: config.labelStyle),
                                ])
                              : EzRichText(config, children: <InlineSpan>[
                                  EzPlainText(
                                    text: 'Compare locale:',
                                    style: config.titleStyle?.copyWith(
                                      decoration: TextDecoration.underline,
                                      decorationColor: config.colors.primary,
                                    ),
                                  ),
                                  EzPlainText(
                                    text: ' $comparePreview',
                                    style: config.bodyStyle?.copyWith(color: config.colors.outline),
                                  ),
                                ]),
                        ),
                      ]),
                    ),
                    halfSpacer,
                  ]),
                ),

                // Div
                Center(
                  child: EzTitledDivider(
                    config,
                    height: config.spacing * 2,
                    title: EzCol(children: <Widget>[
                      // Toggle
                      EzFlipFlop(
                        config,
                        init: wrap,
                        onLabel: 'Wrap',
                        offLabel: 'List',
                        onChanged: (bool choice) => setState(() => wrap = choice),
                      ),
                      config.margin,

                      // Filter
                      EzTextField(
                        constraints: filterConstraints,
                        hintText: 'Filter',
                        validator: (String? check) {
                          if (check == null) return null;

                          final RegExp regex = RegExp(r'[\w_]*');
                          if (!regex.hasMatch(check)) return r'[\w_]*';

                          return null;
                        },
                        onChanged: (String input) => setState(() => filter = input),
                      )
                    ]),
                  ),
                ),
                halfSpacer,

                // Choices/options
                buildOptions(config),
                halfSpacer,
              ]),
            ),
            actions: removing
                ? <HybridAction>[
                    // End removing locales
                    HybridAction(
                      label: 'Removing',
                      icon: Icons.remove_done,
                      onPressed: () => setState(() => removing = !removing),
                    ),
                  ]
                : <HybridAction>[
                    if (local) ...<HybridAction>[
                      // Save all
                      HybridAction(
                        label: 'Save all',
                        icon: Icons.save,
                        onPressed: () async => await ezNoTouch(() async {
                          for (final ARBFile arb in files) {
                            await writeSortedJson(config, file: File(arb.path), arb: arb);
                          }
                        }).whenComplete(() => context.mounted
                            ? ezSnackBar(config, context: context, message: 'All done!')
                            : doNothing()),
                      ),

                      // Add entries
                      _AddEntryAction(
                        config,
                        context: context,
                        workDir: widget.workDir,
                        truth: truth,
                        setState: () => setState(() {}),
                      ),

                      // Remove entries
                      _RemoveEntryAction(
                        config,
                        context: context,
                        workDir: widget.workDir,
                        truth: truth,
                        setState: () => setState(() {}),
                      ),
                    ],

                    // Add locale
                    _AddLocaleAction(
                      config,
                      context: context,
                      workDir: widget.workDir,
                      filterConstraints: filterConstraints,
                      truth: truth,
                      setState: () => setState(() {}),
                    ),

                    if (local) ...<HybridAction>[
                      // Start removing locales
                      HybridAction(
                        label: 'Remove locale(s)',
                        icon: Icons.group_remove_outlined,
                        onPressed: () => setState(() => removing = !removing),
                      ),

                      // Undo select
                      if (truth != null)
                        HybridAction(
                          label: 'Undo select',
                          icon: Icons.undo,
                          onPressed: () => setState(() => truth = null),
                        ),
                    ],

                    // Settings
                    settingsAction(config, context),
                  ],
          );
        },
      );
}

//* Fancy actions *//

class _AddEntryAction extends HybridAction {
  final EzCP config;
  final BuildContext context;
  final ARBDir workDir;
  final ARBFile? truth;
  final VoidCallback setState;

  _AddEntryAction(
    this.config, {
    required this.context,
    required this.workDir,
    this.truth,
    required this.setState,
  }) : super(
          label: 'Add entries',
          icon: Icons.playlist_add_outlined,
          onPressed: () async {
            // Define (modal) build data //

            final double modalWidth = widthOf(context);

            ARBFile? adding = truth;
            final Set<_AddCache> completed = <_AddCache>{};
            bool showPreview = true;
            _AddCache? previewTruth;
            ARBFile? previewCompare = workDir.files.first;

            final TextEditingController arbController = TextEditingController();

            // Define custom (modal) functions //

            String? validateARB(String? check) {
              if (check == null || check.trim().isEmpty) {
                return 'Cannot be empty';
              }

              // Allow for optional brackets
              String textToParse = check.trim();
              if (!textToParse.startsWith('{')) {
                textToParse = '{$textToParse}';
              }

              try {
                final dynamic decoded = jsonDecode(textToParse);
                if (decoded is! Map<String, dynamic>) {
                  return 'Must evaluate to a JSON object';
                }
              } catch (e) {
                return 'Invalid JSON format';
              }

              return null;
            }

            Map<String, dynamic> getMissing() {
              final Map<String, dynamic> toReturn = <String, dynamic>{};
              if (previewTruth == null ||
                  previewCompare == null ||
                  previewTruth?.file == previewCompare) {
                return toReturn;
              }

              final Set<String> missing = previewTruth!.file.entries.keys
                  .toSet()
                  .difference(previewCompare!.entries.keys.toSet());
              for (final String key in missing) {
                toReturn[key] = previewTruth!.file.entries[key];
              }

              return toReturn;
            }

            // Return (modal) build //

            final Widget div = ConstrainedBox(
              constraints: BoxConstraints.tight(Size.square(config.marginVal)),
              child: VerticalDivider(color: config.colors.outline),
            );

            await ezFullScreenModal(
              config,
              context: context,
              child: StatefulBuilder(builder: (BuildContext mCon, StateSetter setModal) {
                final Iterable<MapEntry<String, dynamic>> missingPreview =
                    (previewTruth == null || previewCompare == null)
                        ? <MapEntry<String, dynamic>>[]
                        : (previewTruth!.entries.isEmpty ? getMissing() : previewTruth!.entries)
                            .entries;

                return EzCol(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    // Add/submit && /cancel
                    EzRow(
                      config,
                      children: (adding == null)
                          // For all
                          ? <Widget>[
                              EzTextIconButton(
                                config,
                                label: config.ezL10n.gCancel,
                                icon: EzIcon(config, Icons.cancel),
                                onPressed: (completed.length == workDir.files.length)
                                    ? null
                                    : () => Navigator.of(context).pop(),
                              ),
                              config.rowSpacer,
                              EzTextIconButton(
                                config,
                                label: 'Save',
                                icon: EzIcon(config, Icons.save),
                                onPressed: completed.isEmpty
                                    ? null
                                    : () => ezNoTouch(() async {
                                          for (final _AddCache cache in completed) {
                                            cache.file.entries.addAll(cache.entries);
                                            await writeSortedJson(
                                              config,
                                              file: File(cache.file.path),
                                              arb: cache.file,
                                            );
                                          }

                                          if (context.mounted) Navigator.of(context).pop();
                                        }).whenComplete(setState),
                              ),
                            ]
                          // For one
                          : <Widget>[
                              EzTextIconButton(
                                config,
                                label: config.ezL10n.gCancel,
                                icon: EzIcon(config, Icons.cancel),
                                onPressed: () {
                                  arbController.clear();
                                  setModal(() => adding = null);
                                },
                              ),
                              config.rowSpacer,
                              EzTextIconButton(
                                config,
                                label: 'Add',
                                icon: EzIcon(config, Icons.add),
                                onPressed: () {
                                  if (validateARB(arbController.text) != null) {
                                    ezSnackBar(
                                      config,
                                      context: mCon,
                                      message: 'Resolve issues please',
                                    );
                                    return;
                                  }

                                  String textToParse = arbController.text.trim();
                                  if (!textToParse.startsWith('{')) {
                                    textToParse = '{$textToParse}';
                                  }

                                  final _AddCache toAdd = _AddCache(
                                    file: adding!,
                                    entries: jsonDecode(textToParse),
                                  );
                                  if (completed.isEmpty) {
                                    previewTruth = toAdd;
                                  }
                                  if (previewCompare == toAdd.file) {
                                    previewCompare = workDir.files
                                        .where((ARBFile arb) => !completed
                                            .map((_AddCache cache) => cache.file)
                                            .contains(arb))
                                        .firstOrNull;
                                  }
                                  completed.add(toAdd);

                                  arbController.clear();
                                  setModal(() => adding = null);
                                },
                              ),
                            ],
                    ),
                    config.spacer,

                    // Main work
                    Expanded(
                      child: EzAnimSwitch(
                        config,
                        mod: 0.667,
                        child: (adding == null)
                            ? EzScrollView(config, children: <Widget>[
                                // To-do section
                                Text(
                                  'TODO:',
                                  textAlign: TextAlign.center,
                                  style: config.titleStyle,
                                ),
                                config.spacer,
                                EzWrap(
                                  children: workDir.files
                                      .where((ARBFile arb) => completed.isEmpty
                                          ? true
                                          : !completed
                                              .map((_AddCache cache) => cache.file)
                                              .contains(arb))
                                      .map((ARBFile arb) => Padding(
                                            padding: EzInsets.wrap(config.spacing),
                                            child: EzElevatedIconButton(
                                              config,
                                              label: arb.localeCode,
                                              icon: Text(
                                                arb.entries.length.toString(),
                                                style: config.labelStyle?.copyWith(
                                                  color: config.colors.outline,
                                                ),
                                              ),
                                              onPressed: () => setModal(() => adding = arb),
                                              onLongPress: () {
                                                final _AddCache toAdd = _AddCache(
                                                  file: arb,
                                                  entries: <String, dynamic>{},
                                                );
                                                if (completed.isEmpty) previewTruth = toAdd;
                                                if (previewCompare == toAdd.file) {
                                                  previewCompare = workDir.files
                                                      .where((ARBFile arb) => !completed
                                                          .map((_AddCache cache) => cache.file)
                                                          .contains(arb))
                                                      .firstOrNull;
                                                }
                                                completed.add(toAdd);
                                                setModal(() {});
                                              },
                                            ),
                                          ))
                                      .toList(),
                                ),

                                // To-done section
                                if (completed.isNotEmpty) ...<Widget>[
                                  EzTitledDivider(
                                    config,
                                    title: Text(
                                      'toDONE:',
                                      textAlign: TextAlign.center,
                                      style: config.titleStyle,
                                    ),
                                    height: config.spacing * 2,
                                  ),
                                  EzWrap(
                                    children: completed
                                        .map((_AddCache cache) => Padding(
                                              padding: EzInsets.wrap(config.spacing),
                                              child: EzElevatedIconButton(
                                                config,
                                                fauxDisabled: true,
                                                label: cache.file.localeCode,
                                                icon: Text(
                                                  (cache.file.entries.length + cache.entries.length)
                                                      .toString(),
                                                  style: config.labelStyle?.copyWith(
                                                    color: config.colors.outline,
                                                  ),
                                                ),
                                                onPressed: doNothing,
                                                onLongPress: () {
                                                  completed.remove(cache);
                                                  setModal(() {});
                                                },
                                              ),
                                            ))
                                        .toList(),
                                  ),

                                  // Preview toggle
                                  EzTitledDivider(
                                    config,
                                    color: showPreview
                                        ? config.colors.secondaryContainer
                                        : Colors.transparent,
                                    height: config.spacing * 2,
                                    width: 250,
                                    title: EzSwitchPair(
                                      config,
                                      key: ValueKey<bool>(showPreview),
                                      text: 'Preview missing',
                                      value: showPreview,
                                      onChanged: (bool? choice) {
                                        if (choice == null) return;
                                        setModal(() => showPreview = choice);
                                      },
                                    ),
                                  ),

                                  // Preview
                                  EzAnimVis(
                                    config,
                                    visible: showPreview,
                                    forceType: EzTransitionType.slideY,
                                    kid: EzCol(children: <Widget>[
                                      EzDropdownMenu<_AddCache>(
                                        config,
                                        label: 'Truth (keys & values)',
                                        initialSelection: previewTruth,
                                        dropdownMenuEntries: completed
                                            .map((_AddCache cache) => DropdownMenuEntry<_AddCache>(
                                                  label: cache.file.localeCode,
                                                  value: cache,
                                                ))
                                            .toList(),
                                        widthEntry: 'en_US_BB',
                                        onSelected: (_AddCache? selected) =>
                                            setModal(() => previewTruth = selected),
                                      ),
                                      config.margin,
                                      EzDropdownMenu<ARBFile>(
                                        config,
                                        label: 'Compare (keys)',
                                        initialSelection: previewCompare,
                                        dropdownMenuEntries: workDir.files
                                            .where((ARBFile file) => !completed
                                                .map((_AddCache cache) => cache.file)
                                                .contains(file))
                                            .map((ARBFile arb) => DropdownMenuEntry<ARBFile>(
                                                  label: arb.localeCode,
                                                  value: arb,
                                                ))
                                            .toList(),
                                        widthEntry: 'en_US_BB',
                                        onSelected: (ARBFile? selected) =>
                                            setModal(() => previewCompare = selected),
                                      ),
                                      if (previewTruth != null &&
                                          previewCompare != null) ...<Widget>[
                                        EzTitledDivider(
                                          config,
                                          title: missingPreview.isEmpty
                                              ? const SizedBox.shrink()
                                              : EzTextIconButton(
                                                  config,
                                                  label: 'Copy .json',
                                                  icon: EzIcon(config, Icons.copy),
                                                  onPressed: () async =>
                                                      await Clipboard.setData(ClipboardData(
                                                    text: a11howEncoder.convert(
                                                        Map<String, dynamic>.fromEntries(
                                                            missingPreview)),
                                                  )).whenComplete(() => context.mounted
                                                          ? ezSnackBar(
                                                              config,
                                                              context: context,
                                                              message: 'Copied!',
                                                            )
                                                          : doNothing()),
                                                ),
                                          height: config.spacing * 2,
                                        ),
                                        EzTextBackground(
                                          config,
                                          backgroundColor: config.colors.surface,
                                          text: EzCol(
                                            children: missingPreview
                                                .map((MapEntry<String, dynamic> entry) =>
                                                    EzScrollView(
                                                      config,
                                                      scrollDirection: Axis.horizontal,
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: <Widget>[
                                                        div,
                                                        ConstrainedBox(
                                                          constraints: BoxConstraints.tightFor(
                                                              width: modalWidth * 0.15),
                                                          child: Text(
                                                            entry.key,
                                                            style: config.bodyStyle,
                                                            textAlign: TextAlign.start,
                                                          ),
                                                        ),
                                                        div,
                                                        ConstrainedBox(
                                                          constraints: BoxConstraints.tightFor(
                                                              width: modalWidth * 0.425),
                                                          child: Text(
                                                            entry.value,
                                                            style: config.bodyStyle,
                                                            textAlign: TextAlign.start,
                                                          ),
                                                        ),
                                                        div,
                                                      ],
                                                    ))
                                                .toList(),
                                          ),
                                        ),
                                      ],
                                    ]),
                                  ),
                                ],
                              ])
                            : EzScrollView(config, children: <Widget>[
                                // Flare
                                Container(
                                  margin: EdgeInsets.all(config.marginVal),
                                  alignment:
                                      config.isLTR ? Alignment.centerLeft : Alignment.centerRight,
                                  constraints: BoxConstraints(maxWidth: modalWidth * 0.8),
                                  child: Text(
                                    '{\n\t"@@locale": "${adding!.localeCode}",\n\t...',
                                    textAlign: TextAlign.start,
                                    style: config.bodyStyle,
                                  ),
                                ),

                                // Field
                                EzTextField(
                                  maxLines: null,
                                  validator: validateARB,
                                  hintText: '\t"newKey(s)": "New value(s)",',
                                  controller: arbController,
                                  textAlign: TextAlign.start,
                                  constraints: BoxConstraints(maxWidth: modalWidth * 0.8),
                                ),

                                // Flare
                                Container(
                                  margin: EdgeInsets.all(config.marginVal),
                                  alignment:
                                      config.isLTR ? Alignment.centerLeft : Alignment.centerRight,
                                  constraints: BoxConstraints(maxWidth: modalWidth * 0.8),
                                  child: Text(
                                    '\t...\n}',
                                    textAlign: TextAlign.start,
                                    style: config.bodyStyle,
                                  ),
                                ),
                              ]),
                      ),
                    ),
                    config.spacer,
                  ],
                );
              }),
            );
          },
        );
}

class _AddCache {
  final ARBFile file;
  final Map<String, dynamic> entries;

  const _AddCache({
    required this.file,
    required this.entries,
  });
}

class _RemoveEntryAction extends HybridAction {
  final EzCP config;
  final BuildContext context;
  final ARBDir workDir;
  final ARBFile? truth;
  final VoidCallback setState;

  _RemoveEntryAction(
    this.config, {
    required this.context,
    required this.workDir,
    this.truth,
    required this.setState,
  }) : super(
          label: 'Remove entries',
          icon: Icons.playlist_remove_outlined,
          onPressed: () async {
            // Define (modal) build data //

            ARBFile? keySource = truth;
            final Set<String> choppingBlock = <String>{};

            String filterString = '';
            FilterType filterType =
                FTypeCon.lookup(EzCM.get(removeKeyFilterTypeKey)) ?? FilterType.contains;
            final MenuController filterMC = MenuController();
            bool caseSensitive = false;

            // Define custom functions //

            bool checkFilter(String check) =>
                !choppingBlock.contains(check) &&
                switch (filterType) {
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

            // Return (modal) build //

            await ezFullScreenModal(
              config,
              context: context,
              child: StatefulBuilder(
                builder: (BuildContext mCon, StateSetter setModal) => EzCol(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // Add/submit && /cancel
                    EzRow(config, children: <Widget>[
                      EzTextIconButton(
                        config,
                        label: config.ezL10n.gCancel,
                        icon: EzIcon(config, Icons.cancel),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      config.rowSpacer,
                      EzTextIconButton(
                        config,
                        label: 'Save',
                        icon: EzIcon(config, Icons.save),
                        onPressed: choppingBlock.isEmpty
                            ? null
                            : () => ezNoTouch(() async {
                                  for (final ARBFile arb in workDir.files) {
                                    arb.entries.removeWhere(
                                        (String key, _) => choppingBlock.contains(key));
                                    await writeSortedJson(config, file: File(arb.path), arb: arb);
                                  }

                                  if (context.mounted) Navigator.of(context).pop();
                                }).whenComplete(setState),
                      ),
                    ]),
                    config.spacer,
                    Expanded(
                      child: EzAnimSwitch(
                        config,
                        mod: 0.667,
                        child: (keySource == null)
                            ? // Choose key source
                            EzCol(children: <Widget>[
                                Text(
                                  'Key source',
                                  textAlign: TextAlign.center,
                                  style: config.titleStyle,
                                ),
                                EzWrap(
                                  children: workDir.files
                                      .map((ARBFile arb) => Padding(
                                            padding: EzInsets.wrap(config.spacing),
                                            child: EzElevatedButton(
                                              config,
                                              text: arb.localeCode,
                                              onPressed: () => setModal(() => keySource = arb),
                                            ),
                                          ))
                                      .toList(),
                                ),
                              ])
                            : // Choose keys to remove
                            EzCol(children: <Widget>[
                                // Title
                                Text(
                                  choppingBlock.isEmpty ? 'Select keys to remove' : 'Removing...',
                                  style: config.bodyStyle,
                                  textAlign: TextAlign.center,
                                ),

                                // Chopping block
                                choppingBlock.isEmpty
                                    ? config.margin
                                    : EzWrap(
                                        children: choppingBlock
                                            .map((String key) => Padding(
                                                  padding: EzInsets.wrap(config.spacing),
                                                  child: EzTextButton(
                                                    config,
                                                    key: ValueKey<String>(key),
                                                    text: key,
                                                    onPressed: doNothing,
                                                    onLongPress: () {
                                                      choppingBlock.remove(key);
                                                      setModal(() {});
                                                    },
                                                  ),
                                                ))
                                            .toList(),
                                      ),
                                if (choppingBlock.isNotEmpty) ...<Widget>[
                                  EzDivider(height: config.marginVal),
                                  EzSpacer(config.spacing / 2),
                                ],

                                // Filter
                                EzRow(config, children: <Widget>[
                                  config.rowSpacer,
                                  Expanded(
                                    child: EzTextField(
                                      constraints: const BoxConstraints(),
                                      hintText: 'Filter',
                                      onChanged: (String entry) =>
                                          setModal(() => filterString = entry),
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
                                              onPressed: () => setModal(() => filterType = ft),
                                            ))
                                        .toList(),
                                    child: EzTextIconButton(
                                      config,
                                      label: filterType.name(config),
                                      textAlign: TextAlign.start,
                                      icon: EzIcon(config, Icons.filter_list),
                                      onPressed: () => toggleMenu(filterMC),
                                    ),
                                  ),
                                  config.rowMargin,
                                  EzIconButton(
                                    config,
                                    fauxDisabled: !caseSensitive,
                                    tooltip: 'Toggle case sensitivity',
                                    icon: EzIcon(config, Icons.abc),
                                    onPressed: () => setModal(() => caseSensitive = !caseSensitive),
                                  ),
                                  config.rowSpacer,
                                ]),

                                // Options
                                Expanded(
                                  child: EzScrollView(
                                    config,
                                    mainAxisSize: MainAxisSize.max,
                                    child: EzWrap(
                                      children: keySource!.entries.keys
                                          .where((String key) =>
                                              !key.contains('@@locale') && checkFilter(key))
                                          .map((String key) => Padding(
                                                padding: EzInsets.wrap(config.spacing),
                                                child: EzTextIconButton(
                                                  config,
                                                  key: ValueKey<String>(key),
                                                  label: key,
                                                  icon: EzIcon(config, Icons.remove),
                                                  onPressed: () {
                                                    choppingBlock.add(key);
                                                    setModal(() {});
                                                  },
                                                ),
                                              ))
                                          .toList(),
                                    ),
                                  ),
                                ),
                              ]),
                      ),
                    ),
                    config.spacer,
                  ],
                ),
              ),
            );
          },
        );
}

class _AddLocaleAction extends HybridAction {
  final EzCP config;
  final BuildContext context;
  final ARBDir workDir;
  final BoxConstraints filterConstraints;
  final ARBFile? truth;
  final VoidCallback setState;

  _AddLocaleAction(
    this.config, {
    required this.context,
    required this.workDir,
    required this.filterConstraints,
    this.truth,
    required this.setState,
  }) : super(
          label: 'Add locale',
          icon: Icons.group_add_outlined,
          onPressed: () async {
            // Define (modal) build data //

            String? sourceCode;
            TranslationService service = TranslationService.proZ;

            final TextEditingController destController = TextEditingController();
            final TextEditingController arbController = TextEditingController();

            // Define custom (modal) functions //

            String? validateDest(String? check) {
              if (check == null || check.trim().isEmpty) {
                return 'Cannot be empty';
              }

              const String pattern = r'^[a-z]+_?[A-Z]*$';
              final RegExp regex = RegExp(pattern);
              if (!regex.hasMatch(check)) {
                return 'Invalid; $pattern';
              }

              return null;
            }

            String? validateARB(String? check) {
              if (check == null || check.trim().isEmpty) {
                return 'Cannot be empty';
              }

              try {
                final dynamic decoded = jsonDecode(check);
                if (decoded is! Map<String, dynamic>) {
                  return 'Must evaluate to a JSON object';
                }
              } catch (e) {
                return 'Invalid JSON format';
              }

              return null;
            }

            // Init (modal) //

            sourceCode = (truth == null)
                ? workDir.files
                    .where((ARBFile arb) => arb.localeCode == 'en_US')
                    .firstOrNull
                    ?.localeCode
                : truth.localeCode;

            // Return (modal) build //

            await ezFullScreenModal(
              config,
              context: context,
              child: StatefulBuilder(
                builder: (BuildContext mCon, StateSetter setModal) =>
                    EzCol(mainAxisSize: MainAxisSize.max, children: <Widget>[
                  // Submit/cancel
                  EzRow(config, children: <Widget>[
                    EzTextIconButton(
                      config,
                      label: config.ezL10n.gCancel,
                      icon: EzIcon(config, Icons.cancel),
                      onPressed: () => Navigator.of(mCon).pop(),
                    ),
                    config.rowSpacer,
                    EzTextIconButton(
                      config,
                      label: 'Add',
                      icon: EzIcon(config, Icons.add),
                      onPressed: () async {
                        if (validateDest(destController.text) != null ||
                            validateARB(arbController.text) != null) {
                          ezSnackBar(
                            config,
                            context: mCon,
                            message: 'Resolve issues please',
                          );

                          return;
                        }

                        String newPath = workDir.files.first.path;
                        newPath = newPath.replaceFirst(
                          RegExp(r'_[a-zA-Z_]+\.arb'),
                          '_${destController.text}.arb',
                        );

                        // Save
                        if (workDir.local) {
                          await writeSortedJson(
                            config,
                            file: File(newPath),
                            arb: ARBFile(
                              path: newPath,
                              local: true,
                              localeCode: destController.text,
                              entries: jsonDecode(arbController.text),
                            ),
                          );
                        } else {
                          final String? token = await getPAT(config, context);
                          if (token == null || token.isEmpty) {
                            if (context.mounted) {
                              ezSnackBar(
                                config,
                                context: context,
                                message: 'Git PAT required to submit changes.',
                              );
                            }
                            return;
                          }

                          // Parse Url
                          final Uri url = Uri.parse(newPath);
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
                            if (userRes.statusCode != 200) {
                              throw Exception('Authentication failed.');
                            }
                            final String forkOwner = jsonDecode(userRes.body)['login'];

                            // Check if file already exists
                            final Response existsRes = await get(
                              Uri.parse(
                                  'https://api.github.com/repos/$owner/$repo/contents/$filePath?ref=$branch'),
                              headers: headers,
                            );

                            if (existsRes.statusCode == 200) {
                              throw Exception('${destController.text}.arb already exists.');
                            } else if (existsRes.statusCode != 404) {
                              throw Exception('Failed to verify file status: ${existsRes.body}');
                            }

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

                            // Commit new file
                            final Map<String, dynamic> newEntries = jsonDecode(arbController.text);
                            final List<String> sortedKeys = newEntries.keys.toList()
                              ..remove('@@locale')
                              ..sort();

                            final Map<String, dynamic> sortedMap = <String, dynamic>{
                              '@@locale': destController.text
                            };
                            for (final String key in sortedKeys) {
                              sortedMap[key] = newEntries[key] ?? '';
                            }

                            final String newContent =
                                base64Encode(utf8.encode(a11howEncoder.convert(sortedMap)));
                            final Response updateRes = await put(
                              Uri.parse(
                                  'https://api.github.com/repos/$forkOwner/$repo/contents/$filePath'),
                              headers: headers,
                              body: jsonEncode(<String, dynamic>{
                                'message': 'Add locale ${destController.text} w/ $filePath',
                                'content': newContent,
                                'branch': branch,
                              }),
                            );

                            if (updateRes.statusCode != 200 && updateRes.statusCode != 201) {
                              throw Exception('Failed to commit new file: ${updateRes.body}');
                            }

                            // Open PR
                            final Response prRes = await post(
                              Uri.parse('https://api.github.com/repos/$owner/$repo/pulls'),
                              headers: headers,
                              body: jsonEncode(<String, dynamic>{
                                'title': 'Add locale ${destController.text}',
                                'head': '$forkOwner:$branch',
                                'base': branch,
                                'body': 'Submitted via a11how.',
                              }),
                            );

                            if (prRes.statusCode == 201) {
                              if (context.mounted) {
                                ezSnackBar(config, context: context, message: 'PR opened!');
                              }
                            } else {
                              final String errorMsg =
                                  jsonDecode(prRes.body)['errors']?[0]?['message'] ?? prRes.body;
                              throw Exception(prRes.statusCode == 422
                                  ? 'PR might already exist: $errorMsg'
                                  : 'Failed to open PR: $errorMsg');
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ezSnackBar(
                                config,
                                context: context,
                                message: 'GitHub Error: $e',
                              );
                            }
                          }
                        }

                        if (mCon.mounted) Navigator.of(mCon).pop();
                        setState();
                      },
                    ),
                  ]),
                  config.spacer,
                  Expanded(
                    child: EzScrollView(config, children: <Widget>[
                      if (workDir.local) ...<Widget>[
                        // Source
                        EzDropdownMenu<String>(
                          config,
                          label: 'Source locale',
                          initialSelection: sourceCode,
                          dropdownMenuEntries: workDir.files
                              .map((ARBFile arb) => DropdownMenuEntry<String>(
                                    label: arb.localeCode,
                                    value: arb.localeCode,
                                  ))
                              .toList(),
                          widthEntry: 'en_US_BB',
                          onSelected: (String? choice) {
                            if (choice == null) return;
                            setModal(() => sourceCode = choice);
                          },
                        ),
                        config.margin,
                      ],

                      // Destination
                      EzRow(config, children: <Widget>[
                        Text('New locale:', style: config.bodyStyle),
                        config.rowMargin,
                        EzTextField(
                          constraints: filterConstraints,
                          hintText: 'xx_YY',
                          controller: destController,
                          onTapOutside: (_) => setModal(() {}),
                          onEditingComplete: () => setModal(() {}),
                          onFieldSubmitted: (_) => setModal(() {}),
                          validator: validateDest,
                        ),
                      ]),
                      config.separator,

                      if (workDir.local) ...<Widget>[
                        // Service
                        EzRow(config, children: <Widget>[
                          EzDropdownMenu<TranslationService>(
                            config,
                            label: 'Choose service',
                            initialSelection: service,
                            dropdownMenuEntries: TranslationService.values
                                .map((TranslationService ts) =>
                                    DropdownMenuEntry<TranslationService>(
                                      label: ts.name(config),
                                      value: ts,
                                    ))
                                .toList(),
                            widthEntry: 'en_US_BB',
                            onSelected: (TranslationService? choice) {
                              if (choice == null) return;
                              setModal(() => service = choice);
                            },
                          ),
                          service.twoCents(config),
                        ]),
                        config.margin,
                        EzTextIconButton(
                          config,
                          label: 'Copy prompt',
                          icon: EzIcon(config, Icons.copy),
                          onPressed: sourceCode == null
                              ? null
                              : () async {
                                  if (sourceCode == null ||
                                      validateDest(destController.text) != null) {
                                    ezSnackBar(
                                      config,
                                      context: mCon,
                                      message: 'Please complete the form',
                                    );
                                    return;
                                  }
                                  final ARBFile sourceFile = workDir.files
                                      .firstWhere((ARBFile arb) => arb.localeCode == sourceCode);
                                  final String jsonString =
                                      a11howEncoder.convert(sourceFile.entries);

                                  await Clipboard.setData(ClipboardData(
                                    text: service.prompt(
                                      source: sourceCode!,
                                      dest: destController.text,
                                      json: jsonString,
                                    ),
                                  ));

                                  if (service.human) {
                                    final Map<String, dynamic> blankEntries = <String, dynamic>{};

                                    for (final MapEntry<String, dynamic> entry
                                        in sourceFile.entries.entries) {
                                      blankEntries[entry.key] =
                                          entry.key.startsWith('@') ? destController.text : '';
                                    }
                                    final String blankJson = a11howEncoder.convert(blankEntries);

                                    final Archive archive = Archive()
                                      ..addFile(ArchiveFile(
                                        '$sourceCode.arb',
                                        jsonString.length,
                                        utf8.encode(jsonString),
                                      ))
                                      ..addFile(ArchiveFile(
                                        '${destController.text}.arb',
                                        blankJson.length,
                                        utf8.encode(blankJson),
                                      ));

                                    final List<int> zipData = ZipEncoder().encode(archive);

                                    Directory? outDir = await getDownloadsDirectory();
                                    outDir ??= await getApplicationDocumentsDirectory();
                                    final String zipPath =
                                        p.join(outDir.path, '${service.name(config)}_gig.zip');

                                    try {
                                      final File zipFile = File(zipPath);
                                      await zipFile.writeAsBytes(zipData);
                                    } catch (e) {
                                      if (context.mounted) {
                                        ezSnackBar(
                                          config,
                                          context: mCon,
                                          message: 'Failed to create zip: $e',
                                        );
                                      }
                                    }
                                  }

                                  await launchUrl(service.url);
                                },
                        ),
                        config.divider,
                      ],

                      // Value/Field
                      EzTextField(
                        maxLines: null,
                        validator: validateARB,
                        hintText:
                            '{\n\t"@@locale": "${destController.text.isEmpty ? 'xx_YY' : destController.text}",\n\t"newKey(s)": "New value(s)"\n}',
                        controller: arbController,
                        textAlign: TextAlign.start,
                        constraints: BoxConstraints.tightFor(width: widthOf(context) * 0.8),
                      ),
                      config.spacer,
                    ]),
                  ),
                ]),
              ),
            );
          },
        );
}
