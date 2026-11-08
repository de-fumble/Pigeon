import 'package:flutter/material.dart';
import 'package:pigeon/components/auth/auth_header.dart';
import 'package:pigeon/components/auth/auth_scaffold.dart';
import 'package:pigeon/components/auth/otp_code_row.dart';
import 'package:pigeon/components/auth/resend_code_row.dart';
import 'package:pigeon/components/auth/verification_banner.dart';
import 'package:pigeon/components/shared/app_pill_button.dart';
import 'package:pigeon/constants/app_colors.dart';
import 'package:pigeon/constants/app_strings.dart';
import 'package:pigeon/models/otp_channel.dart' as app_otp;
import 'package:pigeon/router/app_router.dart';
import 'package:pigeon/services/auth_service.dart';
import 'package:pigeon/services/sign_up_session.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({
    super.key,
    required this.channel,
    this.source = 'signup',
    this.showVerifiedBanner = false,
    this.contact,
  });

  final app_otp.OtpChannel channel;
  final String source;
  final bool showVerifiedBanner;

  /// The email or phone number the OTP was sent to.
  final String? contact;

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen>
    with SingleTickerProviderStateMixin {
  static const Duration _loadingDuration = Duration(milliseconds: 800);

  late final List<TextEditingController> _controllers =
      List<TextEditingController>.generate(
        AuthService.otpLength,
        (_) => TextEditingController(),
      );
  String? _errorText;
  bool _isLoading = false;
  bool _justVerified = false;
  bool _isResending = false;

  late final AnimationController _dotsController;

  @override
  void initState() {
    super.initState();
    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
    if (widget.showVerifiedBanner) {
      // Pre-fill for preview mode
      for (final TextEditingController c in _controllers) {
        c.text = '0';
      }
    }
    for (final TextEditingController c in _controllers) {
      c.addListener(_onCodeChanged);
    }
  }

  @override
  void dispose() {
    _dotsController.dispose();
    for (final TextEditingController c in _controllers) {
      c.removeListener(_onCodeChanged);
      c.dispose();
    }
    super.dispose();
  }

  void _onCodeChanged() {
    if (mounted) {
      setState(() {
        if (_errorText != null) _errorText = null;
      });
    }
  }

  String get _enteredCode =>
      _controllers.map((TextEditingController c) => c.text).join();

  bool get _codeIsComplete => _enteredCode.length == AuthService.otpLength;

  /// Returns the contact (email or phone) from the session or widget property.
  String? get _contact =>
      widget.contact ??
      (widget.channel == app_otp.OtpChannel.email
          ? SignUpSession.email
          : SignUpSession.phone);

  Future<void> _submit() async {
    if (!_codeIsComplete || _isLoading) return;
    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    // Brief visual pause so user sees loading state
    await Future<void>.delayed(_loadingDuration);
    if (!mounted) return;

    try {
      if (widget.source == 'signup') {
        // Sign-up OTP verification
        if (widget.channel == app_otp.OtpChannel.email) {
          await AuthService.verifyEmailOtp(
            email: _contact ?? '',
            token: _enteredCode,
          );
        } else {
          await AuthService.verifyPhoneOtp(
            phone: _contact ?? '',
            token: _enteredCode,
          );
        }
      } else {
        // Login OTP verification
        if (widget.channel == app_otp.OtpChannel.email) {
          await AuthService.verifyLoginEmailOtp(
            email: _contact ?? '',
            token: _enteredCode,
          );
        } else {
          await AuthService.verifyLoginPhoneOtp(
            phone: _contact ?? '',
            token: _enteredCode,
          );
        }
      }

      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _justVerified = true;
      });

      await Future<void>.delayed(const Duration(milliseconds: 1200));
      if (!mounted) return;

      if (widget.source == 'login') {
        final bool isAdmin = await AuthService.isAdmin();
        if (!mounted) return;
        Navigator.of(context).pushNamedAndRemoveUntil(
          isAdmin ? AppRouter.adminPanel : AppRouter.enableNotifications,
          (Route<dynamic> route) => false,
        );
      } else {
        // Sign-up: continue to interests screen
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRouter.interests,
          (Route<dynamic> route) => false,
        );
      }
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
          _errorText = 'Incorrect code. Please try again.';
        });
      }
    }
  }

  Future<void> _resend() async {
    if (_isResending) return;
    setState(() => _isResending = true);
    try {
      final bool isEmail = widget.channel == app_otp.OtpChannel.email;
      if (widget.source == 'login') {
        // resend() only covers sign-up codes; login codes are re-requested.
        if (isEmail) {
          await AuthService.sendLoginEmailOtp(_contact ?? '');
        } else {
          await AuthService.sendLoginPhoneOtp(_contact ?? '');
        }
      } else if (isEmail) {
        await AuthService.resendEmailOtp(_contact ?? '');
      } else {
        await AuthService.resendPhoneOtp(_contact ?? '');
      }
    } catch (_) {
      // Silently ignore — the resend button will re-enable
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEmail = widget.channel == app_otp.OtpChannel.email;

    return AuthScaffold(
      onBack: () => Navigator.of(context).pop(),
      contentTopSpacing: widget.showVerifiedBanner || _justVerified ? 92 : 126,
      topBanner: widget.showVerifiedBanner || _justVerified
          ? VerificationBanner(
              message: widget.channel == app_otp.OtpChannel.email
                  ? 'Your email has been verified!'
                  : 'Your phone has been verified!',
            )
          : null,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthHeader(
            title: 'Enter Code',
            subtitle: isEmail
                ? 'We sent a verification code to your email,\n${_contact ?? ''}'
                : 'We sent a verification code to your phone number,\n${_contact ?? ''}',
          ),
          const SizedBox(height: 30),
          OtpCodeRow(
            controllers: _controllers,
            timerLabel: isEmail ? '00:41' : '00:00',
            hasError: _errorText != null,
          ),
          if (_errorText != null) ...<Widget>[
            const SizedBox(height: 12),
            Text(
              _errorText!,
              style: const TextStyle(
                color: Color(0xFFFFB800),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(height: 18),
          ResendCodeRow(onResend: _resend),
        ],
      ),
      bottomContent: widget.showVerifiedBanner
          ? AppPillButton(
              label: AppStrings.enterPigeon,
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRouter.interests,
                  (Route<dynamic> route) => false,
                );
              },
            )
          : AppPillButton(
              label: _isLoading ? null : AppStrings.continueLabel,
              onPressed: _codeIsComplete && !_isLoading ? _submit : null,
              child: _isLoading
                  ? _LoadingDots(controller: _dotsController)
                  : null,
            ),
    );
  }
}

class _LoadingDots extends StatelessWidget {
  const _LoadingDots({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, Widget? child) {
        final double t = controller.value;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: List<Widget>.generate(3, (int i) {
            final double phase = (t + (i / 3)) % 1.0;
            final double opacity = (phase < 0.5)
                ? (0.3 + phase * 1.4)
                : (1.0 - (phase - 0.5) * 1.4);
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: i == 1 ? 10 : 0),
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.buttonText.withValues(
                    alpha: opacity.clamp(0.2, 1.0),
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
