import 'package:flutter/material.dart';
import 'package:kdh_mobile/constants/color.dart';
import 'package:kdh_mobile/constants/text_style.dart';
import 'package:kdh_mobile/core/widgets/kdh_confirm_dialog.dart';

extension BuildContextFeedbackExtension on BuildContext {
  void showKdhSnackBar(
    String message, {
    Duration duration = const Duration(milliseconds: 1500),
  }) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message, style: KdhTextStyle.body7),
          behavior: SnackBarBehavior.floating,
          duration: duration,
          backgroundColor: KdhColor.red50,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
      );
  }

  Future<bool> showKdhConfirmDialog({
    required String title,
    required String message,
    required String confirmLabel,
    String cancelLabel = '취소',
  }) async {
    final result = await showDialog<bool>(
      context: this,
      barrierColor: Colors.black.withAlpha(80),
      builder: (dialogContext) => KdhConfirmDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        onConfirm: () => Navigator.of(dialogContext).pop(true),
        onCancel: () => Navigator.of(dialogContext).pop(false),
      ),
    );

    return result ?? false;
  }
}
