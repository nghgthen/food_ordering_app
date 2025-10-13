import 'package:flutter/material.dart';
class LocaleProvider extends ChangeNotifier{ Locale _locale = const Locale('vi'); Locale get locale=>_locale; void setLocale(Locale l){ _locale=l; notifyListeners(); } }
