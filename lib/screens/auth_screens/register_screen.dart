import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/motion/pressable.dart';
import 'package:pigeon/components/auth/auth_header.dart';
import 'package:pigeon/components/auth/auth_scaffold.dart';
import 'package:pigeon/components/auth/password_suffix_icon.dart';
import 'package:pigeon/components/shared/app_pill_button.dart';
import 'package:pigeon/components/shared/app_text_input.dart';
import 'package:pigeon/constants/app_colors.dart';
import 'package:pigeon/constants/app_spacing.dart';
import 'package:pigeon/constants/app_strings.dart';
import 'package:pigeon/router/app_router.dart';
import 'package:pigeon/services/auth_service.dart';
import 'package:pigeon/services/sign_up_session.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

enum _PasswordStrength { empty, weak, medium, strong }

enum _UsernameStatus { idle, invalid, checking, available, taken }

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  bool _obscurePassword = true;

  _UsernameStatus _usernameStatus = _UsernameStatus.idle;

  // Debounce timer for username availability check
  DateTime? _lastUsernameCheck;

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_onUsernameChanged);
    _passwordController.addListener(_onPasswordChanged);
  }

  @override
  void dispose() {
    _usernameController.removeListener(_onUsernameChanged);
    _passwordController.removeListener(_onPasswordChanged);
    _passwordController.dispose();
    _usernameController.dispose();
    _passwordFocus.dispose();
    _usernameFocus.dispose();
    super.dispose();
  }

  void _onPasswordChanged() {
    if (mounted) setState(() {});
  }

  void _onUsernameChanged() {
    final String username = _usernameController.text.trim();
    if (username.isEmpty) {
      _lastUsernameCheck = null; // cancel any pending check
      if (mounted) setState(() => _usernameStatus = _UsernameStatus.idle);
      return;
    }
    // The server rejects any other format at sign-up, so catch it here.
    if (!AuthService.usernamePattern.hasMatch(username)) {
      _lastUsernameCheck = null;
      if (mounted) setState(() => _usernameStatus = _UsernameStatus.invalid);
      return;
    }
    // Debounce: wait 600ms after last keystroke before checking
    final DateTime now = DateTime.now();
    _lastUsernameCheck = now;
    if (mounted) setState(() => _usernameStatus = _UsernameStatus.checking);
    Future<void>.delayed(const Duration(milliseconds: 600), () async {
      if (_lastUsernameCheck != now) return; // superseded
      if (!mounted) return;
      try {
        final bool available = await AuthService.isUsernameAvailable(username);
        if (!mounted) return;
        setState(() {
          _usernameStatus = available
              ? _UsernameStatus.available
              : _UsernameStatus.taken;
        });
      } catch (_) {
        // If the profiles table doesn't exist yet or there's a network error,
        // optimistically treat the username as available.
        // The real uniqueness constraint is enforced server-side at signUp.
        if (mounted) {
          setState(() => _usernameStatus = _UsernameStatus.available);
        }
      }
    });
  }

  String get _username => _usernameController.text.trim();

  _PasswordStrength get _passwordStrength {
    final String value = _passwordController.text;
    if (value.isEmpty) return _PasswordStrength.empty;
    final bool longEnough = value.length >= 8;
    final bool hasLetter = value.contains(RegExp(r'[A-Za-z]'));
    final bool hasDigit = value.contains(RegExp(r'[0-9]'));
    final bool hasUpperLower =
        value.contains(RegExp(r'[A-Z]')) && value.contains(RegExp(r'[a-z]'));
    final bool hasSymbol = value.contains(RegExp(r'[^A-Za-z0-9]'));
    final int score = <int>[
      longEnough ? 1 : 0,
      hasLetter ? 1 : 0,
      hasDigit ? 1 : 0,
      hasUpperLower ? 1 : 0,
      hasSymbol ? 1 : 0,
    ].reduce((int a, int b) => a + b);
    if (score >= 4) return _PasswordStrength.strong;
    if (score >= 2) return _PasswordStrength.medium;
    return _PasswordStrength.weak;
  }

  bool get _canSubmit =>
      _usernameStatus == _UsernameStatus.available &&
      _passwordStrength != _PasswordStrength.empty &&
      _passwordStrength != _PasswordStrength.weak;

  void _submit() {
    if (!_canSubmit) return;
    // Store credentials in session — they'll be used after OTP verification
    SignUpSession.username = _username;
    SignUpSession.password = _passwordController.text;
    Navigator.of(context).pushNamed(AppRouter.contactInput);
  }

  void _clearUsername() {
    _usernameController.clear();
    _usernameFocus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final _PasswordStrength strength = _passwordStrength;
    final bool passwordEmpty = strength == _PasswordStrength.empty;

    return AuthScaffold(
      onBack: () => Navigator.of(context).pop(),
      contentTopSpacing: 126,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AuthHeader(title: 'Create an account'),
          const SizedBox(height: AppSpacing.xl),
          AppTextInput(
            controller: _usernameController,
            focusNode: _usernameFocus,
            hintText: 'Username',
            suffix: _username.isEmpty
                ? null
                : Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Pressable(
                      onTap: _clearUsername,
                      behavior: HitTestBehavior.opaque,
                      child: const Icon(
                        Icons.close_rounded,
                        color: AppColors.textMuted,
                        size: 22,
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 10),
          _UsernameCaption(status: _usernameStatus),
          const SizedBox(height: 26),
          AppTextInput(
            controller: _passwordController,
            focusNode: _passwordFocus,
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
          const SizedBox(height: 10),
          _PasswordCaption(strength: strength, empty: passwordEmpty),
        ],
      ),
      bottomContent: AppPillButton(
        label: AppStrings.next,
        onPressed: _canSubmit ? _submit : null,
      ),
    );
  }
}

class _UsernameCaption extends StatelessWidget {
  const _UsernameCaption({required this.status});

  final _UsernameStatus status;

  @override
  Widget build(BuildContext context) {
    final String text;
    final Color color;
    switch (status) {
      case _UsernameStatus.idle:
        text = 'Only use letters, numbers, underscores, and periods.';
        color = AppColors.textMuted;
        break;
      case _UsernameStatus.invalid:
        text = 'Use 3–30 letters, numbers, underscores, or periods.';
        color = const Color(0xFFFFB800);
        break;
      case _UsernameStatus.checking:
        text = 'Checking availability…';
        color = AppColors.textMuted;
        break;
      case _UsernameStatus.available:
        text = 'Great! Username is available';
        color = const Color(0xFF19D36D);
        break;
      case _UsernameStatus.taken:
        text = 'Username not available';
        color = const Color(0xFFFFB800);
        break;
    }
    return Text(text, style: TextStyle(color: color, fontSize: 15));
  }
}

class _PasswordCaption extends StatelessWidget {
  const _PasswordCaption({required this.strength, required this.empty});

  final _PasswordStrength strength;
  final bool empty;

  @override
  Widget build(BuildContext context) {
    final String text;
    final Color color;
    if (empty || strength == _PasswordStrength.weak) {
      text = 'Passwords must be 8 or more characters.';
      color = AppColors.textMuted;
    } else if (strength == _PasswordStrength.medium) {
      text = 'Medium — add a symbol or mixed case to strengthen.';
      color = const Color(0xFFFFB800);
    } else {
      text = 'Strong!';
      color = const Color(0xFF19D36D);
    }
    return Text(text, style: TextStyle(color: color, fontSize: 15));
  }
}
