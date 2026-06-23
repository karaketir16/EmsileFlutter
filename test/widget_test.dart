import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:emsile_flutter/app/emsile_app.dart';
import 'package:emsile_flutter/data/models.dart';
import 'package:emsile_flutter/features/conjugation/conjugation_screen.dart';
import 'package:emsile_flutter/features/home/home_screen.dart';
import 'package:emsile_flutter/features/ibare/ibare_study_screen.dart';
import 'package:emsile_flutter/features/lessons/lessons_screen.dart';
import 'package:emsile_flutter/features/practice/practice_screen.dart';
import 'package:emsile_flutter/features/source/source_screen.dart';
import 'package:emsile_flutter/shared/widgets/arabic_result_card.dart';

Future<void> pumpLoadedApp(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  await tester.pumpWidget(const EmsileApp());
  for (var i = 0; i < 60; i++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (find.text('Nasıl kullanılır?').evaluate().isNotEmpty) {
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

IbareBook _loadBookSync(String manifestPath) {
  final manifestRaw = File(manifestPath).readAsStringSync();
  final manifestJson = jsonDecode(manifestRaw) as Map<String, dynamic>;
  Map<String, dynamic> loadPassage(String path) =>
      jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
  final fullJson = Map<String, dynamic>.from(manifestJson);
  if (manifestJson['sections'] case final List<dynamic> sections) {
    fullJson['sections'] = sections.map((item) {
      final section = Map<String, dynamic>.from(item as Map<String, dynamic>);
      section['passages'] = List<String>.from(
        section['passages'] as List,
      ).map(loadPassage).toList();
      return section;
    }).toList();
  } else {
    fullJson['passages'] = List<String>.from(
      manifestJson['passages'] as List,
    ).map(loadPassage).toList();
  }
  return IbareBook.fromJson(fullJson);
}

void main() {
  final binaBook = _loadBookSync('assets/data/ibare/bina.json');

  test('ibare data preserves printed harakat and toggles added harakat', () {
    final besmele = binaBook.passages.first.tokens.first;
    final printedPattern = binaBook.passages[2].tokens.firstWhere(
      (token) => token.arabic == 'فَعَلَ',
    );

    expect(besmele.displayArabic(false), 'بسم');
    expect(besmele.displayArabic(true), 'بِسْمِ');
    expect(printedPattern.displayArabic(false), 'فَعَلَ –');
    expect(printedPattern.displayArabic(true), 'فَعَلَ –');

    final numberedSentence = binaBook.passages[1].tokens.firstWhere(
      (token) => token.arabic == 'بَابًا',
    );
    expect(numberedSentence.displayArabic(false), 'باباً،');
    expect(numberedSentence.displayArabic(true), 'بَابًا،');

    final alametuhu = binaBook.passages[2].tokens.firstWhere(
      (token) => token.arabic == 'وَعَلَامَتُهُ',
    );
    expect(alametuhu.displayArabic(false), 'وعلامَتُهُ');
    expect(alametuhu.displayArabic(true), 'وَعَلَامَتُهُ');

    final bina = binaBook.passages[3].tokens.firstWhere(
      (token) => token.arabic == 'وَبِنَاؤُهُ',
    );
    expect(bina.displayArabic(false), 'وبِناؤُهُ');
    expect(bina.displayArabic(true), 'وَبِنَاؤُهُ');
  });

  test('ibare text matches the book forms when harakat are hidden', () {
    expect(
      binaBook.passages
          .map(
            (passage) => passage.tokens
                .map((token) => token.displayArabic(false))
                .join(' '),
          )
          .toList(),
      [
        'بسم اللّٰه الرحمن الرحيم',
        'اعلم أن أبواب التصريف خمسة وثلاثون باباً، ستة منها للثلاثي المجرد',
        'الباب الأول: فَعَلَ – يَفْعُلُ موزونه: نَصَرَ يَنْصُرُ، وعلامَتُهُ أن يكون عَيْنُ فِعْلِهِ مَفْتُوحاً فِي الماضي ومَضْمُوماً فِي المضارعِ',
        'وبِناؤُهُ لِلتَّعْدِيَةِ غَالِباً وَقَدْ يَكُونُ لَازِماً مثال المتعدِّي نحو: نَصَرَ زَيْدٌ عَمْرًا ومثال اللازم نحو: خَرَجَ زَيْدٌ',
        'الباب الثاني: فَعَلَ – يَفْعِلُ موزونه: ضَرَبَ يَضْرِبُ، وعلامته أن يكون عين فعله مفتوحاً في الماضي ومكسوراً في المضارع',
        'وبناؤه أيضاً للتعدية غالباً وقد يكون لازماً مثال المتعدي نحو: ضَرَبَ زَيْدٌ عَمْرًا ومثال اللازم مثل: جَلَسَ زَيْدٌ',
        'الباب الثالث: فَعَلَ – يَفْعَلُ موزونه: فَتَحَ يَفْتَحُ، وعلامته أن يكون عين فعله مفتوحاً في الماضي والمضارع بشرط أن يكون عين فعله أو لامه واحداً من حروف الحلق وهي ستة: الحاء والخاء والعين والغين والهاء والهمزة.',
        'وبناؤه أيضاً للتعدية غالباً وقد يكون لازماً مثال المتعدي نحو: فَتَحَ زَيْدٌ الْبَابَ ومثال اللازم نحو: ذَهَبَ زَيْدٌ.',
        'الْبَابُ الرَّابِعُ: فَعِلَ يَفْعَلُ مَوْزُونُهُ: عَلِمَ يَعْلَمُ، وَعَلَامَتُهُ أَنْ يَكُونَ عَيْنُ فِعْلِهِ مَكْسُورًا فِي الْمَاضِي وَمَفْتُوحًا فِي الْمُضَارِعِ',
        'وَبِنَاؤُهُ أَيْضًا لِلتَّعْدِيَةِ غَالِبًا وَقَدْ يَكُونُ لَازِمًا مِثَالُ الْمُتَعَدِّي نَحْوُ: عَلِمَ زَيْدٌ الْمَسْأَلَةَ وَمِثَالُ اللَّازِمِ نَحْوُ: وَجِلَ زَيْدٌ',
        'الباب الخامس: فَعُلَ يَفْعُلُ موزونه: حسن يحسن، وعلامته أن يكون عين فعله مضموماً في الماضي والمضارع',
        'وبناؤه لا يكون إلا لازماً نحو: حسن زيد.',
        'الباب السادس: فَعِلَ يَفْعِلُ موزونه: حسب يحسب، وعلامته أن يكون عين فعله مكسوراً في الماضي والمضارع',
        'وبناؤه أيضاً للتعدية غالباً وقد يكون لازماً مثال المتعدي نحو: حسب زيد عمراً فاضلاً ومثال اللازم نحو: ورث زيد.',
        'واثنا عشر باباً منها لما زاد على الثلاثي وهو ثلاثة أنواع، النوع الأول: الفعل الثلاثي المزيد بحرف واحد وهو ما زيد فيه حرف واحد على الثلاثي وهو ثلاثة أبواب.',
        'الباب الأول: أفعل يفعل إفعالاً موزونه: أكرم يكرم إكراماً، وعلامته أن يكون ماضيه على أربعة أحرف بزيادة الهمزة في أوله.',
        'وبناؤه للتعدية غالباً وقد يكون لازماً مثال المتعدي نحو: أكرم زيد عمراً ومثال اللازم نحو: أصبح الرجل.',
      ],
    );
  });

  test('ibare broken meanings preserve conjunction waw', () {
    final conjunctions = binaBook.passages
        .expand((passage) => passage.tokens)
        .where(
          (token) =>
              token.arabic.startsWith('وَ') &&
              !token.arabic.contains('وَاحِد') &&
              token.arabic != 'وَجِلَ' &&
              token.arabic != 'وَرِثَ',
        );

    expect(
      conjunctions.every((token) => token.gloss.startsWith('Ve ')),
      isTrue,
    );
  });

  test('ibare broken meanings stay within token boundaries', () {
    IbareToken token(String id) => binaBook.passages
        .expand((passage) => passage.tokens)
        .firstWhere((token) => token.id == id);

    expect(token('p1_t1').gloss, 'İsim ile, adıyla');
    expect(token('p3_t11').gloss, 'Orta harfi');
    expect(token('p5_t11').gloss, 'Orta harfi');
    expect(token('p7_t11').gloss, 'Ayn harfi, orta harfi');
    expect(token('p7_t14').gloss, '-de');
    expect(token('p7_t15').gloss, 'Mâzi');
    expect(token('p7_t23').gloss, 'Lâmı, son harfi');
    expect(token('p7_t25').gloss, '-den, -dan');
    expect(token('p7_t26').gloss, 'Harfleri');
    final phrases = binaBook.passages[6].phrasesForToken('p7_t26');
    expect(phrases.first.meaning, 'Boğaz harfleri');
    expect(phrases[1].meaning, 'Boğaz harflerinden');
  });

  test('ibare tokens follow real word boundaries', () {
    final multiWordTokens = binaBook.passages
        .expand((passage) => passage.tokens)
        .where((token) => token.arabic.contains(' '));

    expect(multiWordTokens, isEmpty);
    expect(
      binaBook.passages[7].phrasesForToken('p8_t8').first.meaning,
      'Müteaddinin misali',
    );
    expect(
      binaBook.passages[7].phrasesForToken('p8_t1').first.meaning,
      'Bu babın binası da',
    );
  });

  test('third bab distinguishes the kane sentence from its verbal noun', () {
    final phrases = binaBook.passages[6].phrases;
    final kane = phrases.firstWhere((phrase) => phrase.id == 'p7_ph15');
    final masdar = phrases.firstWhere((phrase) => phrase.id == 'p7_ph16');

    expect(
      kane.meaning,
      'Fiilinin ayn veya lâm harfi boğaz harflerinden biri olur.',
    );
    expect(
      masdar.meaning,
      'Fiilinin ayn veya lâm harfinin boğaz harflerinden biri olması',
    );
  });

  test('all ibare phrase layers grow and have distinct meanings', () {
    for (final passage in binaBook.passages) {
      final byId = {for (final phrase in passage.phrases) phrase.id: phrase};
      final coveredTokens = passage.phrases
          .expand((phrase) => phrase.tokenIds)
          .toSet();

      expect(
        coveredTokens,
        containsAll(passage.tokens.map((token) => token.id)),
        reason: passage.id,
      );

      for (final phrase in passage.phrases) {
        if (phrase.parentId case final parentId?) {
          final parent = byId[parentId]!;
          expect(
            parent.tokenIds.length,
            greaterThan(phrase.tokenIds.length),
            reason: '${passage.id}: ${phrase.id} -> $parentId',
          );
          expect(
            parent.meaning.trim(),
            isNot(phrase.meaning.trim()),
            reason: '${passage.id}: ${phrase.id} -> $parentId',
          );
        }
      }
    }
  });

  test('besmele and introduction expose layered phrases', () {
    final besmele = binaBook.passages[0];
    final introduction = binaBook.passages[1];

    expect(
      besmele.phrasesForToken('p1_t2').map((phrase) => phrase.meaning),
      containsAll([
        'Allah’ın adıyla',
        'Rahman olan Allah',
        'Rahman ve Rahim olan Allah',
        'Rahman ve Rahim olan Allah’ın adıyla [başlarım].',
      ]),
    );
    expect(
      introduction.phrasesForToken('p2_t5').map((phrase) => phrase.meaning),
      containsAll([
        'Otuz beş',
        'Otuz beş bap',
        'Sarf ilminin bapları otuz beş baptır.',
        'Muhakkak ki sarf ilminin bapları otuz beş baptır.',
        'Bil ki sarf ilminin bapları otuz beş baptır.',
      ]),
    );
    expect(
      introduction.phrasesForToken('p2_t10').map((phrase) => phrase.meaning),
      containsAll([
        'Sülâsî mücerred için',
        'Bunlardan altısı sülâsî mücerred içindir.',
      ]),
    );
  });

  testWidgets('ibare phrase layers open separately and grow with arrows', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(home: IbarePassageScreen(book: binaBook, initialIndex: 6)),
    );

    await tester.tap(find.byKey(const ValueKey('detail_p7_t26')));
    await tester.pumpAndSettle();

    expect(find.text('Kelime grubunu göster (8)'), findsOneWidget);
    expect(find.text('Boğaz harfleri'), findsNothing);

    final phraseButton = find.text('Kelime grubunu göster (8)');
    await tester.ensureVisible(phraseButton);
    await tester.pumpAndSettle();
    await tester.tap(phraseButton);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Terkip (Kelime Grubu)'));
    expect(find.text('Terkip (Kelime Grubu)'), findsOneWidget);
    expect(find.text('Boğaz harfleri'), findsOneWidget);
    expect(find.text('1/8'), findsOneWidget);

    await tester.tap(find.byTooltip('Daha büyük terkip'));
    await tester.pumpAndSettle();

    expect(find.text('Boğaz harflerinden'), findsOneWidget);
    expect(find.text('2/8'), findsOneWidget);
  });

  testWidgets('shows the Emsile home screen', (WidgetTester tester) async {
    await pumpLoadedApp(tester);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    expect(find.text('Emsile'), findsOneWidget);
    expect(find.text('Nasıl kullanılır?'), findsOneWidget);
    expect(find.text('Bilgini pekiştir'), findsOneWidget);
  });

  testWidgets('renders the conjugation screen', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(home: ConjugationScreen(data: testData)),
    );

    // Seçim ekranı görünmeli
    expect(find.text('Çekim Tablosu'), findsOneWidget);
    expect(find.text('Çekimler'), findsOneWidget);
    expect(find.text('Zamirler'), findsOneWidget);

    // Çekimler kartına tıklayarak çekim sayfasına geç
    await tester.tap(find.text('Çekimler'));
    await tester.pumpAndSettle();

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
          body: SafeArea(
            child: PracticeScreen(data: testData, random: Random(1)),
          ),
        ),
      ),
    );

    expect(find.text('Çoktan Seçmeli'), findsOneWidget);
    await startPractice(tester);

    expect(find.text('Pratik'), findsOneWidget);
    expect(find.byType(AnswerButton), findsWidgets);
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

    // Seçim ekranı görünmeli
    expect(find.text('Çekim Tablosu'), findsOneWidget);
    expect(find.text('Çekimler'), findsOneWidget);
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

    expect(find.text('Çoktan Seçmeli'), findsOneWidget);
    expect(find.text('Tabloyu Doldur'), findsOneWidget);
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
    expect(find.text('İbare Çalışması'), findsOneWidget);
  });

  testWidgets('ibare study reveals word analysis and meanings', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(home: IbarePassageScreen(book: binaBook, initialIndex: 1)),
    );

    expect(find.text('اعلم'), findsOneWidget);
    expect(find.text('اِعْلَمْ'), findsNothing);

    await tester.tap(find.text('اعلم'));
    await tester.pumpAndSettle();

    expect(find.text('Emr-i hâzır, malûm'), findsOneWidget);
    expect(find.text('أَنْتَ “sen”'), findsOneWidget);
    expect(find.text('Sülâsî mücerred 4. bab'), findsOneWidget);

    await tester.tap(find.text('Harekeleri göster'));
    await tester.pumpAndSettle();

    expect(find.text('اِعْلَمْ'), findsWidgets);
    expect(find.text('Mefhum'), findsNothing);

    await tester.tap(find.text('التَّصْرِيفِ'));
    await tester.pumpAndSettle();

    expect(find.text('Masdar / isim'), findsOneWidget);
    expect(find.text('صَرَّفَ يُصَرِّفُ'), findsOneWidget);
    expect(find.text('Sülâsî mezîd, tef‘îl babı'), findsOneWidget);

    final showBrokenMeanings = find.widgetWithText(TextButton, 'Göster').first;
    await tester.tap(showBrokenMeanings);
    await tester.pumpAndSettle();

    expect(find.text('Muhakkak ki'), findsOneWidget);
    expect(find.text('Bapları'), findsOneWidget);
  });

  testWidgets('ibare book shows passages, word analysis, and detail action', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(home: IbareStudyScreen(books: [binaBook])),
    );

    expect(find.text(binaBook.title), findsOneWidget);
    await tester.tap(find.text(binaBook.title));
    await tester.pumpAndSettle();

    expect(find.text('Giriş'), findsOneWidget);
    expect(find.text('Birinci Bab'), findsOneWidget);
    expect(find.text('Harekeler'), findsNWidgets(binaBook.passages.length));

    await tester.tap(find.byKey(const ValueKey('harakat_passage_1')));
    await tester.pumpAndSettle();

    expect(find.text('بِسْمِ'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('overview_p1_t1')));
    await tester.pumpAndSettle();

    expect(find.text('İsim'), findsOneWidget);
    expect(find.text('İsim ile, adıyla'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('overview_p1_t1')));
    await tester.pumpAndSettle();

    expect(find.text('İsim ile, adıyla'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('inspect_passage_1')));
    await tester.pumpAndSettle();

    expect(find.text('Kırık Mana'), findsOneWidget);
    expect(find.text('Toparlanmış Mana'), findsOneWidget);
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
    expect(find.text('Fiil-i Mâzi'), findsOneWidget);
    expect(find.text('نَصَرَ'), findsOneWidget);
    expect(find.text('Yardım etti.'), findsOneWidget);
    expect(find.text('İsm-i Fâil'), findsOneWidget);
    expect(find.text('Yardım eden.'), findsOneWidget);
  });

  testWidgets('lesson detail includes PDF conjugation rules', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: LessonDetailScreen(
          lesson: Lesson(
            order: 2,
            title: 'Fiil-i Mâzi',
            summary: '',
            rule: '',
            relatedCategory: FormCategory.mazi,
          ),
          data: testData,
        ),
      ),
    );

    expect(find.text('Meçhulün Yapılışı'), findsOneWidget);
    expect(find.textContaining('Cezimli harflerin'), findsOneWidget);
    expect(find.textContaining('önceki harekeli harfler'), findsOneWidget);
  });

  testWidgets('muttaride lesson advances to the next category', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: LessonDetailScreen(
          lesson: Lesson(
            order: 2,
            title: 'Fiil-i Mâzi',
            summary: '',
            rule: '',
            relatedCategory: FormCategory.mazi,
          ),
          data: testData,
        ),
      ),
    );

    expect(find.text('Önceki'), findsNothing);
    await tester.tap(find.text('Sonraki'));
    await tester.pumpAndSettle();

    expect(find.text('Fiil-i Muzâri'), findsWidgets);
    expect(find.text('Önceki'), findsOneWidget);

    await tester.tap(find.text('Önceki'));
    await tester.pumpAndSettle();

    expect(find.text('Fiil-i Mâzi'), findsWidgets);
  });

  testWidgets('selected index 4 renders source screen', (
    WidgetTester tester,
  ) async {
    final notifier = await pumpShell(tester);
    addTearDown(() {
      tester.binding.setSurfaceSize(null);
      notifier.dispose();
    });

    notifier.value = 4; // Hakkında
    await tester.pumpAndSettle();

    expect(
      tester.getTopLeft(find.text('Geliştirici')).dy,
      lessThan(tester.getTopLeft(find.text('Atıf')).dy),
    );
    expect(find.textContaining('github.com/karaketir16'), findsOneWidget);
    expect(find.textContaining('arapcadiyari.blogspot.com'), findsOneWidget);
  });

  // ── Conjugation interactions ────────────────────────────────────────────────

  testWidgets('conjugation: tapping Meçhul switches voice', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(home: ConjugationScreen(data: richTestData)),
    );
    await navigateToConjugations(tester);

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
      MaterialApp(home: ConjugationScreen(data: richTestData)),
    );
    await navigateToConjugations(tester);

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
      MaterialApp(home: ConjugationScreen(data: richTestData)),
    );
    await navigateToConjugations(tester);

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
      MaterialApp(home: ConjugationScreen(data: richTestData)),
    );
    await navigateToConjugations(tester);

    await tester.ensureVisible(find.text('نَصَرْتَ').first);
    await tester.tap(find.text('نَصَرْتَ').first);
    await tester.pumpAndSettle();

    expect(find.text('Sen (er.)'), findsWidgets);
    expect(find.text('نَصَرْتَ'), findsWidgets);
  });

  testWidgets(
    'conjugation: selecting Muzari and tapping third person plural masculine highlights it in selection table',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final scenarioTestData = AppData(
        lessons: const [],
        pronouns: const [],
        muhtelifeEntries: const [],
        forms: [
          ...testFormsList,
          const ConjugationForm(
            category: FormCategory.muzari,
            voice: Voice.malum,
            person: FormPerson.third,
            number: FormNumber.plural,
            gender: FormGender.masculine,
            pronounLabel: 'Onlar (er.)',
            arabic: 'يَنْصُرُونَ',
            meaning: 'Yardım ediyorlar.',
          ),
        ],
        practiceQuestions: const [],
      );

      await tester.pumpWidget(
        MaterialApp(home: ConjugationScreen(data: scenarioTestData)),
      );
      await navigateToConjugations(tester);

      // Select 'Fiil-i Muzâri' from the dropdown
      await selectConjugationCategory(tester, 'Fiil-i Muzâri');

      // Tap on the plural third person masculine form cell ('يَنْصُرُونَ')
      await tester.ensureVisible(find.text('يَنْصُرُونَ').first);
      await tester.tap(find.text('يَنْصُرُونَ').first);
      await tester.pumpAndSettle();

      // Verify that in the SelectionTable (Şahıs Tablosu), the 'Onlar (er.)' cell is colored with primaryContainer
      final cellContainerFinder = find
          .ancestor(
            of: find.text('Onlar (er.)'),
            matching: find.byType(Container),
          )
          .first;

      final containerWidget = tester.widget<Container>(cellContainerFinder);
      final decoration = containerWidget.decoration as BoxDecoration;

      // The color should be primaryContainer
      final context = tester.element(find.text('Onlar (er.)'));
      final primaryContainerColor = Theme.of(
        context,
      ).colorScheme.primaryContainer;
      expect(decoration.color, primaryContainerColor);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'conjugation: selecting Muzari Malum plural masculine, then switching to Mechul preserves plural masculine selection',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final scenarioTestData = AppData(
        lessons: const [],
        pronouns: const [],
        muhtelifeEntries: const [],
        forms: [
          ...testFormsList,
          const ConjugationForm(
            category: FormCategory.muzari,
            voice: Voice.malum,
            person: FormPerson.third,
            number: FormNumber.plural,
            gender: FormGender.masculine,
            pronounLabel: 'Onlar (er.)',
            arabic: 'يَنْصُرُونَ',
            meaning: 'Yardım ediyorlar.',
          ),
          const ConjugationForm(
            category: FormCategory.muzari,
            voice: Voice.mechul,
            person: FormPerson.third,
            number: FormNumber.singular,
            gender: FormGender.masculine,
            pronounLabel: 'O (er.)',
            arabic: 'يُنْصَرُ',
            meaning: 'Yardım edilir.',
          ),
          const ConjugationForm(
            category: FormCategory.muzari,
            voice: Voice.mechul,
            person: FormPerson.third,
            number: FormNumber.plural,
            gender: FormGender.masculine,
            pronounLabel: 'Onlar (er.)',
            arabic: 'يُنْصَرُونَ',
            meaning: 'Yardım ediliyorlar.',
          ),
        ],
        practiceQuestions: const [],
      );

      await tester.pumpWidget(
        MaterialApp(home: ConjugationScreen(data: scenarioTestData)),
      );
      await navigateToConjugations(tester);

      // Select 'Fiil-i Muzâri' from the dropdown
      await selectConjugationCategory(tester, 'Fiil-i Muzâri');

      // Tap on the plural third person masculine form cell ('يَنْصُرُونَ')
      await tester.ensureVisible(find.text('يَنْصُرُونَ').first);
      await tester.tap(find.text('يَنْصُرُونَ').first);
      await tester.pumpAndSettle();

      // Verify that 'Onlar (er.)' is selected in SelectionTable
      var cellContainerFinder = find
          .ancestor(
            of: find.text('Onlar (er.)'),
            matching: find.byType(Container),
          )
          .first;
      var containerWidget = tester.widget<Container>(cellContainerFinder);
      var decoration = containerWidget.decoration as BoxDecoration;
      var context = tester.element(find.text('Onlar (er.)'));
      expect(decoration.color, Theme.of(context).colorScheme.primaryContainer);

      // Tap on 'Meçhul'
      await tester.ensureVisible(find.text('Meçhul'));
      await tester.tap(find.text('Meçhul'));
      await tester.pumpAndSettle();

      // Verify that the result card now displays يُنْصَرُونَ (the plural mechul form)
      expect(find.text('يُنْصَرُونَ'), findsWidgets);

      // Verify that 'Onlar (er.)' is STILL selected in SelectionTable
      cellContainerFinder = find
          .ancestor(
            of: find.text('Onlar (er.)'),
            matching: find.byType(Container),
          )
          .first;
      containerWidget = tester.widget<Container>(cellContainerFinder);
      decoration = containerWidget.decoration as BoxDecoration;
      expect(decoration.color, Theme.of(context).colorScheme.primaryContainer);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'conjugation: selecting Muzari Malum second person singular masculine does not highlight third person singular feminine and displays correct meaning',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final scenarioTestData = AppData(
        lessons: const [],
        pronouns: const [],
        muhtelifeEntries: const [],
        forms: [
          ...testFormsList,
          const ConjugationForm(
            category: FormCategory.muzari,
            voice: Voice.malum,
            person: FormPerson.third,
            number: FormNumber.singular,
            gender: FormGender.feminine,
            pronounLabel: 'O (kd.)',
            arabic: 'تَنْصُرُ',
            meaning: 'O kadın yardım ediyor.',
          ),
        ],
        practiceQuestions: const [],
      );

      await tester.pumpWidget(
        MaterialApp(home: ConjugationScreen(data: scenarioTestData)),
      );
      await navigateToConjugations(tester);

      // Select 'Fiil-i Muzâri' from the dropdown
      await selectConjugationCategory(tester, 'Fiil-i Muzâri');

      // Tapping on 'تَنْصُرُ' (Muhatap) in FormsTable (it's the last one)
      // The first 'تَنْصُرُ' is Gaibe (O kd.), the last one is Muhatap (Sen er.)
      await tester.ensureVisible(find.text('تَنْصُرُ').last);
      await tester.tap(find.text('تَنْصُرُ').last);
      await tester.pumpAndSettle();

      // Now verify result card displays 'Yardım ediyorsun.' (the 2nd person meaning)
      expect(find.text('Yardım ediyorsun.'), findsWidgets);
      expect(find.text('O kadın yardım ediyor.'), findsNothing);

      // Verify that in SelectionTable, 'O (kd.)' is uncolored (white)
      final oKdFinder = find
          .ancestor(of: find.text('O (kd.)'), matching: find.byType(Container))
          .first;
      final oKdWidget = tester.widget<Container>(oKdFinder);
      final oKdDecoration = oKdWidget.decoration as BoxDecoration;
      expect(oKdDecoration.color, Colors.white);

      // Verify that in SelectionTable, 'Sen (er.)' is colored (primaryContainer)
      final senErFinder = find
          .ancestor(
            of: find.text('Sen (er.)'),
            matching: find.byType(Container),
          )
          .first;
      final senErWidget = tester.widget<Container>(senErFinder);
      final senErDecoration = senErWidget.decoration as BoxDecoration;
      final context = tester.element(find.text('Sen (er.)'));
      expect(
        senErDecoration.color,
        Theme.of(context).colorScheme.primaryContainer,
      );

      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'conjugation: Muzari Malum selecting Gaib plural, switching to Mechul preserves plural and does not fallback to singular',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final scenarioTestData = AppData(
        lessons: const [],
        pronouns: const [],
        muhtelifeEntries: const [],
        forms: [
          ...testFormsList,
          const ConjugationForm(
            category: FormCategory.muzari,
            voice: Voice.malum,
            person: FormPerson.third,
            number: FormNumber.plural,
            gender: FormGender.masculine,
            pronounLabel: 'Onlar (er.)',
            arabic: 'يَنْصُرُونَ',
            meaning: 'Yardım ediyorlar.',
          ),
          const ConjugationForm(
            category: FormCategory.muzari,
            voice: Voice.mechul,
            person: FormPerson.third,
            number: FormNumber.singular,
            gender: FormGender.masculine,
            pronounLabel: 'O (er.)',
            arabic: 'يُنْصَرُ',
            meaning: 'Yardım edilir.',
          ),
          const ConjugationForm(
            category: FormCategory.muzari,
            voice: Voice.mechul,
            person: FormPerson.third,
            number: FormNumber.plural,
            gender: FormGender.masculine,
            pronounLabel: 'Onlar (er.)',
            arabic: 'يُنْصَرُونَ',
            meaning: 'Yardım ediliyorlar.',
          ),
        ],
        practiceQuestions: const [],
      );

      await tester.pumpWidget(
        MaterialApp(home: ConjugationScreen(data: scenarioTestData)),
      );
      await navigateToConjugations(tester);

      // Select 'Fiil-i Muzâri' from the dropdown
      await selectConjugationCategory(tester, 'Fiil-i Muzâri');

      // Tap on the plural third person masculine form cell ('يَنْصُرُونَ')
      await tester.ensureVisible(find.text('يَنْصُرُونَ').first);
      await tester.tap(find.text('يَنْصُرُونَ').first);
      await tester.pumpAndSettle();

      // Tap on 'Meçhul'
      await tester.ensureVisible(find.text('Meçhul'));
      await tester.tap(find.text('Meçhul'));
      await tester.pumpAndSettle();

      // Verify that the result card now displays يُنْصَرُونَ (the plural mechul form) and NOT يُنْصَرُ (the singular)
      expect(find.text('يُنْصَرُونَ'), findsWidgets);
      expect(find.text('Yardım ediliyorlar.'), findsWidgets);

      // Verify that 'Onlar (er.)' is STILL selected in SelectionTable
      final cellContainerFinder = find
          .ancestor(
            of: find.text('Onlar (er.)'),
            matching: find.byType(Container),
          )
          .first;
      final containerWidget = tester.widget<Container>(cellContainerFinder);
      final decoration = containerWidget.decoration as BoxDecoration;
      final context = tester.element(find.text('Onlar (er.)'));
      expect(decoration.color, Theme.of(context).colorScheme.primaryContainer);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'conjugation: selected person is preserved when switching voice',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(home: ConjugationScreen(data: richTestData)),
      );
      await navigateToConjugations(tester);

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
        MaterialApp(home: ConjugationScreen(data: richTestData)),
      );
      await navigateToConjugations(tester);

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
      MaterialApp(home: ConjugationScreen(data: richTestData)),
    );
    await navigateToConjugations(tester);

    final beforeTop = tester.getTopLeft(find.byType(ArabicResultCard)).dy;

    await tester.drag(
      find.byType(SingleChildScrollView).first,
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();

    final afterTop = tester.getTopLeft(find.byType(ArabicResultCard)).dy;

    expect(afterTop, beforeTop);
    expect(find.text('Tüm Muttaride Tablolarını Gör'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('conjugation: narrow tables expand to available width', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(home: ConjugationScreen(data: richTestData)),
    );
    await navigateToConjugations(tester);

    final horizontalScrollFinder = find.byWidgetPredicate(
      (widget) =>
          widget is SingleChildScrollView &&
          widget.scrollDirection == Axis.horizontal,
    );
    final horizontalViewportWidth = tester
        .getSize(horizontalScrollFinder.first)
        .width;
    final firstTableWidth = tester.getSize(find.byType(Table).first).width;

    expect(
      firstTableWidth,
      moreOrLessEquals(horizontalViewportWidth, epsilon: 0.01),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('conjugation: selection coloring is only applied to the active table', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(500, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(home: ConjugationScreen(data: richTestData)),
    );
    await navigateToConjugations(tester);

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
  });

  // ── Practice interactions ───────────────────────────────────────────────────

  testWidgets('practice: tapping correct answer shows Doğru feedback', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SafeArea(
            child: PracticeScreen(data: testData, random: Random(1)),
          ),
        ),
      ),
    );

    await startPractice(tester);

    final promptFinder = find.byWidgetPredicate(
      (w) => w is Text && w.data != null && w.data!.contains('?'),
    );
    final promptText = (tester.widget(promptFinder.first) as Text).data!;

    String correctAnswer = '';
    if (promptText.contains('anlamı hangisi')) {
      final arabicText =
          (tester.widget(
                    find
                        .byWidgetPredicate(
                          (w) =>
                              w is Text &&
                              w.data != '?' &&
                              w.data!.runes.any((r) => r > 1000),
                        )
                        .first,
                  )
                  as Text)
              .data!;
      final matchedForm = testFormsList.firstWhere(
        (f) => f.arabic == arabicText,
      );
      correctAnswer = matchedForm.meaning;
    } else if (promptText.contains('şahsa aittir')) {
      final arabicText =
          (tester.widget(
                    find
                        .byWidgetPredicate(
                          (w) =>
                              w is Text &&
                              w.data != '?' &&
                              w.data!.runes.any((r) => r > 1000),
                        )
                        .first,
                  )
                  as Text)
              .data!;
      final matchedForm = testFormsList.firstWhere(
        (f) => f.arabic == arabicText,
      );
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
          body: SafeArea(
            child: PracticeScreen(data: testData, random: Random(1)),
          ),
        ),
      ),
    );

    await startPractice(tester);

    final promptFinder = find.byWidgetPredicate(
      (w) => w is Text && w.data != null && w.data!.contains('?'),
    );
    final promptText = (tester.widget(promptFinder.first) as Text).data!;

    String correctAnswer = '';
    if (promptText.contains('anlamı hangisi')) {
      final arabicText =
          (tester.widget(
                    find
                        .byWidgetPredicate(
                          (w) =>
                              w is Text &&
                              w.data != '?' &&
                              w.data!.runes.any((r) => r > 1000),
                        )
                        .first,
                  )
                  as Text)
              .data!;
      final matchedForm = testFormsList.firstWhere(
        (f) => f.arabic == arabicText,
      );
      correctAnswer = matchedForm.meaning;
    } else if (promptText.contains('şahsa aittir')) {
      final arabicText =
          (tester.widget(
                    find
                        .byWidgetPredicate(
                          (w) =>
                              w is Text &&
                              w.data != '?' &&
                              w.data!.runes.any((r) => r > 1000),
                        )
                        .first,
                  )
                  as Text)
              .data!;
      final matchedForm = testFormsList.firstWhere(
        (f) => f.arabic == arabicText,
      );
      correctAnswer = matchedForm.pronounLabel;
    } else {
      final meaning = promptText.split('"')[1];
      final matchedForm = testFormsList.firstWhere((f) => f.meaning == meaning);
      correctAnswer = matchedForm.arabic;
    }

    final wrongOptionFinder = find.byWidgetPredicate((widget) {
      return widget is InkWell &&
          widget.child is Container &&
          find
              .descendant(
                of: find.byWidget(widget),
                matching: find.text(correctAnswer),
              )
              .evaluate()
              .isEmpty;
    });

    await tester.tap(wrongOptionFinder.first);
    await tester.pumpAndSettle();

    expect(find.text('Tekrar Bak'), findsOneWidget);
    expect(find.text('Sonraki Soru'), findsOneWidget);
    expect(find.text('Doğru cevap'), findsNothing);
    expect(find.byIcon(Icons.check_circle), findsNothing);
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
          body: SafeArea(
            child: PracticeScreen(data: multiQuestionData, random: Random(1)),
          ),
        ),
      ),
    );

    await startPractice(tester);

    // İlk sorunun doğru cevabını bulalım
    final promptFinder = find.byWidgetPredicate(
      (w) => w is Text && w.data != null && w.data!.contains('?'),
    );
    final firstPromptText = (tester.widget(promptFinder.first) as Text).data!;

    String firstCorrectAnswer = '';
    if (firstPromptText.contains('anlamı hangisi')) {
      final arabicText =
          (tester.widget(
                    find
                        .byWidgetPredicate(
                          (w) =>
                              w is Text &&
                              w.data != '?' &&
                              w.data!.runes.any((r) => r > 1000),
                        )
                        .first,
                  )
                  as Text)
              .data!;
      final matchedForm = testFormsList.firstWhere(
        (f) => f.arabic == arabicText,
      );
      firstCorrectAnswer = matchedForm.meaning;
    } else if (firstPromptText.contains('şahsa aittir')) {
      final arabicText =
          (tester.widget(
                    find
                        .byWidgetPredicate(
                          (w) =>
                              w is Text &&
                              w.data != '?' &&
                              w.data!.runes.any((r) => r > 1000),
                        )
                        .first,
                  )
                  as Text)
              .data!;
      final matchedForm = testFormsList.firstWhere(
        (f) => f.arabic == arabicText,
      );
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
    await tester.ensureVisible(find.text('Sonraki Soru'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sonraki Soru'));
    await tester.pumpAndSettle();
    expect(find.text('Doğru'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('practice: setup requires a category and voice for verbs', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(500, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SafeArea(
            child: PracticeScreen(data: testData, random: Random(1)),
          ),
        ),
      ),
    );
    await openMultipleChoicePractice(tester);

    // Başlangıçta canStart true olmalı
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).enabled,
      isTrue,
    );

    // Çekim Tablolarını temizle diyelim -> buton kilitlenir
    await tester.tap(
      find
          .descendant(of: find.byType(Row), matching: find.text('Temizle'))
          .first,
    );
    await tester.pumpAndSettle();

    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).enabled,
      isFalse,
    );
    expect(
      find.text('Pratiğe başlamak için en az bir çekim tablosu seç.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Fiil-i Mâzi'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).enabled,
      isTrue,
    );

    await tester.ensureVisible(find.text('Çatı (Malum/Meçhul)'));
    await tester.tap(
      find
          .descendant(of: find.byType(Row), matching: find.text('Temizle'))
          .last,
    );
    await tester.pumpAndSettle();

    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).enabled,
      isFalse,
    );
    expect(
      find.text('Fiil kategorileri için en az bir çatı seç.'),
      findsOneWidget,
    );
  });

  testWidgets(
    'practice: setup omits person filters and toggles broken plurals',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(500, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SafeArea(child: PracticeScreen(data: nounTestData)),
          ),
        ),
      );
      await openMultipleChoicePractice(tester);

      expect(find.text('Şahıslar (Fiiller)'), findsNothing);
      expect(find.text('Kırık Çoğullar'), findsOneWidget);
      expect(
        tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
        isTrue,
      );

      await tester.tap(find.byType(SwitchListTile));
      await tester.pumpAndSettle();

      expect(
        tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
        isFalse,
      );
    },
  );

  testWidgets(
    'practice: table fill marks wrong and correct drops and closes empty slots',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(500, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeArea(
              child: PracticeScreen(data: testData, random: Random(1)),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tabloyu Doldur'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tabloyu Başlat'));
      await tester.pumpAndSettle();

      const targetKey = ValueKey('drop-third-singular-masculine');
      final target = find.byKey(targetKey);
      final wrongToken = find.ancestor(
        of: find.text('نَصَرْتَ'),
        matching: find.byWidgetPredicate((widget) => widget is Draggable),
      );

      await tester.dragFrom(
        tester.getCenter(wrongToken),
        tester.getCenter(target) - tester.getCenter(wrongToken),
      );
      await tester.pumpAndSettle();

      var targetWidget = tester.widget<AnimatedContainer>(target);
      expect(
        (targetWidget.decoration as BoxDecoration).color,
        const Color(0xFFFFDCDC),
      );
      expect(
        find.descendant(of: target, matching: find.byIcon(Icons.cancel)),
        findsOneWidget,
      );
      expect(find.text('نَصَرْتَ'), findsOneWidget);

      final correctToken = find.ancestor(
        of: find.text('نَصَرَ'),
        matching: find.byWidgetPredicate((widget) => widget is Draggable),
      );
      await tester.dragFrom(
        tester.getCenter(correctToken),
        tester.getCenter(target) - tester.getCenter(correctToken),
      );
      await tester.pumpAndSettle();

      targetWidget = tester.widget<AnimatedContainer>(target);
      expect(
        (targetWidget.decoration as BoxDecoration).color,
        const Color(0xFFE0F3E5),
      );
      expect(
        find.descendant(of: target, matching: find.byIcon(Icons.check_circle)),
        findsOneWidget,
      );
      expect(
        find.ancestor(
          of: find.text('نَصَرْتَ'),
          matching: find.byWidgetPredicate((widget) => widget is Draggable),
        ),
        findsOneWidget,
      );

      final closed = tester.widget<Container>(
        find.byKey(const ValueKey('drop-second-singular-feminine')),
      );
      expect(closed.color, const Color(0xFF5F625F));
    },
  );

  testWidgets(
    'practice: table fill shows completion only after every token is correct',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(500, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeArea(
              child: PracticeScreen(data: testData, random: Random(1)),
            ),
          ),
        ),
      );

      await openTableFillPractice(tester);
      await tester.tap(find.text('Tabloyu Başlat'));
      await tester.pumpAndSettle();

      await dragArabicTokenTo(
        tester,
        arabic: 'نَصَرَ',
        targetKey: const ValueKey('drop-third-singular-masculine'),
      );
      expect(find.text('Tablo tamamlandı!'), findsNothing);

      await dragArabicTokenTo(
        tester,
        arabic: 'نَصَرْتَ',
        targetKey: const ValueKey('drop-second-singular-masculine'),
      );

      expect(find.text('Tablo tamamlandı!'), findsOneWidget);
      expect(find.text('Yeniden Karıştır'), findsOneWidget);
    },
  );

  testWidgets(
    'practice: table fill supports independent and attached pronouns',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(500, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SafeArea(child: PracticeScreen(data: pronounTestData)),
          ),
        ),
      );

      await openTableFillPractice(tester);
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Zamirler').last);
      await tester.pumpAndSettle();

      expect(find.text('Zamir Türü'), findsOneWidget);
      expect(find.text('Ayrı Zamirler'), findsOneWidget);
      expect(find.text('Bitişik Zamirler'), findsOneWidget);

      await tester.tap(find.text('Tabloyu Başlat'));
      await tester.pumpAndSettle();
      expect(find.text('هُوَ'), findsOneWidget);
      expect(find.text('أَنْتَ'), findsOneWidget);
      expect(find.text('نَحْنُ'), findsOneWidget);

      await tester.tap(find.text('Konuyu Değiştir'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Bitişik Zamirler'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tabloyu Başlat'));
      await tester.pumpAndSettle();
      expect(find.text('ـهُ'), findsOneWidget);
      expect(find.text('ـكَ'), findsOneWidget);
    },
  );

  testWidgets(
    'practice: back button returns from a practice mode to mode selection',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeArea(
              child: PracticeScreen(data: testData, random: Random(1)),
            ),
          ),
        ),
      );

      await openTableFillPractice(tester);
      expect(
        find.text('Doldurmak istediğin çekim tablosunu seç.'),
        findsOneWidget,
      );

      await tester.tap(find.byTooltip('Geri'));
      await tester.pumpAndSettle();

      expect(find.text('Çoktan Seçmeli'), findsOneWidget);
      expect(find.text('Tabloyu Doldur'), findsOneWidget);
    },
  );

  testWidgets(
    'practice: noun table fill hides voice and can exclude broken plurals',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(500, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeArea(
              child: PracticeScreen(
                data: nounTableFillTestData,
                random: Random(1),
              ),
            ),
          ),
        ),
      );

      await openTableFillPractice(tester);
      await selectTableFillCategory(tester, 'İsm-i Fâil');

      expect(find.text('Çatı'), findsNothing);
      expect(find.text('Malum'), findsNothing);
      expect(find.text('Kırık Çoğullar'), findsOneWidget);

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tabloyu Başlat'));
      await tester.pumpAndSettle();

      expect(find.text('نُصَّارٌ'), findsNothing);
      expect(find.text('نُصَّرٌ'), findsNothing);
      expect(find.text('Kırık Çoğullar'), findsNothing);
      expect(find.text('Müzekker'), findsOneWidget);
      expect(find.text('Müennes'), findsOneWidget);
    },
  );

  testWidgets(
    'practice: broken plurals can be dropped into either broken plural slot',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(500, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeArea(
              child: PracticeScreen(
                data: nounTableFillTestData,
                random: Random(1),
              ),
            ),
          ),
        ),
      );

      await openTableFillPractice(tester);
      await selectTableFillCategory(tester, 'İsm-i Fâil');
      await tester.tap(find.text('Tabloyu Başlat'));
      await tester.pumpAndSettle();

      final token = find.ancestor(
        of: find.text('نُصَّارٌ'),
        matching: find.byWidgetPredicate((widget) => widget is Draggable),
      );
      final otherBrokenSlot = find.byKey(
        const ValueKey('drop-none-plural-masculine-نُصَّرٌ'),
      );

      await tester.ensureVisible(otherBrokenSlot);
      await tester.dragFrom(
        tester.getCenter(token),
        tester.getCenter(otherBrokenSlot) - tester.getCenter(token),
      );
      await tester.pumpAndSettle();

      final target = tester.widget<AnimatedContainer>(otherBrokenSlot);
      expect(
        (target.decoration as BoxDecoration).color,
        const Color(0xFFE0F3E5),
      );
      expect(
        find.descendant(
          of: otherBrokenSlot,
          matching: find.byIcon(Icons.check_circle),
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'conjugation: first-person row merges dual and plural into one Biz cell',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(500, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FormsTable(
              forms: firstPersonForms,
              selectedForm: FormSelection(
                person: FormPerson.first,
                number: FormNumber.plural,
                gender: FormGender.common,
              ),
              activeCategory: FormCategory.mazi,
              activeVoice: Voice.malum,
              onSelect: _ignoreSelection,
              highlightSelection: false,
            ),
          ),
        ),
      );

      expect(find.text('نَصَرْنَا'), findsOneWidget);
      expect(find.text('نَصَرْتُ'), findsOneWidget);
      expect(find.text('1. Şahıs\nOrtak'), findsOneWidget);
    },
  );

  testWidgets(
    'conjugation: noun category hides voice selector and handles table/chip clicks',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(home: ConjugationScreen(data: nounTestData)),
      );
      await navigateToConjugations(tester);

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
      await tester.ensureVisible(find.text('نَاصِرَةٌ').first);
      await tester.tap(find.text('نَاصِرَةٌ').first);
      await tester.pumpAndSettle();

      // ArabicResultCard should display the selected word and rule details
      expect(find.text('نَاصِرَةٌ'), findsWidgets);
      expect(find.textContaining('Yardım eden bir kadın.'), findsWidgets);

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
      expect(
        find.textContaining('Yardım eden erkekler (Kırık Çoğul 1).'),
        findsWidgets,
      );
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
            body: SafeArea(
              child: PracticeScreen(data: nounTestData, random: Random(1)),
            ),
          ),
        ),
      );
      await openMultipleChoicePractice(tester);

      // Initially, ismFail is selected by default in filters.
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).enabled,
        isTrue,
      );

      // Clear all categories
      await tester.tap(
        find
            .descendant(
              of: find.byType(Row),
              matching: find.text('Temizle').first,
            )
            .first,
      );
      await tester.pumpAndSettle();

      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).enabled,
        isFalse,
      );

      // Tap on the 'İsm-i Fâil' chip to select it again
      await tester.tap(find.text('İsm-i Fâil'));
      await tester.pumpAndSettle();

      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).enabled,
        isTrue,
      );

      // Start the practice
      await startPractice(tester);

      // Confirm we transition to the Practice view
      expect(find.text('Pratik'), findsOneWidget);

      // Check for prompt
      final promptFinder = find.byWidgetPredicate(
        (w) => w is Text && w.data != null && w.data!.contains('?'),
      );
      expect(promptFinder, findsOneWidget);

      final promptText = (tester.widget(promptFinder.first) as Text).data!;

      String correctAnswer = '';
      if (promptText.contains('anlamı hangisi')) {
        final arabicText =
            (tester.widget(
                      find
                          .byWidgetPredicate(
                            (w) =>
                                w is Text &&
                                w.data != '?' &&
                                w.data!.runes.any((r) => r > 1000),
                          )
                          .first,
                    )
                    as Text)
                .data!;
        final matchedForm = nounTestFormsList.firstWhere(
          (f) => f.arabic == arabicText,
        );
        correctAnswer = matchedForm.meaning;
      } else if (promptText.contains('dil bilgisi özelliği')) {
        final arabicText =
            (tester.widget(
                      find
                          .byWidgetPredicate(
                            (w) =>
                                w is Text &&
                                w.data != '?' &&
                                w.data!.runes.any((r) => r > 1000),
                          )
                          .first,
                    )
                    as Text)
                .data!;
        final matchedForm = nounTestFormsList.firstWhere(
          (f) => f.arabic == arabicText,
        );
        correctAnswer = matchedForm.pronounLabel;
      } else {
        final meaning = promptText.split('"')[1];
        final matchedForm = nounTestFormsList.firstWhere(
          (f) => f.meaning == meaning,
        );
        correctAnswer = matchedForm.arabic;
      }

      await tester.tap(find.text(correctAnswer));
      await tester.pumpAndSettle();

      expect(find.text('Doğru'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'conjugation: pronoun view renders independent and attached tables',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const MaterialApp(home: ConjugationScreen(data: pronounTestData)),
      );

      // Seçim ekranında 'Zamirler' kartına tıkla → ayrı sayfaya gider
      await tester.tap(find.text('Zamirler'));
      await tester.pumpAndSettle();

      expect(find.text('Ayrı Zamirler'), findsOneWidget);
      expect(find.text('هُوَ'), findsOneWidget);
      expect(find.text('أَنْتَ'), findsOneWidget);

      await tester.tap(find.text('Bitişik'));
      await tester.pumpAndSettle();

      expect(find.text('Bitişik Zamirler'), findsOneWidget);
      expect(find.text('ـهُ'), findsOneWidget);
      expect(find.text('ـكَ'), findsOneWidget);
      expect(find.textContaining('ضَرَبْتُهُ'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'lessons: pronoun lesson switches between independent and attached tables',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SafeArea(child: LessonsScreen(data: pronounTestData)),
          ),
        ),
      );

      await tester.tap(find.text('Şahıs Zamirleri'));
      await tester.pumpAndSettle();

      expect(find.text('Ayrı Zamirler'), findsOneWidget);
      expect(find.text('هُوَ'), findsOneWidget);

      await tester.tap(find.text('Bitişik'));
      await tester.pumpAndSettle();

      expect(find.text('Bitişik Zamirler'), findsOneWidget);
      expect(find.text('ـهُ'), findsOneWidget);
      expect(find.textContaining('iyelik veya mef‘ûl'), findsOneWidget);
    },
  );

  testWidgets(
    'conjugation: opening all tables page does not highlight cells in inactive tables',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(500, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(home: ConjugationScreen(data: richTestData)),
      );
      await navigateToConjugations(tester);

      // Open 'Tüm Muttaride Tablolarını Gör' page
      await tester.ensureVisible(find.text('Tüm Muttaride Tablolarını Gör'));
      await tester.tap(find.text('Tüm Muttaride Tablolarını Gör'));
      await tester.pumpAndSettle();

      // The default category on the main screen is Mazi Malum.
      // So on the All Tables page, the Mazi Malum table should highlight 'نَصَرَ' (Hüve).
      // But the Muzari Malum table ('يَنْصُرُ') should NOT highlight 'يَنْصُرُ' (Hüve).

      // Let's verify 'نَصَرَ' is highlighted (with primaryContainer color)
      final nasaraFinder = find.text('نَصَرَ');
      expect(nasaraFinder, findsAtLeastNWidgets(1));

      final nasaraContainers = tester.widgetList<Container>(
        find.ancestor(of: nasaraFinder, matching: find.byType(Container)),
      );

      bool foundHighlightedNasara = false;
      for (final container in nasaraContainers) {
        if (container.decoration is BoxDecoration) {
          final deco = container.decoration as BoxDecoration;
          if (deco.color != null) {
            foundHighlightedNasara = true;
            break;
          }
        }
      }
      expect(
        foundHighlightedNasara,
        isTrue,
        reason: 'Mazi Malum cell should be highlighted',
      );

      // Now verify 'يَنْصُرُ' (Muzari Malum) is NOT highlighted
      final yansuruFinder = find.text('يَنْصُرُ');
      expect(yansuruFinder, findsAtLeastNWidgets(1));

      final yansuruContainers = tester.widgetList<Container>(
        find.ancestor(of: yansuruFinder, matching: find.byType(Container)),
      );

      for (final container in yansuruContainers) {
        if (container.decoration is BoxDecoration) {
          final deco = container.decoration as BoxDecoration;
          expect(
            deco.color,
            isNull,
            reason: 'Muzari Malum cell should not be highlighted',
          );
        }
      }

      expect(tester.takeException(), isNull);
    },
  );
}

