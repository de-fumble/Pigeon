import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/app_text_input.dart';
import 'package:pigeon/constants/app_colors.dart';

class DobPickerGroup extends StatefulWidget {
  const DobPickerGroup({
    super.key,
    required this.selectedMonth,
    required this.selectedDay,
    required this.selectedYear,
    required this.onMonthChanged,
    required this.onDayChanged,
    required this.onYearChanged,
    this.controller,
  });

  final int? selectedMonth;
  final int? selectedDay;
  final int? selectedYear;
  final ValueChanged<int> onMonthChanged;
  final ValueChanged<int> onDayChanged;
  final ValueChanged<int> onYearChanged;
  final TextEditingController? controller;

  @override
  State<DobPickerGroup> createState() => _DobPickerGroupState();
}

class _DobPickerGroupState extends State<DobPickerGroup> {
  static const int _firstYear = 1950;
  static const double _itemExtent = 30;
  static const double _pickerHeight = _itemExtent * 3;

  late final FixedExtentScrollController _monthController;
  late final FixedExtentScrollController _dayController;
  late final FixedExtentScrollController _yearController;

  late int _yearNow;
  String _lastWrittenText = '';

  @override
  void initState() {
    super.initState();
    _yearNow = DateTime.now().year;
    _monthController = FixedExtentScrollController(
      initialItem: (widget.selectedMonth ?? 1) - 1,
    );
    _dayController = FixedExtentScrollController(
      initialItem: (widget.selectedDay ?? 1) - 1,
    );
    _yearController = FixedExtentScrollController(
      initialItem: (widget.selectedYear ?? _yearNow) - _firstYear,
    );
    _lastWrittenText = _formatDate();
    _writeToController();
  }

  @override
  void didUpdateWidget(covariant DobPickerGroup oldWidget) {
    super.didUpdateWidget(oldWidget);
    final int? newMonth = widget.selectedMonth;
    if (oldWidget.selectedMonth != newMonth &&
        newMonth != null &&
        _monthController.selectedItem != newMonth - 1) {
      _monthController.jumpToItem(newMonth - 1);
    }
    final int? newDay = widget.selectedDay;
    if (oldWidget.selectedDay != newDay &&
        newDay != null &&
        _dayController.selectedItem != newDay - 1) {
      _dayController.jumpToItem(newDay - 1);
    }
    final int? newYear = widget.selectedYear;
    if (oldWidget.selectedYear != newYear &&
        newYear != null &&
        _yearController.selectedItem != newYear - _firstYear) {
      _yearController.jumpToItem(newYear - _firstYear);
    }
    _writeToController();
  }

  @override
  void dispose() {
    _monthController.dispose();
    _dayController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  int get _daysInMonth {
    final int year = widget.selectedYear ?? _yearNow;
    final int month = widget.selectedMonth ?? 1;
    final int nextMonth = month == 12 ? 1 : month + 1;
    final int nextYear = month == 12 ? year + 1 : year;
    return DateTime(nextYear, nextMonth, 0).day;
  }

  String _formatDate() {
    final int? m = widget.selectedMonth;
    final int? d = widget.selectedDay;
    final int? y = widget.selectedYear;
    if (m == null || d == null || y == null) return '';
    final int maxDay = _daysInMonth;
    final int clampedDay = d > maxDay ? maxDay : d;
    return '${clampedDay.toString().padLeft(2, '0')}/'
        '${m.toString().padLeft(2, '0')}/'
        '$y';
  }

  void _writeToController() {
    final TextEditingController? ctrl = widget.controller;
    if (ctrl == null) return;
    final String next = _formatDate();
    if (next == _lastWrittenText) return;
    _lastWrittenText = next;
    ctrl.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: next.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int maxDay = _daysInMonth;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date of Birth',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 10),
        AppTextInput(
          controller: widget.controller,
          readOnly: true,
          hintText: 'DD/MM/YYYY',
        ),
        const SizedBox(height: 12),
        const Text(
          'You must be 18 and above to join Pigeon.',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 80),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280),
            child: SizedBox(
              height: _pickerHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: _WheelColumn<String>(
                      controller: _monthController,
                      itemExtent: _itemExtent,
                      items: const <String>[
                        'Jan',
                        'Feb',
                        'Mar',
                        'Apr',
                        'May',
                        'Jun',
                        'Jul',
                        'Aug',
                        'Sep',
                        'Oct',
                        'Nov',
                        'Dec',
                      ],
                      onSelectedItemChanged: (int index) =>
                          widget.onMonthChanged(index + 1),
                    ),
                  ),
                  Expanded(
                    child: _WheelColumn<int>(
                      controller: _dayController,
                      itemExtent: _itemExtent,
                      items: List<int>.generate(maxDay, (int i) => i + 1),
                      formatter: (int v) => v.toString().padLeft(2, '0'),
                      onSelectedItemChanged: (int index) =>
                          widget.onDayChanged(index + 1),
                    ),
                  ),
                  Expanded(
                    child: _WheelColumn<int>(
                      controller: _yearController,
                      itemExtent: _itemExtent,
                      items: List<int>.generate(
                        _yearNow - _firstYear + 1,
                        (int i) => _firstYear + i,
                      ),
                      formatter: (int v) => v.toString(),
                      onSelectedItemChanged: (int index) =>
                          widget.onYearChanged(_firstYear + index),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _WheelColumn<T> extends StatelessWidget {
  const _WheelColumn({
    required this.controller,
    required this.itemExtent,
    required this.items,
    required this.onSelectedItemChanged,
    this.formatter,
  });

  final FixedExtentScrollController controller;
  final double itemExtent;
  final List<T> items;
  final ValueChanged<int> onSelectedItemChanged;
  final String Function(T value)? formatter;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ListWheelScrollView.useDelegate(
          controller: controller,
          itemExtent: itemExtent,
          physics: const FixedExtentScrollPhysics(),
          perspective: 0.0001,
          diameterRatio: 1000,
          onSelectedItemChanged: onSelectedItemChanged,
          childDelegate: ListWheelChildBuilderDelegate(
            childCount: items.length,
            builder: (BuildContext context, int index) {
              final String label = formatter != null
                  ? formatter!(items[index])
                  : '${items[index]}';
              final bool isSelected = controller.selectedItem == index;
              return SizedBox(
                height: itemExtent,
                child: Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.textPrimary
                          : AppColors.textMuted,
                      fontSize: isSelected ? 18 : 16,
                      fontWeight: isSelected
                          ? FontWeight.w500
                          : FontWeight.w400,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        IgnorePointer(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(height: 1, width: 72, color: AppColors.divider),
              SizedBox(height: itemExtent - 1),
              Container(height: 1, width: 72, color: AppColors.divider),
            ],
          ),
        ),
      ],
    );
  }
}
