import 'package:flutter/material.dart';

import 'constants/app_colors.dart';
import 'constants/app_spacing.dart';
import 'router/app_router.dart';

class PigeonApp extends StatelessWidget {
  const PigeonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pigeon',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.textPrimary,
          secondary: AppColors.accent,
          surface: AppColors.background,
        ),
        useMaterial3: true,
        fontFamily: 'SF Pro Display',
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 28,
            height: 1.15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          bodyLarge: TextStyle(
            fontSize: 18,
            height: 1.3,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          bodyMedium: TextStyle(
            fontSize: 16,
            height: 1.4,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
        // Sheets keep a phone-like width on tablets and laptops.
        bottomSheetTheme: const BottomSheetThemeData(
          constraints: BoxConstraints(maxWidth: 640),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
          ),
        ),
      ),
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: AppRouter.splash,
    );
  }
}
