import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

mixin UserModel on Model {
  bool _isAuthenticated = false;

  bool get isAuthenticated {
    return _isAuthenticated;
  }

  loggedInUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('spreeApiKey');
    if (token != null) {
      _isAuthenticated = true;
    }
    _isAuthenticated = false;
  }

  notifyListeners();
}
