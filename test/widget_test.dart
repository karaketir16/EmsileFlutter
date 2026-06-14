import 'dart:math';
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
    expect(find.text('Fiil-i Mâzi'), findsOneWidget);
    expect(find.text('Malum'), findsOneWidget);
    expect(find.text('Çoğul'), findsWidgets);
  });

  testWidgets('renders practice at mobile width', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SafeArea(child: PracticeScreen(data: testData, random: Random(1))),
        ),
      ),
    );

    expect(find.text('Pratik Ayarları'), findsOneWidget);
    await startPractice(tester);

    expect(find.text('Pratik'), findsOneWidget);
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
    expect(find.text('Fiil-i Mâzi'), findsOneWidget);
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

    expect(find.text('Pratik Ayarları'), findsOneWidget);
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

    expect(find.textContaining('arapcadiyari.blogspot.com'), findsOneWidget);
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

    await selectConjugationCategory(tester, 'Fiil-i Muzâri');

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

      await selectConjugationCategory(tester, 'Fiil-i Muzâri');

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
    expect(find.text('Tüm Muttaride Tabloları'), findsOneWidget);
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
      MaterialApp(
        home: Scaffold(
          body: SafeArea(child: PracticeScreen(data: testData, random: Random(1))),
        ),
      ),
    );

    await startPractice(tester);

    final promptFinder = find.byWidgetPredicate((w) => w is Text && w.data != null && w.data!.contains('?'));
    final promptText = (tester.widget(promptFinder.first) as Text).data!;
    
    String correctAnswer = '';
    if (promptText.contains('anlamı hangisi')) {
      final arabicText = (tester.widget(find.byWidgetPredicate((w) => w is Text && w.data != '?' && w.data!.runes.any((r) => r > 1000)).first) as Text).data!;
      final matchedForm = testFormsList.firstWhere((f) => f.arabic == arabicText);
      correctAnswer = matchedForm.meaning;
    } else if (promptText.contains('şahsa aittir')) {
      final arabicText = (tester.widget(find.byWidgetPredicate((w) => w is Text && w.data != '?' && w.data!.runes.any((r) => r > 1000)).first) as Text).data!;
      final matchedForm = testFormsList.firstWhere((f) => f.arabic == arabicText);
      correctAnswer = matchedForm.pronounLabel;
    } else {
      final meaning = promptText.split('"')[1];
      final matchedForm = testFormsList.firstWhere((f) => f.meaning == meaning);
      correctAnswer = matchedForm.arabic;
    }

    await tester.tap(find.text(correctAnswer));
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
      MaterialApp(
        home: Scaffold(
          body: SafeArea(child: PracticeScreen(data: testData, random: Random(1))),
        ),
      ),
    );

    await startPractice(tester);

    final promptFinder = find.byWidgetPredicate((w) => w is Text && w.data != null && w.data!.contains('?'));
    final promptText = (tester.widget(promptFinder.first) as Text).data!;
    
    String correctAnswer = '';
    if (promptText.contains('anlamı hangisi')) {
      final arabicText = (tester.widget(find.byWidgetPredicate((w) => w is Text && w.data != '?' && w.data!.runes.any((r) => r > 1000)).first) as Text).data!;
      final matchedForm = testFormsList.firstWhere((f) => f.arabic == arabicText);
      correctAnswer = matchedForm.meaning;
    } else if (promptText.contains('şahsa aittir')) {
      final arabicText = (tester.widget(find.byWidgetPredicate((w) => w is Text && w.data != '?' && w.data!.runes.any((r) => r > 1000)).first) as Text).data!;
      final matchedForm = testFormsList.firstWhere((f) => f.arabic == arabicText);
      correctAnswer = matchedForm.pronounLabel;
    } else {
      final meaning = promptText.split('"')[1];
      final matchedForm = testFormsList.firstWhere((f) => f.meaning == meaning);
      correctAnswer = matchedForm.arabic;
    }

    final wrongOptionFinder = find.byWidgetPredicate((widget) {
      return widget is InkWell &&
          widget.child is Container &&
          find.descendant(
            of: find.byWidget(widget),
            matching: find.text(correctAnswer),
          ).evaluate().isEmpty;
    });

    await tester.tap(wrongOptionFinder.first);
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
      MaterialApp(
        home: Scaffold(
          body: SafeArea(child: PracticeScreen(data: multiQuestionData, random: Random(1))),
        ),
      ),
    );

    await startPractice(tester);

    // İlk sorunun doğru cevabını bulalım
    final promptFinder = find.byWidgetPredicate((w) => w is Text && w.data != null && w.data!.contains('?'));
    final firstPromptText = (tester.widget(promptFinder.first) as Text).data!;
    
    String firstCorrectAnswer = '';
    if (firstPromptText.contains('anlamı hangisi')) {
      final arabicText = (tester.widget(find.byWidgetPredicate((w) => w is Text && w.data != '?' && w.data!.runes.any((r) => r > 1000)).first) as Text).data!;
      final matchedForm = testFormsList.firstWhere((f) => f.arabic == arabicText);
      firstCorrectAnswer = matchedForm.meaning;
    } else if (firstPromptText.contains('şahsa aittir')) {
      final arabicText = (tester.widget(find.byWidgetPredicate((w) => w is Text && w.data != '?' && w.data!.runes.any((r) => r > 1000)).first) as Text).data!;
      final matchedForm = testFormsList.firstWhere((f) => f.arabic == arabicText);
      firstCorrectAnswer = matchedForm.pronounLabel;
    } else {
      final meaning = firstPromptText.split('"')[1];
      final matchedForm = testFormsList.firstWhere((f) => f.meaning == meaning);
      firstCorrectAnswer = matchedForm.arabic;
    }

    await tester.tap(find.text(firstCorrectAnswer));
    await tester.pumpAndSettle();

    expect(find.text('Doğru'), findsOneWidget);

    // Sonraki soruya geçelim.
    await tester.tap(find.text('Sonraki Soru'));
    await tester.pumpAndSettle();
    expect(find.text('Doğru'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('practice: setup view allows filtering and disables button when matching < 5', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(500, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SafeArea(child: PracticeScreen(data: testData, random: Random(1))),
        ),
      ),
    );

    // Başlangıçta 6 form eşleştiği için canStart true olmalı
    expect(find.text('Eşleşen Form Sayısı:'), findsOneWidget);
    expect(find.text('6'), findsOneWidget);
    expect(tester.widget<FilledButton>(find.byType(FilledButton)).enabled, isTrue);

    // Çekim Tablolarını temizle diyelim -> Eşleşen 0 olur, buton kilitlenir
    await tester.tap(find.descendant(
      of: find.byType(Row),
      matching: find.text('Temizle'),
    ).first);
    await tester.pumpAndSettle();

    expect(find.text('0'), findsOneWidget);
    expect(tester.widget<FilledButton>(find.byType(FilledButton)).enabled, isFalse);
    expect(find.text('Soru üretilebilmesi için en az 5 farklı çekim formu eşleşmelidir. Lütfen seçimlerinizi artırın.'), findsOneWidget);
  });

  testWidgets(
    'practice: clicking column headers and row labels toggles selection groups',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(500, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeArea(child: PracticeScreen(data: testData, random: Random(1))),
          ),
        ),
      );

      // Verify column deselect/select via 'Tekil' header
      await tester.ensureVisible(find.text('Tekil').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tekil').first);
      await tester.pumpAndSettle();
      expect(find.text('0'), findsOneWidget);

      await tester.ensureVisible(find.text('Tekil').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tekil').first);
      await tester.pumpAndSettle();
      expect(find.text('6'), findsOneWidget);

      // Verify row deselect/select via '3. Şh. Müzekker\n(Gâib)' label
      await tester.ensureVisible(find.text('3. Şh. Müzekker\n(Gâib)'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('3. Şh. Müzekker\n(Gâib)'));
      await tester.pumpAndSettle();
      expect(find.text('3'), findsOneWidget);
    },
  );

  testWidgets(
    'conjugation: noun category hides voice selector and handles table/chip clicks',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeArea(child: ConjugationScreen(data: nounTestData)),
          ),
        ),
      );

      // Select 'İsm-i Fâil' from the dropdown
      await selectConjugationCategory(tester, 'İsm-i Fâil');

      // Voice segmented button (Malum/Meçhul) must NOT be present for nouns
      expect(find.text('Malum'), findsNothing);
      expect(find.text('Meçhul'), findsNothing);

      // Table headers should be present
      expect(find.text('Tekil'), findsWidgets);
      expect(find.text('İkil'), findsWidgets);
      expect(find.text('Çoğul'), findsWidgets);
      expect(find.text('Müzekker'), findsWidgets);
      expect(find.text('Müennes'), findsWidgets);

      // Tap on the singular feminine cell ('نَاصِرَةٌ')
      await tester.tap(find.text('نَاصِرَةٌ').first);
      await tester.pumpAndSettle();

      // ArabicResultCard should display the selected word and rule details
      expect(find.text('نَاصِرَةٌ'), findsWidgets);
      expect(find.textContaining('müennes tekil İsm-i Fâil formudur.'), findsWidgets);

      // Broken plural chip 'نُصَّارٌ' should be visible at the bottom
      expect(find.text('نُصَّارٌ'), findsWidgets);

      // Scroll to the broken plural chip
      await tester.ensureVisible(find.text('نُصَّارٌ').last);
      await tester.pumpAndSettle();

      // Tap on the broken plural chip
      await tester.tap(find.text('نُصَّارٌ').last);
      await tester.pumpAndSettle();

      // Result card should update to 'نُصَّارٌ'
      expect(find.text('نُصَّارٌ'), findsWidgets);
      expect(find.textContaining('müzekker çoğul İsm-i Fâil formudur.'), findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'practice: setup view lists noun categories and starts practice for nouns',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(500, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeArea(child: PracticeScreen(data: nounTestData, random: Random(1))),
          ),
        ),
      );

      // Initially, ismFail is selected by default in filters, and we have 7 forms matching.
      expect(find.text('7'), findsOneWidget);
      expect(tester.widget<FilledButton>(find.byType(FilledButton)).enabled, isTrue);

      // Clear all categories
      await tester.tap(find.descendant(
        of: find.byType(Row),
        matching: find.text('Temizle').first,
      ).first);
      await tester.pumpAndSettle();

      expect(find.text('0'), findsOneWidget);
      expect(tester.widget<FilledButton>(find.byType(FilledButton)).enabled, isFalse);

      // Tap on the 'İsm-i Fâil' chip to select it again
      await tester.tap(find.text('İsm-i Fâil'));
      await tester.pumpAndSettle();

      expect(find.text('7'), findsOneWidget);
      expect(tester.widget<FilledButton>(find.byType(FilledButton)).enabled, isTrue);

      // Start the practice
      await startPractice(tester);

      // Confirm we transition to the Practice view
      expect(find.text('Pratik'), findsOneWidget);

      // Check for prompt
      final promptFinder = find.byWidgetPredicate((w) => w is Text && w.data != null && w.data!.contains('?'));
      expect(promptFinder, findsOneWidget);

      final promptText = (tester.widget(promptFinder.first) as Text).data!;
      
      String correctAnswer = '';
      if (promptText.contains('anlamı hangisi')) {
        final arabicText = (tester.widget(find.byWidgetPredicate((w) => w is Text && w.data != '?' && w.data!.runes.any((r) => r > 1000)).first) as Text).data!;
        final matchedForm = nounTestFormsList.firstWhere((f) => f.arabic == arabicText);
        correctAnswer = matchedForm.meaning;
      } else if (promptText.contains('dil bilgisi özelliği')) {
        final arabicText = (tester.widget(find.byWidgetPredicate((w) => w is Text && w.data != '?' && w.data!.runes.any((r) => r > 1000)).first) as Text).data!;
        final matchedForm = nounTestFormsList.firstWhere((f) => f.arabic == arabicText);
        correctAnswer = matchedForm.pronounLabel;
      } else {
        final meaning = promptText.split('"')[1];
        final matchedForm = nounTestFormsList.firstWhere((f) => f.meaning == meaning);
        correctAnswer = matchedForm.arabic;
      }

      await tester.tap(find.text(correctAnswer));
      await tester.pumpAndSettle();

      expect(find.text('Doğru'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
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

Future<void> startPractice(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Pratiğe Başla'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Pratiğe Başla'));
  await tester.pumpAndSettle();
}

