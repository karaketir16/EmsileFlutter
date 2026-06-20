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

      expect(forms, hasLength(339));
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

      // 3. Şahıs Müfred Müennes Cehd-i Mutlak çekimi testi
      expect(
        _hasForm(
          forms,
          category: FormCategory.cahdMutlak,
          voice: Voice.malum,
          person: FormPerson.third,
          number: FormNumber.singular,
          gender: FormGender.feminine,
          arabic: 'لَمْ تَنْصُرْ',
        ),
        isTrue,
      );

      // İsm-i Fail (noun) checks
      expect(
        _hasForm(
          forms,
          category: FormCategory.ismFail,
          voice: Voice.malum,
          person: FormPerson.none,
          number: FormNumber.singular,
          gender: FormGender.masculine,
          arabic: 'نَ\ufe8eصِرٌ',
        ),
        isTrue,
      );

      expect(
        _hasForm(
          forms,
          category: FormCategory.ismFail,
          voice: Voice.malum,
          person: FormPerson.none,
          number: FormNumber.plural,
          gender: FormGender.masculine,
          arabic: 'نَ\ufe8eصِرُونَ',
        ),
        isTrue,
      );

      // Masdar Bina-i Merre checks (checking dual accusative casing as per Emsile rule: نَصْرَتَيْنِ)
      expect(
        _hasForm(
          forms,
          category: FormCategory.masdarMerre,
          voice: Voice.malum,
          person: FormPerson.none,
          number: FormNumber.dual,
          gender: FormGender.common,
          arabic: 'نَصْرَتَيْنِ',
        ),
        isTrue,
      );

      // Taaccub (fiilTaaccubEvvel) checks
      expect(
        _hasForm(
          forms,
          category: FormCategory.fiilTaaccubEvvel,
          voice: Voice.malum,
          person: FormPerson.second,
          number: FormNumber.singular,
          gender: FormGender.masculine,
          arabic: 'مَا أَنْصَرَكَ',
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

    test('generates natural Turkish person and case meanings', () {
      final entry = VerbEntry.fromJson(
        jsonDecode(nasaraVerbJson) as Map<String, dynamic>,
      );

      final forms = MuttarideGenerator.fromVerbEntry(entry);

      expect(
        _findForm(
          forms,
          category: FormCategory.mazi,
          voice: Voice.malum,
          person: FormPerson.second,
          number: FormNumber.dual,
          gender: FormGender.feminine,
        ).meaning,
        'İkiniz (kadın) yardım ettiniz.',
      );
      expect(
        _findForm(
          forms,
          category: FormCategory.mazi,
          voice: Voice.mechul,
          person: FormPerson.second,
          number: FormNumber.dual,
          gender: FormGender.feminine,
        ).meaning,
        'İkinize (kadın) yardım edildi.',
      );
      expect(
        _findForm(
          forms,
          category: FormCategory.emrHazir,
          voice: Voice.mechul,
          person: FormPerson.second,
          number: FormNumber.dual,
          gender: FormGender.feminine,
        ).meaning,
        'İkinize (kadın) yardım edilsin.',
      );
      expect(
        _findForm(
          forms,
          category: FormCategory.muzari,
          voice: Voice.malum,
          person: FormPerson.first,
          number: FormNumber.plural,
          gender: FormGender.common,
        ).meaning,
        'Biz yardım ediyoruz.',
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

ConjugationForm _findForm(
  List<ConjugationForm> forms, {
  required FormCategory category,
  required Voice voice,
  required FormPerson person,
  required FormNumber number,
  required FormGender gender,
}) {
  return forms.firstWhere(
    (form) =>
        form.category == category &&
        form.voice == voice &&
        form.person == person &&
        form.number == number &&
        form.gender == gender,
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
