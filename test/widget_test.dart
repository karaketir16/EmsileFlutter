import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:emsile_flutter/app/emsile_app.dart';
import 'package:emsile_flutter/data/models.dart';
import 'package:emsile_flutter/features/conjugation/conjugation_screen.dart';
import 'package:emsile_flutter/features/home/home_screen.dart';
import 'package:emsile_flutter/features/lessons/lessons_screen.dart';
import 'package:emsile_flutter/features/practice/practice_screen.dart';
import 'package:emsile_flutter/features/source/source_screen.dart';

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

  // ── Navigation ─────────────────────────────────────────────────────────────
  // Drive the selected index from the test so we can verify screen mapping
  // without coupling to NavigationBar internals.

  Future<ValueNotifier<int>> pumpShell(WidgetTester tester) async {
    final indexNotifier = ValueNotifier<int>(0);
    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpWidget(
      MaterialApp(
        home: ValueListenableBuilder<int>(
          valueListenable: indexNotifier,
          builder: (context, index, _) => _IndexedAppShell(
            data: testData,
            selectedIndex: index,
            onSelect: (i) => indexNotifier.value = i,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return indexNotifier;
  }

  testWidgets('selected index 2 renders conjugation screen',
      (WidgetTester tester) async {
    final notifier = await pumpShell(tester);
    addTearDown(() {
      tester.binding.setSurfaceSize(null);
      notifier.dispose();
    });

    notifier.value = 2; // Tablo
    await tester.pumpAndSettle();

    expect(find.text('Çekim Tablosu'), findsOneWidget);
    expect(find.text('Mâzi'), findsOneWidget);
  });

  testWidgets('selected index 3 renders practice screen',
      (WidgetTester tester) async {
    final notifier = await pumpShell(tester);
    addTearDown(() {
      tester.binding.setSurfaceSize(null);
      notifier.dispose();
    });

    notifier.value = 3; // Pratik
    await tester.pumpAndSettle();

    expect(find.text('Formu gör, anlamı hatırla.'), findsOneWidget);
  });

  testWidgets('selected index 1 renders lessons screen',
      (WidgetTester tester) async {
    final notifier = await pumpShell(tester);
    addTearDown(() {
      tester.binding.setSurfaceSize(null);
      notifier.dispose();
    });

    notifier.value = 1; // Dersler
    await tester.pumpAndSettle();

    expect(find.text('Dersler'), findsWidgets);
  });

  testWidgets('selected index 4 renders source screen',
      (WidgetTester tester) async {
    final notifier = await pumpShell(tester);
    addTearDown(() {
      tester.binding.setSurfaceSize(null);
      notifier.dispose();
    });

    notifier.value = 4; // Kaynak
    await tester.pumpAndSettle();

    expect(find.textContaining('Zafer ESEN'), findsOneWidget);
  });

  // ── Conjugation interactions ────────────────────────────────────────────────

  testWidgets('conjugation: tapping Meçhul switches voice',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SafeArea(child: ConjugationScreen(data: richTestData)),
        ),
      ),
    );

    // Default is Malum — Meçhul form should not be visible yet.
    expect(find.text('نُصِرَ'), findsNothing);

    await tester.tap(find.text('Meçhul'));
    await tester.pumpAndSettle();

    // After switching, the Meçhul form should appear in both the result card
    // and the compact list — findsWidgets accepts one or more matches.
    expect(find.text('نُصِرَ'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('conjugation: tapping Muzâri switches category',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SafeArea(child: ConjugationScreen(data: richTestData)),
        ),
      ),
    );

    await tester.tap(find.text('Muzâri'));
    await tester.pumpAndSettle();

    expect(find.text('يَنْصُرُ'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('conjugation: tapping a pronoun chip updates result card',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SafeArea(child: ConjugationScreen(data: richTestData)),
        ),
      ),
    );

    // First chip ("O") is selected by default — tap the second one ("Sen").
    await tester.tap(find.widgetWithText(ChoiceChip, 'Sen'));
    await tester.pumpAndSettle();

    expect(find.text('نَصَرْتَ'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  // ── Practice interactions ───────────────────────────────────────────────────

  testWidgets('practice: tapping correct answer shows Doğru feedback',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SafeArea(child: PracticeScreen(data: testData)),
        ),
      ),
    );

    // Tap the correct answer.
    await tester.tap(find.text('Yardım etti.'));
    await tester.pumpAndSettle();

    expect(find.text('Doğru'), findsOneWidget);
    expect(find.text('Sonraki Soru'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('practice: tapping wrong answer shows Tekrar Bak feedback',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SafeArea(child: PracticeScreen(data: testData)),
        ),
      ),
    );

    // Tap a wrong answer.
    await tester.tap(find.text('Yardım ediyor.'));
    await tester.pumpAndSettle();

    expect(find.text('Tekrar Bak'), findsOneWidget);
    expect(find.text('Sonraki Soru'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('practice: Sonraki Soru advances to the next question',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SafeArea(child: PracticeScreen(data: multiQuestionData)),
        ),
      ),
    );

    // Answer the first question.
    await tester.tap(find.text('Yardım etti.'));
    await tester.pumpAndSettle();

    expect(find.text('1/2'), findsOneWidget);

    // Advance to the next question.
    await tester.tap(find.text('Sonraki Soru'));
    await tester.pumpAndSettle();

    expect(find.text('2/2'), findsOneWidget);
    // Feedback panel is gone for the new question.
    expect(find.text('Doğru'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

// ── Shared test data ──────────────────────────────────────────────────────────

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

/// Richer dataset for interaction tests that need multiple forms.
const richTestData = AppData(
  lessons: [],
  forms: [
    ConjugationForm(
      category: FormCategory.mazi,
      voice: Voice.malum,
      pronounLabel: 'O',
      arabic: 'نَصَرَ',
      meaning: 'Yardım etti.',
      rule: 'Mâzi malum 3. tekil müzekker.',
    ),
    ConjugationForm(
      category: FormCategory.mazi,
      voice: Voice.malum,
      pronounLabel: 'Sen',
      arabic: 'نَصَرْتَ',
      meaning: 'Yardım ettin.',
      rule: 'Mâzi malum 2. tekil müzekker.',
    ),
    ConjugationForm(
      category: FormCategory.mazi,
      voice: Voice.mechul,
      pronounLabel: 'O',
      arabic: 'نُصِرَ',
      meaning: 'Yardım edildi.',
      rule: 'Mâzi meçhul 3. tekil müzekker.',
    ),
    ConjugationForm(
      category: FormCategory.muzari,
      voice: Voice.malum,
      pronounLabel: 'O',
      arabic: 'يَنْصُرُ',
      meaning: 'Yardım ediyor.',
      rule: 'Muzâri malum 3. tekil müzekker.',
    ),
  ],
  practiceQuestions: [],
);

/// Two-question dataset for the "Sonraki Soru" advance test.
const multiQuestionData = AppData(
  lessons: [],
  forms: [],
  practiceQuestions: [
    PracticeQuestion(
      prompt: 'Bu formun anlamı hangisi?',
      arabic: 'نَصَرَ',
      options: ['Yardım etti.', 'Yardım ediyor.', 'Yardım edilen.'],
      answer: 'Yardım etti.',
      explanation: 'نَصَرَ fiil-i mâzi bina-i malumdur.',
    ),
    PracticeQuestion(
      prompt: 'Bu form hangi zamana aittir?',
      arabic: 'يَنْصُرُ',
      options: ['Geçmiş', 'Şimdiki/Gelecek', 'Emir'],
      answer: 'Şimdiki/Gelecek',
      explanation: 'يَنْصُرُ fiil-i muzâridir.',
    ),
  ],
);

// ── Test helpers ──────────────────────────────────────────────────────────────

/// Mirrors AppShell screen selection while allowing tests to drive the index
/// directly without relying on NavigationBar internals.
class _IndexedAppShell extends StatelessWidget {
  const _IndexedAppShell({
    required this.data,
    required this.selectedIndex,
    required this.onSelect,
  });

  final AppData data;
  final int selectedIndex;
  final void Function(int) onSelect;

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(data: data),
      LessonsScreen(data: data),
      ConjugationScreen(data: data),
      PracticeScreen(data: data),
      const SourceScreen(),
    ];

    return Scaffold(
      body: SafeArea(child: screens[selectedIndex]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onSelect,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Ana',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Dersler',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view),
            label: 'Tablo',
          ),
          NavigationDestination(
            icon: Icon(Icons.quiz_outlined),
            selectedIcon: Icon(Icons.quiz),
            label: 'Pratik',
          ),
          NavigationDestination(
            icon: Icon(Icons.info_outline),
            selectedIcon: Icon(Icons.info),
            label: 'Kaynak',
          ),
        ],
      ),
    );
  }
}
