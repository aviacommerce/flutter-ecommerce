import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ofypets_mobile_app/scoped-models/main.dart';

mixin UserModel on Model {
  bool _isAuthenticated = false;
  MainModel model;

  bool get isAuthenticated {
    return _isAuthenticated;
  }

  loggedInUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('spreeApiKey');
    if (token != null) {
      _isAuthenticated = true;
      notifyListeners();
    } else {
      _isAuthenticated = false;
      notifyListeners();
    }
  }
}
