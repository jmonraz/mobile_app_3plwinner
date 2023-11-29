import 'package:flutter/material.dart';

class ApiUPCReportTaskIdProvider with ChangeNotifier {
  String? _taskId;

  String? get taskId => _taskId;

  void setTaskId(String taskId) {
    _taskId = taskId;
    notifyListeners();
  }
}