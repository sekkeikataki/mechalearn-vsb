import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/courses.dart';
import '../providers/progress_provider.dart';

class CoursesHubScreen extends ConsumerWidget {
  const CoursesHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider).value;
    final active = progress?.activeCourseId ?? 'matematika';

    return Scaffold(
      appBar: AppBar(title: const Text('Kurzy')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: allCourses.length,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final c = allCourses[i];
          final selected = c.id == active;
          return Card(
            color: selected
                ? Theme.of(context).colorScheme.primaryContainer
                : null,
            child: ListTile(
              leading: Text(c.iconEmoji, style: const TextStyle(fontSize: 32)),
              title: Text(
                c.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                c.isPlaceholder
                    ? '${c.description}\n(zatím prázdný placeholder)'
                    : c.description,
              ),
              isThreeLine: true,
              trailing: selected
                  ? const Icon(Icons.check_circle)
                  : const Icon(Icons.chevron_right),
              onTap: () async {
                await ref.read(progressProvider.notifier).setActiveCourse(c.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        c.isPlaceholder
                            ? 'Kurz „${c.title}“ je zatím bez obsahu.'
                            : 'Aktivní kurz: ${c.title}',
                      ),
                    ),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }
}