Future<void> navigateToConjugations(WidgetTester tester) async {
  await tester.tap(find.text('Çekimler'));
  await tester.pumpAndSettle();
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
  await openMultipleChoicePractice(tester);
  await tester.ensureVisible(find.text('Pratiğe Başla'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Pratiğe Başla'));
  await tester.pumpAndSettle();
}

Future<void> openMultipleChoicePractice(WidgetTester tester) async {
  if (find.text('Çoktan Seçmeli').evaluate().isEmpty) return;
  await tester.tap(find.text('Çoktan Seçmeli'));
  await tester.pumpAndSettle();
}

Future<void> openTableFillPractice(WidgetTester tester) async {
  await tester.tap(find.text('Tabloyu Doldur'));
  await tester.pumpAndSettle();
}

Future<void> selectTableFillCategory(
  WidgetTester tester,
  String categoryLabel,
) async {
  final dropdown = find.byType(DropdownButtonFormField<String>);
  await tester.tap(dropdown);
  await tester.pumpAndSettle();
  await tester.tap(find.text(categoryLabel).last);
  await tester.pumpAndSettle();
}

Future<void> dragArabicTokenTo(
  WidgetTester tester, {
  required String arabic,
  required Key targetKey,
}) async {
  final token = find.ancestor(
    of: find.text(arabic),
    matching: find.byWidgetPredicate((widget) => widget is Draggable),
  );
  final target = find.byKey(targetKey);
  await tester.dragFrom(
    tester.getCenter(token),
    tester.getCenter(target) - tester.getCenter(token),
  );
  await tester.pumpAndSettle();
}

void _ignoreSelection(FormSelection _) {}

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
  pronouns: [],
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
  pronouns: [],
  muhtelifeEntries: [],
  forms: nounTestFormsList,
  practiceQuestions: [],
);

const nounTableFillTestForms = [
  ...nounTestFormsList,
  ConjugationForm(
    category: FormCategory.ismFail,
    voice: Voice.malum,
    person: FormPerson.none,
    number: FormNumber.plural,
    gender: FormGender.masculine,
    pronounLabel: 'Kırık Çoğul Müzekker 2',
    arabic: 'نُصَّرٌ',
    meaning: 'Yardım eden erkekler (Kırık Çoğul 2).',
  ),
];

const nounTableFillTestData = AppData(
  lessons: [],
  pronouns: [],
  muhtelifeEntries: [],
  forms: nounTableFillTestForms,
  practiceQuestions: [],
);

const firstPersonForms = [
  ConjugationForm(
    category: FormCategory.mazi,
    voice: Voice.malum,
    person: FormPerson.first,
    number: FormNumber.singular,
    gender: FormGender.common,
    pronounLabel: 'Ben',
    arabic: 'نَصَرْتُ',
    meaning: 'Yardım ettim.',
  ),
  ConjugationForm(
    category: FormCategory.mazi,
    voice: Voice.malum,
    person: FormPerson.first,
    number: FormNumber.plural,
    gender: FormGender.common,
    pronounLabel: 'Biz',
    arabic: 'نَصَرْنَا',
    meaning: 'Yardım ettik.',
  ),
];

/// Richer dataset for interaction tests that need multiple forms.
const richTestData = AppData(
  lessons: [],
  pronouns: [],
  muhtelifeEntries: [],
  forms: testFormsList,
  practiceQuestions: [],
);

/// Two-question dataset for the "Sonraki Soru" advance test.
const multiQuestionData = AppData(
  lessons: [],
  pronouns: [],
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
  pronouns: [],
  muhtelifeEntries: [
    MuhtelifeEntry(
      type: 'fiil_mazi',
      label: 'Fiil-i Mâzi',
      arabic: 'نَصَرَ',
      meaning: 'Yardım etti.',
      sortOrder: 10,
      row: 1,
      column: 'left',
    ),
    MuhtelifeEntry(
      type: 'fiil_muzari',
      label: 'Fiil-i Muzâri',
      arabic: 'يَنْصُرُ',
      meaning: 'Yardım ediyor / yardım eder.',
      sortOrder: 20,
      row: 1,
      column: 'right',
    ),
    MuhtelifeEntry(
      type: 'masdar',
      label: 'Masdar-ı Gayr-ı Mîmî',
      arabic: 'نَصْرًا',
      meaning: 'Yardım etmek.',
      sortOrder: 30,
      row: 2,
      column: 'left',
    ),
    MuhtelifeEntry(
      type: 'ism_fail',
      label: 'İsm-i Fâil',
      arabic: 'نَاصِرٌ',
      meaning: 'Yardım eden.',
      sortOrder: 40,
      row: 2,
      column: 'right',
    ),
  ],
  forms: [],
  practiceQuestions: [],
);

const pronounTestData = AppData(
  lessons: [],
  pronouns: [
    PronounEntry(
      kind: PronounKind.independent,
      person: FormPerson.third,
      number: FormNumber.singular,
      gender: FormGender.masculine,
      labelTr: 'O',
      arabic: 'هُوَ',
      meaning: '3. şahıs müzekker tekil ayrı zamir',
    ),
    PronounEntry(
      kind: PronounKind.independent,
      person: FormPerson.second,
      number: FormNumber.singular,
      gender: FormGender.masculine,
      labelTr: 'Sen',
      arabic: 'أَنْتَ',
      meaning: '2. şahıs müzekker tekil ayrı zamir',
    ),
    PronounEntry(
      kind: PronounKind.independent,
      person: FormPerson.first,
      number: FormNumber.plural,
      gender: FormGender.common,
      labelTr: 'Biz',
      arabic: 'نَحْنُ',
      meaning: '1. şahıs ortak çoğul ayrı zamir',
    ),
    PronounEntry(
      kind: PronounKind.independent,
      person: FormPerson.first,
      number: FormNumber.dual,
      gender: FormGender.common,
      labelTr: 'İkimiz',
      arabic: 'نَحْنُ',
      meaning: '1. şahıs ortak ikil ayrı zamir',
    ),
    PronounEntry(
      kind: PronounKind.attached,
      person: FormPerson.third,
      number: FormNumber.singular,
      gender: FormGender.masculine,
      labelTr: 'Onun',
      arabic: 'ـهُ',
      meaning: '3. şahıs müzekker tekil bitişik zamir',
    ),
    PronounEntry(
      kind: PronounKind.attached,
      person: FormPerson.second,
      number: FormNumber.singular,
      gender: FormGender.masculine,
      labelTr: 'Senin',
      arabic: 'ـكَ',
      meaning: '2. şahıs müzekker tekil bitişik zamir',
    ),
  ],
  muhtelifeEntries: [],
  forms: testFormsList,
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
        child: IndexedStack(index: selectedIndex, children: screens),
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
            label: 'Hakkında',
          ),
        ],
      ),
    );
  }
}
