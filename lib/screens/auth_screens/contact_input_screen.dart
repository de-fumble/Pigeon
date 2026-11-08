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
import 'package:pigeon/services/sign_up_session.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ContactInputScreen extends StatefulWidget {
  const ContactInputScreen({
    super.key,
    this.initialMode = ContactInputMode.email,
  });

  final ContactInputMode initialMode;

  @override
  State<ContactInputScreen> createState() => _ContactInputScreenState();
}

class _ContactInputScreenState extends State<ContactInputScreen> {
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
    // Rebuild when text changes so _canContinue re-evaluates
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
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

  bool get _canContinue =>
      _contact.isNotEmpty &&
      !_isLoading &&
      (_mode == ContactInputMode.email
          ? _contact.contains('@')
          : _contact.length >= 8);

  Future<void> _continue() async {
    if (!_canContinue) return;
    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      final String? username = SignUpSession.username;
      final String? password = SignUpSession.password;

      if (username == null || password == null) {
        // Should not happen, but guard against it
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorText = 'Session expired. Please go back and try again.';
          });
        }
        return;
      }

      if (_mode == ContactInputMode.email) {
        SignUpSession.email = _contact;
        await AuthService.registerWithEmail(
          email: _contact,
          password: password,
          username: username,
        );
      } else {
        SignUpSession.phone = _contact;
        await AuthService.registerWithPhone(
          phone: _contact,
          password: password,
          username: username,
        );
      }

      if (!mounted) return;
      Navigator.of(context).pushNamed(
        AppRouter.otpVerification,
        arguments: <String, dynamic>{
          'channel': _mode == ContactInputMode.email,
          'source': 'signup',
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
          AuthHeader(
            title: _mode == ContactInputMode.email
                ? 'What\'s your email?'
                : 'What\'s your number?',
          ),
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
            onPressed: _canContinue ? _continue : null,
          ),
          const SizedBox(height: 28),
          AuthBottomLink(
            label: 'I already have an account',
            onTap: () => Navigator.of(context).pushNamed(AppRouter.login),
          ),
        ],
      ),
    );
  }
}
