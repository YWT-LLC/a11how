/* a11how
 * Copyright (c) 2026 YWT. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../utils/export.dart';

import 'dart:math';
import 'package:open_ui/open_ui.dart';
import 'package:flutter/material.dart';

class A11howScaffold extends StatelessWidget {
  final EzCP config;
  final Widget body;
  final List<HybridAction> actions;
  final List<Widget>? settingsFABs;
  final bool isHome;

  const A11howScaffold(
    this.config, {
    super.key,
    required this.body,
    required this.actions,
    this.settingsFABs,
    this.isHome = false,
  });

  @override
  Widget build(BuildContext context) {
    final double toolbarHeight = max(
            config.iconSize,
            ezTextSize(
              config,
              text: 'Settings',
              style: config.bodyStyle,
              textScaler: MediaQuery.textScalerOf(context),
            ).height) +
        config.padding;

    Iterable<Widget> fabActions() => actions.map((HybridAction action) => FloatingActionButton(
          heroTag: '${action.label}_FAB',
          onPressed: action.onPressed,
          tooltip: action.label,
          child: EzIcon(config, action.icon),
        ));

    List<Widget> toolbarActions() => actions
        .map((HybridAction action) => Padding(
            padding: EdgeInsets.symmetric(horizontal: config.spacing / 2),
            child: EzTextIconButton(
              config,
              label: action.label,
              icon: EzIcon(config, action.icon),
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              onPressed: action.onPressed,
            )))
        .toList();

    return EzAdaptiveParent(
      small: EzScaffold(
        config,
        body: body,
        fabs: <Widget>[
          updater(config),
          ...fabActions(),
          if (settingsFABs != null) ...settingsFABs!,
          ...config.backFABs(isHome),
        ],
      ),
      medium: EzScaffold(
        config,
        appBar: actions.isEmpty
            ? null
            : PreferredSize(
                preferredSize: Size(double.infinity, toolbarHeight),
                child: EzAppBar(
                  config,
                  height: toolbarHeight,
                  leading: config.isLefty
                      ? null
                      : EzScrollView(
                          config,
                          thumbVisibility: false,
                          scrollDirection: Axis.horizontal,
                          children: toolbarActions(),
                        ),
                  leadingWidth: config.isLefty ? null : double.infinity,
                  actions: config.isLefty ? toolbarActions() : null,
                ),
              ),
        body: body,
        fabs: <Widget>[
          updater(config),
          if (settingsFABs != null) ...settingsFABs!,
          ...config.backFABs(isHome),
        ],
      ),
    );
  }
}

EzUpdaterFAB updater(EzCP config) => EzUpdaterFAB(
      config,
      appVersion: '1.0.0',
      versionSource:
          'https://raw.githubusercontent.com/USER_PH/REPO_PH/refs/heads/main/APP_VERSION',
      gPlay: 'https://play.google.com/store/apps/details?id=llc.ywt.a11how',
      appStore: 'https://apps.apple.com/us/app/a11how/APP_ID_PH',
      github: 'https://github.com/USER_PH/REPO_PH/releases',
    );
