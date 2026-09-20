/* a11how
 * Copyright (c) 2026 YWT. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../screens/export.dart';
import '../utils/export.dart';
import '../widgets/export.dart';

import 'dart:io';
import 'dart:async';
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

  bool developing = EzCM.get(developingKey) ?? false;
  late String recentProjectsKey = developing ? recentProjectDirKey : recentProjectUrlKey;
  List<String> recentProjects = <String>[];

  TextEditingController urlController = TextEditingController();

  // Define custom functions //

  Future<void> flippityFloppity(bool choice) async {
    developing = choice;
    recentProjectsKey = choice ? recentProjectDirKey : recentProjectUrlKey;
    recentProjects = await EzCM.getStringList(recentProjectsKey) ?? <String>[];
    setState(() {});
  }

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

  String? validateUrl(String? check) {
    if (check == null || check.isEmpty) {
      return 'Cannot be empty';
    }
    return Uri.parse(check).isAbsolute ? null : 'Invalid URL';
  }

  Future<void> processURL(EzCP config, String? preSelected) async {
    await ezNoTouch(() async {
      // Valid url?
      final String url = preSelected ?? urlController.text;
      if (validateUrl(url) != null) {
        ezSnackBar(
          config,
          context: context,
          message: 'Invalid URL',
        );
        return;
      }

      // Get files
      final Directory dir = Directory(url);
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
        recentProjects.remove(url);
        recentProjects.insert(0, url);

        await EzCM.setStringList(recentProjectsKey, recentProjects);

        if (mounted) {
          context.goNamed(
            selectPath,
            extra: ARBDir(path: url, files: loadedFiles),
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
            EzIconLink(
              config,
              icon: EzIcon(config, Icons.launch),
              label: path,
              textAlign: TextAlign.start,
              textColor: config.colors.onSurface,
              hint: config.ezL10n.gOpen,
              onTap: () async => await processPath(config, path),
            ),
            Tooltip(
              message: config.ezL10n.gRemove,
              child: InkWell(
                mouseCursor: SystemMouseCursors.click,
                onTap: () async {
                  recentProjects.remove(path);
                  await EzCM.setStringList(recentProjectsKey, recentProjects);
                  setState(() {});
                },
                child: Container(
                  padding: EzInsets.wrap(config.padding),
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: EzIcon(
                    config,
                    Icons.remove_circle_outline,
                    color: config.colors.error,
                  ),
                ),
              ),
            ),
          ],
        ),
      ));

  // Init //

  Future<void> gatherRecent() async {
    recentProjects = await EzCM.getStringList(recentProjectsKey) ?? <String>[];
    if (recentProjects.isNotEmpty) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    ezWindowNamer(appName);
    gatherRecent();
  }

  // Return the build //

  Widget openButton(EzCP config) => developing
      ? EzTextIconButton(
          config,
          label: 'Open .arb directory',
          icon: EzIcon(config, Icons.folder_open),
          onPressed: () async => await processPath(config, null),
        )
      : EzCol(crossAxisAlignment: CrossAxisAlignment.end, children: <Widget>[
          EzTextIconButton(
            config,
            label: 'Open GitHub repo',
            icon: EzIcon(config, Icons.search),
            onPressed: () async => await processURL(config, null),
          ),
          config.margin,
          EzTextField(
            controller: urlController,
            hintText: 'https://github.com/YWT-LLC/a11how/tree/main/lib/l10n',
            constraints: ezTextFieldConstraints(context, prop: 0.667),
            validator: validateUrl,
          ),
        ]);

  @override
  Widget build(BuildContext context) {
    return Consumer<EzCP>(
      builder: (_, EzCP config, __) => A11howScaffold(
        config,
        body: EzScreen(
          config,
          child: EzSwapWidget(
            config,
            animate: true, // TODO: fix
            mod: 0.667,
            restricted: EzScrollView(
              config,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                // Toggle
                EzFlipFlop(
                  config,
                  init: developing,
                  onLabel: 'Developing',
                  offLabel: 'Contributing',
                  onChanged: flippityFloppity,
                ),
                config.spacer,

                // Open new
                openButton(config),

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
              ],
            ),
            expanded: EzCol(mainAxisSize: MainAxisSize.max, children: <Widget>[
              // Toggle
              EzFlipFlop(
                config,
                init: developing,
                onLabel: 'Developing',
                offLabel: 'Contributing',
                onChanged: flippityFloppity,
              ),
              config.separator,

              EzScrollView(
                config,
                reverseHands: true,
                scrollDirection: Axis.horizontal,
                children: <Widget>[
                  // Open new
                  openButton(config),

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
            ]),
          ),
        ),
        isHome: true,
        actions: <HybridAction>[settingsAction(config, context)],
      ),
    );
  }
}
