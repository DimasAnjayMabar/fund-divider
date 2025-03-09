import 'package:flutter/material.dart';

class ErrorHandler {
  static final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);

  static void showError(String error) {
    errorMessage.value = error;
  }

  static void clearError() {
    errorMessage.value = null;
  }
}
