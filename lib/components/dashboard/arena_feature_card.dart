import 'package:flutter/material.dart';

class ArenaFeatureCard extends StatelessWidget {
  const ArenaFeatureCard({super.key, this.partial = false});

  final bool partial;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: partial ? 120 : 392,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const SizedBox.expand(),
    );
  }
}
