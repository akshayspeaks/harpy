part of 'post_tweet_bloc.dart';

/// Posts the tweet for the authenticated user.
///
/// The attached media (if any) is uploaded separately before posting the tweet.
/// If the attached media is a video, it is converted beforehand to comply with
/// the twitter requirements.
@immutable
class PostTweetEvent extends Equatable with HarpyLogger {
  const PostTweetEvent(this.text);

  final String text;

  @override
  List<Object> get props => <Object>[
        text,
      ];

  Stream<PostTweetState> _uploadMedia(PostTweetBloc bloc) async* {
    log.fine('uploading media');

    final List<File> mediaFiles = <File>[];

    if (bloc.composeBloc.state.hasVideo) {
      final PlatformFile videoSource = bloc.composeBloc.state.media.first;

      yield const ConvertingTweetVideo();

      final File output = await app<MediaVideoConverter>().convertVideo(
        videoSource.path,
        videoSource.extension,
      );

      if (output != null) {
        mediaFiles.add(output);
      } else {
        yield const ConvertingTweetVideoError();
      }
    } else {
      mediaFiles.addAll(
        bloc.composeBloc.state.media.map(
          (PlatformFile platformFile) => File(platformFile.path),
        ),
      );
    }

    final List<String> mediaIds = <String>[];

    try {
      for (int i = 0; i < mediaFiles.length; i++) {
        yield UploadingTweetMedia(
          index: i,
          multiple: mediaFiles.length > 1,
          type: bloc.composeBloc.state.type,
        );

        final String mediaId = await bloc.mediaUploadService.upload(
          mediaFiles[i],
          type: bloc.composeBloc.state.type,
        );

        if (mediaId != null) {
          mediaIds.add(mediaId);
        }
      }

      log.fine('${mediaIds.length} media uploaded');
      yield TweetMediaSuccessfullyUploaded(
        previousMessage: bloc.state.message,
        previousAdditionalInfo: bloc.state.additionalInfo,
        mediaIds: mediaIds,
      );
    } catch (e, st) {
      log.severe('error while uploading media', e, st);
      yield const UploadingTweetMediaError();
    }
  }

  Stream<PostTweetState> applyAsync({
    PostTweetState currentState,
    PostTweetBloc bloc,
  }) async* {
    if (bloc.composeBloc.state.hasMedia) {
      await for (PostTweetState state in _uploadMedia(bloc)) {
        yield state;
      }
    }

    if (bloc.state is PostTweetErrorState) {
      return;
    }

    log.fine('updating status');

    yield const PostingTweet();

    List<String> mediaIds;
    if (bloc.state is TweetMediaSuccessfullyUploaded) {
      mediaIds = (bloc.state as TweetMediaSuccessfullyUploaded).mediaIds;
    }

    // additional info that will be displayed in the dialog (e.g. error message)
    String additionalInfo;

    final TweetData sentStatus = await bloc.tweetService
        .update(
          status: text,
          mediaIds: mediaIds,
          attachmentUrl: bloc.composeBloc.quotedTweet?.tweetUrl,
          inReplyToStatusId: bloc.composeBloc.inReplyToStatus?.idStr,
          autoPopulateReplyMetadata: true,
        )
        .then((Tweet tweet) => TweetData.fromTweet(tweet))
        .catchError((dynamic error) {
      if (error is Response) {
        final String message = responseErrorMessage(error.body);
        log.info(
          'handling error while sending status with message $message',
          error,
        );
        additionalInfo = message;
      } else {
        silentErrorHandler(error);
      }
    });

    if (sentStatus != null) {
      yield TweetSuccessfullyPosted(tweet: sentStatus);
    } else {
      yield PostingTweetError(errorMessage: additionalInfo);
    }
  }
}
