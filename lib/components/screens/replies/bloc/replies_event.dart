part of 'replies_bloc.dart';

@immutable
abstract class RepliesEvent with HarpyLogger {
  const RepliesEvent();

  Future<void> _loadReplies(RepliesBloc bloc) async {
    final RepliesResult result = await bloc.searchService
        .findReplies(bloc.originalTweet, bloc.lastResult)
        .catchError(twitterApiErrorHandler);

    if (result != null) {
      bloc.lastResult = result;

      result.replies.sort((TweetData a, TweetData b) {
        return b.favoriteCount - a.favoriteCount;
      });

      bloc.replies.addAll(result.replies);
      log.fine('found ${result.replies.length} replies');
    }
  }

  Stream<RepliesState> applyAsync({
    RepliesState currentState,
    RepliesBloc bloc,
  });
}

/// Loads the replies for the [RepliesBloc.tweet].
///
/// If the [RepliesBloc.tweet] itself is a reply, the parent tweets will also be
/// loaded.
class LoadRepliesEvent extends RepliesEvent with HarpyLogger {
  const LoadRepliesEvent();

  Future<TweetData> _loadParentTweets(
    RepliesBloc bloc,
    TweetData tweet,
  ) async {
    if (tweet.hasParent) {
      final TweetData parent = await bloc.tweetService
          .show(id: tweet.inReplyToStatusIdStr)
          .then((Tweet tweet) => TweetData.fromTweet(tweet))
          .catchError(silentErrorHandler);

      if (parent != null) {
        parent.replies.add(tweet);
        return _loadParentTweets(bloc, parent);
      }
    }

    log.fine('found ${tweet.replies.length} parent tweets');

    return tweet;
  }

  @override
  Stream<RepliesState> applyAsync({
    RepliesState currentState,
    RepliesBloc bloc,
  }) async* {
    yield LoadingParentsState();

    bloc.tweet = await _loadParentTweets(bloc, bloc.originalTweet);

    yield LoadingRepliesState();

    await _loadReplies(bloc);

    if (bloc.replies.isEmpty &&
        bloc.lastResult != null &&
        !bloc.lastResult.lastPage) {
      // try loading next page if first result did not yield any replies for
      // the tweet
      await _loadReplies(bloc);
    }

    yield LoadedRepliesState();
  }
}

/// Loads the next replies when more replies for the [RepliesBloc.tweet] exist.
class LoadMoreRepliesEvent extends RepliesEvent with HarpyLogger {
  const LoadMoreRepliesEvent();

  @override
  Stream<RepliesState> applyAsync({
    RepliesState currentState,
    RepliesBloc bloc,
  }) async* {
    if (bloc.allRepliesLoaded) {
      log.fine('all replies already loaded');
      return;
    }

    await _loadReplies(bloc);

    yield LoadedRepliesState();
  }
}
