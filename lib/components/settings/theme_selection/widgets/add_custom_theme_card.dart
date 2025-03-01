import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:harpy/components/components.dart';
import 'package:harpy/core/core.dart';
import 'package:harpy/harpy.dart';
import 'package:harpy/harpy_widgets/harpy_widgets.dart';
import 'package:harpy/misc/misc.dart';

/// A card used to add a custom theme for the [ThemeSelectionScreen].
class AddCustomThemeCard extends StatelessWidget {
  const AddCustomThemeCard();

  Future<void> _onTap(
    BuildContext context,
    HarpyThemeData themeData,
    int themeId,
  ) async {
    if (Harpy.isFree) {
      final bool result = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) => const ProDialog(
          feature: 'theme customization',
        ),
      );

      if (result == true) {
        // todo: add try pro feature analytics
        app<HarpyNavigator>().pushCustomTheme(
          themeData: themeData,
          themeId: themeId,
        );
      }
    } else {
      app<HarpyNavigator>().pushCustomTheme(
        themeData: themeData,
        themeId: themeId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ThemeBloc themeBloc = ThemeBloc.of(context);

    // the initial custom theme data uses the currently selected theme
    final HarpyThemeData initialCustomThemeData =
        HarpyThemeData.fromHarpyTheme(HarpyTheme.of(context))
          ..name = 'new theme';

    // use the next available custom theme id
    final int nextCustomThemeId = themeBloc.customThemes.length + 10;

    // only build a trailing icon when using harpy free
    const Widget trailing =
        Harpy.isFree ? FlareIcon.shiningStar(size: 28) : null;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: kDefaultBorderRadius,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: ListTile(
          shape: kDefaultShapeBorder,
          leading: const Icon(CupertinoIcons.add),
          title: const Text('add custom theme'),
          trailing: trailing,
          onTap: () => _onTap(
            context,
            initialCustomThemeData,
            nextCustomThemeId,
          ),
        ),
      ),
    );
  }
}
