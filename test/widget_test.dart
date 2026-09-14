import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mechalearn_vsb/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('onboarding shows MechaLearn', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      const ProviderScope(child: MechaLearnApp()),
    );
    await tester.pumpAndSettle();
    expect(find.text('MechaLearn'), findsWidgets);
    expect(find.textContaining('denní cíl'), findsOneWidget);
  });
}
