/* a11how
 * Copyright (c) 2026 YWT. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import 'package:flutter/material.dart';
import 'package:open_ui/open_ui.dart';

class CountFAB extends StatelessWidget {
  /// EzConfig Provider
  final EzCP config;

  /// [FloatingActionButton.onPressed] passthrough
  final void Function() count;

  /// Increases the count (for the home screen)
  const CountFAB(this.config, this.count, {super.key});

  @override
  Widget build(BuildContext context) => FloatingActionButton(
        heroTag: 'count_fab',
        onPressed: count,
        child: EzIcon(config, Icons.add),
      );
}

// todo: Complete link placeholders and include in scripts
EzUpdaterFAB updater(EzCP config) => EzUpdaterFAB(
      config,
      appVersion: '1.0.0',
      versionSource:
          'https://raw.githubusercontent.com/USER_PH/REPO_PH/refs/heads/main/APP_VERSION',
      gPlay: 'https://play.google.com/store/apps/details?id=llc.ywt.a11how',
      appStore: 'https://apps.apple.com/us/app/a11how/APP_ID_PH',
      github: 'https://github.com/USER_PH/REPO_PH/releases',
    );
