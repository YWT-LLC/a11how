/* a11how
 * Copyright (c) 2026 YWT. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import 'package:a11how/utils/a11how_cache.dart';
import 'package:open_ui/open_ui.dart';
import 'package:flutter/material.dart';

//* Filter Target *//

enum FilterTarget { key, truth, compare }

const String esKey = 'key';
const String esTruth = 'truth';
const String esCompare = 'compare';

extension FTargetCon on FilterTarget {
  String get value => switch (this) {
        FilterTarget.key => esKey,
        FilterTarget.truth => esTruth,
        FilterTarget.compare => esCompare,
      };

  Widget icon(EzCP config) => switch (this) {
        FilterTarget.key => EzIcon(config, Icons.key),
        FilterTarget.truth => EzIcon(config, Icons.balance),
        FilterTarget.compare => EzIcon(config, Icons.compare),
      };

  String name(EzCP config) => switch (this) {
        FilterTarget.key => l10n(config).gKey,
        FilterTarget.truth => l10n(config).gTruth,
        FilterTarget.compare => l10n(config).gCompare,
      };

  static FilterTarget? lookup(String? value) => switch (value) {
        esKey => FilterTarget.key,
        esTruth => FilterTarget.truth,
        esCompare => FilterTarget.compare,
        _ => null,
      };

  /// Defaults to [FilterTarget.key]
  static FilterTarget safeLookup(String? value) => switch (value) {
        esTruth => FilterTarget.truth,
        esCompare => FilterTarget.compare,
        _ => FilterTarget.key,
      };
}

//* Filter Type *//

enum FilterType { startsWith, contains, endsWith }

const String esStarts = 'startsWith';
const String esContains = 'contains';
const String esEnds = 'endsWith';

extension FTypeCon on FilterType {
  String get value => switch (this) {
        FilterType.startsWith => esStarts,
        FilterType.contains => esContains,
        FilterType.endsWith => esEnds,
      };

  String name(EzCP config) => switch (this) {
        FilterType.startsWith => l10n(config).gStarts,
        FilterType.contains => l10n(config).gContains,
        FilterType.endsWith => l10n(config).gEnds,
      };

  static FilterType? lookup(String? value) => switch (value) {
        esStarts => FilterType.startsWith,
        esContains => FilterType.contains,
        esEnds => FilterType.endsWith,
        _ => null,
      };

  /// Defaults to [FilterType.startsWith]
  static FilterType safeLookup(String? value) => switch (value) {
        esContains => FilterType.contains,
        esEnds => FilterType.endsWith,
        _ => FilterType.startsWith,
      };
}

//* Translation Service *//

enum TranslationService {
  proZ,
  cafe,
  gengo,
  fiverr,
  upwork,
  gemini,
  qwen,
  gpt,
  claude,
}

const String esProZ = 'proZ';
const String esCafe = 'cafe';
const String esGengo = 'gengo';
const String esFiverr = 'fiverr';
const String esUpwork = 'upwork';
const String esGemini = 'gemini';
const String esQwen = 'qwen';
const String esGPT = 'gpt';
const String esClaude = 'claude';

extension TSConfig on TranslationService {
  String get value => switch (this) {
        TranslationService.proZ => esProZ,
        TranslationService.cafe => esCafe,
        TranslationService.gengo => esGengo,
        TranslationService.fiverr => esFiverr,
        TranslationService.upwork => esUpwork,
        TranslationService.gemini => esGemini,
        TranslationService.qwen => esQwen,
        TranslationService.gpt => esGPT,
        TranslationService.claude => esClaude,
      };

  String name(EzCP config) => switch (this) {
        TranslationService.proZ => 'ProZ',
        TranslationService.cafe => 'Translators Cafe',
        TranslationService.gengo => 'Gengo',
        TranslationService.fiverr => 'Fiverr',
        TranslationService.upwork => 'Upwork',
        TranslationService.gemini => 'Gemini',
        TranslationService.qwen => 'Qwen',
        TranslationService.gpt => 'GPT',
        TranslationService.claude => 'Claude',
      };

  Uri get url => switch (this) {
        TranslationService.proZ => Uri.parse('https://www.proz.com/'),
        TranslationService.cafe => Uri.parse('https://www.translatorscafe.com/cafe/'),
        TranslationService.gengo => Uri.parse('https://gengo.com/'),
        TranslationService.fiverr => Uri.parse('https://www.fiverr.com/'),
        TranslationService.upwork => Uri.parse('https://www.upwork.com/'),
        TranslationService.gemini => Uri.parse('https://gemini.google.com/app'),
        TranslationService.qwen => Uri.parse('https://chat.qwen.ai/'),
        TranslationService.gpt => Uri.parse('https://chatgpt.com/'),
        TranslationService.claude => Uri.parse('https://claude.ai/chat/'),
      };

  String prompt({required String source, required String dest, required String json}) =>
      switch (this) {
        TranslationService.proZ ||
        TranslationService.fiverr ||
        TranslationService.upwork =>
          """Hello!
I need help translating an app I'm working on.

I've attached a .zip with the `$source` source file (for reference) and a blank `$dest` file (to complete). Both are .arb files; don't worry if you haven't heard of .arb before, it's exactly the same as .json.

If you haven't worked with either, it's pretty simple. Basically, the left hand side of each pair is a variable name. So, you can (and should) ignore it/leave it unchanged.
The right hand side is the actual entry to be translated. So, fill in `$dest.arb` with the translated versions of `$source.arb`, and you're good to go!

Please let me know if you're interested in this gig. Thanks!
""",
        _ =>
          '''Please translate this .arb file from `$source` to `$dest`. Please maintain the format so I can copy/paste the results.

----  ----  ----

$json
''',
      };

  bool get human => switch (this) {
        TranslationService.proZ ||
        TranslationService.cafe ||
        TranslationService.gengo ||
        TranslationService.fiverr ||
        TranslationService.upwork =>
          true,
        _ => false,
      };

  Widget twoCents(EzCP config) => human
      ? const SizedBox.shrink()
      : EzToolTipper(
          config,
          message: """Reminder: LLMs are a shortcut.
And inherently, mathematically, unreliable.

Disclose you're using machine translation until you can afford proper translations <3
There's no shame in it.

The shame is for those who choose to take a short cut, that will yield objectively worse results, AND take away a job that could have been
...to save a couple of bucks...
But actually not, because you're still spending your privacy/data and our Earth's resources. Oh, and a subscription/token fee.

LARPing has a time and place: the forest, and the bedroom.
Let's keep it out of our resumes though, shall we?

...unless you have a ren-fair resume, then pop-off my liege.""",
        );

  static TranslationService? lookup(String? value) => switch (value) {
        esProZ => TranslationService.proZ,
        esCafe => TranslationService.cafe,
        esGengo => TranslationService.gengo,
        esFiverr => TranslationService.fiverr,
        esUpwork => TranslationService.upwork,
        esGemini => TranslationService.gemini,
        esQwen => TranslationService.qwen,
        esGPT => TranslationService.gpt,
        esClaude => TranslationService.claude,
        _ => null,
      };

  /// Defaults to [TranslationService.proZ]
  static TranslationService safeLookup(String? value) => switch (value) {
        esCafe => TranslationService.cafe,
        esGengo => TranslationService.gengo,
        esFiverr => TranslationService.fiverr,
        esUpwork => TranslationService.upwork,
        esGemini => TranslationService.gemini,
        esQwen => TranslationService.qwen,
        esGPT => TranslationService.gpt,
        esClaude => TranslationService.claude,
        _ => TranslationService.proZ,
      };
}
