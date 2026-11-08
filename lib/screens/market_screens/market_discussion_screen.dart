import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/motion/fade_slide_in.dart';
import 'package:pigeon/components/dashboard/market_top_bar.dart';
import 'package:pigeon/constants/app_colors.dart';

class MarketDiscussionScreen extends StatelessWidget {
  const MarketDiscussionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
          children: staggeredEntrance([
            MarketTopBar(title: 'Politics - Election'),
            const SizedBox(height: 16),
            const Text(
              'Who will be the next\nNigerian President?',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 34,
                height: 1.08,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                _LegendDot(color: Color(0xFF2DA6FF)),
                SizedBox(width: 6),
                Text(
                  'Bola Ahmed Tinubu 55%',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
                SizedBox(width: 14),
                _LegendDot(color: Color(0xFFAA8CFF)),
                SizedBox(width: 6),
                Text(
                  'Peter Obi 28%',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Row(
              children: [
                _LegendDot(color: Color(0xFFFFD74A)),
                SizedBox(width: 6),
                Text(
                  'Atiku Abubakar 13%',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
                SizedBox(width: 14),
                _LegendDot(color: Color(0xFFFF5F42)),
                SizedBox(width: 6),
                Text(
                  'El Rufai 5%',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 26),
            const Row(
              children: [
                Text(
                  'NOW',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 18),
                Text(
                  '1D',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 210),
            const Row(
              children: [
                Text(
                  'N769,642,414 Vol.',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  '↑N378.9874',
                  style: TextStyle(
                    color: Color(0xFF1FD36B),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Options',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 18),
            const _OptionRow(
              avatar: '👨🏾',
              title: 'Bola Ahmed Tinubu',
              percentage: '55%',
              price: 'N59',
              avatarColor: Color(0xFFCB3D59),
            ),
            const SizedBox(height: 18),
            const _OptionRow(
              avatar: '👤',
              title: 'Peter Obi',
              percentage: '28%',
              price: 'N41',
              avatarColor: Color(0xFF9E8D77),
            ),
            const SizedBox(height: 18),
            const _OptionRow(
              avatar: '👤',
              title: 'Atiku Abubakar',
              percentage: '13%',
              price: 'N26',
              avatarColor: Color(0xFFC5A47C),
            ),
            const SizedBox(height: 18),
            const _OptionRow(
              avatar: '👤',
              title: 'El Rufai',
              percentage: '5%',
              price: 'N11',
              avatarColor: Color(0xFFB7A172),
            ),
          ]),
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.avatar,
    required this.title,
    required this.percentage,
    required this.price,
    required this.avatarColor,
  });

  final String avatar;
  final String title;
  final String percentage;
  final String price;
  final Color avatarColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: avatarColor,
          child: Text(avatar, style: const TextStyle(fontSize: 16)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                percentage,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 64,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            price,
            style: const TextStyle(
              color: AppColors.buttonText,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
