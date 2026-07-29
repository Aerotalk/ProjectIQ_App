import 'package:flutter/material.dart';
import '../../../core/theme/app_typography.dart';
import '../buttons/app_button.dart';

class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onDismiss;

  const ErrorDialog({
    super.key,
    required this.title,
    required this.message,
    this.onDismiss,
  });

  static Future<void> show(BuildContext context, {required String title, required String message}) {
    return showDialog(
      context: context,
      builder: (context) => ErrorDialog(title: title, message: message),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title, style: AppTypography.title),
      content: Text(message, style: AppTypography.body),
      actions: [
        AppButton(
          text: 'OK',
          onPressed: () {
            Navigator.of(context).pop();
            onDismiss?.call();
          },
        ),
      ],
    );
  }
}
