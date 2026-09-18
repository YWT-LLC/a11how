/* a11how
 * Copyright (c) 2026 YWT. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import 'package:open_ui/open_ui.dart';

enum FilterType { startsWith, contains, endsWith }

const String esStarts = 'startsWith';
const String esContains = 'contains';
const String esEnds = 'endsWith';

extension FTConfig on FilterType {
  String get value => switch (this) {
        FilterType.startsWith => esStarts,
        FilterType.contains => esContains,
        FilterType.endsWith => esEnds,
      };

  String name(EzCP config) => switch (this) {
        FilterType.startsWith => 'Starts with',
        FilterType.contains => 'Contains',
        FilterType.endsWith => 'Ends with',
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
