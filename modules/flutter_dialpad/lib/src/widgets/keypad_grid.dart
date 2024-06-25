import 'package:flutter/material.dart';

class KeypadGrid extends StatelessWidget {
  const KeypadGrid({
    required this.itemBuilder,
    required this.itemCount,
    super.key,
    this.crossAxisCount = 3,
    this.footer,
  });

  /// The number of items in the grid.
  final int itemCount;

  /// The [IndexedWidgetBuilder] for each item in the grid.
  final IndexedWidgetBuilder itemBuilder;

  /// The number of items in each row of the grid.
  final int crossAxisCount;

  /// The number of items in each row of the grid.
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final length = (itemCount / crossAxisCount).floor();

    final List<Widget> items = List.generate(length, (index) => index).map((e) {
      final subItems = List.generate(
        crossAxisCount,
        (index) {
          return Expanded(
            child: itemBuilder(context, e * crossAxisCount + index),
          );
        },
      );
      return Expanded(
        child: Row(children: subItems),
      );
    }).toList();
    if (footer != null) {
      items.add(
        Expanded(child: footer!),
      );
    }

    return Column(children: items);
  }
}
