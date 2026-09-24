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
              text: config.ezL10n.gSettings,
              style: config.bodyStyle,
              textScaler: MediaQuery.textScalerOf(context),
            ).height) +
        config.padding;

    Iterable<Widget> fabActions() => actions.map((HybridAction action) {
          final Widget core = Padding(
            padding: EdgeInsets.only(top: config.spacing),
            child: FloatingActionButton(
              heroTag: '${action.label}_FAB',
              onPressed: action.onPressed,
              tooltip: action.label,
              child: EzIcon(config, action.icon),
            ),
          );

          return action.menuController == null
              ? core
              : MenuAnchor(
                  controller: action.menuController!,
                  menuChildren: action.menuChildren!,
                  child: core,
                );
        });

    List<Widget> toolbarActions() => actions.map((HybridAction action) {
          final Widget core = Padding(
              padding: EdgeInsets.symmetric(horizontal: config.spacing / 2),
              child: EzTextIconButton(
                config,
                label: action.label,
                icon: EzIcon(config, action.icon),
                onPressed: action.onPressed,
              ));

          return action.menuController == null
              ? core
              : MenuAnchor(
                  controller: action.menuController!,
                  menuChildren: action.menuChildren!,
                  child: core,
                );
        }).toList();

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
        appBar: PreferredSize(
          preferredSize: Size(double.infinity, toolbarHeight),
          child: EzAppBar(
            config,
            height: toolbarHeight,
            title: EzScrollView(
              config,
              reverseHands: true,
              showScrollHint: true,
              thumbVisibility: false,
              scrollDirection: Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.center,
              children: toolbarActions(),
            ),
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
      versionSource: 'https://raw.githubusercontent.com/YWT-LLC/a11how/refs/heads/main/APP_VERSION',
      gPlay: 'https://play.google.com/store/apps/details?id=llc.ywt.a11how',
      appStore: 'https://apps.apple.com/us/app/a11how/APP_ID_PH',
      github: 'https://github.com/YWT-LLC/a11how/releases',
    );
