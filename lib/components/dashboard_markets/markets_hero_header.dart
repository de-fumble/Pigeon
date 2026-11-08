import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/motion/pressable.dart';

class MarketsHeroHeader extends StatelessWidget {
  const MarketsHeroHeader({super.key, required this.onTap});

  final VoidCallback? onTap;

  static const double _heroWidth = 430;
  static const double _heroHeight = 550;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: _heroWidth,
        height: _heroHeight,
        child: Stack(
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Color(0xFFC4C4C4),
                    Color(0xCCC4C4C4),
                    Color(0x00C4C4C4),
                  ],
                  stops: <double>[0.0, 0.55, 1.0],
                ),
              ),
              child: SizedBox.expand(),
            ),
            const Positioned.fill(
              child: Padding(
                padding: EdgeInsets.fromLTRB(32, 0, 32, 80),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      'Track the world’s\nmost talked-about\nmoments in real time',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF1A1A1A),
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        height: 1.15,
                      ),
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
