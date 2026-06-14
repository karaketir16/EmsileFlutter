import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:emsile_flutter/app/emsile_app.dart';
import 'package:emsile_flutter/data/models.dart';
import 'package:emsile_flutter/features/conjugation/conjugation_screen.dart';
import 'package:emsile_flutter/features/home/home_screen.dart';
import 'package:emsile_flutter/features/lessons/lessons_screen.dart';
import 'package:emsile_flutter/features/practice/practice_screen.dart';
import 'package:emsile_flutter/features/source/source_screen.dart';
import 'package:emsile_flutter/shared/widgets/arabic_result_card.dart';

Future<void> pumpLoadedApp(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  await tester.pumpWidget(const EmsileApp());
  for (var i = 0; i < 60; i++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (find.text('Bugünkü Akış').evaluate().isNotEmpty) {
      return;
    }
    if (find.textContaining('Veri yüklenemedi').evaluate().isNotEmpty) {
      final errorText =
          tester.widget<Text>(find.textContaining('Veri yüklenemedi')).data ??
          'Veri yüklenemedi';
      throw TestFailure(errorText);
    }
  }
  throw TestFailure('AppData did not finish loading in widget test.');
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
    expect(find.text('Çoğul'), findsWidgets);
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

  testWidgets('selected index 2 renders conjugation screen', (
    WidgetTester tester,
  ) async {
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

  testWidgets('selected index 3 renders practice screen', (
    WidgetTester tester,
  ) async {
    final notifier = await pumpShell(tester);
    addTearDown(() {
      tester.binding.setSurfaceSize(null);
      notifier.dispose();
    });

    notifier.value = 3; // Pratik
    await tester.pumpAndSettle();

    expect(find.text('Formu gör, anlamı hatırla.'), findsOneWidget);
  });

  testWidgets('selected index 1 renders lessons screen', (
    WidgetTester tester,
  ) async {
    final notifier = await pumpShell(tester);
    addTearDown(() {
      tester.binding.setSurfaceSize(null);
      notifier.dispose();
    });

    notifier.value = 1; // Dersler
    await tester.pumpAndSettle();

    expect(find.text('Dersler'), findsWidgets);
  });

  testWidgets('lesson detail renders muhtelife table entries', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SafeArea(
            child: LessonDetailScreen(
              lesson: muhtelifeLesson,
              data: muhtelifeTestData,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Muhtelife Tablosu'), findsOneWidget);
    expect(find.text('İsm-i Fâil'), findsOneWidget);
    expect(find.text('نَاصِرٌ'), findsOneWidget);
    expect(find.text('Fiil-i Mâzi'), findsOneWidget);
    expect(find.text('نَصَرَ'), findsOneWidget);
  });

  testWidgets('selected index 4 renders source screen', (
    WidgetTester tester,
  ) async {
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

  testWidgets('conjugation: tapping Meçhul switches voice', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SafeArea(child: ConjugationScreen(data: richTestData)),
        ),
      ),
    );

    await tester.tap(find.text('Meçhul'));
    await tester.pumpAndSettle();

    // After switching, the Meçhul form should appear in both the result card
    // and the compact list — findsWidgets accepts one or more matches.
    expect(find.text('نُصِرَ'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('conjugation: tapping Muzâri switches category', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SafeArea(child: ConjugationScreen(data: richTestData)),
        ),
      ),
    );

    await selectConjugationCategory(tester, 'Muzâri');

    expect(find.text('يَنْصُرُ'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('conjugation: tapping a pronoun cell updates result card', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SafeArea(child: ConjugationScreen(data: richTestData)),
        ),
      ),
    );

    await tester.ensureVisible(find.text('Sen (er.)'));
    await tester.tap(find.text('Sen (er.)'));
    await tester.pumpAndSettle();

    expect(find.text('نَصَرْتَ'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('conjugation: tapping a form cell updates result card', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SafeArea(child: ConjugationScreen(data: richTestData)),
        ),
      ),
    );

    await tester.ensureVisible(find.text('نَصَرْتَ').first);
    await tester.tap(find.text('نَصَرْتَ').first);
    await tester.pumpAndSettle();

    expect(find.text('Sen (er.)'), findsWidgets);
    expect(find.text('نَصَرْتَ'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'conjugation: selected person is preserved when switching voice',
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

      await tester.ensureVisible(find.text('Sen (er.)'));
      await tester.tap(find.text('Sen (er.)'));
      await tester.pumpAndSettle();
      expect(find.text('نَصَرْتَ'), findsWidgets);

      await tester.ensureVisible(find.text('Meçhul'));
      await tester.tap(find.text('Meçhul'));
      await tester.pumpAndSettle();

      expect(find.text('نُصِرْتَ'), findsWidgets);
      expect(find.text('Sen (er.)'), findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'conjugation: selected person is preserved when switching category',
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

      await tester.ensureVisible(find.text('Sen (er.)'));
      await tester.tap(find.text('Sen (er.)'));
      await tester.pumpAndSettle();
      expect(find.text('نَصَرْتَ'), findsWidgets);

      await selectConjugationCategory(tester, 'Muzâri');

      expect(find.text('تَنْصُرُ'), findsWidgets);
      expect(find.text('Sen (er.)'), findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('conjugation: top controls stay fixed while tables scroll', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SafeArea(child: ConjugationScreen(data: richTestData)),
        ),
      ),
    );

    final beforeTop = tester.getTopLeft(find.byType(ArabicResultCard)).dy;

    await tester.drag(
      find.byType(SingleChildScrollView).first,
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();

    final afterTop = tester.getTopLeft(find.byType(ArabicResultCard)).dy;

    expect(afterTop, beforeTop);
    expect(find.text('Tüm Fiil Muttaride Tabloları'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'conjugation: selection coloring is only applied to the active table',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(500, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeArea(child: ConjugationScreen(data: richTestData)),
          ),
        ),
      );

      // Başlangıçta Mazi Malum aktiftir.
      // 'نَصَرَ' (Mazi Malum Hüve) hücresini saran Container'ın Container rengini bulalım.
      // testData içinde birden fazla 'نَصَرَ' ve 'يَنْصُرُ' olabilir (hem Seçili Tablo hem de Tüm Tablolar altında).
      // Seçili Tablo altındaki 'نَصَرَ' aktif olmalı.
      // Tüm Tablolar altındaki 'يَنْصُرُ' (Muzari Malum) ise o an aktif olmadığı için boyanmamalı.

      // Seçili tek bir hücre olmalı (Seçili Tablo altındaki Hüve hücresi).
      // Şahıs Tablosunda ise pronounLabel olan hücre seçilidir (primaryContainer ile).
      // FormsTable içinde sadece bir hücre boyanmalıdır (Mazi Malum Hüve).
      // Eğer düzeltmemiz çalışıyorsa, Tüm Tablolar altındaki diğer pasif tabloların (Muzari Malum gibi) Hüve hücresi boyanmamıştır.
      // Testi doğrudan text üzerinden veya widget ağacından doğrulayalım:
      
      expect(find.text('نَصَرَ'), findsAtLeastNWidgets(1));
      
      // Tüm Tablolar altındaki 'يَنْصُرُ' (Muzari Malum Hüve) hücresinin (o an Mazi aktifken) 
      // arka planının boyanmadığını doğrula.
      final yansuruContainerFinder = find.ancestor(
        of: find.text('يَنْصُرُ'),
        matching: find.byType(Container),
      );

      // yansuruContainer'lardan hiçbirinin arka planı primaryContainer olmamalı (yani decoration.color null olmalı)
      final contexts = tester.elementList(yansuruContainerFinder);
      for (final element in contexts) {
        final container = element.widget as Container;
        if (container.decoration is BoxDecoration) {
          final deco = container.decoration as BoxDecoration;
          // Eğer boyanmış olsaydı null olmazdı
          expect(deco.color, isNull);
        }
      }
      
      // Tüm testler geçmeli
      expect(tester.takeException(), isNull);
    },
  );

  // ── Practice interactions ───────────────────────────────────────────────────

  testWidgets('practice: tapping correct answer shows Doğru feedback', (
    WidgetTester tester,
  ) async {
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

  testWidgets('practice: tapping wrong answer shows Tekrar Bak feedback', (
    WidgetTester tester,
  ) async {
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

  testWidgets('practice: Sonraki Soru advances to the next question', (
    WidgetTester tester,
  ) async {
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

Future<void> selectConjugationCategory(
  WidgetTester tester,
  String categoryLabel,
) async {
  final dropdown = find.byType(DropdownButtonFormField<FormCategory>);
  await tester.ensureVisible(dropdown);
  await tester.tap(dropdown);
  await tester.pumpAndSettle();
  await tester.tap(find.text(categoryLabel).last);
  await tester.pumpAndSettle();
}

// ── Shared test data ──────────────────────────────────────────────────────────

const testData = AppData(
  lessons: [],
  muhtelifeEntries: [],
  forms: [
    ConjugationForm(
      category: FormCategory.mazi,
      voice: Voice.malum,
      person: FormPerson.third,
      number: FormNumber.singular,
      gender: FormGender.masculine,
      pronounLabel: 'O (er.)',
      arabic: 'نَصَرَ',
      meaning: 'Yardım etti.',
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
  muhtelifeEntries: [],
  forms: [
    ConjugationForm(
      category: FormCategory.mazi,
      voice: Voice.malum,
      person: FormPerson.third,
      number: FormNumber.singular,
      gender: FormGender.masculine,
      pronounLabel: 'O (er.)',
      arabic: 'نَصَرَ',
      meaning: 'Yardım etti.',
    ),
    ConjugationForm(
      category: FormCategory.mazi,
      voice: Voice.malum,
      person: FormPerson.second,
      number: FormNumber.singular,
      gender: FormGender.masculine,
      pronounLabel: 'Sen (er.)',
      arabic: 'نَصَرْتَ',
      meaning: 'Yardım ettin.',
    ),
    ConjugationForm(
      category: FormCategory.mazi,
      voice: Voice.mechul,
      person: FormPerson.third,
      number: FormNumber.singular,
      gender: FormGender.masculine,
      pronounLabel: 'O (er.)',
      arabic: 'نُصِرَ',
      meaning: 'Yardım edildi.',
    ),
    ConjugationForm(
      category: FormCategory.mazi,
      voice: Voice.mechul,
      person: FormPerson.second,
      number: FormNumber.singular,
      gender: FormGender.masculine,
      pronounLabel: 'Sen (er.)',
      arabic: 'نُصِرْتَ',
      meaning: 'Yardım edildin.',
    ),
    ConjugationForm(
      category: FormCategory.muzari,
      voice: Voice.malum,
      person: FormPerson.third,
      number: FormNumber.singular,
      gender: FormGender.masculine,
      pronounLabel: 'O (er.)',
      arabic: 'يَنْصُرُ',
      meaning: 'Yardım ediyor.',
    ),
    ConjugationForm(
      category: FormCategory.muzari,
      voice: Voice.malum,
      person: FormPerson.second,
      number: FormNumber.singular,
      gender: FormGender.masculine,
      pronounLabel: 'Sen (er.)',
      arabic: 'تَنْصُرُ',
      meaning: 'Yardım ediyorsun.',
    ),
  ],
  practiceQuestions: [],
);

/// Two-question dataset for the "Sonraki Soru" advance test.
const multiQuestionData = AppData(
  lessons: [],
  muhtelifeEntries: [],
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

const muhtelifeLesson = Lesson(
  order: 1,
  title: 'Emsile-i Muhtelife',
  summary: 'Muhtelife kaliplari',
  rule: 'Bu derste PDF tablosundaki farkli kaliplar izlenir.',
  relatedCategory: FormCategory.mazi,
);

const muhtelifeTestData = AppData(
  lessons: [muhtelifeLesson],
  muhtelifeEntries: [
    MuhtelifeEntry(
      type: 'ism_fail',
      label: 'İsm-i Fâil',
      arabic: 'نَاصِرٌ',
      meaning: 'Yardım eden.',
      sortOrder: 10,
      row: 1,
      column: 'left',
    ),
    MuhtelifeEntry(
      type: 'masdar',
      label: 'Masdar-ı Gayr-ı Mîmî',
      arabic: 'نَصْرًا',
      meaning: 'Yardım etmek.',
      sortOrder: 20,
      row: 1,
      column: 'right',
    ),
    MuhtelifeEntry(
      type: 'fiil_muzari',
      label: 'Fiil-i Muzâri',
      arabic: 'يَنْصُرُ',
      meaning: 'Yardım ediyor.',
      sortOrder: 30,
      row: 2,
      column: 'left',
    ),
    MuhtelifeEntry(
      type: 'fiil_mazi',
      label: 'Fiil-i Mâzi',
      arabic: 'نَصَرَ',
      meaning: 'Yardım etti.',
      sortOrder: 40,
      row: 2,
      column: 'right',
    ),
  ],
  forms: [],
  practiceQuestions: [],
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
