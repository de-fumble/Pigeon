import 'package:flutter/material.dart';
import 'package:pigeon/constants/app_colors.dart';

class AdminMarketSettlementSheet extends StatefulWidget {
  const AdminMarketSettlementSheet({super.key, required this.initial});

  final String initial;

  @override
  State<AdminMarketSettlementSheet> createState() =>
      _AdminMarketSettlementSheetState();
}

class _AdminMarketSettlementSheetState
    extends State<AdminMarketSettlementSheet> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initial,
  );
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
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
                      const Expanded(
                        child: Text(
                          'Settlement',
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
                const SizedBox(height: 80),
                SizedBox(
                  width: double.infinity,
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    textAlign: TextAlign.center,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 96,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                    cursorColor: AppColors.accent,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isCollapsed: true,
                      hintText: 'NO',
                      hintStyle: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 96,
                        fontWeight: FontWeight.w700,
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
