import 'package:flutter_test/flutter_test.dart';
import 'package:resolve_file_converter/app/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('app shell renders tool path section', (tester) async {
    SharedPreferences.setMockInitialValues(const {});

    await tester.pumpWidget(const ResolveMediaConverterApp());
    await tester.pumpAndSettle();

    expect(find.text('Resolve Media Converter'), findsWidgets);
    expect(find.text('Tool paths'), findsOneWidget);
    expect(find.text('FFmpeg'), findsOneWidget);
    expect(find.text('FFprobe'), findsOneWidget);
  });
}
