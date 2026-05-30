import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:daily_task_app/app.dart';
import 'package:daily_task_app/providers/task_provider.dart';
import 'package:daily_task_app/providers/user_provider.dart';
import 'package:daily_task_app/providers/focus_provider.dart';
import 'package:daily_task_app/providers/theme_provider.dart';

void main() {
  testWidgets('App should render without errors', (WidgetTester tester) async {
    final themeProvider = ThemeProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => TaskProvider()),
          ChangeNotifierProvider(create: (_) => UserProvider()),
          ChangeNotifierProvider(create: (_) => FocusProvider()),
          ChangeNotifierProvider.value(value: themeProvider),
        ],
        child: DailyTaskApp(themeProvider: themeProvider),
      ),
    );

    // Verify the app renders with bottom navigation
    expect(find.text('首页'), findsOneWidget);
    expect(find.text('统计'), findsOneWidget);
    expect(find.text('专注'), findsOneWidget);
    expect(find.text('我的'), findsOneWidget);
  });
}
