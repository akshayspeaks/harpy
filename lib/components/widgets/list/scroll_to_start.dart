import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:harpy/components/components.dart';
import 'package:harpy/harpy_widgets/harpy_widgets.dart';

/// Builds a button at the bottom of the screen that listens to the
/// [ScrollDirection] and animates in or out of the screen to provide a button
/// to jump to the start of the list.
///
/// The affected list must be built above this widget in the widget tree.
/// Only one primary scroll controller must exist below this widget.
///
/// The button is visible if the current scroll position is greater than the
/// screen size and the current scroll direction is [ScrollDirection.up].
class ScrollToStart extends StatefulWidget {
  const ScrollToStart({
    @required this.child,
    this.controller,
  });

  final Widget child;
  final ScrollController controller;

  @override
  _ScrollToStartState createState() => _ScrollToStartState();
}

class _ScrollToStartState extends State<ScrollToStart> {
  ScrollController _controller;

  // ignore: invalid_use_of_protected_member
  bool get _hasSingleScrollPosition => _controller.positions.length == 1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_controller == null) {
      _controller = widget.controller ?? PrimaryScrollController.of(context);

      assert(_controller != null, 'scroll to start has no scroll controller');
      _controller?.addListener(_scrollListener);
    }
  }

  @override
  void dispose() {
    super.dispose();

    _controller?.removeListener(_scrollListener);
  }

  void _scrollListener() {
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    // rebuild the button when scroll position is lower than the screen size
    // to hide the button when scrolling all the way up

    if (_hasSingleScrollPosition &&
        _controller.offset < mediaQuery.size.height &&
        mounted) {
      setState(() {});
    }
  }

  /// Determines if the button should show.
  bool _show(MediaQueryData mediaQuery, ScrollDirection scrollDirection) {
    if (_controller == null || !_controller.hasClients) {
      return false;
    }

    return _hasSingleScrollPosition &&
        _controller.offset > mediaQuery.size.height &&
        scrollDirection?.up == true;
  }

  void _scrollToStart(MediaQueryData mediaQuery) {
    // ignore: invalid_use_of_protected_member
    if (!_hasSingleScrollPosition ||
        _controller.offset > mediaQuery.size.height * 5) {
      // We use animateTo instead of jumpTo because jumpTo(0) will cause the
      // refresh indicator to trigger.
      // todo: fixed in flutter:master, change to jumpTo when it hits stable
      _controller.animateTo(
        0,
        duration: const Duration(microseconds: 1),
        curve: Curves.linear,
      );
    } else {
      _controller.animateTo(
        0,
        duration: const Duration(seconds: 1),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ScrollDirection scrollDirection = ScrollDirection.of(context);
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    final bool show = _show(mediaQuery, scrollDirection);

    return Stack(
      children: <Widget>[
        widget.child,
        Align(
          alignment: Alignment.bottomCenter,
          child: AnimatedOpacity(
            opacity: show ? 1 : 0,
            curve: Curves.easeInOut,
            duration: kShortAnimationDuration,
            child: AnimatedShiftedPosition(
              shift: show ? Offset.zero : const Offset(0, 1),
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: defaultPaddingValue + mediaQuery.padding.bottom,
                ),
                child: HarpyButton.raised(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  icon: const Icon(CupertinoIcons.arrow_up),
                  backgroundColor: theme.cardColor.withOpacity(.8),
                  onTap: () => _scrollToStart(mediaQuery),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
