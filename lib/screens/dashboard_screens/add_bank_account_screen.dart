import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/motion/pressable.dart';
import 'package:pigeon/components/shared/motion/submit_state.dart';
import 'package:pigeon/components/shared/motion/fade_slide_in.dart';
import 'package:pigeon/constants/app_colors.dart';
import 'package:pigeon/router/app_router.dart';
import 'package:pigeon/screens/dashboard_screens/select_bank_list_screen.dart'
    show showSelectBankListSheet;

class AddBankAccountScreen extends StatefulWidget {
  const AddBankAccountScreen({super.key});

  @override
  State<AddBankAccountScreen> createState() => _AddBankAccountScreenState();
}

class _AddBankAccountScreenState extends State<AddBankAccountScreen>
    with SubmitStateMixin<AddBankAccountScreen> {
  final TextEditingController _accountController = TextEditingController();
  String? _selectedBank;

  static const int _maxAccountLength = 10;

  @override
  void initState() {
    super.initState();
    _accountController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _accountController.dispose();
    super.dispose();
  }

  bool get _canContinue =>
      _accountController.text.length == _maxAccountLength &&
      _selectedBank != null;

  Future<void> _pickBank() async {
    final String? result = await showSelectBankListSheet(context);
    if (result != null) {
      setState(() => _selectedBank = result);
    }
  }

  void _onContinue() {
    if (!_canContinue) return;
    // Hold on a loading state while the account is verified.
    runSubmit(
      () => Navigator.of(context).pushNamed(
        AppRouter.bankAccountLinked,
        arguments: <String, dynamic>{
          'bankName': _selectedBank,
          'accountNumber': _accountController.text,
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int count = _accountController.text.length;
    final bool isFull = count == _maxAccountLength;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: staggeredEntrance(<Widget>[
              Row(
                children: <Widget>[
                  Pressable(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.textPrimary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Add bank account',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Account Number',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: _accountController,
                        keyboardType: TextInputType.number,
                        maxLength: _maxAccountLength,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        cursorColor: AppColors.textPrimary,
                        decoration: const InputDecoration(
                          isCollapsed: true,
                          border: InputBorder.none,
                          counterText: '',
                        ),
                      ),
                    ),
                    Text(
                      '$count/$_maxAccountLength',
                      style: TextStyle(
                        color: isFull
                            ? const Color(0xFFFF2D55)
                            : AppColors.textMuted,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'Select Bank',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickBank,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.backgroundSecondary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          _selectedBank ?? '',
                          style: TextStyle(
                            color: _selectedBank != null
                                ? AppColors.textPrimary
                                : AppColors.textMuted,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.textPrimary,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _canContinue ? _onContinue : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _canContinue
                        ? AppColors.surface
                        : AppColors.surfaceDisabled,
                    foregroundColor: AppColors.buttonText,
                    disabledBackgroundColor: AppColors.surfaceDisabled,
                    disabledForegroundColor: AppColors.textMuted,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: ButtonLoadingContent(
                    isLoading: submitting,
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
