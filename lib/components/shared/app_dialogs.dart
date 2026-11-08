import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/app_toast.dart';
import 'package:pigeon/components/shared/data_source_builder.dart';
import 'package:pigeon/constants/app_colors.dart';

// Text, confirm and save-with-feedback helpers shared across the app.

/// Asks for text. Returns the trimmed text, or null when cancelled or left
/// empty ([allowEmpty] returns '' for an emptied field instead).
Future<String?> showTextInputDialog(
  BuildContext context, {
  required String title,
  String hint = '',
  String initial = '',
  String confirmLabel = 'Save',
  TextInputType keyboardType = TextInputType.text,
  int maxLines = 1,
  int? maxLength,
  bool obscureText = false,
  bool allowEmpty = false,
}) async {
  final String? result = await showDialog<String>(
    context: context,
    builder: (BuildContext context) => TextInputDialog(
      title: title,
      hint: hint,
      initial: initial,
      confirmLabel: confirmLabel,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      obscureText: obscureText,
    ),
  );
  if (allowEmpty) return result?.trim();
  final String? trimmed = result?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}

/// One-field text dialog. Pops with the entered text, with '' when
/// [removeLabel] is shown and tapped, or with null when dismissed. Owns its
/// controller so it outlives the closing animation.
class TextInputDialog extends StatefulWidget {
  const TextInputDialog({
    super.key,
    required this.title,
    this.hint = '',
    this.initial = '',
    this.confirmLabel = 'Save',
    this.removeLabel,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.maxLength,
    this.obscureText = false,
  });

  final String title;
  final String hint;
  final String initial;
  final String confirmLabel;

  /// Adds a red action that pops with ''; omit to show Cancel instead.
  final String? removeLabel;
  final TextInputType keyboardType;
  final int maxLines;
  final int? maxLength;
  final bool obscureText;

  @override
  State<TextInputDialog> createState() => _TextInputDialogState();
}

class _TextInputDialogState extends State<TextInputDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initial,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.backgroundSecondary,
      title: Text(
        widget.title,
        style: const TextStyle(color: AppColors.textPrimary),
      ),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: widget.maxLines > 1
            ? TextInputType.multiline
            : widget.keyboardType,
        maxLines: widget.maxLines,
        maxLength: widget.maxLength,
        obscureText: widget.obscureText,
        cursorColor: AppColors.accent,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: const TextStyle(color: AppColors.textMuted),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.textMuted),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.accent),
          ),
          counterStyle: const TextStyle(color: AppColors.textMuted),
        ),
        onSubmitted: (String value) => Navigator.of(context).pop(value),
      ),
      actions: <Widget>[
        if (widget.removeLabel != null)
          TextButton(
            onPressed: () => Navigator.of(context).pop(''),
            child: Text(
              widget.removeLabel!,
              style: const TextStyle(color: Color(0xFFFF4F4F)),
            ),
          )
        else
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: Text(
            widget.confirmLabel,
            style: const TextStyle(color: AppColors.accent),
          ),
        ),
      ],
    );
  }
}

/// Yes/no confirmation. Returns true only when confirmed.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Delete',
  bool destructive = true,
}) async {
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      backgroundColor: AppColors.backgroundSecondary,
      title: Text(title, style: const TextStyle(color: AppColors.textPrimary)),
      content: Text(
        message,
        style: const TextStyle(color: AppColors.textMuted, height: 1.4),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text(
            'Cancel',
            style: TextStyle(color: AppColors.textMuted),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            confirmLabel,
            style: TextStyle(
              color: destructive ? const Color(0xFFFF4F4F) : AppColors.accent,
            ),
          ),
        ),
      ],
    ),
  );
  return confirmed == true;
}

/// Runs a database write, then shows [success] or the database's error
/// message. Returns whether it succeeded.
Future<bool> runWithToast(
  BuildContext context,
  Future<void> Function() action, {
  String? success,
}) async {
  try {
    await action();
    if (context.mounted && success != null) {
      AppToast.show(
        context,
        message: success,
        variant: AppToastVariant.success,
      );
    }
    return true;
  } catch (e) {
    if (context.mounted) AppToast.show(context, message: liveErrorMessage(e));
    return false;
  }
}
