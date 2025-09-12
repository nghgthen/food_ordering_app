import 'package:flutter/foundation.dart';
class ThemeProvider extends ChangeNotifier { bool _isDark=false; bool get isDark=>_isDark; void setDark(bool v){ _isDark=v; notifyListeners(); } }
