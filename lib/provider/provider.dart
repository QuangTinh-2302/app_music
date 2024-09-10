import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UiProvider extends ChangeNotifier{
  bool _isDark = false;
  bool get isDark => _isDark;

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

  //init method
  init() async{
    storage = await SharedPreferences.getInstance();
    _isDark = storage.getBool('_isDark') ?? false;
    notifyListeners();
  }
}