import 'package:flutter/material.dart';
import 'package:pigeon/components/dashboard/arena_feature_card.dart';

class ArenaHeroCarousel extends StatelessWidget {
  const ArenaHeroCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 474,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: const [
          ArenaFeatureCard(),
          SizedBox(width: 12),
          ArenaFeatureCard(partial: true),
        ],
      ),
    );
  }
}
