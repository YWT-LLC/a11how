/* a11how
 * Copyright (c) 2026 YWT. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../utils/export.dart';
import '../widgets/export.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:open_ui/open_ui.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Define the build data //

  int count = 0;

  // Set the page title //

  @override
  void initState() {
    super.initState();
    ezWindowNamer(appName);
  }

  // Return the build //

  @override
  Widget build(BuildContext context) {
    return Consumer<EzCP>(builder: (_, EzCP config, __) => A11howScaffold(
        config,
        body: EzScreen(
          config,
          child: Center(
            child: EzCol(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  l10n(config).hsCounterLabel,
                  style: ezSubTitleStyle(config.styles),
                  textAlign: TextAlign.center,
                ),
                Text(
                  count.toString(),
                  style: config.headlineStyle,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        title: appName,
        fabs: <Widget>[
          config.spacer,
          CountFAB(config, () => setState(() => count += 1)),
        ],
        isHome: true,
      ),
    );
  }
}
