import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('O aplikaci')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'MechaLearn',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Offline-first studijní aplikace pro studenty mechatroniky. '
            'Kombinuje herní cestu dovedností (ve stylu Duolingo) s '
            'vícekrokovými úlohami a nápovědami (ve stylu Brilliant).',
          ),
          const SizedBox(height: 24),
          Text(
            'VŠB – Technická univerzita Ostrava',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Aplikace vzniká jako studijní pomůcka pro studenty VŠB – '
            'Technické univerzity Ostrava. Nejde o oficiální produkt univerzity '
            'a nepoužívá oficiální loga.',
          ),
          const SizedBox(height: 24),
          const Text('Verze 1.0.0'),
          const SizedBox(height: 8),
          Text(
            'Matematický kurz je plně autorován. Ostatní kurzy jsou prázdné '
            'placeholdery pro budoucí materiály od vyučujících (JSON / Dart balíčky).',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
