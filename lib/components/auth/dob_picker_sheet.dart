import 'package:flutter/material.dart';
import 'package:pigeon/components/auth/dob_picker_group.dart';
import 'package:pigeon/constants/app_colors.dart';
import 'package:pigeon/constants/app_motion.dart';

/// Opens the date-of-birth wheels in a bottom sheet. Returns the picked
/// date, or null when dismissed. Defaults to Jan 1, 18 years ago.
Future<DateTime?> showDateOfBirthPicker(
  BuildContext context, {
  DateTime? initial,
}) {
  return showModalBottomSheet<DateTime>(
    context: context,
    sheetAnimationStyle: AppMotion.sheet,
    backgroundColor: AppColors.background,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (BuildContext context) => _DateOfBirthSheet(
      initial: initial ?? DateTime(DateTime.now().year - 18, 1, 1),
    ),
  );
}

/// Month / day / year wheels from sign-up, with a Done button. Pops with the
/// picked date; users must be at least 18, as at sign-up.
class _DateOfBirthSheet extends StatefulWidget {
  const _DateOfBirthSheet({required this.initial});

  final DateTime initial;

  @override
  State<_DateOfBirthSheet> createState() => _DateOfBirthSheetState();
}

class _DateOfBirthSheetState extends State<_DateOfBirthSheet> {
  late int _month = widget.initial.month;
  late int _day = widget.initial.day;
  late int _year = widget.initial.year;
  final TextEditingController _dateController = TextEditingController();

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  /// Clamps the day so e.g. Feb 31 becomes Feb 28/29.
  DateTime get _date {
    final int lastDay = DateTime(_year, _month + 1, 0).day;
    return DateTime(_year, _month, _day > lastDay ? lastDay : _day);
  }

  bool get _isAdult {
    final DateTime today = DateTime.now();
    return !_date.isAfter(DateTime(today.year - 18, today.month, today.day));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surfaceDisabled,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Date of birth',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 18),
            DobPickerGroup(
              selectedMonth: _month,
              selectedDay: _day,
              selectedYear: _year,
              controller: _dateController,
              onMonthChanged: (int value) => setState(() => _month = value),
              onDayChanged: (int value) => setState(() => _day = value),
              onYearChanged: (int value) => setState(() => _year = value),
            ),
            if (!_isAdult) ...<Widget>[
              const SizedBox(height: 12),
              const Text(
                'You must be at least 18 to use Pigeon.',
                style: TextStyle(
                  color: Color(0xFFFFB800),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            const SizedBox(height: 24),
            Center(
              child: SizedBox(
                width: 150,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isAdult
                      ? () => Navigator.of(context).pop(_date)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.surface,
                    foregroundColor: AppColors.buttonText,
                    disabledBackgroundColor: AppColors.surfaceDisabled,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
