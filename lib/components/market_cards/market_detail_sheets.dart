import 'package:flutter/material.dart';
import 'package:pigeon/constants/app_motion.dart';
import 'package:pigeon/components/shared/app_svg_icon.dart';
import 'package:pigeon/constants/app_colors.dart';

class ResolutionSheet extends StatelessWidget {
  const ResolutionSheet({super.key, this.body});

  /// The market's resolution criteria; the stock copy is used when null.
  final String? body;

  static Future<void> show(BuildContext context, {String? body}) {
    return showModalBottomSheet<void>(
      context: context,
      sheetAnimationStyle: AppMotion.sheet,
      backgroundColor: AppColors.background,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) => ResolutionSheet(body: body),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.85,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const _SheetGrabber(),
            const SizedBox(height: 8),
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(
                Icons.chevron_left_rounded,
                color: AppColors.textPrimary,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Color(0xFF7AFFAF),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const AppSvgIcon(
                asset: AppIcons.resolutionIcon,
                size: 28,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Resolution',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.w700,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  body ?? _defaultResolution,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
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

class SettlementSheet extends StatelessWidget {
  const SettlementSheet({
    super.key,
    this.body,
    this.openLabel,
    this.closeLabel,
  });

  /// Live overrides for the stock copy.
  final String? body;
  final String? openLabel;
  final String? closeLabel;

  static Future<void> show(
    BuildContext context, {
    String? body,
    String? openLabel,
    String? closeLabel,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      sheetAnimationStyle: AppMotion.sheet,
      backgroundColor: AppColors.background,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) => SettlementSheet(
        body: body,
        openLabel: openLabel,
        closeLabel: closeLabel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.85,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const _SheetGrabber(),
            const SizedBox(height: 8),
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(
                Icons.chevron_left_rounded,
                color: AppColors.textPrimary,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Color(0xFFFE2C55),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const AppSvgIcon(
                asset: AppIcons.settlementIcon,
                size: 28,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Settlement',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.w700,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              body ??
                  'This market will close and expire after a person has been officially declared winner of the 2027 Nigeria Presidential election.',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    _SettlementRow(
                      iconColor: const Color(0xFF1DA1F2),
                      title: 'Market open',
                      subtitle: openLabel ?? 'May 10, 2025 - May 10, 2025',
                    ),
                    const SizedBox(height: 16),
                    _SettlementRow(
                      title: 'Market Closes',
                      subtitle: closeLabel ?? 'After the outcome occurs',
                      showDot: true,
                    ),
                    const SizedBox(height: 16),
                    const _SettlementRow(
                      title: 'Projected Payout',
                      subtitle: '10 minutes after verified resolution',
                      showDot: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WageTermsSheet extends StatelessWidget {
  const WageTermsSheet({super.key, this.body});

  /// The market's wager terms; the stock copy is used when null.
  final String? body;

  static Future<void> show(BuildContext context, {String? body}) {
    return showModalBottomSheet<void>(
      context: context,
      sheetAnimationStyle: AppMotion.sheet,
      backgroundColor: AppColors.background,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) => WageTermsSheet(body: body),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.85,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const _SheetGrabber(),
            const SizedBox(height: 8),
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(
                Icons.chevron_left_rounded,
                color: AppColors.textPrimary,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Color(0xFF1DA1F2),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const AppSvgIcon(
                asset: AppIcons.wageTermsIcon,
                size: 28,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Wage Terms',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.w700,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  body ?? _defaultWageTerms,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
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

class _SheetGrabber extends StatelessWidget {
  const _SheetGrabber();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.surfaceDisabled,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _SettlementRow extends StatelessWidget {
  const _SettlementRow({
    required this.title,
    required this.subtitle,
    this.iconColor,
    this.showDot = false,
  });
  final String title;
  final String subtitle;
  final Color? iconColor;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Column(
          children: <Widget>[
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: iconColor ?? Colors.transparent,
                border: showDot
                    ? Border.all(color: AppColors.textPrimary, width: 2)
                    : null,
                shape: BoxShape.circle,
              ),
              child: iconColor != null
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 12,
                    )
                  : null,
            ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Shown when a market has no resolution or wage terms of its own. Kept in
// line with how markets are resolved and settled in supabase/schema.sql.
const String _defaultResolution =
    'This market resolves to the option that matches the official, verified '
    'outcome of the event, as confirmed by the source named for the market '
    '(for example an electoral commission, league or organiser).\n\n'
    'Once the outcome is confirmed, Pigeon marks the winning option and '
    'trading stops. There is a short review window in which a resolution '
    'can be corrected before payouts are made.\n\n'
    'If the event is cancelled, abandoned or cannot be verified, the market '
    'is voided and everyone gets back what they paid for the shares they '
    'still hold.';

const String _defaultWageTerms =
    'Trading on this market follows strict integrity and compliance rules '
    'to ensure fairness and prevent manipulation.\n\n'
    'Each share pays ₦100 if its option wins and ₦0 if it loses. The price '
    'you see is the market\'s current estimate of that option\'s chance, '
    'and it moves as people buy and sell.\n\n'
    'A transaction fee is charged on every buy and every sell, and is shown '
    'before you confirm. You can sell your shares back at any time while '
    'the market is open.\n\n'
    'You must be 18 or older to trade. Accounts found manipulating prices, '
    'using inside information or trading on behalf of others may be '
    'suspended and their positions voided.';
