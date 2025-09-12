import 'package:flutter/material.dart';
class LocaleProvider extends ChangeNotifier{ Locale _locale = const Locale('en'); Locale get locale=>_locale; void setLocale(Locale l){ _locale=l; notifyListeners(); } }
