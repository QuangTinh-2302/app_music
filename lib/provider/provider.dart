
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UiProvider extends ChangeNotifier{
  bool _isDark = false;
  bool get isDark => _isDark;

  String _languageCode = 'en';
  String get languageCode => _languageCode;

  String _notification='';
  String get notification => _notification;

  late SharedPreferences storage;

  final darkTheme = ThemeData(
      primaryColor: Colors.deepPurple,
      brightness: Brightness.dark,
      primaryColorDark: Colors.deepPurple
  );

  final lightTheme = ThemeData(
      primaryColor: Colors.white,
      brightness: Brightness.light,
      primaryColorDark: Colors.white
  );

  //Dark action
  changeTheme(){
    _isDark = !isDark;
    //Luu trạng thái
    storage.setBool('_isDark', _isDark);
    notifyListeners();
  }

  void changeLanguage(String languageCode) {
    _languageCode = languageCode;
    storage.setString('_languageCode', _languageCode);
    notifyListeners();
  }

  void setNotification(String newNotification) {
    if (_notification != newNotification) {
      _notification = newNotification;
      notifyListeners();
    }
  }

  //init method
  init() async{
    storage = await SharedPreferences.getInstance();
    _isDark = storage.getBool('_isDark') ?? false;
    _languageCode = storage.getString('_languageCode') ?? 'en';

    notifyListeners();
  }
}