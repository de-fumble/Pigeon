import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/motion/pressable.dart';
import 'package:pigeon/components/shared/app_svg_icon.dart';
import 'package:pigeon/constants/app_colors.dart';

class ArenaPoliticsPollCard extends StatelessWidget {
  const ArenaPoliticsPollCard({super.key, this.onMenuTap});

  final VoidCallback? onMenuTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            _TopicMark(
              backgroundColor: const Color(0xFFFFD400),
              icon: Icons.account_balance_rounded,
              iconColor: AppColors.buttonText,
            ),
            SizedBox(width: 10),
            Text(
              '@Politics',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 6),
            Text(
              '• 6h',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            Spacer(),
            Pressable(
              onTap: onMenuTap,
              behavior: HitTestBehavior.opaque,
              child: const SizedBox(
                width: 32,
                height: 32,
                child: Icon(
                  Icons.more_horiz_rounded,
                  color: AppColors.textMuted,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Text(
          'Optimism is shared belief',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 12),
        _PollPanel(),
        SizedBox(height: 12),
        _EngagementRow(
          reactions: <_Reaction>[
            _Reaction(
              icon: '💬',
              iconAsset: AppIcons.cultureComments,
              count: '900',
            ),
            _Reaction(
              icon: '✏️',
              iconAsset: AppIcons.cultureQuote,
              count: '406',
            ),
            _Reaction(
              icon: '😀',
              iconAsset: AppIcons.cultureSmile,
              count: '26',
            ),
            _Reaction(
              icon: '💔',
              iconAsset: AppIcons.cultureBrokenHeart,
              count: '12',
            ),
          ],
        ),
      ],
    );
  }
}

class _PollPanel extends StatelessWidget {
  const _PollPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFFE0E0E0),
                  shape: BoxShape.circle,
                ),
                clipBehavior: Clip.antiAlias,
                child: ColorFiltered(
                  colorFilter: const ColorFilter.mode(
                    Color(0xFFE0E0E0),
                    BlendMode.multiply,
                  ),
                  child: Image.asset(
                    AppIcons.presidentThumb,
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Who will be the next Nigerian Preside...',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 2),
          Text(
            'Politics - Election',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 14),
          _PollOption(label: 'Bola Ahmed Tinubu', value: '59%'),
          SizedBox(height: 12),
          _PollOption(label: 'Peter Obi', value: '41%'),
          SizedBox(height: 12),
          _PollOption(label: 'Atiku Abubakar', value: '28%'),
          SizedBox(height: 12),
          _PollOption(label: 'El Rufai', value: '13%'),
          SizedBox(height: 14),
          Row(
            children: [
              Icon(
                Icons.payments_outlined,
                size: 18,
                color: AppColors.textMuted,
              ),
              SizedBox(width: 6),
              Text(
                '₦46,357,211',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 4),
              Text(
                '• Active',
                style: TextStyle(
                  color: Color(0xFFFFA71A),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PollOption extends StatelessWidget {
  const _PollOption({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _EngagementRow extends StatelessWidget {
  const _EngagementRow({required this.reactions});

  final List<_Reaction> reactions;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        ...reactions.expand(
          (reaction) => <Widget>[
            reaction.iconAsset != null
                ? Image.asset(
                    reaction.iconAsset!,
                    width: 18,
                    height: 18,
                    fit: BoxFit.contain,
                  )
                : Text(reaction.icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 4),
            Text(
              reaction.count,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
            const SizedBox(width: 12),
          ],
        ),
      ],
    );
  }
}

class _TopicMark extends StatelessWidget {
  const _TopicMark({
    required this.backgroundColor,
    required this.icon,
    required this.iconColor,
  });

  final Color backgroundColor;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 18, color: iconColor),
    );
  }
}

class _Reaction {
  const _Reaction({required this.icon, required this.count, this.iconAsset});

  final String icon;
  final String? iconAsset;
  final String count;
}
