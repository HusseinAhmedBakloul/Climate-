import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountModel with ChangeNotifier {
  // الحقول الخاصة بالمستخدم
  String _imagePath = '';
  String _name = '';
  String _email = '';

  // Getter للوصول إلى القيم
  String get imagePath => _imagePath;
  String get name => _name;
  String get email => _email;

  // تحميل بيانات الحساب من SharedPreferences
  Future<void> loadAccountData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _imagePath = prefs.getString('imagePath') ?? '';
    _name = prefs.getString('name') ?? '';
    _email = prefs.getString('email') ?? '';
    notifyListeners(); // إبلاغ المستمعين بأن البيانات تم تحميلها
  }

  // تحديث مسار الصورة
  Future<void> updateImagePath(String imagePath) async {
    _imagePath = imagePath;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('imagePath', _imagePath);
    notifyListeners();
  }

  // تحديث اسم المستخدم
  Future<void> updateName(String name) async {
    _name = name;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', _name);
    notifyListeners();
  }

  // تحديث البريد الإلكتروني
  Future<void> updateEmail(String email) async {
    _email = email;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', _email);
    notifyListeners();
  }

  // تصفير بيانات الحساب
  Future<void> clearAccountData() async {
    _imagePath = '';
    _name = '';
    _email = '';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }
}
