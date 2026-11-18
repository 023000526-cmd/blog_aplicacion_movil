import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String _baseUrlOverride = String.fromEnvironment(
    'API_BASE_URL',
  );

  static String get baseUrl {
    if (_baseUrlOverride.isNotEmpty) {
      return _baseUrlOverride;
    }

    return defaultTargetPlatform == TargetPlatform.android
        ? 'http://10.0.2.2:8000'
        : 'http://127.0.0.1:8000';
  }
}
//C:\Projects\raiz\venv\Scripts\python.exe -m uvicorn main:app --host 127.0.0.1 --port 8000 --reload