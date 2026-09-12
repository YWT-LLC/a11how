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
                    : const EzCol(),
              ),
            ),
            isHome: true,
            fabs: <Widget>[SettingsFAB(config, context: context)],
          );
        },
      );
}
