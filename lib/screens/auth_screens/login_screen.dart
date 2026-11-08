import 'package:flutter/material.dart';
import 'package:pigeon/components/auth/auth_bottom_link.dart';
import 'package:pigeon/components/auth/auth_header.dart';
import 'package:pigeon/components/auth/auth_prompt_chip.dart';
import 'package:pigeon/components/auth/auth_scaffold.dart';
import 'package:pigeon/components/auth/login_identifier_group.dart';
import 'package:pigeon/components/auth/password_suffix_icon.dart';
import 'package:pigeon/components/shared/app_pill_button.dart';
import 'package:pigeon/components/shared/app_text_input.dart';
import 'package:pigeon/constants/app_colors.dart';
import 'package:pigeon/constants/app_spacing.dart';
import 'package:pigeon/constants/app_strings.dart';
import 'package:pigeon/models/login_mode.dart';
import 'package:pigeon/router/app_router.dart';
import 'package:pigeon/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  LoginMode _mode = LoginMode.password;
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorText;

  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _identifierController.addListener(_onChanged);
    _passwordController.addListener(_onChanged);
  }

  @override
  void dispose() {
    _identifierController.removeListener(_onChanged);
    _passwordController.removeListener(_onChanged);
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() => _errorText = null);
  }

  void _setOtpMode(LoginMode mode) {
    setState(() {
      _mode = mode;
      _identifierController.text = '';
      _errorText = null;
    });
  }

  bool get _passwordReady =>
      _identifierController.text.isNotEmpty &&
      _passwordController.text.isNotEmpty;

  Future<void> _signInWithPassword() async {
    if (!_passwordReady || _isLoading) return;
    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      final String identifier = _identifierController.text.trim();
      // Detect whether user entered email, phone number or username
      if (identifier.contains('@')) {
        await AuthService.signInWithEmail(
          email: identifier,
          password: _passwordController.text,
        );
      } else if (AuthService.looksLikePhone(identifier)) {
        await AuthService.signInWithPhone(
          phone: identifier,
          password: _passwordController.text,
        );
      } else {
        await AuthService.signInWithUsername(
          username: identifier,
          password: _passwordController.text,
        );
      }

      final bool isAdmin = await AuthService.isAdmin();
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(
        isAdmin ? AppRouter.adminPanel : AppRouter.dashboardFeed,
        (Route<dynamic> route) => false,
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

  Future<void> _sendOtp() async {
    final String contact = _identifierController.text.trim();
    if (contact.isEmpty || _isLoading) return;
    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      if (_mode == LoginMode.emailOtp) {
        await AuthService.sendLoginEmailOtp(contact);
      } else {
        await AuthService.sendLoginPhoneOtp(contact);
      }

      if (!mounted) return;
      Navigator.of(context).pushNamed(
        AppRouter.otpVerification,
        arguments: <String, dynamic>{
          'channel': _mode == LoginMode.emailOtp,
          'source': 'login',
          'contact': contact,
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
    final bool isPasswordMode = _mode == LoginMode.password;

    return AuthScaffold(
      onBack: () => Navigator.of(context).pop(),
      contentTopSpacing: isPasswordMode ? 126 : 118,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthHeader(
            title: _mode == LoginMode.password
                ? 'Welcome back!'
                : 'Welcome Back!',
            subtitle: _mode == LoginMode.emailOtp
                ? 'Log in with your email'
                : _mode == LoginMode.phoneOtp
                ? 'Log in with your phone number'
                : null,
          ),
          const SizedBox(height: AppSpacing.xl),
          LoginIdentifierGroup(mode: _mode, controller: _identifierController),
          if (isPasswordMode) ...<Widget>[
            const SizedBox(height: 56),
            AppTextInput(
              controller: _passwordController,
              hintText: 'Password',
              obscureText: _obscurePassword,
              suffix: PasswordSuffixIcon(
                obscureText: _obscurePassword,
                onToggle: () {
                  if (mounted) {
                    setState(() => _obscurePassword = !_obscurePassword);
                  }
                },
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Forgot password?',
              style: TextStyle(color: AppColors.textDim, fontSize: 15),
            ),
            const SizedBox(height: 30),
            Center(
              child: AuthPromptChip(
                label: 'Use OTP',
                onTap: () =>
                    Navigator.of(context).pushNamed(AppRouter.loginOtpIntro),
              ),
            ),
          ] else ...<Widget>[
            const SizedBox(height: AppSpacing.lg),
            Center(
              child: AuthPromptChip(
                label: _mode == LoginMode.emailOtp
                    ? 'Use number instead'
                    : 'Use email instead',
                onTap: () => _setOtpMode(
                  _mode == LoginMode.emailOtp
                      ? LoginMode.phoneOtp
                      : LoginMode.emailOtp,
                ),
              ),
            ),
          ],
          if (_errorText != null) ...<Widget>[
            const SizedBox(height: 16),
            Text(
              _errorText!,
              style: const TextStyle(
                color: Color(0xFFFFB800),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
      bottomContent: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppPillButton(
            label: _isLoading
                ? null
                : isPasswordMode
                ? AppStrings.enterPigeon
                : AppStrings.continueLabel,
            onPressed: isPasswordMode && !_passwordReady || _isLoading
                ? null
                : isPasswordMode
                ? _signInWithPassword
                : _sendOtp,
          ),
          const SizedBox(height: 28),
          AuthBottomLink(
            label: 'I don\'t have an account',
            onTap: () => Navigator.of(context).pushNamed(AppRouter.register),
          ),
        ],
      ),
    );
  }
}
