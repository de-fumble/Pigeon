import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/motion/fade_slide_in.dart';
import 'package:pigeon/constants/app_colors.dart';
import 'package:pigeon/router/app_router.dart';

class MarketInfoScreen extends StatelessWidget {
  const MarketInfoScreen({
    super.key,
    this.question = 'Who will be the next Nigerian\nPresident?',
    this.thumbnail,
    this.optionsCount = 4,
    this.volume = 211096578,
    this.circulatingSupply = 211096578,
    this.amountOfUsers = 406000,
    this.numberOfBuys = 1000,
    this.numberOfSells = 784,
  });

  final String question;
  final String? thumbnail;
  final int optionsCount;
  final int volume;
  final int circulatingSupply;
  final int amountOfUsers;
  final int numberOfBuys;
  final int numberOfSells;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: staggeredEntrance(<Widget>[
            _TopBar(onBack: () => Navigator.of(context).pop()),
            const SizedBox(height: 22),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 44,
                    height: 44,
                    clipBehavior: Clip.antiAlias,
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    child: thumbnail != null
                        ? ColorFiltered(
                            colorFilter: const ColorFilter.mode(
                              Color(0xFFD9D9D9),
                              BlendMode.multiply,
                            ),
                            child: Image.asset(
                              thumbnail!,
                              width: 44,
                              height: 44,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Container(color: const Color(0xFFD9D9D9)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      question,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: SizedBox(
                width: double.infinity,
                height: 44,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(
                      context,
                    ).pushNamed(AppRouter.marketPoliticsDetails);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1F1F1F),
                    foregroundColor: AppColors.textPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('View Market'),
                ),
              ),
            ),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: <Widget>[
                    _StatRow(
                      label: 'Options',
                      value: _formatNumber(optionsCount),
                    ),
                    const _StatDivider(),
                    _StatRow(
                      label: 'Volume',
                      value: '₦${_formatNumber(volume)}',
                    ),
                    const _StatDivider(),
                    _StatRow(
                      label: 'Circulating supply',
                      value: '₦${_formatNumber(circulatingSupply)}',
                    ),
                    const _StatDivider(),
                    _StatRow(
                      label: 'Amount of users',
                      value: _formatNumber(amountOfUsers),
                    ),
                    const _StatDivider(),
                    _StatRow(
                      label: 'Number of buys',
                      value: _formatNumber(numberOfBuys),
                    ),
                    const _StatDivider(),
                    _StatRow(
                      label: 'Number of sells',
                      value: _formatNumber(numberOfSells),
                    ),
                  ],
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

String _formatNumber(int n) {
  final String s = n.toString();
  final StringBuffer buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return buf.toString();
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 18, 0),
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: onBack,
            icon: const Icon(
              Icons.chevron_left_rounded,
              color: AppColors.textPrimary,
              size: 28,
            ),
          ),
          const Text(
            'Market Details',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: const Color(0xFF2A2A2A),
    );
  }
}
