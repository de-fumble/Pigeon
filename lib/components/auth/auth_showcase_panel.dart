import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pigeon/components/onboarding/onboarding_brand_mark.dart';
import 'package:pigeon/components/onboarding/onboarding_eye_mark.dart';
import 'package:pigeon/components/shared/app_svg_icon.dart';
import 'package:pigeon/constants/app_colors.dart';
import 'package:pigeon/constants/app_strings.dart';
import 'package:pigeon/utils/responsive.dart';

/// The brand panel beside the auth forms on wide windows: Pigeon's eyes with
/// the market categories orbiting them, a few live-looking market chips, and
/// what the app offers. Decorative; it carries no actions.
class AuthShowcasePanel extends StatefulWidget {
  const AuthShowcasePanel({super.key});

  @override
  State<AuthShowcasePanel> createState() => _AuthShowcasePanelState();
}

class _AuthShowcasePanelState extends State<AuthShowcasePanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bool reduceMotion =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduceMotion) {
      _float.stop();
    } else if (!_float.isAnimating) {
      _float.repeat();
    }
  }

  @override
  void dispose() {
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.showcase,
        border: Border(right: BorderSide(color: AppColors.hairline)),
        gradient: RadialGradient(
          center: Alignment(-0.6, -0.5),
          radius: 1.2,
          colors: <Color>[Color(0x1FFF2D55), AppColors.showcase],
        ),
      ),
      child: SafeArea(
        child: Center(
          // On large monitors the artwork and copy stay together in the
          // middle of the panel instead of spreading to its corners.
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 680,
              maxHeight: Breakpoints.formHeight,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(56, 40, 56, 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const OnboardingBrandMark(),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (BuildContext context, BoxConstraints box) {
                        final double size = math.min(
                          math.min(box.maxWidth * 0.78, box.maxHeight),
                          520,
                        );
                        return Center(
                          child: SizedBox.square(
                            dimension: size,
                            child: AnimatedBuilder(
                              animation: _float,
                              builder: (BuildContext context, _) => _Orbit(
                                size: size,
                                spill: (box.maxWidth - size) / 2,
                                t: _float.value,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Text(
                    AppStrings.onboardingHeadline,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontSize: 40,
                      height: 1.1,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Trade on politics, sports, culture and more with people across Nigeria.',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 17,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: <Widget>[
                      _FeaturePill(icon: AppIcons.trendUp, label: 'Live odds'),
                      _FeaturePill(
                        icon: AppIcons.shieldCheck,
                        label: '18+ and secure',
                      ),
                      _FeaturePill(
                        icon: AppIcons.cashOut,
                        label: 'Cash out anytime',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Category badges circling the Pigeon eyes, with market chips drifting in
/// front. [t] runs 0→1 and loops.
class _Orbit extends StatelessWidget {
  const _Orbit({required this.size, required this.spill, required this.t});

  final double size;

  /// Room beside the orbit that the chips may drift into.
  final double spill;
  final double t;

  // Category icons on their market-tab colours.
  static const List<(String, Color)> _badges = <(String, Color)>[
    (AppIcons.politics, Color(0xFFFFD300)),
    (AppIcons.sports, Color(0xFF00C34E)),
    (AppIcons.culture, Color(0xFFFF3C63)),
    (AppIcons.tech, Color(0xFF00E0E0)),
    (AppIcons.economicsChip, Color(0xFFFA4E00)),
  ];

  @override
  Widget build(BuildContext context) {
    final double c = size / 2;
    final double ring = size * 0.36;
    final double badge = size * 0.13;
    final double spin = t * 2 * math.pi / 8; // one slow turn every 48s

    double bob(double phase) =>
        math.sin((t + phase) * 2 * math.pi) * size * 0.012;
    final double chipWidth = (size * 0.5).clamp(190.0, 220.0);
    final double out = math.min(spill, size * 0.22);

    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Positioned.fill(child: CustomPaint(painter: _RingsPainter())),
        for (int i = 0; i < _badges.length; i++)
          Builder(
            builder: (BuildContext context) {
              final double a =
                  spin + i * 2 * math.pi / _badges.length - math.pi / 2;
              return Positioned(
                left: c + ring * math.cos(a) - badge / 2,
                top: c + ring * math.sin(a) - badge / 2,
                child: _Badge(
                  asset: _badges[i].$1,
                  color: _badges[i].$2,
                  size: badge,
                ),
              );
            },
          ),
        Positioned(
          left: c - size * 0.13,
          top: c - size * 0.068,
          child: OnboardingEyeMark(width: size * 0.26, height: size * 0.135),
        ),
        // Chips sit above, beside and below the eyes, never across them.
        Positioned(
          left: -out,
          top: size * 0.02 + bob(0),
          child: _MarketChip(
            width: chipWidth,
            icon: AppIcons.trendUp,
            title: 'Next Nigerian President?',
            value: '59%',
            caption: 'Leading option',
          ),
        ),
        Positioned(
          right: -out,
          top: size * 0.64 + bob(0.33),
          child: _MarketChip(
            width: chipWidth,
            live: true,
            title: 'Arsenal vs. Man City',
            value: '3 – 1',
            caption: 'LIVE  1H 5:17',
          ),
        ),
        Positioned(
          left: -out * 0.4,
          bottom: -size * 0.04 + bob(0.66),
          child: _MarketChip(
            width: chipWidth,
            icon: AppIcons.cashOut,
            title: 'Davido album in 2026?',
            value: 'Yes 55%',
            caption: '₦769M traded',
          ),
        ),
      ],
    );
  }
}

class _RingsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (final (double r, double alpha) in <(double, double)>[
      (0.22, 0.10),
      (0.36, 0.16),
      (0.48, 0.07),
    ]) {
      paint.color = Colors.white.withValues(alpha: alpha);
      canvas.drawCircle(center, size.width * r, paint);
    }
  }

  @override
  bool shouldRepaint(_RingsPainter oldDelegate) => false;
}

class _Badge extends StatelessWidget {
  const _Badge({required this.asset, required this.color, required this.size});

  final String asset;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.18),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.showcase, width: 3),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Image.asset(asset, fit: BoxFit.contain),
    );
  }
}

class _MarketChip extends StatelessWidget {
  const _MarketChip({
    required this.width,
    required this.title,
    required this.value,
    required this.caption,
    this.icon,
    this.live = false,
  });

  final double width;
  final String title;
  final String value;
  final String caption;
  final String? icon;
  final bool live;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.hairline),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: live
                ? Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFE542A),
                      shape: BoxShape.circle,
                    ),
                  )
                : AppSvgIcon(asset: icon!, size: 18, color: AppColors.accent),
          ),
          const SizedBox(width: 10),
          // Title on its own line so it keeps its width on narrow windows.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: <Widget>[
                    Text(
                      value,
                      style: const TextStyle(
                        color: Color(0xFF1FD36B),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  const _FeaturePill({required this.icon, required this.label});

  final String icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 9, 16, 9),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.hairline),
        color: Colors.white.withValues(alpha: 0.03),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AppSvgIcon(asset: icon, size: 20, color: AppColors.textPrimary),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
