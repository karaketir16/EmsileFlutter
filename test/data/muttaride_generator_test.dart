import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:emsile_flutter/data/catalog_models.dart';
import 'package:emsile_flutter/data/models.dart';
import 'package:emsile_flutter/data/muttaride_generator.dart';

void main() {
  group('MuttarideGenerator', () {
    test('generates all muttaride verb tables for nasara source', () {
      final entry = VerbEntry.fromJson(
        jsonDecode(nasaraVerbJson) as Map<String, dynamic>,
      );

      final forms = MuttarideGenerator.fromVerbEntry(entry);

      expect(forms, hasLength(252));
      expect(
        FormCategory.values.every(
          (category) => forms.any((form) => form.category == category),
        ),
        isTrue,
      );
    });

    test('generates key nasara forms correctly', () {
      final entry = VerbEntry.fromJson(
        jsonDecode(nasaraVerbJson) as Map<String, dynamic>,
      );

      final forms = MuttarideGenerator.fromVerbEntry(entry);

      expect(
        forms.any(
          (form) =>
              form.category == FormCategory.mazi &&
              form.voice == Voice.malum &&
              form.person == FormPerson.third &&
              form.number == FormNumber.singular &&
              form.gender == FormGender.masculine &&
              form.arabic == 'نَصَرَ',
        ),
        isTrue,
      );

      expect(
        forms.any(
          (form) =>
              form.category == FormCategory.mazi &&
              form.voice == Voice.mechul &&
              form.person == FormPerson.second &&
              form.number == FormNumber.singular &&
              form.gender == FormGender.masculine &&
              form.arabic == 'نُصِرْتَ',
        ),
        isTrue,
      );

      expect(
        forms.any(
          (form) =>
              form.category == FormCategory.muzari &&
              form.voice == Voice.malum &&
              form.person == FormPerson.second &&
              form.number == FormNumber.plural &&
              form.gender == FormGender.masculine &&
              form.arabic == 'تَنْصُرُونَ',
        ),
        isTrue,
      );

      expect(
        forms.any(
          (form) =>
              form.category == FormCategory.muzari &&
              form.voice == Voice.mechul &&
              form.person == FormPerson.first &&
              form.number == FormNumber.plural &&
              form.gender == FormGender.common &&
              form.arabic == 'نُنْصَرُ',
        ),
        isTrue,
      );

      expect(
        _hasForm(
          forms,
          category: FormCategory.cahdMutlak,
          voice: Voice.malum,
          person: FormPerson.third,
          number: FormNumber.singular,
          gender: FormGender.masculine,
          arabic: 'لَمْ يَنْصُرْ',
        ),
        isTrue,
      );

      expect(
        _hasForm(
          forms,
          category: FormCategory.tekidNefyIstikbal,
          voice: Voice.mechul,
          person: FormPerson.first,
          number: FormNumber.plural,
          gender: FormGender.common,
          arabic: 'لَنْ نُنْصَرَ',
        ),
        isTrue,
      );

      expect(
        _hasForm(
          forms,
          category: FormCategory.emrHazir,
          voice: Voice.malum,
          person: FormPerson.second,
          number: FormNumber.singular,
          gender: FormGender.masculine,
          arabic: 'اُنْصُرْ',
        ),
        isTrue,
      );

      expect(
        _hasForm(
          forms,
          category: FormCategory.nehyGaib,
          voice: Voice.malum,
          person: FormPerson.third,
          number: FormNumber.plural,
          gender: FormGender.masculine,
          arabic: 'لا يَنْصُرُوا',
        ),
        isTrue,
      );
    });

    test('does not generate unavailable command cells', () {
      final entry = VerbEntry.fromJson(
        jsonDecode(nasaraVerbJson) as Map<String, dynamic>,
      );

      final forms = MuttarideGenerator.fromVerbEntry(entry);

      expect(
        forms.any(
          (form) =>
              form.category == FormCategory.emrHazir &&
              form.voice == Voice.malum &&
              form.person == FormPerson.third,
        ),
        isFalse,
      );
      expect(
        forms.any(
          (form) =>
              form.category == FormCategory.emrGaib &&
              form.voice == Voice.malum &&
              form.person == FormPerson.second,
        ),
        isFalse,
      );
    });
  });
}

bool _hasForm(
  List<ConjugationForm> forms, {
  required FormCategory category,
  required Voice voice,
  required FormPerson person,
  required FormNumber number,
  required FormGender gender,
  required String arabic,
}) {
  return forms.any(
    (form) =>
        form.category == category &&
        form.voice == voice &&
        form.person == person &&
        form.number == number &&
        form.gender == gender &&
        form.arabic == arabic,
  );
}

const nasaraVerbJson = '''
{
  "meta": {
    "id": "nasara",
    "root": "نصر",
    "letters": ["ن", "ص", "ر"],
    "title": "نصر",
    "transliteration": "nasara",
    "meaningSummary": "yardım etmek",
    "group": "sulasi_mujarrad"
  },
  "muhtelifeEntries": [
    {
      "type": "fiil_mazi",
      "label": "Fiil-i Mâzi",
      "arabic": "نَصَرَ",
      "meaning": "Yardım etti.",
      "sortOrder": 10
    }
  ],
  "conjugationSource": {
    "strategy": "generated",
    "generated": {
      "family": "sulasi_mujarrad",
      "verbClass": "sahih_salim",
      "bab": "nasara_yansuru",
      "lemma": {
        "mazi": "نَصَرَ",
        "muzari": "يَنْصُرُ"
      }
    }
  }
}
''';
