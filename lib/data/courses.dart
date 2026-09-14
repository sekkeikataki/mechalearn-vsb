import '../models/course.dart';
import 'maths/unit1_cisla.dart';
import 'maths/unit2_funkce.dart';
import 'maths/unit3_derivace.dart';
import 'maths/unit4_integraly.dart';
import 'maths/unit5_linalg.dart';
import 'maths/unit6_dr.dart';
import 'maths/unit7_komplex.dart';
import 'maths/unit8_fourier.dart';

/// Katalog kurzů MechaLearn.
///
/// Integrity (HMAC) se ověřuje přes [ContentIntegrity] před learning flows —
/// ne při importu tohoto souboru (aby smoke testy a nástroje mohly číst data).
final List<Course> allCourses = [
  Course(
    id: 'matematika',
    title: 'Matematika pro mechatroniku',
    description:
        'Kompletní cesta: čísla, funkce, derivace, integrály, lineární algebra, '
        'DR, komplexní čísla a intuice Fourierových signálů.',
    iconEmoji: '🧮',
    isPlaceholder: false,
    units: [
      unit1Cisla,
      unit2Funkce,
      unit3Derivace,
      unit4Integraly,
      unit5Linalg,
      unit6Dr,
      unit7Komplex,
      unit8Fourier,
    ],
  ),
  const Course(
    id: 'fyzika',
    title: 'Fyzika (placeholder)',
    description: 'Placeholder pro materiály od vyučujících — není oficiální kód předmětu VŠB.',
    iconEmoji: '⚛️',
    isPlaceholder: true,
  ),
  const Course(
    id: 'elektronika',
    title: 'Elektronika (placeholder)',
    description: 'Placeholder pro materiály od vyučujících — není oficiální kód předmětu VŠB.',
    iconEmoji: '🔌',
    isPlaceholder: true,
  ),
  const Course(
    id: 'mechanika',
    title: 'Mechanika (placeholder)',
    description: 'Placeholder pro materiály od vyučujících — není oficiální kód předmětu VŠB.',
    iconEmoji: '⚙️',
    isPlaceholder: true,
  ),
  const Course(
    id: 'rizeni',
    title: 'Řízení a automatizace (placeholder)',
    description: 'Placeholder pro materiály od vyučujících — není oficiální kód předmětu VŠB.',
    iconEmoji: '🎛️',
    isPlaceholder: true,
  ),
  const Course(
    id: 'programovani',
    title: 'Programování / vestavěné systémy (placeholder)',
    description: 'Placeholder pro materiály od vyučujících — není oficiální kód předmětu VŠB.',
    iconEmoji: '💻',
    isPlaceholder: true,
  ),
];

Course? courseById(String id) {
  for (final c in allCourses) {
    if (c.id == id) return c;
  }
  return null;
}
