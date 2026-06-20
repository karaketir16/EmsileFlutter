import 'dart:math';
import 'package:emsile_flutter/data/models.dart';
import 'package:emsile_flutter/features/practice/matching_practice_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final testMuhtelifeEntries = [
    const MuhtelifeEntry(
      type: 'fiil_mazi',
      label: 'Fiil-i Mâzi',
      arabic: 'نَصَرَ',
      meaning: 'Yardım etti.',
      sortOrder: 10,
    ),
    const MuhtelifeEntry(
      type: 'fiil_muzari',
      label: 'Fiil-i Muzâri',
      arabic: 'يَنْصُرُ',
      meaning: 'Yardım ediyor.',
      sortOrder: 20,
    ),
    const MuhtelifeEntry(
      type: 'masdar',
      label: 'Masdar-ı Gayr-ı Mîmî',
      arabic: 'نَصْرًا',
      meaning: 'Yardım etmek.',
      sortOrder: 30,
    ),
    const MuhtelifeEntry(
      type: 'ism_fail',
      label: 'İsm-i Fâil',
      arabic: 'نَاصِرٌ',
      meaning: 'Yardım eden.',
      sortOrder: 40,
    ),
    const MuhtelifeEntry(
      type: 'ism_meful',
      label: 'İsm-i Mef\'ûl',
      arabic: 'مَنْصُورٌ',
      meaning: 'Yardım edilen.',
      sortOrder: 50,
    ),
  ];

  final testAppData = AppData(
    lessons: [],
    pronouns: [],
    muhtelifeEntries: testMuhtelifeEntries,
    forms: [],
    practiceQuestions: [],
  );

  testWidgets(
    'matching practice: completes setup, starts game, matches successfully',
    (WidgetTester tester) async {
      // Use fixed size for testing
      await tester.binding.setSurfaceSize(const Size(600, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      // Build our screen
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatchingPracticeScreen(
              data: testAppData,
              random: Random(1), // Fixed seed for reproducible shuffling
            ),
          ),
        ),
      );

      // 1. Verify Setup Screen
      expect(find.text('Sîga Eşleştirme'), findsOneWidget);
      expect(find.text('Arapça ↔ Sîga Adı'), findsOneWidget);
      expect(find.text('Arapça ↔ Türkçe Anlam'), findsOneWidget);
      expect(find.text('Karışık'), findsOneWidget);

      // Select 'Arapça ↔ Sîga Adı' (it is selected by default, let's tap it anyway)
      await tester.tap(find.text('Arapça ↔ Sîga Adı'));
      await tester.pumpAndSettle();

      // Tap 'Eşleştirmeyi Başlat'
      await tester.tap(find.text('Eşleştirmeyi Başlat'));
      await tester.pumpAndSettle();

      // 2. Verify Game Screen is active
      expect(find.textContaining('Tur 1 / 1'), findsOneWidget);
      expect(find.text('Hata Sayısı: 0'), findsOneWidget);

      // With Random(1) seed:
      // Let's print out the items to find what is on screen or find by text.
      // Left items should have: نَصَرَ, يَنْصُرُ, نَصْرًا, نَاصِرٌ, مَنْصُورٌ
      // Right items should have: Fiil-i Mâzi, Fiil-i Muzâri, Masdar-ı Gayr-ı Mîmî, İsm-i Fâil, İsm-i Mef'ûl
      expect(find.text('نَصَرَ'), findsOneWidget);
      expect(find.text('Fiil-i Mâzi'), findsOneWidget);

      // 3. Test Incorrect Match
      await tester.tap(find.text('نَصَرَ'));
      await tester.pump();
      await tester.tap(find.text('Fiil-i Muzâri'));
      await tester.pump();

      // Should show error state / mistake count incremented
      expect(find.text('Hata Sayısı: 1'), findsOneWidget);

      // Wait for error feedback duration to pass
      await tester.pump(const Duration(milliseconds: 700));

      // 4. Test Correct Matches
      // Match 1: نَصَرَ ↔ Fiil-i Mâzi
      await tester.tap(find.text('نَصَرَ'));
      await tester.pump();
      await tester.tap(find.text('Fiil-i Mâzi'));
      await tester.pump();

      // Match 2: يَنْصُرُ ↔ Fiil-i Muzâri
      await tester.tap(find.text('يَنْصُرُ'));
      await tester.pump();
      await tester.tap(find.text('Fiil-i Muzâri'));
      await tester.pump();

      // Match 3: نَصْرًا ↔ Masdar-ı Gayr-ı Mîmî
      await tester.tap(find.text('نَصْرًا'));
      await tester.pump();
      await tester.tap(find.text('Masdar-ı Gayr-ı Mîmî'));
      await tester.pump();

      // Match 4: نَاصِرٌ ↔ İsm-i Fâil
      await tester.tap(find.text('نَاصِرٌ'));
      await tester.pump();
      await tester.tap(find.text('İsm-i Fâil'));
      await tester.pump();

      // Match 5: مَنْصُورٌ ↔ İsm-i Mef'ûl
      await tester.tap(find.text('مَنْصُورٌ'));
      await tester.pump();
      await tester.tap(find.text('İsm-i Mef\'ûl'));
      await tester.pumpAndSettle();

      // Wait for round transition delay
      await tester.pump(const Duration(milliseconds: 1200));
      await tester.pumpAndSettle();

      // 5. Verify Completed Screen
      expect(find.text('Tebrikler!'), findsOneWidget);
      expect(find.text('Toplam Eşleşme'), findsOneWidget);
      expect(find.text('Hata Sayısı'), findsOneWidget);
      expect(find.text('Başarı Oranı'), findsOneWidget);
      expect(find.text('Yeniden Oyna'), findsOneWidget);

      // Tap 'Yeniden Oyna' and verify it restarts the game (showing Tur 1 / 1)
      await tester.tap(find.text('Yeniden Oyna'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Tur 1 / 1'), findsOneWidget);
    },
  );
}
