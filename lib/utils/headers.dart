import 'package:shared_preferences/shared_preferences.dart';

Future<Map<String, String>> getHeaders() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  Map<String, String> headers = {
    'Content-Type': 'application/json',
    'token-type': 'Bearer',
    'ng-api': 'true',
    'auth-token': prefs.getString('spreeApiKey') == null
        ? ''
        : prefs.getString('spreeApiKey'),
    'Guest-Order-Token': prefs.getString('orderToken') == null
        ? ''
        : prefs.getString('orderToken')
  };
  return headers;
}
