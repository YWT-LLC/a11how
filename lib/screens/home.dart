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
          child: Center(
            child: EzTextIconButton(
              config,
              label: 'Open project',
              icon: EzIcon(config, Icons.folder_open),
              onPressed: () async {
                final String? selectedDirectory = await FilePicker.getDirectoryPath();
                if (selectedDirectory == null) return;

                // todo
              },
            ),
          ),
        ),
        isHome: true,
      ),
    );
  }
}
