import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  String? deviceId;
  setDeviceId(String id) {
    deviceId = id;
    notifyListeners();
  }
}
