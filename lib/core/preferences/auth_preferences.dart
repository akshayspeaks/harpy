import 'package:harpy/core/core.dart';

class AuthPreferences {
  final HarpyPreferences harpyPrefs = app<HarpyPreferences>();

  String get userToken => harpyPrefs.getString('userToken', null);
  set userToken(String value) => harpyPrefs.setString('userToken', value);

  String get userSecret => harpyPrefs.getString('userSecret', null);
  set userSecret(String value) => harpyPrefs.setString('userSecret', value);

  String get userId => harpyPrefs.getString('userId', null);
  set userId(String value) => harpyPrefs.setString('userId', value);

  void clearAuth() {
    harpyPrefs.remove('userToken');
    harpyPrefs.remove('userSecret');
    harpyPrefs.remove('userId');
  }
}
