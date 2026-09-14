import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/progress_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _goal = 30;
  final _goals = const [10, 20, 30, 50];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Text(
                'MechaLearn',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: cs.primary,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Studijní cesta pro mechatroniku\nve stylu Duolingo + Brilliant',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 32),
              Text(
                'Jaký je tvůj denní cíl XP?',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _goals.map((g) {
                  final selected = g == _goal;
                  return ChoiceChip(
                    label: Text('$g XP'),
                    selected: selected,
                    onSelected: (_) => setState(() => _goal = g),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Text(
                'Můžeš to kdykoli změnit v nastavení. '
                'Postup se ukládá offline v zařízení.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () async {
                  await ref
                      .read(progressProvider.notifier)
                      .completeOnboarding(_goal);
                  if (context.mounted) context.go('/home');
                },
                child: const Text('Začít učení'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
