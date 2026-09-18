/* a11how
 * Copyright (c) 2026 YWT. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../screens/export.dart';
import '../utils/export.dart';
import '../widgets/export.dart';

import 'dart:io';
import 'package:open_ui/open_ui.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

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
                        constraints: ezTextFieldConstraints(context, prop: 0.5),
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
            // TODO: add and delete langs
            // ...definitely easy copy prompt, maybe integrated browser?
            // TODO: group add and delete (entries)
            // ...ditto (but smaller)
            actions: removing
                ? <HybridAction>[
                    HybridAction(
                      label: 'Removing',
                      icon: Icons.keyboard_arrow_down,
                      onPressed: () => setState(() => removing = !removing),
                    ),
                  ]
                : <HybridAction>[
                    HybridAction(
                      label: 'Add locale',
                      icon: Icons.add,
                      onPressed: doNothing,
                    ),
                    HybridAction(
                      label: 'Remove locale',
                      icon: Icons.remove,
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
