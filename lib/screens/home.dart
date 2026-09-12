/* a11how
 * Copyright (c) 2026 YWT. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../screens/export.dart';
import '../utils/export.dart';
import '../widgets/export.dart';

import 'dart:io';
import 'dart:math';
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

  final ScrollController sharedVert = ScrollController();

  // Init //

  @override
  void initState() {
    super.initState();
    ezWindowNamer(appName);
  }

  // Return the build //

  @override
  Widget build(BuildContext context) => Consumer<EzCP>(
        builder: (_, EzCP config, __) {
          double colWidth = max(widthOf(context) / 4, ScreenSize.small.size);

          final BoxDecoration colDeco = BoxDecoration(
            border: Border.all(
              color: config.colors.onSurface,
              width: config.borderWidth,
            ),
            borderRadius: BorderRadius.zero,
            color: config.colors.surface,
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
                        onPressed: () async => await ezNoTouch(() async {
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

                          arbFiles = loadedFiles;
                          workPath = selectedDirectory.contains(homePath)
                              ? '$homePath${selectedDirectory.split(homePath)[1]}'
                              : selectedDirectory;
                        }).whenComplete(() => setState(() {})),
                      ))
                    : ReorderableListView(
                        buildDefaultDragHandles: false,
                        scrollDirection: Axis.horizontal,
                        onReorderItem: (int oldIndex, int newIndex) {
                          if (oldIndex == newIndex) return;
                          if (oldIndex < newIndex) newIndex -= 1;

                          final ARBFile item = arbFiles.removeAt(oldIndex);
                          arbFiles.insert(newIndex, item);

                          setState(() {});
                        },
                        // header: TODO,
                        children: arbFiles.map((ARBFile arb) {
                          // Filter metadata keys (starts with '@')
                          final List<String> keys =
                              arb.entries.keys.where((String k) => !k.startsWith('@')).toList();

                          return Container(
                            key: ValueKey<String>(arb.path),
                            width: colWidth,
                            decoration: colDeco,
                            child: EzCol(mainAxisSize: MainAxisSize.max, children: <Widget>[
                              // Header
                              Container(
                                width: double.infinity,
                                color: config.colors.secondary,
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
                                controller: sharedVert,
                                itemCount: keys.length,
                                itemBuilder: (_, int index) {
                                  final String key = keys[index];
                                  final String value = arb.entries[key];

                                  return EzTextField(
                                    constraints: BoxConstraints(maxWidth: colWidth),
                                    controller: TextEditingController(text: value.toString()),
                                    hintText: key,
                                    maxLines: null,
                                    textAlign: TextAlign.start,
                                    validator: (_) => null,
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
