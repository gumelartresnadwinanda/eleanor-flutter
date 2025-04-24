import 'package:flutter/material.dart';

class FormControllerProvider extends ChangeNotifier {
  final Map<String, TextEditingController> _controllers = {};

  TextEditingController getController(String fieldKey) {
    return _controllers[fieldKey] ??= TextEditingController();
  }

  void setInitialValue(String fieldKey, String value) {
    if (_controllers.containsKey(fieldKey)) {
      _controllers[fieldKey]!.text = value;
    } else {
      _controllers[fieldKey] = TextEditingController(text: value);
    }
    notifyListeners();
  }

  void disposeControllers() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
  }

  Map<String, String> get currentValues => {
    for (var entry in _controllers.entries) entry.key: entry.value.text,
  };
}
