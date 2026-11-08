import 'package:flutter/material.dart';
import 'package:pigeon/components/auth/auth_scaffold.dart';
import 'package:pigeon/components/auth/dob_picker_group.dart';
import 'package:pigeon/components/auth/legal_text_block.dart';
import 'package:pigeon/components/shared/app_pill_button.dart';
import 'package:pigeon/constants/app_colors.dart';
import 'package:pigeon/constants/app_strings.dart';
import 'package:pigeon/router/app_router.dart';
import 'package:pigeon/services/auth_service.dart';
import 'package:pigeon/services/sign_up_session.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DateOfBirthScreen extends StatefulWidget {
  const DateOfBirthScreen({super.key});

  @override
  State<DateOfBirthScreen> createState() => _DateOfBirthScreenState();
}

class _DateOfBirthScreenState extends State<DateOfBirthScreen> {
  int _month = 1;
  int _day = 1;
  int _year = DateTime.now().year;
  final TextEditingController _dateController = TextEditingController();
  bool _isSaving = false;
  String? _errorText;

  Future<void> _submit() async {
    final NavigatorState navigator = Navigator.of(context);
    setState(() {
      _isSaving = true;
      _errorText = null;
    });
    try {
      // Required: the backend blocks trading until a DOB is on file.
      await AuthService.saveDateOfBirth(_dateOfBirth);
    } on AuthException catch (e) {
      if (mounted) setState(() => _errorText = e.message);
      return;
    } on PostgrestException catch (e) {
      if (mounted) setState(() => _errorText = e.message);
      return;
    } catch (_) {
      if (mounted) {
        setState(() => _errorText = 'Something went wrong. Please try again.');
      }
      return;
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
    // Clear the session after sign-up is fully complete
    SignUpSession.reset();
    navigator.pushNamedAndRemoveUntil(
      AppRouter.accountCreated,
      (Route<dynamic> route) => false,
    );
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  DateTime get _dateOfBirth => DateTime(_year, _month, _day);

  bool get _isAdult {
    final DateTime today = DateTime.now();
    final DateTime adultCutoff = DateTime(
      today.year - 18,
      today.month,
      today.day,
    );
    return !_dateOfBirth.isAfter(adultCutoff);
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      onBack: () => Navigator.of(context).pop(),
      contentTopSpacing: 96,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Text(
            'And, how old are you?',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 30,
              fontWeight: FontWeight.w700,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 24),
          DobPickerGroup(
            selectedMonth: _month,
            selectedDay: _day,
            selectedYear: _year,
            controller: _dateController,
            onMonthChanged: (int value) => setState(() => _month = value),
            onDayChanged: (int value) => setState(() => _day = value),
            onYearChanged: (int value) => setState(() => _year = value),
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
        ],
      ),
      bottomContent: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const LegalTextBlock(),
          const SizedBox(height: 18),
          AppPillButton(
            label: AppStrings.enterPigeon,
            onPressed: _isAdult && !_isSaving ? _submit : null,
          ),
        ],
      ),
    );
  }
}
