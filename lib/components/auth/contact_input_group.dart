import 'package:flutter/material.dart';
import 'package:pigeon/components/auth/phone_prefix_badge.dart';
import 'package:pigeon/components/shared/app_text_input.dart';
import 'package:pigeon/models/contact_input_mode.dart';

class ContactInputGroup extends StatelessWidget {
  const ContactInputGroup({
    super.key,
    required this.mode,
    required this.controller,
  });

  final ContactInputMode mode;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    if (mode == ContactInputMode.phone) {
      return Row(
        children: [
          const SizedBox(width: 78, child: PhonePrefixBadge()),
          const SizedBox(width: 10),
          Expanded(
            child: AppTextInput(
              controller: controller,
              keyboardType: TextInputType.phone,
              hintText: '+ 234',
            ),
          ),
        ],
      );
    }

    return AppTextInput(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      showBorder: true,
    );
  }
}
