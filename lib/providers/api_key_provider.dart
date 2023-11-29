import 'package:flutter/material.dart';

class ApiKeyProvider with ChangeNotifier {
  String? _apiKey;

  String? get apiKey => _apiKey;

  void setApiKey(String apiKey) {
    _apiKey = apiKey;
    notifyListeners();
  }
}