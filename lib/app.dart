import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router.dart';
import 'theme.dart';

class MechaLearnApp extends ConsumerWidget {
  const MechaLearnApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'MechaLearn',
      debugShowCheckedModeBanner: false,
      theme: MechaTheme.light(),
      routerConfig: router,
      locale: const Locale('cs'),
    );
  }
}
