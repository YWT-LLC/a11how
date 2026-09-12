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

  String? workPath;
  List<ARBFile> arbFiles = <ARBFile>[];

  late double colWidth = widthOf(context);

  // Set the page title //

  @override
  void initState() {
    super.initState();
    ezWindowNamer(appName);
  }

  // Return the build //

  @override
  Widget build(BuildContext context) => Consumer<EzCP>(
        builder: (_, EzCP config, __) {
          final BoxDecoration colDeco = BoxDecoration(
            border: Border.all(
              color: config.colors.onSurface,
              width: config.borderWidth,
            ),
            borderRadius: config.textRadius,
            color: config.colors.surface,
          );
          final BoxDecoration headerDeco = BoxDecoration(
            border: Border.all(
              color: config.colors.outline,
              width: config.borderWidth,
            ),
            borderRadius: config.textRadius,
            color: config.colors.secondary,
          );

          return A11howScaffold(
            config,
            body: EzScreen(
              config,
              child: EzAnimSwitch(
                config,
                forceFade: true,
                forceType: EzTransitionType.none,
                child: workPath == null
                    ? Center(
                        child: EzTextIconButton(
                          config,
                          label: 'Open .arb directory',
                          icon: EzIcon(config, Icons.folder_open),
                          onPressed: () async {
                            // Valid dir?
                            final String? selectedDirectory = await FilePicker.getDirectoryPath();
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

                                    final String fallbackName = entity.path
                                        .split(Platform.pathSeparator)
                                        .last
                                        .replaceAll('.arb', '');
                                    final String locale = json['@@locale'] ?? fallbackName;

                                    loadedFiles.add(ARBFile(
                                      filePath: entity.path,
                                      localeCode: locale,
                                      translations: json,
                                    ));
                                  } catch (e) {
                                    ezLog('Skipped invalid ARB file: ${entity.path}');
                                  }
                                }
                              }
                            }

                            arbFiles = loadedFiles;
                            workPath = selectedDirectory.contains(homePath)
                                ? '$homePath${selectedDirectory.split(homePath)[1]}'
                                : selectedDirectory;
                            setState(() {});
                          },
                        ),
                      )
                    : ReorderableListView(
                        scrollDirection: Axis.horizontal,
                        onReorderItem: (int oldIndex, int newIndex) {
                          if (oldIndex == newIndex) return;
                          if (oldIndex < newIndex) newIndex -= 1;

                          final ARBFile item = arbFiles.removeAt(oldIndex);
                          arbFiles.insert(newIndex, item);

                          setState(() {});
                        },
                        children: arbFiles.map((ARBFile arb) {
                          // Filter metadata keys (starts with '@')
                          final List<String> keys = arb.translations.keys
                              .where((String k) => !k.startsWith('@'))
                              .toList();

                          return Container(
                            key: ValueKey<String>(arb.filePath),
                            width: colWidth,
                            decoration: colDeco,
                            child: EzCol(mainAxisSize: MainAxisSize.max, children: <Widget>[
                              // Header
                              Container(
                                decoration: headerDeco,
                                child: Text(
                                  '${arb.localeCode} (HUMAN_VER)',
                                  style:
                                      config.titleStyle?.copyWith(color: config.colors.onSecondary),
                                  textAlign: TextAlign.center,
                                ),
                              ),

                              // Entries
                              Expanded(
                                  child: ListView.builder(
                                itemCount: keys.length,
                                itemBuilder: (_, int index) {
                                  final String key = keys[index];
                                  final String value = arb.translations[key];

                                  return ListTile(
                                    title: Text(
                                      key,
                                      style: config.labelStyle,
                                      textAlign: TextAlign.center,
                                    ),
                                    subtitle: Text(
                                      value.toString(),
                                      style: config.bodyStyle,
                                      textAlign: TextAlign.center,
                                    ),
                                  );
                                },
                              )),
                            ]),
                          );
                        }).toList(),
                      ),
              ),
            ),
            isHome: true,
            fabs: <Widget>[
              FloatingActionButton(
                onPressed: () => context.goNamed(settingsHubPath),
                tooltip: config.ezL10n.ssNavHint,
                child: EzIcon(config, Icons.settings),
              ),
            ],
          );
        },
      );
}
