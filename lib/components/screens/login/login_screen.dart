import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:harpy/components/components.dart';
import 'package:harpy/core/core.dart';
import 'package:harpy/harpy_widgets/harpy_widgets.dart';
import 'package:harpy/misc/misc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen();

  static const String route = 'login';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<SlideAnimationState> _slideLoginKey =
      GlobalKey<SlideAnimationState>();

  Future<void> _startLogin({@required bool webview}) async {
    HapticFeedback.mediumImpact();
    await _slideLoginKey.currentState.forward();

    context.read<AuthenticationBloc>().add(LoginEvent(webview: webview));
  }

  Widget _buildAboutButton(ThemeData theme) {
    return Align(
      alignment: Alignment.topRight,
      child: SafeArea(
        child: HarpyButton.flat(
          icon: Icon(
            CupertinoIcons.info,
            color: theme.textTheme.bodyText1.color.withOpacity(.8),
          ),
          padding: const EdgeInsets.all(16),
          onTap: () => app<HarpyNavigator>().pushNamed(AboutScreen.route),
        ),
      ),
    );
  }

  Widget _buildText() {
    return const Align(
      alignment: Alignment.bottomCenter,
      child: SecondaryHeadline('welcome to'),
    );
  }

  Widget _buildTitle(ThemeData theme) {
    final Color color = theme.textTheme.bodyText2.color;

    return FractionallySizedBox(
      widthFactor: 2 / 3,
      child: SlideInAnimation(
        offset: const Offset(0, 20),
        duration: const Duration(seconds: 3),
        delay: const Duration(milliseconds: 800),
        child: FlareActor(
          'assets/flare/harpy_title.flr',
          alignment: Alignment.bottomCenter,
          animation: 'show',
          color: color,
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return const SlideInAnimation(
      duration: Duration(seconds: 3),
      offset: Offset(0, 20),
      delay: Duration(milliseconds: 800),
      child: FlareActor(
        'assets/flare/harpy_logo.flr',
        animation: 'show',
      ),
    );
  }

  Widget _buildButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        _LegacyLoginButton(onTap: () => _startLogin(webview: false)),
        const SizedBox(height: 8),
        _WebviewLoginButton(onTap: () => _startLogin(webview: true)),
      ],
    );
  }

  Widget _buildLoginScreen(ThemeData theme) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    return SlideAnimation(
      key: _slideLoginKey,
      endPosition: Offset(0, -mediaQuery.size.height),
      child: Stack(
        children: <Widget>[
          _buildAboutButton(theme),
          Column(
            children: <Widget>[
              Expanded(child: _buildText()),
              Expanded(
                flex: 2,
                child: Column(
                  children: <Widget>[
                    Expanded(child: _buildTitle(theme)),
                    Expanded(child: _buildLogo()),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(child: _buildButtons()),
              const SizedBox(height: 16),
              SizedBox(height: mediaQuery.padding.bottom),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (BuildContext context, AuthenticationState state) {
        final ThemeData theme = Theme.of(context);

        return HarpyBackground(
          child: state is AwaitingAuthenticationState
              ? const Center(child: CircularProgressIndicator())
              : _buildLoginScreen(theme),
        );
      },
    );
  }
}

class _LegacyLoginButton extends StatelessWidget {
  const _LegacyLoginButton({
    @required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return BounceInAnimation(
      delay: const Duration(milliseconds: 2800),
      child: HarpyButton.raised(
        text: const Text('login with twitter'),
        onTap: onTap,
      ),
    );
  }
}

class _WebviewLoginButton extends StatelessWidget {
  const _WebviewLoginButton({
    @required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FadeAnimation(
      delay: const Duration(milliseconds: 3100),
      duration: kLongAnimationDuration,
      shouldHide: false,
      child: HarpyButton.flat(
        text: const Text(
          'trouble signing in? try webview login',
          style: TextStyle(fontSize: 13),
        ),
        onTap: onTap,
      ),
    );
  }
}
