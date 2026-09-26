/* a11how
 * Copyright (c) 2026 YWT. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../screens/export.dart';

import 'package:open_ui/open_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ARBDir {
  final String path;
  final String? preselected;
  final bool local;
  final List<ARBFile> files;

  const ARBDir({
    required this.path,
    this.preselected,
    required this.local,
    required this.files,
  });
}

class ARBFile {
  final String path;
  final bool local;
  final String localeCode;
  final Map<String, dynamic> entries;

  const ARBFile({
    required this.path,
    required this.local,
    required this.localeCode,
    required this.entries,
  });
}

class HybridAction {
  final String label;
  final IconData icon;
  final void Function()? onPressed;
  final MenuController? menuController;
  final List<Widget>? menuChildren;

  const HybridAction({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.menuController,
    this.menuChildren,
  }) : assert(
          (menuController == null) == (menuChildren == null),
          'If MenuController is provided, MenuChildren must be. Y vice versa.',
        );
}

HybridAction settingsAction(EzCP config, BuildContext context) => HybridAction(
      label: config.ezL10n.gSettings,
      icon: Icons.settings,
      onPressed: () => context.goNamed(settingsHubPath),
    );

class WorkPair {
  final ARBFile truth;
  final ARBFile compare;

  const WorkPair({
    required this.truth,
    required this.compare,
  });
}

class WorkRow {
  String key;
  String truth;
  String compare;

  WorkRow({
    required this.key,
    required this.truth,
    required this.compare,
  });
}
