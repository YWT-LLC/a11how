/* a11how
 * Copyright (c) 2026 YWT. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../utils/export.dart';
import '../widgets/export.dart';

import 'dart:math';
import 'package:open_ui/open_ui.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WorkScreen extends StatefulWidget {
  const WorkScreen({super.key});

  @override
  State<WorkScreen> createState() => _WorkScreenState();
}

class _WorkScreenState extends State<WorkScreen> {
  // Define the build data //

  String? workPath;
  List<ARBFile> arbFiles = <ARBFile>[];

  // Return the build //

  @override
  Widget build(BuildContext context) => Consumer<EzCP>(
        builder: (_, EzCP config, __) {
          double colWidth = max(widthOf(context) / 4, ScreenSize.small.size);

          final BoxDecoration colDeco = BoxDecoration(
            border: Border.all(
              color: config.colors.onSurface,
              width: config.borderWidth,
            ),
            borderRadius: BorderRadius.zero,
            color: config.colors.surface,
          );

          return A11howScaffold(
            config,
            body: EzScreen(
              config,
              child: ReorderableListView(
                buildDefaultDragHandles: false,
                scrollDirection: Axis.horizontal,
                onReorderItem: (int oldIndex, int newIndex) {
                  if (oldIndex == newIndex) return;
                  if (oldIndex < newIndex) newIndex -= 1;

                  final ARBFile item = arbFiles.removeAt(oldIndex);
                  arbFiles.insert(newIndex, item);

                  setState(() {});
                },
                // header: TODO,
                children: arbFiles.map((ARBFile arb) {
                  // Filter metadata keys (starts with '@')
                  final List<String> keys =
                      arb.entries.keys.where((String k) => !k.startsWith('@')).toList();

                  return Container(
                    key: ValueKey<String>(arb.path),
                    width: colWidth,
                    decoration: colDeco,
                    child: EzCol(mainAxisSize: MainAxisSize.max, children: <Widget>[
                      // Header
                      Container(
                        width: double.infinity,
                        color: config.colors.secondary,
                        child: Text(
                          '${arb.localeCode} (HUMAN_VER)',
                          style: config.titleStyle?.copyWith(color: config.colors.onSecondary),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      // Entries
                      Expanded(
                          child: ListView.builder(
                        itemCount: keys.length,
                        itemBuilder: (_, int index) {
                          final String key = keys[index];
                          final String value = arb.entries[key];

                          return EzTextField(
                            constraints: BoxConstraints(maxWidth: colWidth),
                            controller: TextEditingController(text: value.toString()),
                            hintText: key,
                            maxLines: null,
                            textAlign: TextAlign.start,
                            validator: (_) => null,
                          );
                        },
                      )),
                    ]),
                  );
                }).toList(),
              ),
            ),
            fabs: <Widget>[SettingsFAB(config, context: context)],
          );
        },
      );
}
