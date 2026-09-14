/* a11how
 * Copyright (c) 2026 YWT. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import './screens/export.dart';
import './utils/export.dart';

import 'package:open_ui/open_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  // Configure the app //

  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(DeviceOrientation.values);

  EzCM.init(
    appName: appName,
    androidPackage: androidPackage,
    assetPaths: <String>{},
    orientations: DeviceOrientation.values,
    localeFallback: americanEnglish,
    l10nFallback: await OUILang.delegate.load(americanEnglish),
    preferences: await SharedPreferencesWithCache.create(
      cacheOptions: SharedPreferencesWithCacheOptions(
        allowList: allEZConfigKeys.keys.toSet(),
      ),
    ),
    defaults: isMobile() ? a11HowMobile : a11HowDesktop,
  );

  // Run the app //

  final (Locale storedLocale, OUILang storedOUILang) = await ezStoredL10n();

  runApp(A11how(
    storedLocale,
    storedOUILang,
    await Lang.delegate.load(storedLocale),
  ));
}

class A11how extends StatelessWidget {
  final Locale storedLocale;
  final OUILang storedOUILang;
  final Lang storedLang;

  const A11how(
    this.storedLocale,
    this.storedOUILang,
    this.storedLang, {
    super.key,
  });

  @override
  Widget build(BuildContext context) => EzConfigurableApp(
        localizationsDelegates: ezLocalizationsDelegates(Lang.localizationsDelegates),
        supportedLocales: Lang.supportedLocales,
        locale: storedLocale,
        el10n: storedOUILang,
        appCache: A11howCache(storedLocale, storedLang),
        routerConfig: GoRouter(
          navigatorKey: ezRootNav,
          initialLocation: homePath,
          errorBuilder: (_, GoRouterState state) => const ErrorScreen(),
          routes: <RouteBase>[
            // Home
            GoRoute(
              path: homePath,
              name: homePath,
              pageBuilder: (BuildContext pbc, GoRouterState pbs) =>
                  ezPageBuilder(configWatcher(pbc), pbc, pbs, const HomeScreen()),
              routes: <RouteBase>[
                // Settings
                GoRoute(
                  path: comparePath,
                  name: comparePath,
                  pageBuilder: (BuildContext pbc, GoRouterState pbs) =>
                      ezPageBuilder(configWatcher(pbc), pbc, pbs, const CompareScreen()),
                ),

                // Settings
                GoRoute(
                  path: settingsHubPath,
                  name: settingsHubPath,
                  pageBuilder: (BuildContext pbc, GoRouterState pbs) =>
                      ezPageBuilder(configWatcher(pbc), pbc, pbs, const SettingsHubScreen()),
                ),
              ],
            ),
          ],
        ),
      );
}
