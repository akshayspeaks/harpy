import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:harpy/api/api.dart';
import 'package:harpy/components/components.dart';
import 'package:harpy/core/core.dart';
import 'package:harpy/harpy_widgets/harpy_widgets.dart';
import 'package:harpy/misc/misc.dart';

/// Builds the buttons with actions for the [tweet].
class TweetActionRow extends StatelessWidget {
  const TweetActionRow(this.tweet);

  final TweetData tweet;

  @override
  Widget build(BuildContext context) {
    final TweetBloc bloc = TweetBloc.of(context);
    final RouteSettings route = ModalRoute.of(context).settings;
    final Locale locale = Localizations.localeOf(context);
    final String translateLanguage =
        app<LanguagePreferences>().activeTranslateLanguage(locale.languageCode);

    return BlocBuilder<TweetBloc, TweetState>(
      builder: (BuildContext context, TweetState state) => Row(
        children: <Widget>[
          RetweetButton(bloc, padding: DefaultEdgeInsets.all()),
          FavoriteButton(bloc, padding: DefaultEdgeInsets.all()),
          if (!tweet.currentReplyParent(route))
            HarpyButton.flat(
              onTap: () => app<HarpyNavigator>().pushRepliesScreen(
                tweet: tweet,
              ),
              icon: const Icon(CupertinoIcons.bubble_left),
              iconSize: 22,
              padding: DefaultEdgeInsets.all(),
            )
          else
            HarpyButton.flat(
              onTap: () => app<HarpyNavigator>().pushComposeScreen(
                inReplyToStatus: tweet,
              ),
              icon: const Icon(CupertinoIcons.reply),
              iconSize: 22,
              padding: DefaultEdgeInsets.all(),
            ),
          const Spacer(),
          if (tweet.translatable(translateLanguage) ||
              tweet.quoteTranslatable(translateLanguage))
            TweetTranslationButton(bloc, padding: DefaultEdgeInsets.all()),
        ],
      ),
    );
  }
}
