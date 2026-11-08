import 'package:flutter/material.dart';
import 'package:pigeon/components/auth/auth_header.dart';
import 'package:pigeon/components/auth/auth_scaffold.dart';
import 'package:pigeon/components/auth/interest_chip.dart';
import 'package:pigeon/components/shared/app_pill_button.dart';
import 'package:pigeon/constants/app_strings.dart';
import 'package:pigeon/models/interest_option_model.dart';
import 'package:pigeon/router/app_router.dart';
import 'package:pigeon/services/auth_service.dart';

class InterestsScreen extends StatefulWidget {
  const InterestsScreen({super.key});

  @override
  State<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends State<InterestsScreen> {
  static const List<InterestOptionModel> _options = <InterestOptionModel>[
    InterestOptionModel(label: 'Sports', emoji: '⚽'),
    InterestOptionModel(label: 'Gaming', emoji: '🎮'),
    InterestOptionModel(label: 'Crypto & Finance', emoji: '💰'),
    InterestOptionModel(label: 'Politics', emoji: '🗳️'),
    InterestOptionModel(label: 'Science', emoji: '🔭'),
    InterestOptionModel(label: 'Culture & Entertainment', emoji: '🎭'),
    InterestOptionModel(label: 'Markets & Economy', emoji: '📈'),
    InterestOptionModel(label: 'Tech & AI', emoji: '🤖'),
    InterestOptionModel(label: 'Memes & Pop Culture', emoji: '😂'),
    InterestOptionModel(label: 'Future Trends', emoji: '🔮'),
    InterestOptionModel(label: 'Influencer & Lifestyle', emoji: '🧑'),
  ];

  final Set<String> _selectedLabels = <String>{};
  bool _isSaving = false;

  void _toggle(String label) {
    setState(() {
      if (_selectedLabels.contains(label)) {
        _selectedLabels.remove(label);
      } else {
        _selectedLabels.add(label);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool canContinue = _selectedLabels.length >= 3;

    return AuthScaffold(
      onBack: () => Navigator.of(context).pop(),
      contentTopSpacing: 102,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AuthHeader(
            title: 'Pick what you’re into',
            subtitle:
                'Choose 3-5 topics to personalize your Pigeon\nexperience and we’ll curate the best events for your\nfeed',
          ),
          const SizedBox(height: 26),
          Wrap(
            spacing: 12,
            runSpacing: 16,
            children: _options
                .map(
                  (InterestOptionModel option) => InterestChip(
                    label: option.label,
                    emoji: option.emoji,
                    isSelected: _selectedLabels.contains(option.label),
                    onTap: () => _toggle(option.label),
                  ),
                )
                .toList(),
          ),
        ],
      ),
      bottomContent: AppPillButton(
        label: AppStrings.next,
        onPressed: canContinue && !_isSaving
            ? () async {
                final NavigatorState navigator = Navigator.of(context);
                setState(() => _isSaving = true);
                try {
                  await AuthService.saveInterests(_selectedLabels.toList());
                } catch (_) {
                  // Non-critical — continue even if save fails
                } finally {
                  if (mounted) setState(() => _isSaving = false);
                }
                navigator.pushNamed(AppRouter.dateOfBirth);
              }
            : null,
      ),
    );
  }
}
