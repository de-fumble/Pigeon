import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pigeon/router/app_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const Duration _delay = Duration(milliseconds: 1400);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Timer(_delay, () {
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed(AppRouter.onboarding);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SizedBox(
          width: 184,
          height: 30,
          child: SvgPicture.asset(
            'assets/Pigeon Wordmark small.svg',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
