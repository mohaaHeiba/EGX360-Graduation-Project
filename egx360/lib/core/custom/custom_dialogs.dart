import 'dart:ui';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:egx/core/custom/custom_loading.dart';
import 'package:egx/core/helper/context_extensions.dart';
import 'package:flutter/material.dart';

class CustomDialogs {
  // (Loading Dialog)
  static void showLoading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return PopScope(
          canPop: false,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: Center(
                child: CandlestickLoader(
                  color: context.appTheme.textTheme.bodyLarge!.color!,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // (Confirm Dialog)
  static void showConfirm(
    BuildContext context, {
    required String title,
    required String desc,
    required VoidCallback onConfirm,
    DialogType dialogType = DialogType.warning,
    String? btnOkText,
    String? btnCancelText,
    Color? btnOkColor,
  }) {
    AwesomeDialog(
      context: context,
      dialogType: dialogType,
      animType: AnimType.scale,
      title: title,
      desc: desc,
      titleTextStyle: context.textStyles.titleMedium?.copyWith(
        color: context.onSurface,
      ),
      descTextStyle: context.textStyles.bodyMedium?.copyWith(
        color: context.onSurface.withValues(alpha: 0.7),
      ),
      btnCancelText: btnCancelText,
      btnOkText: btnOkText,
      btnOkColor: btnOkColor,
      btnCancelOnPress: () {},
      btnOkOnPress: onConfirm,
    ).show();
  }
}
