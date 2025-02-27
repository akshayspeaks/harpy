import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:harpy/components/components.dart';

class NewTweetsText extends StatelessWidget {
  const NewTweetsText(this.amount);

  final int amount;

  String get _text => amount != null && amount > 0
      ? '$amount new tweet${amount > 1 ? 's' : ''} since last visit'
      : 'new tweets since last visit';

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: DefaultEdgeInsets.symmetric(horizontal: true),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(FeatherIcons.chevronsUp),
          defaultHorizontalSpacer,
          Text(_text, style: theme.textTheme.subtitle2),
        ],
      ),
    );
  }
}
