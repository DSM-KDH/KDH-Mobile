import 'package:flutter/material.dart';
import 'package:kdh_mobile/constants/color.dart';
import 'package:kdh_mobile/constants/text_style.dart';

class KdhConfirmDialog extends StatelessWidget {
  const KdhConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.onConfirm,
    required this.onCancel,
    this.cancelLabel = '취소',
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: KdhColor.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: KdhTextStyle.body3, textAlign: TextAlign.center),
            const SizedBox(height: 10),
            Text(
              message,
              style: KdhTextStyle.caption2.copyWith(color: KdhColor.gray400),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: onConfirm,
              child: Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  color: KdhColor.red100,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(confirmLabel, style: KdhTextStyle.caption3),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: onCancel,
              child: Text(
                cancelLabel,
                style: KdhTextStyle.caption4.copyWith(color: KdhColor.gray400),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
