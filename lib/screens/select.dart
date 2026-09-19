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
                    HybridAction(
                      label: 'Removing',
                      icon: Icons.remove_done,
                      onPressed: () => setState(() => removing = !removing),
                    ),
                  ]
                : <HybridAction>[
                    HybridAction(
                      label: 'Add entry',
                      icon: Icons.playlist_add_outlined,
                      onPressed: doNothing,
                    ),
                    HybridAction(
                      label: 'Remove entries',
                      icon: Icons.playlist_remove_outlined,
                      onPressed: doNothing,
                    ),
                    HybridAction(
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

                        try {
                          sourceCode = widget.workDir.files
                              .firstWhere((ARBFile arb) => arb.localeCode == 'en_US')
                              .localeCode;
                        } catch (_) {
                          // Contains with extra steps, if above fails sourceCode remains null (and that's okay)
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
                                  dropdownMenuEntries: widget.workDir.files
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
                                          final ARBFile sourceFile = widget.workDir.files
                                              .firstWhere(
                                                  (ARBFile arb) => arb.localeCode == sourceCode);

                                          final String jsonString =
                                              const JsonEncoder.withIndent('  ')
                                                  .convert(sourceFile.entries);

                                          await Clipboard.setData(ClipboardData(
                                            text: service.prompt(
                                              source: sourceCode!,
                                              dest: destController.text,
                                              json: jsonString,
                                            ),
                                          ));

                                          if (service.human) {
                                            final Map<String, dynamic> blankEntries =
                                                <String, dynamic>{};

                                            for (final MapEntry<String, dynamic> entry
                                                in sourceFile.entries.entries) {
                                              blankEntries[entry.key] = entry.key.startsWith('@')
                                                  ? destController.text
                                                  : '';
                                            }

                                            final String blankJson =
                                                const JsonEncoder.withIndent('  ')
                                                    .convert(blankEntries);

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
                                            final String zipPath = p.join(
                                                outDir.path, '${service.name(config)}_gig.zip');

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
                                    hintText: 'New entries',
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

                                      String newPath = widget.workDir.files.first.path;
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
                    ),
                    HybridAction(
                      label: 'Remove locales',
                      icon: Icons.group_remove_outlined,
                      onPressed: () => setState(() => removing = !removing),
                    ),
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
