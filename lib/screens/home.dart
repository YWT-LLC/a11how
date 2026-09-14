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
// import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Define the build data //

  List<String> recentProjects = <String>[];

  String? workPath;
  List<ARBFile> arbFiles = <ARBFile>[];

  // Init //

  Future<void> gatherRecent() async {
    recentProjects = await EzCM.getStringList(recentProjectsKey) ?? recentProjects;
    if (recentProjects.isNotEmpty) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    ezWindowNamer(appName);
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
              child: workPath == null
                  ? EzTextIconButton(
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
                        if (arbFiles.isNotEmpty) {
                          workPath = selectedDirectory.contains(homePath)
                              ? '$homePath${selectedDirectory.split(homePath)[1]}'
                              : selectedDirectory;

                          recentProjects.remove(workPath);
                          recentProjects.insert(0, workPath!);

                          await EzCM.setStringList(recentProjectsKey, recentProjects);
                        }
                      }).whenComplete(() => setState(() {})),
                    )
                  : const SizedBox.shrink(), // TODO: choose langs, then nav? three screen(file)s?
            ),
          ),
        ),
        isHome: true,
        fabs: <Widget>[SettingsFAB(config, context: context)],
      ),
    );
  }
}
