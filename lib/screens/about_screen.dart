import 'package:flutter/material.dart';

import '../data/content_manifest.dart';
import '../data/courses.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
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
            'Aplikace vzniká jako studijní pomůcka pro studenty programu '
            'mechatroniky na VŠB – Technické univerzitě Ostrava (VŠB–TUO). '
            'Nejde o oficiální produkt univerzity a nepoužívá oficiální loga '
            'ani oficiální katalogové kódy předmětů.',
          ),
          const SizedBox(height: 24),
          Text(
            'Mapa programu (orientační)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Mechatronika spojuje mechaniku, elektroniku, řízení a software. '
            'MechaLearn mapuje tyto oblasti jako kurzy v aplikaci:',
          ),
          const SizedBox(height: 12),
          ...allCourses.map((c) {
            final status = c.isPlaceholder
                ? 'placeholder — obsah od vyučujících později'
                : 'autorovaný obsah (matematika)';
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.iconEmoji),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${c.title}\n$status',
                      style: TextStyle(color: cs.onSurfaceVariant, height: 1.35),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
          Text(
            'Popisky kurzů mimo matematiku jsou záměrně obecné placeholdery — '
            'nejsou to ověřené oficiální ID předmětů VŠB–TUO.',
            style: TextStyle(
              color: cs.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 24),
          const Text('Verze aplikace 1.0.0'),
          Text('Obsah: content_version ${ContentManifest.contentVersion}'),
          Text(
            'Integrity HMAC refuse-on-tamper: odloženo (offline v1 / PATCH v1.1.1).',
            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(
            'Matematický kurz je plně autorován. Ostatní kurzy čekají na '
            'materiály od vyučujících (podepsané balíčky s content_version + HMAC). '
            'Multi-device sync je v1 odloženo.',
            style: TextStyle(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
