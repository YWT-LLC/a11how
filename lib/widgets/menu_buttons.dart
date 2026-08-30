/* a11how
 * Copyright (c) 2026 YWT. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../screens/export.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:open_ui/open_ui.dart';

class SettingsButton extends StatelessWidget {
  /// EzConfig Provider
  final EzCP config;

  /// [BuildContext] to call [GoRouter.goNamed] with
  final BuildContext parentContext;

  /// [EzMenuButton] for opening the settings
  const SettingsButton(this.config, {super.key, required this.parentContext});

  @override
  Widget build(_) => EzMenuButton(
        config,
        onPressed: () => parentContext.goNamed(settingsHubPath),
        icon: EzIcon(config, Icons.settings),
        label: config.ezL10n.gSettings,
      );
}

class OUICredits extends StatelessWidget {
  /// EzConfig Provider
  final EzCP config;

  final String _label;

  /// [EzMenuButton] for opening Open UI's product page
  /// Honor system: keep a version of this in your app
  /// Remove iff appropriate contributions have been made to YWT
  /// https://www.ywt.llc/#/contribute
  OUICredits(this.config, {super.key})
      : _label = config.isLefty ? config.ezL10n.gMadeBy : config.ezL10n.gCreator;

  @override
  Widget build(BuildContext context) => Tooltip(
        message: config.ezL10n.gOpenYWT,
        excludeFromSemantics: true,
        child: EzMenuLink(
          config,
          uri: Uri.parse('https://www.ywt.llc/#/products/open-ui'),
          icon: EzIcon(config, Icons.settings),
          label: _label,
          semanticsLabel:
              '${config.isLefty ? '${config.ezL10n.gSettings} $_label' : '$_label ${config.ezL10n.gSettings}'}. ${config.ezL10n.gOpenYWT}',
        ),
      );
}
