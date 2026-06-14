import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:emsile_flutter/app/emsile_app.dart';
import 'package:emsile_flutter/data/models.dart';
import 'package:emsile_flutter/features/conjugation/conjugation_screen.dart';
import 'package:emsile_flutter/features/practice/practice_screen.dart';

Future<void> pumpLoadedApp(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  await tester.pumpWidget(const EmsileApp());
  for (var i = 0; i < 20; i++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (find.text('Bugünkü Akış').evaluate().isNotEmpty) {
      return;
    }
  }
}

void main() {
  testWidgets('shows the Emsile home screen', (WidgetTester tester) async {
    await pumpLoadedApp(tester);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    expect(find.text('Emsile'), findsOneWidget);
    expect(find.text('Bugünkü Akış'), findsOneWidget);
    expect(find.text('نَصَرَ'), findsOneWidget);
  });

  testWidgets('renders the conjugation screen', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SafeArea(child: ConjugationScreen(data: testData)),
        ),
      ),
    );

    expect(find.text('Çekim Tablosu'), findsOneWidget);
    expect(find.text('Mâzi'), findsOneWidget);
    expect(find.text('Malum'), findsOneWidget);
  });

  testWidgets('renders practice at mobile width', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SafeArea(child: PracticeScreen(data: testData)),
        ),
      ),
    );

    expect(find.text('Formu gör, anlamı hatırla.'), findsOneWidget);
    expect(find.text('Yardım etti.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

const testData = AppData(
  lessons: [],
  forms: [
    ConjugationForm(
      category: FormCategory.mazi,
      voice: Voice.malum,
      pronounLabel: 'O',
      arabic: 'نَصَرَ',
      meaning: 'Yardım etti.',
      rule: '3. tekil müzekker mâzi malum temel formdur.',
    ),
  ],
  practiceQuestions: [
    PracticeQuestion(
      prompt: 'Bu formun anlamı hangisi?',
      arabic: 'نَصَرَ',
      options: ['Yardım etti.', 'Yardım ediyor.', 'Yardım edilen.'],
      answer: 'Yardım etti.',
      explanation: 'نَصَرَ fiil-i mâzi bina-i malumdur.',
    ),
  ],
);
