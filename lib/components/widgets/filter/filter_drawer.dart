import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:harpy/components/components.dart';
import 'package:harpy/core/core.dart';
import 'package:harpy/harpy_widgets/harpy_widgets.dart';
import 'package:harpy/misc/misc.dart';

class FilterDrawer extends StatelessWidget {
  const FilterDrawer({
    @required this.title,
    @required this.filterGroups,
    @required this.onSearch,
    @required this.onClear,
    this.showClear = true,
    this.showSearchButton = true,
    this.searchButtonText = 'search',
    this.searchButtonIcon = CupertinoIcons.search,
  });

  final String title;
  final List<Widget> filterGroups;
  final VoidCallback onClear;
  final VoidCallback onSearch;
  final bool showClear;
  final bool showSearchButton;
  final String searchButtonText;
  final IconData searchButtonIcon;

  Widget _buildTitleRow(ThemeData theme) {
    return Row(
      children: <Widget>[
        defaultHorizontalSpacer,
        Expanded(
          child: Text(title, style: theme.textTheme.subtitle1),
        ),
        HarpyButton.flat(
          dense: true,
          icon: const Icon(CupertinoIcons.xmark),
          onTap: showClear ? onClear : null,
        ),
      ],
    );
  }

  Widget _buildSearchButton(ThemeData theme, EdgeInsets padding) {
    return CustomAnimatedSize(
      child: AnimatedSwitcher(
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        duration: kShortAnimationDuration,
        child: showSearchButton
            ? Padding(
                padding: padding,
                child: SizedBox(
                  width: double.infinity,
                  child: HarpyButton.raised(
                    icon: Icon(searchButtonIcon),
                    text: Text(searchButtonText),
                    backgroundColor: theme.cardColor,
                    dense: true,
                    onTap: () async {
                      await app<HarpyNavigator>().state.maybePop();
                      onSearch();
                    },
                  ),
                ),
              )
            : defaultVerticalSpacer,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    return Drawer(
      child: HarpyBackground(
        child: ListView(
          primary: false,
          padding: EdgeInsets.zero,
          children: <Widget>[
            // add status bar height to top padding and make it scrollable
            SizedBox(height: defaultPaddingValue + mediaQuery.padding.top),
            _buildTitleRow(theme),
            _buildSearchButton(theme, DefaultEdgeInsets.all()),
            for (Widget group in filterGroups) ...<Widget>[
              group,
              if (group != filterGroups.last) defaultVerticalSpacer,
            ],
            _buildSearchButton(
              theme,
              DefaultEdgeInsets.all().copyWith(bottom: 0),
            ),
            // add nav bar height to bottom padding and make it scrollable
            SizedBox(height: defaultPaddingValue + mediaQuery.padding.bottom),
          ],
        ),
      ),
    );
  }
}
