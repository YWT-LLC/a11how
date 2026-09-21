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
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Define the build data //

  bool developing = false;
  List<String> recentDirs = <String>[];
  List<String> recentUrls = <String>[];

  TextEditingController urlController = TextEditingController();

  // Define custom functions //

  Future<void> flippityFloppity(bool choice) async {
    developing = choice;
    await EzCM.setBool(developingKey, choice);
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
        final List<String> recentProjects = developing ? recentDirs : recentUrls;
        recentProjects.remove(selectedDirectory);
        recentProjects.insert(0, selectedDirectory);

        await EzCM.setStringList(developing ? recentDirsKey : recentUrlsKey, recentProjects);

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
          final List<String> recentProjects = developing ? recentDirs : recentUrls;
          recentProjects.remove(preSelected);
          await EzCM.setStringList(developing ? recentDirsKey : recentUrlsKey, recentProjects);
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

      final Uri uri = Uri.parse(url);
      if (uri.host != 'github.com') {
        ezSnackBar(
          config,
          context: context,
          message: 'Only GitHub URLs are supported at this time',
        );
        return;
      }

      final List<String> segments = uri.pathSegments;
      if (segments.length < 5 || segments[2] != 'tree') {
        ezSnackBar(
          config,
          context: context,
          message: 'Please provide the full path the the .arb directory',
        );
        return;
      }

      final String owner = segments[0];
      final String repo = segments[1];
      final String branch = segments[3];
      final String path = segments.sublist(4).join('/');

      final Uri apiUrl =
          Uri.parse('https://api.github.com/repos/$owner/$repo/contents/$path?ref=$branch');
      final List<ARBFile> loadedFiles = <ARBFile>[];

      try {
        final http.Response response = await http.get(
          apiUrl,
          headers: <String, String>{'Accept': 'application/vnd.github.v3+json'},
        );

        if (response.statusCode == 200) {
          final List<dynamic> contents = jsonDecode(response.body);

          for (final dynamic item in contents) {
            // Check if item is a file and ends with .arb
            if (item['type'] == 'file' && item['name'].toString().endsWith('.arb')) {
              final String downloadUrl = item['download_url'];
              final http.Response fileResponse = await http.get(Uri.parse(downloadUrl));

              if (fileResponse.statusCode == 200) {
                try {
                  final String content = utf8.decode(fileResponse.bodyBytes);
                  final Map<String, dynamic> json = jsonDecode(content);

                  final String fallbackName = item['name'].toString().replaceAll('.arb', '');
                  final String locale = json['@@locale'] ?? fallbackName;

                  loadedFiles.add(ARBFile(
                    path: item['html_url'],
                    localeCode: locale,
                    entries: json,
                  ));
                } catch (e) {
                  ezLog('Skipped invalid ARB file: ${item['name']}');
                }
              }
            }
          }
        } else {
          ezLog('GitHub API error: ${response.statusCode}...\n${response.body}');
        }
      } catch (e) {
        ezLog('Error fetching from GitHub: $e');
      }

      if (loadedFiles.isNotEmpty) {
        final List<String> recentProjects = developing ? recentDirs : recentUrls;

        recentProjects.remove(url);
        recentProjects.insert(0, url);

        await EzCM.setStringList(developing ? recentDirsKey : recentUrlsKey, recentProjects);

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
          final List<String> recentProjects = developing ? recentDirs : recentUrls;
          recentProjects.remove(preSelected);
          await EzCM.setStringList(developing ? recentDirsKey : recentUrlsKey, recentProjects);
        }
      }
    });
    setState(() {});
  }

  // Init //

  Future<void> gatherRecent() async {
    developing = await EzCM.getBool(developingKey) ?? false;
    recentDirs = await EzCM.getStringList(recentDirsKey) ?? <String>[];
    recentUrls = await EzCM.getStringList(recentUrlsKey) ?? <String>[];
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    ezWindowNamer(appName);
    gatherRecent();
  }

  // Define the build //

  Widget toggle(EzCP config) => EzFlipFlop(
        config,
        key: ValueKey<bool>(developing),
        init: developing,
        onLabel: 'Developing',
        offLabel: 'Contributing',
        onChanged: flippityFloppity,
      );

  Widget openButton(EzCP config) => developing
      ? EzTextIconButton(
          config,
          label: 'Open .arb directory',
          icon: EzIcon(config, Icons.folder_open),
          onPressed: () async => await processPath(config, null),
        )
      : EzCol(crossAxisAlignment: CrossAxisAlignment.end, children: <Widget>[
          EzTextField(
            controller: urlController,
            textAlign: TextAlign.end,
            hintText: 'https://github.com/YWT-LLC/a11how/tree/main/lib/l10n',
            constraints: ezTextFieldConstraints(context, prop: 0.4),
            validator: validateUrl,
            onFieldSubmitted: (String url) async => await processURL(config, url),
          ),
          config.margin,
          EzTextIconButton(
            config,
            label: 'Open GitHub repo',
            textAlign: TextAlign.end,
            icon: EzIcon(config, Icons.folder_open),
            onPressed: () async => await processURL(config, null),
          ),
        ]);

  List<Widget> displayRecent(EzCP config) => <Widget>[
        // Title & options
        EzRow(config, reverseHands: false, children: <Widget>[
          EzText(
            config,
            text: 'Recent projects',
            textAlign: TextAlign.start,
            style: config.titleStyle,
          ),
          config.rowMargin,
          EzIconTouch(
            config,
            enabled: (developing ? recentDirs : recentUrls).isNotEmpty,
            tooltip: 'Save config',
            icon: Icons.save,
            onPressed: () async {
              try {
                await FileSaver.instance.saveAs(
                  name: 'a11how-${developing ? 'directories' : 'links'}.csv',
                  bytes: utf8.encode((developing ? recentDirs : recentUrls).join(',')),
                  mimeType: MimeType.csv,
                );
              } catch (e) {
                (mounted)
                    ? ezLogAlert(config, context: context, message: e.toString())
                    : ezLog(e.toString());
                return;
              }
            },
          ),
          EzIconTouch(
            config,
            tooltip: 'Upload config',
            icon: Icons.upload,
            onPressed: () async {
              final PlatformFile? result = await FilePicker.pickFile(
                type: FileType.custom,
                allowedExtensions: <String>['csv', 'txt'],
              );
              if (result == null) return;

              try {
                final Uint8List fileBytes = await result.readAsBytes();
                final String fileContent = utf8.decode(fileBytes);

                if (developing) {
                  final List<String> newDirs = fileContent.split(',');
                  await EzCM.setStringList(recentDirsKey, newDirs);
                  recentDirs = newDirs;
                } else {
                  final List<String> newUrls = fileContent.split(',');
                  await EzCM.setStringList(recentUrlsKey, newUrls);
                  recentUrls = newUrls;
                }

                setState(() {});
              } catch (e) {
                (mounted)
                    ? ezLogAlert(config, context: context, message: e.toString())
                    : ezLog(e.toString());
                return;
              }
            },
          ),
        ]),
        EzSpacer(config.spacing / 2),

        // Projects
        ...(developing ? recentDirs : recentUrls).map((String path) => Padding(
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
                  EzIconTouch(
                    config,
                    tooltip: config.ezL10n.gRemove,
                    icon: Icons.remove_circle_outline,
                    color: config.colors.error,
                    onPressed: () async {
                      final List<String> recentProjects = developing ? recentDirs : recentUrls;
                      recentProjects.remove(path);
                      await EzCM.setStringList(
                          developing ? recentDirsKey : recentUrlsKey, recentProjects);
                      setState(() {});
                    },
                  ),
                ],
              ),
            )),
      ];

  // Return the build //

  @override
  Widget build(BuildContext context) {
    return Consumer<EzCP>(
      builder: (_, EzCP config, __) => A11howScaffold(
        config,
        body: EzScreen(
          config,
          child: EzSwapWidget(
            config,
            animate: true,
            mod: 0.667,
            restricted: EzScrollView(
              config,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                toggle(config),
                config.spacer,
                openButton(config),
                EzDivider(
                  height: config.spacing * 3,
                  width: widthOf(context) * 0.667,
                  color: config.colors.secondaryContainer,
                ),
                ...displayRecent(config),
              ],
            ),
            expanded: EzCol(mainAxisSize: MainAxisSize.max, children: <Widget>[
              toggle(config),
              config.separator,
              EzScrollView(
                config,
                reverseHands: true,
                scrollDirection: Axis.horizontal,
                children: <Widget>[
                  openButton(config),
                  SizedBox(
                    height: heightOf(context) * 0.667,
                    child: VerticalDivider(
                      width: config.spacing * 3,
                      color: config.colors.secondaryContainer,
                    ),
                  ),
                  EzCol(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: displayRecent(config),
                  ),
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
