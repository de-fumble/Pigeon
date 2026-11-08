import 'package:flutter/material.dart';
import 'package:pigeon/constants/app_colors.dart';

class AppTextInput extends StatelessWidget {
  const AppTextInput({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText,
    this.keyboardType,
    this.prefix,
    this.suffix,
    this.obscureText = false,
    this.readOnly = false,
    this.onTap,
    this.showBorder = false,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hintText;
  final TextInputType? keyboardType;
  final Widget? prefix;
  final Widget? suffix;
  final bool obscureText;
  final bool readOnly;
  final VoidCallback? onTap;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        obscureText: obscureText,
        readOnly: readOnly,
        onTap: onTap,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        cursorColor: AppColors.accent,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          filled: true,
          fillColor: AppColors.surfaceMuted,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
          prefixIcon: prefix,
          suffixIcon: suffix,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(
              color: showBorder ? AppColors.divider : Colors.transparent,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: AppColors.divider, width: 1),
          ),
        ),
      ),
    );
  }
}
