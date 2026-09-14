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
    title: 'Fyzika',
    description: 'Materiály od vyučujících — připraveno jako prázdný kurz.',
    iconEmoji: '⚛️',
    isPlaceholder: true,
  ),
  const Course(
    id: 'elektronika',
    title: 'Elektronika',
    description: 'Materiály od vyučujících — připraveno jako prázdný kurz.',
    iconEmoji: '🔌',
    isPlaceholder: true,
  ),
  const Course(
    id: 'mechanika',
    title: 'Mechanika',
    description: 'Materiály od vyučujících — připraveno jako prázdný kurz.',
    iconEmoji: '⚙️',
    isPlaceholder: true,
  ),
  const Course(
    id: 'rizeni',
    title: 'Řízení a automatizace',
    description: 'Materiály od vyučujících — připraveno jako prázdný kurz.',
    iconEmoji: '🎛️',
    isPlaceholder: true,
  ),
  const Course(
    id: 'programovani',
    title: 'Programování / vestavěné systémy',
    description: 'Materiály od vyučujících — připraveno jako prázdný kurz.',
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