// ── Shared test data ──────────────────────────────────────────────────────────

const testFormsList = [
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
];

const testData = AppData(
  lessons: [],
  muhtelifeEntries: [],
  forms: testFormsList,
  practiceQuestions: [],
);

const nounTestFormsList = [
  ConjugationForm(
    category: FormCategory.ismFail,
    voice: Voice.malum,
    person: FormPerson.none,
    number: FormNumber.singular,
    gender: FormGender.masculine,
    pronounLabel: 'Tekil Müzekker',
    arabic: 'نَاصِرٌ',
    meaning: 'Yardım eden bir erkek.',
  ),
  ConjugationForm(
    category: FormCategory.ismFail,
    voice: Voice.malum,
    person: FormPerson.none,
    number: FormNumber.dual,
    gender: FormGender.masculine,
    pronounLabel: 'İkil Müzekker',
    arabic: 'نَاصِرَانِ',
    meaning: 'Yardım eden iki erkek.',
  ),
  ConjugationForm(
    category: FormCategory.ismFail,
    voice: Voice.malum,
    person: FormPerson.none,
    number: FormNumber.plural,
    gender: FormGender.masculine,
    pronounLabel: 'Çoğul Müzekker (Sâlim)',
    arabic: 'نَاصِرُونَ',
    meaning: 'Yardım eden erkekler.',
  ),
  ConjugationForm(
    category: FormCategory.ismFail,
    voice: Voice.malum,
    person: FormPerson.none,
    number: FormNumber.singular,
    gender: FormGender.feminine,
    pronounLabel: 'Tekil Müennes',
    arabic: 'نَاصِرَةٌ',
    meaning: 'Yardım eden bir kadın.',
  ),
  ConjugationForm(
    category: FormCategory.ismFail,
    voice: Voice.malum,
    person: FormPerson.none,
    number: FormNumber.dual,
    gender: FormGender.feminine,
    pronounLabel: 'İkil Müennes',
    arabic: 'نَاصِرَتَانِ',
    meaning: 'Yardım eden iki kadın.',
  ),
  ConjugationForm(
    category: FormCategory.ismFail,
    voice: Voice.malum,
    person: FormPerson.none,
    number: FormNumber.plural,
    gender: FormGender.feminine,
    pronounLabel: 'Çoğul Müennes (Sâlim)',
    arabic: 'نَاصِرَاتٌ',
    meaning: 'Yardım eden kadınlar.',
  ),
  ConjugationForm(
    category: FormCategory.ismFail,
    voice: Voice.malum,
    person: FormPerson.none,
    number: FormNumber.plural,
    gender: FormGender.masculine,
    pronounLabel: 'Kırık Çoğul Müzekker 1',
    arabic: 'نُصَّارٌ',
    meaning: 'Yardım eden erkekler (Kırık Çoğul 1).',
  ),
];

const nounTestData = AppData(
  lessons: [],
  muhtelifeEntries: [],
  forms: nounTestFormsList,
  practiceQuestions: [],
);

/// Richer dataset for interaction tests that need multiple forms.
const richTestData = AppData(
  lessons: [],
  muhtelifeEntries: [],
  forms: testFormsList,
  practiceQuestions: [],
);

/// Two-question dataset for the "Sonraki Soru" advance test.
const multiQuestionData = AppData(
  lessons: [],
  muhtelifeEntries: [],
  forms: testFormsList,
  practiceQuestions: [],
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
      PracticeScreen(data: data, random: Random(1)),
      const SourceScreen(),
    ];

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: selectedIndex,
          children: screens,
        ),
      ),
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
