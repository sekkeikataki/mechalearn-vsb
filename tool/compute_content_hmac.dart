import 'package:mechalearn_vsb/data/content_manifest.dart';
import 'package:mechalearn_vsb/data/courses.dart';
import 'package:mechalearn_vsb/services/content_integrity.dart';

void main() {
  final hex = ContentIntegrity.computeHmacHex(allCourses);
  final payload = ContentIntegrity.signedPayload(allCourses);
  final body = payload.split('\n').skip(1).join('\n');
  final lines = body.isEmpty ? 0 : body.split('\n').length;
  print('content_version=${ContentManifest.contentVersion}');
  print('lines=$lines');
  print('hmac=$hex');
}
