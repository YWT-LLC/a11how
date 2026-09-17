/* a11how
 * Copyright (c) 2026 YWT. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../screens/export.dart';
import '../utils/export.dart';
import '../widgets/export.dart';

import 'dart:io';
import 'dart:convert';
import 'package:open_ui/open_ui.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Define the build data //

  List<String> recentProjects = <String>[];

  // Define custom functions //

  Future<void> processPath(EzCP config, String? preSelected) async {
    await ezNoTouch(() async {
      // Valid dir?
      final String? selectedDirectory = preSelected ?? await FilePicker.getDirectoryPath();
      if (selectedDirectory == null) return;

      // Get files
      final Directory dir = Directory(selectedDirectory);
      final List<ARBFile> loadedFiles = <ARBFile>[];

      if (dir.existsSync()) {
        final List<FileSystemEntity> entities = dir.listSync();
        for (final FileSystemEntity entity in entities) {
          if (entity is File && entity.path.endsWith('.arb')) {
            // Save valid .arb files
            try {
              final String content = await entity.readAsString();
              final Map<String, dynamic> json = jsonDecode(content);

              final String fallbackName =
                  entity.path.split(Platform.pathSeparator).last.replaceAll('.arb', '');
              final String locale = json['@@locale'] ?? fallbackName;

              loadedFiles.add(ARBFile(
                path: entity.path,
                localeCode: locale,
                entries: json,
              ));
            } catch (e) {
              ezLog('Skipped invalid ARB file: ${entity.path}');
            }
          }
        }
      }

      if (loadedFiles.isNotEmpty) {
        recentProjects.remove(selectedDirectory);
        recentProjects.insert(0, selectedDirectory);

        await EzCM.setStringList(recentProjectsKey, recentProjects);

        if (mounted) {
          context.goNamed(
            selectPath,
            extra: ARBDir(path: selectedDirectory, files: loadedFiles),
          );
        }
      } else {
        if (mounted) {
          ezSnackBar(
            config,
            context: context,
            message: 'Nothing found${preSelected == null ? '' : ' - removing from recent'}',
          );
        }
        if (preSelected != null) {
          recentProjects.remove(preSelected);
          await EzCM.setStringList(recentProjectsKey, recentProjects);
        }
      }
    });
    setState(() {});
  }

  Iterable<Widget> displayRecent(EzCP config) => recentProjects.map((String path) => Padding(
        padding: EdgeInsets.symmetric(
          horizontal: config.marginVal,
          vertical: config.spacing / 2,
        ),
        child: EzScrollView(
          config,
          reverseHands: true,
          thumbVisibility: false,
          scrollDirection: Axis.horizontal,
          children: <Widget>[
            EzLink(
              config,
              text: path,
              textAlign: TextAlign.start,
              hint: config.ezL10n.gOpen,
              onTap: () async => await processPath(config, path),
            ),
            config.rowMargin,
            EzIconButton(
              config,
              tooltip: config.ezL10n.gRemove,
              icon: const Icon(Icons.remove),
              style: IconButton.styleFrom(
                side: config.borderSide(color: config.colors.errorContainer),
                foregroundColor: config.colors.error,
                backgroundColor: config.colors.surface,
              ),
              onPressed: () async {
                recentProjects.remove(path);
                await EzCM.setStringList(recentProjectsKey, recentProjects);
                setState(() {});
              },
            ),
          ],
        ),
      ));

  // Init //

  Future<void> gatherRecent() async {
    recentProjects = await EzCM.getStringList(recentProjectsKey) ?? recentProjects;
    if (recentProjects.isNotEmpty) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    ezWindowNamer(appName);
    gatherRecent();
  }

  // Return the build //

  @override
  Widget build(BuildContext context) {
    return Consumer<EzCP>(
      builder: (_, EzCP config, __) => A11howScaffold(
        config,
        body: EzScreen(
          config,
          child: EzAnimSwitch(
            config,
            forceFade: true,
            forceType: EzTransitionType.none,
            child: Center(
              child: EzSwapWidget(
                restricted: EzScrollView(config, children: <Widget>[
                  // Open new
                  EzTextIconButton(
                    config,
                    label: 'Open .arb directory',
                    icon: EzIcon(config, Icons.folder_open),
                    onPressed: () async => await processPath(config, null),
                  ),

                  // Div
                  EzDivider(
                    height: config.spacing * 3,
                    width: widthOf(context) * 0.667,
                    color: config.colors.secondaryContainer,
                  ),

                  // Recent(s)
                  EzText(
                    config,
                    text: 'Recent projects',
                    textAlign: TextAlign.start,
                    style: config.titleStyle,
                  ),
                  EzSpacer(config.spacing / 2),
                  ...displayRecent(config),
                ]),
                expanded: EzScrollView(
                  config,
                  reverseHands: true,
                  scrollDirection: Axis.horizontal,
                  children: <Widget>[
                    // Open new
                    EzTextIconButton(
                      config,
                      label: 'Open .arb directory',
                      icon: EzIcon(config, Icons.folder_open),
                      onPressed: () async => await processPath(config, null),
                    ),

                    // Div
                    SizedBox(
                      height: heightOf(context) * 0.667,
                      child: VerticalDivider(
                        width: config.spacing * 3,
                        color: config.colors.secondaryContainer,
                      ),
                    ),

                    // Recent(s)
                    if (recentProjects.isNotEmpty) ...<Widget>[
                      EzCol(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          EzText(
                            config,
                            text: 'Recent projects',
                            textAlign: TextAlign.start,
                            style: config.titleStyle,
                          ),
                          EzSpacer(config.spacing / 2),
                          ...displayRecent(config),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
        isHome: true,
        actions: <HybridAction>[settingsAction(config, context)],
      ),
    );
  }
}
