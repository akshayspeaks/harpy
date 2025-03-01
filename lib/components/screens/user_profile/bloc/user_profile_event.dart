part of 'user_profile_bloc.dart';

@immutable
abstract class UserProfileEvent {
  const UserProfileEvent();

  Stream<UserProfileState> applyAsync({
    UserProfileState currentState,
    UserProfileBloc bloc,
  });
}

/// Initializes the data for the [UserProfileBloc.user].
///
/// Either [user] or [screenName] must not be `null`.
///
/// If [user] is `null`, requests the user data for the [screenName] and the
/// relationship status (following / followed_by).
///
/// Otherwise if the [user.connections] is `null`, only requests the
/// relationship status (connections).
///
/// Yields a [InitializedUserState] if [user] is not `null`, or when a user
/// object was able to be requested, regardless of the relationship status
/// request.
///
/// Yields a [FailedLoadingUserState] otherwise.
class InitializeUserEvent extends UserProfileEvent with HarpyLogger {
  const InitializeUserEvent({
    this.user,
    this.screenName,
  }) : assert(user != null || screenName != null);

  final UserData user;

  final String screenName;

  /// The user id used to request the user or the relationship status.
  String get _screenName => screenName ?? user?.screenName;

  @override
  Stream<UserProfileState> applyAsync({
    UserProfileState currentState,
    UserProfileBloc bloc,
  }) async* {
    log.fine('initialize user');

    yield LoadingUserState();

    UserData userData = user;
    List<String> connections = user?.connections;

    if (user?.connections == null) {
      await Future.wait<void>(<Future<void>>[
        // user data
        if (userData == null && _screenName != null)
          bloc.userService
              .usersShow(screenName: _screenName)
              .then((User user) => UserData.fromUser(user))
              .then((UserData user) => userData = user)
              .catchError(silentErrorHandler),

        // friendship lookup for the relationship status (following /
        // followed_by)
        if (connections == null && _screenName != null)
          bloc.userService
              .friendshipsLookup(screenNames: <String>[_screenName])
              .then(
                (List<Friendship> response) =>
                    response.length == 1 ? response.first : null,
              )
              .then(
                (Friendship friendship) =>
                    connections = friendship?.connections,
              )
              .catchError(silentErrorHandler),
      ]);
    }

    if (userData == null) {
      yield FailedLoadingUserState();
    } else {
      userData.connections = connections;
      bloc.user = userData;

      yield InitializedUserState();
    }
  }
}

/// Follows the [bloc.user].
class FollowUserEvent extends UserProfileEvent with HarpyLogger {
  const FollowUserEvent();

  @override
  Stream<UserProfileState> applyAsync({
    UserProfileState currentState,
    UserProfileBloc bloc,
  }) async* {
    log.fine('following @${bloc.user.screenName}');

    bloc.user.connections?.add('following');
    yield InitializedUserState();

    try {
      await bloc.userService.friendshipsCreate(userId: bloc.user.idStr);
      log.fine('successfully followed @${bloc.user.screenName}');
    } catch (e) {
      twitterApiErrorHandler(e);

      // assume still not following
      bloc.user.connections?.remove('following');
      yield InitializedUserState();
    }
  }
}

/// Unfollows the [bloc.user].
class UnfollowUserEvent extends UserProfileEvent with HarpyLogger {
  const UnfollowUserEvent();

  @override
  Stream<UserProfileState> applyAsync({
    UserProfileState currentState,
    UserProfileBloc bloc,
  }) async* {
    log.fine('unfollowing @${bloc.user.screenName}');

    bloc.user.connections?.remove('following');
    yield InitializedUserState();

    try {
      await bloc.userService.friendshipsDestroy(userId: bloc.user.idStr);
      log.fine('successfully unfollowed @${bloc.user.screenName}');
    } catch (e) {
      twitterApiErrorHandler(e);

      // assume still following
      bloc.user.connections?.add('following');
      yield InitializedUserState();
    }
  }
}

/// Translates the user description.
///
/// The translation is saved in the [UserData.descriptionTranslation].
class TranslateUserDescriptionEvent extends UserProfileEvent {
  const TranslateUserDescriptionEvent({
    @required this.locale,
  });

  final Locale locale;

  @override
  Stream<UserProfileState> applyAsync({
    UserProfileState currentState,
    UserProfileBloc bloc,
  }) async* {
    HapticFeedback.lightImpact();

    final TranslationService translationService = app<TranslationService>();

    final String translateLanguage =
        bloc.languagePreferences.activeTranslateLanguage(locale.languageCode);

    yield TranslatingDescriptionState();

    await translationService
        .translate(text: bloc.user.description, to: translateLanguage)
        .then((Translation translation) =>
            bloc.user.descriptionTranslation = translation)
        .catchError(silentErrorHandler);

    if (!bloc.user.hasDescriptionTranslation ||
        bloc.user.descriptionTranslation.unchanged) {
      app<MessageService>().show('description not translated');
    }

    yield InitializedUserState();
  }
}
