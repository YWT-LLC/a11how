/* a11how
 * Copyright (c) 2026 YWT (Empathetech LLC). All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../screens/export.dart';
import '../utils/export.dart';
import '../widgets/export.dart';
import 'package:ywt_private/ywt_private.dart' as ywt;

import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:open_ui/open_ui.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:file_saver/file_saver.dart';
import 'package:material_ui/material_ui.dart';
import 'package:file_picker/file_picker.dart';
import 'package:after_layout/after_layout.dart';

class HomeScreen extends StatefulWidget {
  final String? projectLink;
  final String? localeLink;

  const HomeScreen({
    super.key,
    this.projectLink,
    this.localeLink,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AfterLayoutMixin<HomeScreen> {
  // Define the build data //

  bool developing = false;
  List<String> recentDirs = <String>[];
  List<String> recentUrls = <String>[];

  TextEditingController urlController = TextEditingController();

  // Define custom functions //

  Future<void> flippityFloppity(bool choice) async {
    developing = choice;
    await EzManager.setBool(developingKey, choice);
    setState(() {});
  }

  Future<void> processPath(EzProvider config, Uri? preSelected) async {
    await ezNoTouch(config, () async {
      // Valid dir?
      final Uri? selectedUri = preSelected ?? await FilePicker.pickDirectory();
      if (selectedUri == null) return;

      // dart:io can only read file URIs (Android returns a content:// tree URI)
      final String selectedDirectory =
          selectedUri.isScheme('file') ? selectedUri.toFilePath() : selectedUri.toString();

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
                local: developing,
                localeCode: locale,
                entries: json,
              ));
            } catch (e) {
              ezLog(l10n(config).hsSkippedInvalid(entity.path));
            }
          }
        }
      }

      if (loadedFiles.isNotEmpty) {
        final List<String> recentProjects = developing ? recentDirs : recentUrls;
        recentProjects.remove(selectedDirectory);
        recentProjects.insert(0, selectedDirectory);

        await EzManager.setStringList(developing ? recentDirsKey : recentUrlsKey, recentProjects);

        if (mounted) {
          context.goNamed(
            selectScreenName,
            extra: ARBDir(path: selectedDirectory, local: developing, files: loadedFiles),
          );
        }
      } else {
        if (mounted) {
          ezSnackBar(
            config,
            context: context,
            message:
                '${l10n(config).hsNothingFound}${preSelected == null ? '' : l10n(config).hsRemovingRecent}',
          );
        }
        if (preSelected != null) {
          final List<String> recentProjects = developing ? recentDirs : recentUrls;
          recentProjects.remove(selectedDirectory);
          await EzManager.setStringList(developing ? recentDirsKey : recentUrlsKey, recentProjects);
        }
      }
    });
    setState(() {});
  }

  String? validateUrl(EzProvider config, String? check) {
    if (check == null || check.isEmpty) {
      return l10n(config).gNoEmpty;
    }
    return Uri.parse(check).isAbsolute ? null : l10n(config).gInvalidURL;
  }

  Future<void> processUrl(EzProvider config, String? preSelected) async {
    await ezNoTouch(config, () async {
      // Valid url?
      final String url = preSelected ?? urlController.text;
      if (validateUrl(config, url) != null) {
        ezSnackBar(
          config,
          context: context,
          message: l10n(config).gInvalidURL,
        );
        return;
      }

      final Uri uri = Uri.parse(url);
      if (uri.host != 'github.com') {
        ezSnackBar(
          config,
          context: context,
          message: l10n(config).hsOnlyGit,
        );
        return;
      }

      final List<String> segments = uri.pathSegments;
      if (segments.length < 5 || segments[2] != 'tree') {
        ezSnackBar(
          config,
          context: context,
          message: l10n(config).hsFullPath,
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
                    local: developing,
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

        await EzManager.setStringList(developing ? recentDirsKey : recentUrlsKey, recentProjects);

        if (mounted) {
          context.goNamed(
            selectScreenName,
            extra: ARBDir(
              path: url,
              preselected: widget.localeLink,
              local: developing,
              files: loadedFiles,
            ),
          );
        }
      } else {
        if (mounted) {
          ezSnackBar(
            config,
            context: context,
            message:
                '${l10n(config).hsNothingFound}${preSelected == null ? '' : l10n(config).hsRemovingRecent}',
          );
        }
        if (preSelected != null) {
          final List<String> recentProjects = developing ? recentDirs : recentUrls;
          recentProjects.remove(preSelected);
          await EzManager.setStringList(developing ? recentDirsKey : recentUrlsKey, recentProjects);
        }
      }
    });
    setState(() {});
  }

  // Init //

  Future<void> gatherRecent() async {
    developing = await EzManager.getBool(developingKey) ?? false;
    recentDirs = await EzManager.getStringList(recentDirsKey) ?? <String>[];
    recentUrls = await EzManager.getStringList(recentUrlsKey) ?? <String>[];
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    ezWindowNamer(appName);
    gatherRecent();
  }

  @override
  Future<void> afterFirstLayout(BuildContext context) async => widget.projectLink == null
      ? doNothing()
      : await processUrl(configWatcher(context), widget.projectLink);

  // Define the build //

  Widget toggle(EzProvider config) => EzFlipFlop(
        config,
        key: ValueKey<bool>(developing),
        init: developing,
        onLabel: l10n(config).hsDeveloping,
        offLabel: l10n(config).hsContributing,
        onChanged: flippityFloppity,
      );

  Widget openButton(EzProvider config) => developing
      ? EzTextIconButton(
          config,
          label: l10n(config).hsOpenDir,
          icon: EzIcon(config, Icons.folder_open),
          onPressed: () async => await processPath(config, null),
        )
      : EzCol(crossAxisAlignment: CrossAxisAlignment.end, children: <Widget>[
          EzTextField(
            controller: urlController,
            textAlign: TextAlign.end,
            hintText: '${ywt.a11howGitHub}/tree/main/lib/l10n',
            constraints: ezTextFieldConstraints(context, prop: 0.4),
            validator: (String? check) => validateUrl(config, check),
            onFieldSubmitted: (String url) async => await processUrl(config, url),
          ),
          config.margin,
          EzRow(config, children: <Widget>[
            EzTextIconButton(
              config,
              label: l10n(config).hsOpenGit,
              textAlign: TextAlign.end,
              icon: EzIcon(config, Icons.folder_open),
              onPressed: () async => await processUrl(config, null),
            ),
            EzToolTipper(
              config,
              message: l10n(config).hsGitTip(ywt.a11howGitHub),
            )
          ]),
        ]);

  List<Widget> displayRecent(EzProvider config) => <Widget>[
        // Title & options
        EzRow(config, reverseHands: false, children: <Widget>[
          EzText(
            config,
            text: l10n(config).hsRecent,
            textAlign: TextAlign.start,
            style: config.titleStyle,
          ),
          config.rowMargin,
          EzIconTouch(
            config,
            enabled: (developing ? recentDirs : recentUrls).isNotEmpty,
            tooltip: config.ezL10n.ssSaveConfig,
            icon: Icons.save,
            backgroundFill: config.surfaceContainerFill,
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
            tooltip: config.ezL10n.ssLoadConfig,
            icon: Icons.upload,
            backgroundFill: config.surfaceContainerFill,
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
                  await EzManager.setStringList(recentDirsKey, newDirs);
                  recentDirs = newDirs;
                } else {
                  final List<String> newUrls = fileContent.split(',');
                  await EzManager.setStringList(recentUrlsKey, newUrls);
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
        config.halfSpacer,

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
                    label: developing ? path : Uri.parse(path).pathSegments[1],
                    tooltip: developing ? null : path,
                    textAlign: TextAlign.start,
                    textColor: config.onSurface,
                    hint: config.ezL10n.gOpen,
                    onTap: () async => developing
                        ? await processPath(config, Uri.file(path))
                        : await processUrl(config, path),
                  ),
                  EzIconTouch(
                    config,
                    tooltip: config.ezL10n.gRemove,
                    icon: Icons.remove_circle_outline,
                    backgroundFill: config.surfaceContainerFill,
                    iconFill: config.errorFill,
                    onPressed: () async {
                      final List<String> recentProjects = developing ? recentDirs : recentUrls;
                      recentProjects.remove(path);
                      await EzManager.setStringList(
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
    return Consumer<EzProvider>(
      builder: (_, EzProvider config, __) => A11howScaffold(
        config,
        body: EzScreen(
          config,
          safeArea: true,
          alignment: Alignment.topCenter,
          child: EzSwapWidget(
            config,
            animate: true,
            mod: 0.667,
            restricted: EzScrollView(config, children: <Widget>[
              if (!kIsWeb) toggle(config),
              config.spacer,
              openButton(config),
              EzDivider(
                config,
                width: widthOf(context) * 0.667,
                fill: config.secondaryContainerFill,
              ),
              ...displayRecent(config),
              config.separator,
            ]),
            expanded: EzScrollView(config, children: <Widget>[
              if (!kIsWeb) toggle(config),
              config.separator,
              EzScrollView(
                config,
                reverseHands: true,
                scrollDirection: Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  openButton(config),
                  EzVerticalDivider(
                    config,
                    height: heightOf(context) * 0.667,
                    width: config.spacing * 3,
                    fill: config.secondaryContainerFill,
                  ),
                  EzCol(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: displayRecent(config),
                  ),
                ],
              ),
              config.separator,
            ]),
          ),
        ),
        isHome: true,
        actions: <HybridAction>[
          HybridAction(
            label: config.ezL10n.gSettings,
            icon: Icons.settings,
            onPressed: () => context.goNamed(settingsScreenName),
          ),
        ],
      ),
    );
  }
}
