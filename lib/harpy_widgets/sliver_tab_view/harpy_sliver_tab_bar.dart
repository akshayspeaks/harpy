import 'package:flutter/material.dart';
import 'package:harpy/components/components.dart';
import 'package:harpy/harpy_widgets/harpy_widgets.dart';

/// Used by [HarpySliverTabView] to build the [HarpyTab]s.
class HarpySliverTapBar extends StatelessWidget {
  const HarpySliverTapBar({
    @required this.tabs,
  });

  final List<Widget> tabs;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: DefaultEdgeInsets.only(top: true),
        child: HarpyTabBar(
          tabs: tabs,
        ),
      ),
    );
  }
}
