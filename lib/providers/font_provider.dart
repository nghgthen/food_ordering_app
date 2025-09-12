import 'package:flutter/foundation.dart';
class FontProvider extends ChangeNotifier{ double _scale=1.0; double get scale=>_scale; void setScale(double s){ _scale=s.clamp(0.8,1.4); notifyListeners(); } }
