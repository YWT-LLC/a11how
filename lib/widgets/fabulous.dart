/* a11how
 * Copyright (c) 2026 YWT. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../screens/export.dart';

import 'package:open_ui/open_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsFAB extends FloatingActionButton {
  final EzCP config;

  SettingsFAB(this.config, {required BuildContext context, super.key})
      : super(
          heroTag: 'settings_FAB',
          child: EzIcon(config, Icons.settings),
          onPressed: () => context.goNamed(settingsHubPath),
          tooltip: config.ezL10n.ssNavHint,
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
