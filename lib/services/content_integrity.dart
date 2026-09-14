import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../data/content_manifest.dart';
import '../data/content_secret.dart';
import '../models/course.dart';
import '../models/exercise.dart';

/// Výjimka při selhání integrity content packu.
class ContentIntegrityException implements Exception {
  ContentIntegrityException([
    this.message = 'Kontrola integrity obsahu selhala',
  ]);

  final String message;

  @override
  String toString() => message;
}

/// HMAC-SHA256 kontrola vestavěného kurikula (Architect PATCH v1.1).
///
/// Pack musí mít [ContentManifest.contentVersion] a HMAC přes id/odpovědi.
/// Tampered pack → [verifyOrThrow] / [loadVerifiedCourses] odmítne načtení.
class ContentIntegrity {
  ContentIntegrity._();

  /// Jedna řádka kanonického payloadu pro cvičení.
  static String exerciseCanonicalLine({
    required String courseId,
    required String unitId,
    required String lessonId,
    required Exercise exercise,
  }) {
    final parts = <String>[
      courseId,
      unitId,
      lessonId,
      exercise.id,
      exercise.type.name,
      _fmtNum(exercise.numericAnswer),
      exercise.correctIndex?.toString() ?? '',
      exercise.trueFalseAnswer?.toString() ?? '',
      exercise.correctOrder?.join(',') ?? '',
    ];

    if (exercise.type == ExerciseType.multiStep && exercise.steps != null) {
      for (final step in exercise.steps!) {
        parts.add(_fmtNum(step.numericAnswer));
        parts.add(step.correctIndex?.toString() ?? '');
      }
    }

    return parts.join('|');
  }

  static String _fmtNum(double? v) {
    if (v == null) return '';
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toString();
  }

  /// Seřazený kanonický text všech cvičení napříč kurzy.
  static String canonicalPayload(List<Course> courses) {
    final entries = <({String c, String u, String l, String e, String line})>[];

    for (final course in courses) {
      for (final unit in course.units) {
        for (final lesson in unit.lessons) {
          for (final exercise in lesson.exercises) {
            final line = exerciseCanonicalLine(
              courseId: course.id,
              unitId: unit.id,
              lessonId: lesson.id,
              exercise: exercise,
            );
            entries.add((
              c: course.id,
              u: unit.id,
              l: lesson.id,
              e: exercise.id,
              line: line,
            ));
          }
        }
      }
    }

    entries.sort((a, b) {
      final c = a.c.compareTo(b.c);
      if (c != 0) return c;
      final u = a.u.compareTo(b.u);
      if (u != 0) return u;
      final l = a.l.compareTo(b.l);
      if (l != 0) return l;
      return a.e.compareTo(b.e);
    });

    return entries.map((e) => e.line).join('\n');
  }

  /// Payload včetně content_version (součást integrity kontraktu).
  static String signedPayload(
    List<Course> courses, {
    String? contentVersion,
  }) {
    final ver = contentVersion ?? ContentManifest.contentVersion;
    return 'content_version=$ver\n${canonicalPayload(courses)}';
  }

  /// HMAC-SHA256 hex over UTF-8 of [signedPayload].
  static String computeHmacHex(
    List<Course> courses, {
    String? contentVersion,
  }) {
    final payload = signedPayload(courses, contentVersion: contentVersion);
    final hmac = Hmac(sha256, utf8.encode(contentHmacSecret));
    return hmac.convert(utf8.encode(payload)).toString();
  }

  /// True if recomputed HMAC matches [ContentManifest.contentHmacHex].
  static bool verify(List<Course> courses) {
    if (ContentManifest.contentVersion.isEmpty) return false;
    if (ContentManifest.contentHmacHex.isEmpty ||
        ContentManifest.contentHmacHex.startsWith('PLACEHOLDER')) {
      return false;
    }
    return computeHmacHex(courses) == ContentManifest.contentHmacHex;
  }

  /// Ověří HMAC; při neshodě hodí [ContentIntegrityException].
  static void verifyOrThrow(List<Course> courses) {
    if (!verify(courses)) {
      throw ContentIntegrityException(
        'Kontrola integrity obsahu selhala '
        '(content_version=${ContentManifest.contentVersion})',
      );
    }
  }

  /// Maths data load path: ověřený katalog, nebo refuse (prázdný seznam + throw).
  static List<Course> loadVerifiedCourses(List<Course> courses) {
    verifyOrThrow(courses);
    return courses;
  }
}
