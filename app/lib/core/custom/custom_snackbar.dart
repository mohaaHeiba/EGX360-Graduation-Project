import 'package:flutter/material.dart';
import 'package:get/get.dart';

SnackbarController customSnackbar({
  required String title,
  required String message,
  color = Colors.green,
}) {
  return Get.showSnackbar(
    GetSnackBar(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      titleText: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      messageText: Text(
        message,
        style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
      ),
      backgroundColor: color,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 4),
      borderRadius: 8,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.linearToEaseOut,
    ),
  );
}
