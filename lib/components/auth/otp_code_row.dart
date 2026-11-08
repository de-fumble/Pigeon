import 'package:flutter/material.dart';
import 'package:pigeon/constants/app_colors.dart';

class OtpCodeRow extends StatelessWidget {
  const OtpCodeRow({
    super.key,
    required this.controllers,
    required this.timerLabel,
    this.hasError = false,
  });

  final List<TextEditingController> controllers;
  final String timerLabel;
  final bool hasError;

  static const double _gap = 6;

  @override
  Widget build(BuildContext context) {
    // Boxes shrink (up to _OtpBox._size) so a 6-digit code fits narrow phones.
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              for (int i = 0; i < controllers.length; i++) ...[
                if (i > 0) const SizedBox(width: _gap),
                Flexible(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: _OtpBox._size),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: _OtpBox(
                        controller: controllers[i],
                        hasError: hasError,
                        onChanged: (String value) {
                          if (value.isNotEmpty && i < controllers.length - 1) {
                            FocusScope.of(context).nextFocus();
                          }
                          if (value.isEmpty && i > 0) {
                            FocusScope.of(context).previousFocus();
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          timerLabel,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _OtpBox extends StatelessWidget {
  const _OtpBox({
    required this.controller,
    required this.hasError,
    required this.onChanged,
  });

  static const double _size = 56;
  static const double _radius = 14;
  static const Color _fill = AppColors.surfaceMutedAlt;
  static const Color _borderIdle = Color(0xFF3A3640);

  final TextEditingController controller;
  final bool hasError;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _fill,
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(
          color: hasError ? const Color(0xFFFFB800) : _borderIdle,
          width: 1.5,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (controller.text.isEmpty)
            Container(
              width: 14,
              height: 2,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          TextField(
            controller: controller,
            onChanged: onChanged,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            cursorColor: AppColors.accent,
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
              isCollapsed: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}
