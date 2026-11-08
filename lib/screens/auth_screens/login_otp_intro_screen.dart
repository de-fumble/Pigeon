import 'package:flutter/material.dart';
import 'package:pigeon/components/auth/auth_bottom_link.dart';
import 'package:pigeon/components/auth/auth_header.dart';
import 'package:pigeon/components/auth/auth_prompt_chip.dart';
import 'package:pigeon/components/auth/auth_scaffold.dart';
import 'package:pigeon/components/auth/contact_input_group.dart';
import 'package:pigeon/components/shared/app_pill_button.dart';
import 'package:pigeon/constants/app_spacing.dart';
import 'package:pigeon/constants/app_strings.dart';
import 'package:pigeon/models/contact_input_mode.dart';
import 'package:pigeon/router/app_router.dart';
import 'package:pigeon/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginOtpIntroScreen extends StatefulWidget {
  const LoginOtpIntroScreen({
    super.key,
    this.initialMode = ContactInputMode.email,
  });

  final ContactInputMode initialMode;

  @override
  State<LoginOtpIntroScreen> createState() => _LoginOtpIntroScreenState();
}

class _LoginOtpIntroScreenState extends State<LoginOtpIntroScreen> {
  late ContactInputMode _mode;
  late TextEditingController _controller;
  bool _isLoading = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
    _controller = TextEditingController(
      text: _mode == ContactInputMode.phone ? '+ 234' : '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _mode = _mode == ContactInputMode.email
          ? ContactInputMode.phone
          : ContactInputMode.email;
      _controller.text = _mode == ContactInputMode.phone ? '+ 234' : '';
      _errorText = null;
    });
  }

  String get _contact => _controller.text.trim();

  Future<void> _continue() async {
    if (_contact.isEmpty || _isLoading) return;
    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      if (_mode == ContactInputMode.email) {
        await AuthService.sendLoginEmailOtp(_contact);
      } else {
        await AuthService.sendLoginPhoneOtp(_contact);
      }

      if (!mounted) return;
      Navigator.of(context).pushNamed(
        AppRouter.otpVerification,
        arguments: <String, dynamic>{
          'channel': _mode == ContactInputMode.email,
          'source': 'login',
          'contact': _contact,
        },
      );
    } on AuthException catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorText = e.message;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorText = 'Something went wrong. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      onBack: () => Navigator.of(context).pop(),
      contentTopSpacing: 126,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AuthHeader(title: 'Welcome back!'),
          const SizedBox(height: AppSpacing.xl),
          ContactInputGroup(mode: _mode, controller: _controller),
          if (_errorText != null) ...<Widget>[
            const SizedBox(height: 12),
            Text(
              _errorText!,
              style: const TextStyle(
                color: Color(0xFFFFB800),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(height: 30),
          Center(
            child: AuthPromptChip(
              label: _mode == ContactInputMode.email
                  ? 'Use number instead'
                  : 'Use email instead',
              onTap: _toggleMode,
            ),
          ),
        ],
      ),
      bottomContent: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppPillButton(
            label: _isLoading ? null : AppStrings.continueLabel,
            onPressed: _contact.isEmpty || _isLoading ? null : _continue,
          ),
          const SizedBox(height: 28),
          AuthBottomLink(
            label: 'I don\u2019t have an account',
            onTap: () => Navigator.of(context).pushNamed(AppRouter.register),
          ),
        ],
      ),
    );
  }
}
