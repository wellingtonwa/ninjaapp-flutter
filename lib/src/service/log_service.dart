import 'package:flutter/material.dart';

class LogService extends ChangeNotifier {
  List<String> logText = [];

  VoidCallback? scrollToBotton;

  List<String> getLogText() => logText;

  setScrollToBottonAction(VoidCallback func) {
    scrollToBotton = func;
  }

  appendLogText(String logToAppend) {
    logText.add('${DateTime.now()}: $logToAppend');
    if (scrollToBotton != null) {
      // scrollToBotton?.call();
    }
    notifyListeners();
  }

  clearLogText() {
    logText.clear();
    notifyListeners();
  }
}
