import 'package:flutter/foundation.dart';

class Auth extends ChangeNotifier {
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  void login() {
    // Implementieren Sie den Anmeldevorgang
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    // Implementieren Sie den Abmeldevorgang
    _isLoggedIn = false;
    notifyListeners();
  }
}
