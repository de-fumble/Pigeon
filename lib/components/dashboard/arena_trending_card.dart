import 'package:flutter/material.dart';
import 'package:pigeon/components/dashboard/arena_fanbase_card.dart';
import 'package:pigeon/components/shared/app_svg_icon.dart';

class ArenaTrendingCard extends StatelessWidget {
  const ArenaTrendingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ArenaFanbaseCard(
      title: 'Nigerian Elections',
      items: const <ArenaFanbaseItemData>[
        ArenaFanbaseItemData(
          avatar: '🗳️',
          avatarImage: AppIcons.neNextPresident,
          avatarBgColor: Color(0xFF1F2A1F),
          title: 'Who\'ll be the next\nNigerian President?',
        ),
        ArenaFanbaseItemData(
          avatar: '🏛️',
          avatarImage: AppIcons.neNextLagosState,
          avatarBgColor: Color(0xFF1F2A1F),
          title: 'Next Lagos state\nGovernor?',
        ),
        ArenaFanbaseItemData(
          avatar: '🧑🏾',
          avatarImage: AppIcons.neAtikuStepDown,
          avatarBgColor: Color(0xFF1F2A1F),
          title: 'Will Atiku step down\nfrom the 2027...',
        ),
        ArenaFanbaseItemData(
          avatar: '👴🏾',
          avatarImage: AppIcons.neElRufai,
          avatarBgColor: Color(0xFF1F2A1F),
          title: 'Will El Rufai contest for\n2027 presidency?',
        ),
      ],
    );
  }
}
