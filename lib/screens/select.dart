/* a11how
 * Copyright (c) 2026 YWT. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../screens/export.dart';
import '../utils/export.dart';
import '../widgets/export.dart';

import 'dart:io';
import 'dart:convert';
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
          : context.goNamed(workPath, extra: WorkPair(truth: truth!, compare: arb));
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
                        .where((ARBFile arb) => filter.isEmpty
                            ? (arb.localeCode != truth?.localeCode)
                            : arb.localeCode.contains(filter))
                        .map((ARBFile arb) => Padding(
                              padding: EzInsets.wrap(config.spacing),
                              child: MouseRegion(
                                onHover: (_) => hoverOption(arb),
                                child: EzElevatedButton(
                                  config,
                                  text: arb.localeCode,
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
                    .where((ARBFile arb) => filter.isEmpty
                        ? (arb.localeCode != truth?.localeCode)
                        : arb.localeCode.contains(filter))
                    .map((ARBFile arb) => Padding(
                          padding: EdgeInsets.symmetric(vertical: config.spacing / 2),
                          child: MouseRegion(
                            onHover: (_) => hoverOption(arb),
                            child: EzTextButton(
                              config,
                              text: arb.localeCode,
                              onPressed: () async => await chooseOption(config, arb),
                            ),
                          ),
                        ))
                    .toList(),
              ),
      );

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
            // TODO: group add && delete (entries)
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
                    // Add entries
                    _AddEntryAction(
                      config,
                      context: context,
                      workDir: widget.workDir,
                      truth: truth,
                    ),

                    // Remove entries
                    _RemoveEntryAction(
                      config,
                      context: context,
                      workDir: widget.workDir,
                      truth: truth,
                    ),

                    // Add locale
                    _AddLocaleAction(
                      config,
                      context: context,
                      workDir: widget.workDir,
                      filterConstraints: filterConstraints,
                      truth: truth,
                    ),

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

  _AddEntryAction(
    this.config, {
    required this.context,
    required this.workDir,
    this.truth,
  }) : super(
          label: 'Add entries',
          icon: Icons.playlist_add_outlined,
          onPressed: () async {
            // Define (modal) build data //

            ARBFile? adding = truth;
            final Set<ARBFile> completed = <ARBFile>{};

            final TextEditingController arbController = TextEditingController();

            // Define custom (modal) functions //

            String? validateARB(String? check) {
              if (check == null || check.trim().isEmpty) {
                return 'Cannot be empty';
              }

              return null;
            }

            // Return (modal) build //

            await ezModal(
              config,
              context: context,
              enableDrag: false,
              isDismissible: false,
              showDragHandle: false,
              constraints: const BoxConstraints.expand(),
              builder: (_) => StatefulBuilder(
                builder: (BuildContext mCon, StateSetter setModal) => Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.all(config.marginVal),
                  constraints: const BoxConstraints.expand(),
                  child: EzScrollView(
                    config,
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      EzHeader(config),
                      EzAnimSwitch(
                        config,
                        mod: 0.667,
                        child: (adding == null)
                            ? EzCol(children: <Widget>[
                                Text(
                                  'TODO:',
                                  textAlign: TextAlign.center,
                                  style: config.titleStyle,
                                ),
                                config.margin,
                                EzWrap(
                                  children: workDir.files
                                      .where((ARBFile arb) =>
                                          completed.isEmpty ? true : !completed.contains(arb))
                                      .map((ARBFile arb) => Padding(
                                            padding: EzInsets.wrap(config.spacing),
                                            child: EzElevatedButton(
                                              config,
                                              text: arb.localeCode,
                                              onPressed: () => setModal(() => adding = arb),
                                            ),
                                          ))
                                      .toList(),
                                ),
                                if (completed.isNotEmpty) ...<Widget>[
                                  config.divider,
                                  Text(
                                    'toDONE:',
                                    textAlign: TextAlign.center,
                                    style: config.titleStyle,
                                  ),
                                  config.margin,
                                  EzWrap(
                                    children: completed
                                        .map((ARBFile arb) => Padding(
                                              padding: EzInsets.wrap(config.spacing),
                                              child: EzElevatedButton(
                                                config,
                                                fauxDisabled: true,
                                                text: arb.localeCode,
                                                onPressed: doNothing,
                                                onLongPress: () {
                                                  completed.remove(arb);
                                                  setModal(() {});
                                                },
                                              ),
                                            ))
                                        .toList(),
                                  ),
                                ],
                              ])
                            : EzCol(children: <Widget>[
                                // Flare
                                Container(
                                  margin: EdgeInsets.all(config.marginVal),
                                  alignment:
                                      config.isLTR ? Alignment.centerLeft : Alignment.centerRight,
                                  constraints: BoxConstraints(maxWidth: widthOf(context) * 0.8),
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
                                  constraints: BoxConstraints(maxWidth: widthOf(context) * 0.8),
                                ),

                                // Flare
                                Container(
                                  margin: EdgeInsets.all(config.marginVal),
                                  alignment:
                                      config.isLTR ? Alignment.centerLeft : Alignment.centerRight,
                                  constraints: BoxConstraints(maxWidth: widthOf(context) * 0.8),
                                  child: Text(
                                    '\t...\n}',
                                    textAlign: TextAlign.start,
                                    style: config.bodyStyle,
                                  ),
                                ),
                              ]),
                      ),
                      config.spacer,

                      // Add/submit && /cancel
                      EzRow(
                        config,
                        children: (adding == null)
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
                                  // TODO: write all caches
                                  onPressed:
                                      completed.isEmpty ? null : () => Navigator.of(context).pop(),
                                ),
                              ]
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
                                    // TODO: create a local class/model for "cache"
                                    // When big save is pressed, all the caches get append written (and sorted)
                                    // ...prolly have some more stuff to classify/send to utils
                                    completed.add(adding!);
                                    arbController.clear();
                                    setModal(() => adding = null);
                                  },
                                ),
                              ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
}

class _RemoveEntryAction extends HybridAction {
  final EzCP config;
  final BuildContext context;
  final ARBDir workDir;
  final ARBFile? truth;

  _RemoveEntryAction(
    this.config, {
    required this.context,
    required this.workDir,
    this.truth,
  }) : super(
          label: 'Remove entries',
          icon: Icons.playlist_remove_outlined,
          onPressed: () async {
            // Define (modal) build data //

            ARBFile? keySource = truth;
            final Set<String> choppingBlock = <String>{};

            String filterString = '';
            FilterType filterType =
                FTConfig.lookup(EzCM.get(removeKeyFilterTypeKey)) ?? FilterType.contains;
            final MenuController filterMC = MenuController();
            bool caseSensitive = false;

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

            // Return (modal) build //

            await ezModal(
              config,
              context: context,
              enableDrag: false,
              isDismissible: false,
              showDragHandle: false,
              constraints: const BoxConstraints.expand(),
              builder: (_) => StatefulBuilder(
                builder: (BuildContext mCon, StateSetter setModal) => Container(
                  alignment: Alignment.topCenter,
                  constraints: const BoxConstraints.expand(),
                  child: EzCol(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      EzHeader(config),
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
                                    'Remove keys...',
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

                                  // Filter
                                  EzRow(config, children: <Widget>[
                                    config.rowSpacer,
                                    Expanded(
                                      child: EzTextField(
                                        constraints: const BoxConstraints(),
                                        hintText: 'Filter (key)',
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
                                      onPressed: () =>
                                          setModal(() => caseSensitive = !caseSensitive),
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
                          // TODO: make it so
                          onPressed: choppingBlock.isEmpty
                              ? null
                              : () async {
                                  for (final ARBFile arb in workDir.files) {
                                    arb.entries.removeWhere(
                                        (String key, _) => choppingBlock.contains(key));
                                  }

                                  // TODO: make sorted save shared (after fixing it)
                                  await save;

                                  if (context.mounted) Navigator.of(context).pop();
                                },
                        ),
                      ]),
                      config.spacer,
                    ],
                  ),
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

  _AddLocaleAction(
    this.config, {
    required this.context,
    required this.workDir,
    required this.filterConstraints,
    this.truth,
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

              return null;
            }

            // Init (modal) //

            if (truth == null) {
              try {
                sourceCode =
                    workDir.files.firstWhere((ARBFile arb) => arb.localeCode == 'en_US').localeCode;
              } catch (_) {
                // Contains with extra steps, if above fails sourceCode remains null (and that's okay)
              }
            } else {
              sourceCode = truth.localeCode;
            }

            // Return (modal) build //

            await ezModal(
              config,
              context: context,
              enableDrag: false,
              isDismissible: false,
              showDragHandle: false,
              constraints: const BoxConstraints.expand(),
              builder: (_) => StatefulBuilder(
                builder: (BuildContext mCon, StateSetter setModal) => Container(
                  margin: EdgeInsets.all(config.marginVal),
                  constraints: const BoxConstraints.expand(),
                  child: EzCol(mainAxisSize: MainAxisSize.max, children: <Widget>[
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

                    // Service
                    EzRow(config, children: <Widget>[
                      EzDropdownMenu<TranslationService>(
                        config,
                        label: 'Choose service',
                        initialSelection: service,
                        dropdownMenuEntries: TranslationService.values
                            .map((TranslationService ts) => DropdownMenuEntry<TranslationService>(
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
                              if (sourceCode == null || validateDest(destController.text) != null) {
                                ezSnackBar(
                                  config,
                                  context: mCon,
                                  message: 'Please complete the form',
                                ); // TODO: fix these
                                return;
                              }
                              final ARBFile sourceFile = workDir.files
                                  .firstWhere((ARBFile arb) => arb.localeCode == sourceCode);

                              final String jsonString =
                                  const JsonEncoder.withIndent('  ').convert(sourceFile.entries);

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

                                final String blankJson =
                                    const JsonEncoder.withIndent('  ').convert(blankEntries);

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

                    // Value/Field
                    Expanded(
                      child: EzTextField(
                        maxLines: null,
                        validator: validateARB,
                        hintText:
                            '{\n\t"@@locale": "${destController.text.isEmpty ? 'xx_YY' : destController.text}",\n\t"newKey(s)": "New value(s)"\n}',
                        controller: arbController,
                        textAlign: TextAlign.start,
                        constraints: const BoxConstraints.expand(),
                      ),
                    ),
                    config.spacer,

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
                          try {
                            final File file = File(newPath);
                            await file.writeAsString(arbController.text);
                          } catch (e) {
                            if (mCon.mounted) {
                              ezSnackBar(
                                config,
                                context: mCon,
                                message: 'Failure saving: $e',
                              );
                            }
                          }

                          if (mCon.mounted) Navigator.of(mCon).pop();
                        },
                      ),
                    ]),
                    config.spacer,
                  ]),
                ),
              ),
            );
          },
        );
}
