import 'package:flutter/material.dart';
import 'package:pigeon/constants/app_colors.dart';

class AdminMarketResolutionSheet extends StatefulWidget {
  const AdminMarketResolutionSheet({
    super.key,
    required this.initial,
    this.title = 'Resolution',
    this.hint = 'Describe how this market will be resolved',
  });

  final String initial;
  final String title;
  final String hint;

  @override
  State<AdminMarketResolutionSheet> createState() =>
      _AdminMarketResolutionSheetState();
}

class _AdminMarketResolutionSheetState
    extends State<AdminMarketResolutionSheet> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initial,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: keyboardInset),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(top: BorderSide(color: Color(0xFF1A91FF), width: 2)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: AppColors.textPrimary,
                          size: 20,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: <Widget>[
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Color(0xFF19D36D),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.flag_circle_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      widget.title,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Container(
                  width: double.infinity,
                  height: 180,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF262626),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextField(
                    controller: _controller,
                    maxLines: null,
                    expands: true,
                    keyboardType: TextInputType.multiline,
                    textAlignVertical: TextAlignVertical.top,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                    ),
                    cursorColor: AppColors.accent,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isCollapsed: true,
                      hintText: widget.hint,
                      hintStyle: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton(
                    onPressed: () =>
                        Navigator.of(context).pop(_controller.text.trim()),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.surface,
                      foregroundColor: AppColors.buttonText,
                      shape: const StadiumBorder(),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: const Text('Done'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
