/* a11how
 * Copyright (c) 2026 YWT. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../utils/export.dart';
import '../widgets/export.dart';

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
  List<File> files = <File>[];

  // Set the page title //

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
            child: workPath == null
                ? Center(
                    child: EzTextIconButton(
                      config,
                      label: 'Open .arb directory',
                      icon: EzIcon(config, Icons.folder_open),
                      onPressed: () async {
                        final String? selectedDirectory = await FilePicker.getDirectoryPath();
                        if (selectedDirectory == null) return;

                        setState(() {
                          workPath = selectedDirectory.contains(homePath)
                              ? '$homePath${selectedDirectory.split(homePath)[1]}'
                              : selectedDirectory;
                        });
                      },
                    ),
                  )
                : ReorderableListView(
                    scrollDirection: Axis.horizontal,
                    children: <Widget>[],
                  ),
          ),
        ),
        isHome: true,
      ),
    );
  }
}
