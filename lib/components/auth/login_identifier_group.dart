import 'package:flutter/material.dart';
import 'package:pigeon/components/auth/phone_prefix_badge.dart';
import 'package:pigeon/components/shared/app_text_input.dart';
import 'package:pigeon/models/login_mode.dart';

class LoginIdentifierGroup extends StatelessWidget {
  const LoginIdentifierGroup({
    super.key,
    required this.mode,
    required this.controller,
  });

  final LoginMode mode;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    switch (mode) {
      case LoginMode.phoneOtp:
        return Row(
          children: [
            const SizedBox(width: 78, child: PhonePrefixBadge()),
            const SizedBox(width: 10),
            Expanded(
              child: AppTextInput(
                controller: controller,
                keyboardType: TextInputType.phone,
              ),
            ),
          ],
        );
      case LoginMode.emailOtp:
        return AppTextInput(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
        );
      case LoginMode.password:
        return AppTextInput(
          controller: controller,
          hintText: 'Email, phone number or username',
        );
    }
  }
}
