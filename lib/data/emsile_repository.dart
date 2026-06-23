import 'dart:convert';

import 'package:flutter/services.dart';

import 'catalog_models.dart';
import 'models.dart';
import 'muttaride_generator.dart';
import 'practice_question_generator.dart';

class EmsileRepository {
  EmsileRepository({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;

  Future<AppData> load() async {
    final catalogRaw = await _bundle.loadString('assets/data/catalog.json');
    final catalogJson = jsonDecode(catalogRaw) as Map<String, dynamic>;
    final catalog = CatalogData.fromJson(catalogJson);

    final manifest = catalog.verbs.firstWhere(
      (verb) => verb.id == catalog.defaultVerbId,
      orElse: () => throw StateError(
        'Default verb "${catalog.defaultVerbId}" not found in catalog.',
      ),
    );
    final verbRaw = await _bundle.loadString(manifest.assetPath);
    final verbJson = jsonDecode(verbRaw) as Map<String, dynamic>;
    final verbEntry = VerbEntry.fromJson(verbJson);
    final forms = MuttarideGenerator.fromVerbEntry(verbEntry);
    final ibareBooks = await Future.wait(
      catalog.ibareBooks.map((manifest) async {
        final raw = await _bundle.loadString(manifest.assetPath);
        final bookJson = jsonDecode(raw) as Map<String, dynamic>;
        Future<Map<String, dynamic>> loadPassage(String path) async {
          final passageRaw = await _bundle.loadString(path);
          return jsonDecode(passageRaw) as Map<String, dynamic>;
        }

        final fullBookJson = Map<String, dynamic>.from(bookJson);
        if (bookJson['sections'] case final List<dynamic> sections) {
          fullBookJson['sections'] = await Future.wait(
            sections.map((item) async {
              final section = Map<String, dynamic>.from(
                item as Map<String, dynamic>,
              );
              section['passages'] = await Future.wait(
                List<String>.from(section['passages'] as List).map(loadPassage),
              );
              return section;
            }),
          );
        } else {
          fullBookJson['passages'] = await Future.wait(
            List<String>.from(bookJson['passages'] as List).map(loadPassage),
          );
        }
        final book = IbareBook.fromJson(fullBookJson);
        if (book.id != manifest.id) {
          throw FormatException(
            'İbare kitap kimliği manifest ile eşleşmiyor: '
            '${manifest.id} != ${book.id}',
          );
        }
        return book;
      }),
    );

    final seedData = AppData(
      lessons: catalog.lessons,
      pronouns: catalog.pronouns,
      muhtelifeEntries: verbEntry.muhtelifeEntries,
      forms: forms,
      practiceQuestions: const [],
      ibareBooks: ibareBooks,
    );

    return seedData.copyWith(
      practiceQuestions: PracticeQuestionGenerator.fromForms(forms),
    );
  }
}
