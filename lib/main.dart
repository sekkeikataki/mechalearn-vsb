import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'data/courses.dart';
import 'services/content_integrity.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Maths / content pack load path: tampered pack → refuse start.
  ContentIntegrity.loadVerifiedCourses(allCourses);
  runApp(const ProviderScope(child: MechaLearnApp()));
}
