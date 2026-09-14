import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/progress_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(progressProvider).value;
    final today = ref.watch(todayXpProvider).value ?? 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    child: const Icon(Icons.engineering, size: 40),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Student mechatroniky',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _stat('XP', '${p?.xp ?? 0}'),
                      _stat('Série', '${p?.streak ?? 0}'),
                      _stat('Dnes', '$today'),
                      _stat('Lekce', '${p?.completedLessons.length ?? 0}'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Nastavení'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/profile/settings'),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('O aplikaci'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/profile/about'),
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        Text(label),
      ],
    );
  }
}
