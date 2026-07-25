/* a11how
 * Copyright (c) 2026 YWT. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../utils/export.dart';
import './export.dart';

import 'package:flutter/material.dart';
import 'package:open_ui/open_ui.dart';

class A11howScaffold extends StatelessWidget {
  /// EzConfig Provider
  final EzCP config;

  /// [AppBar.title] passthrough (via [Text] widget)
  final String title;

  /// Whether to include [SettingsButton] in the [MenuAnchor]
  final bool showSettings;

  /// [Scaffold.body] passthrough
  final Widget body;

  /// [FloatingActionButton]s to add on top of the [EzUpdaterFAB]
  /// BYO spacing widgets
  final List<Widget>? fabs;

  /// For [EzCP.backFABs]
  final bool isHome;

  /// Standardized [Scaffold] for all of the Open UI example app's screens
  const A11howScaffold(this.config, {
    super.key,
    this.title = appName,
    this.showSettings = true,
    required this.body,
    this.fabs,
    this.isHome = false,
  });

  @override
  Widget build(BuildContext context) {
    // Gather the contextual theme data //

    final double toolbarHeight =
        ezToolbarHeight(config, context: context, title: appName);

    // Define custom widgets //

    late final Widget options = MenuAnchor(
      builder: (_, MenuController controller, ___) => EzIconButton(config, 
        onPressed: () => toggleMenu(controller),
        tooltip: config.ezL10n.gOptions,
        iconSize: config.titleStyle!.fontSize,
        icon: Icon(Icons.more_vert, semanticLabel: config.ezL10n.gOptions),
      ),
      menuChildren: <Widget>[
        (showSettings) ? SettingsButton(config, parentContext: context) : OUICredits(config),
      ],
    );

    // Return the build //

    return EzAdaptiveParent(
      small: EzScaffold(
        config,
        appBar: PreferredSize(
          preferredSize: Size(double.infinity, toolbarHeight),
          child: EzAppBar(
            config,
            height: toolbarHeight,
            leading: config.isLefty ? options : EzBackAction(config),
            leadingWidth: toolbarHeight,
            title: Text(title, textAlign: TextAlign.center),
            actions: <Widget>[config.isLefty ? EzBackAction(config) : options],
          ),
        ),
        body: body,
        fabs: <Widget>[
          updater(config),
          if (fabs != null) ...fabs!,
          ...config.backFABs(isHome),
        ],
      ),
    );
  }
}
