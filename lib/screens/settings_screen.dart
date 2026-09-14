import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/progress_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(progressProvider).value;
    final goals = const [10, 20, 30, 50];

    return Scaffold(
      appBar: AppBar(title: const Text('Nastavení')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Životy (srdce)'),
            subtitle: const Text('Při chybě ztratíš život. Vypni pro volný režim.'),
            value: p?.heartsEnabled ?? true,
            onChanged: (v) =>
                ref.read(progressProvider.notifier).setHeartsEnabled(v),
          ),
          ListTile(
            title: const Text('Doplnit životy'),
            subtitle: Text('Aktuálně: ${p?.hearts ?? 0} / ${p?.heartsMax ?? 5}'),
            trailing: FilledButton.tonal(
              onPressed: () =>
                  ref.read(progressProvider.notifier).refillHearts(),
              child: const Text('Doplnit'),
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              'Denní cíl XP',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              children: goals.map((g) {
                return ChoiceChip(
                  label: Text('$g'),
                  selected: (p?.dailyGoalXp ?? 30) == g,
                  onSelected: (_) =>
                      ref.read(progressProvider.notifier).setDailyGoal(g),
                );
              }).toList(),
            ),
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.delete_forever,
                color: Theme.of(context).colorScheme.error),
            title: const Text('Resetovat postup'),
            onTap: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (c) => AlertDialog(
                  title: const Text('Resetovat?'),
                  content: const Text(
                    'Smaže XP, sérii, dokončené lekce a onboarding.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(c, false),
                      child: const Text('Zrušit'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(c, true),
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              );
              if (ok == true) {
                await ref.read(progressProvider.notifier).resetProgress();
              }
            },
          ),
        ],
      ),
    );
  }
}
