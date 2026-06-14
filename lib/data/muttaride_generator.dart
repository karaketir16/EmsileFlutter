import 'catalog_models.dart';
import 'models.dart';

class MuttarideGenerator {
  const MuttarideGenerator._();

  static List<ConjugationForm> fromVerbEntry(VerbEntry entry) {
    if (entry.muttarideForms.isNotEmpty) {
      return entry.muttarideForms;
    }

    final source = entry.conjugationSource;
    if (source == null) {
      throw StateError(
        'Verb entry must define muttarideForms or conjugationSource.',
      );
    }

    switch (source.strategy) {
      case 'generated':
        final generated = source.generated;
        if (generated == null) {
          throw StateError(
            'Generated conjugation source is missing its config.',
          );
        }
        return _generate(entry.meta, generated);
      default:
        throw UnsupportedError(
          'Unsupported conjugation strategy: ${source.strategy}',
        );
    }
  }

  static List<ConjugationForm> _generate(
    VerbMeta meta,
    GeneratedConjugationSource config,
  ) {
    if (config.family != 'sulasi_mujarrad' ||
        config.verbClass != 'sahih_salim' ||
        config.bab != 'nasara_yansuru') {
      throw UnsupportedError(
        'Unsupported generated profile: ${config.family}/${config.verbClass}/${config.bab}',
      );
    }

    final forms = <ConjugationForm>[];

    for (final slot in _slots) {
      _addCoreForms(forms, meta.letters, slot);
      _addPrefixedMuzariForms(forms, meta.letters, slot);
      _addRestrictedCommandForms(forms, meta.letters, slot);
    }

    return forms;
  }

  static void _addCoreForms(
    List<ConjugationForm> forms,
    List<String> letters,
    _Slot slot,
  ) {
    forms
      ..add(
        _form(
          category: FormCategory.mazi,
          voice: Voice.malum,
          slot: slot,
          arabic: _maziMalum(letters, slot),
          meaning: '${slot.subjectPhrase} yardim etti.',
        ),
      )
      ..add(
        _form(
          category: FormCategory.mazi,
          voice: Voice.mechul,
          slot: slot,
          arabic: _maziMechul(letters, slot),
          meaning: '${slot.objectPhrase} icin yardim edildi.',
        ),
      )
      ..add(
        _form(
          category: FormCategory.muzari,
          voice: Voice.malum,
          slot: slot,
          arabic: _muzariMalum(letters, slot, _MuzariMood.marfu),
          meaning: '${slot.subjectPhrase} yardim ediyor.',
        ),
      )
      ..add(
        _form(
          category: FormCategory.muzari,
          voice: Voice.mechul,
          slot: slot,
          arabic: _muzariMechul(letters, slot, _MuzariMood.marfu),
          meaning: '${slot.objectPhrase} icin yardim ediliyor.',
        ),
      );
  }

  static void _addPrefixedMuzariForms(
    List<ConjugationForm> forms,
    List<String> letters,
    _Slot slot,
  ) {
    final specs = [
      _PrefixedMuzariSpec(
        category: FormCategory.nefyHal,
        prefix: 'مَا ',
        mood: _MuzariMood.marfu,
        activeMeaning: '${slot.subjectPhrase} yardim etmiyor.',
        passiveMeaning: '${slot.objectPhrase} icin yardim edilmiyor.',
      ),
      _PrefixedMuzariSpec(
        category: FormCategory.nefyIstikbal,
        prefix: 'لا ',
        mood: _MuzariMood.marfu,
        activeMeaning: '${slot.subjectPhrase} yardim etmeyecek.',
        passiveMeaning: '${slot.objectPhrase} icin yardim edilmeyecek.',
      ),
      _PrefixedMuzariSpec(
        category: FormCategory.cahdMutlak,
        prefix: 'لَمْ ',
        mood: _MuzariMood.majzum,
        activeMeaning: '${slot.subjectPhrase} yardim etmedi.',
        passiveMeaning: '${slot.objectPhrase} icin yardim edilmedi.',
      ),
      _PrefixedMuzariSpec(
        category: FormCategory.cahdMustagrak,
        prefix: 'لَمَّا ',
        mood: _MuzariMood.majzum,
        activeMeaning: '${slot.subjectPhrase} henuz yardim etmedi.',
        passiveMeaning: '${slot.objectPhrase} icin henuz yardim edilmedi.',
      ),
      _PrefixedMuzariSpec(
        category: FormCategory.tekidNefyIstikbal,
        prefix: 'لَنْ ',
        mood: _MuzariMood.mansub,
        activeMeaning: '${slot.subjectPhrase} asla yardim etmeyecek.',
        passiveMeaning: '${slot.objectPhrase} icin asla yardim edilmeyecek.',
      ),
    ];

    for (final spec in specs) {
      forms
        ..add(
          _form(
            category: spec.category,
            voice: Voice.malum,
            slot: slot,
            arabic: spec.prefix + _muzariMalum(letters, slot, spec.mood),
            meaning: spec.activeMeaning,
          ),
        )
        ..add(
          _form(
            category: spec.category,
            voice: Voice.mechul,
            slot: slot,
            arabic: spec.prefix + _muzariMechul(letters, slot, spec.mood),
            meaning: spec.passiveMeaning,
          ),
        );
    }
  }

  static void _addRestrictedCommandForms(
    List<ConjugationForm> forms,
    List<String> letters,
    _Slot slot,
  ) {
    if (slot.isThirdPerson) {
      forms
        ..add(
          _form(
            category: FormCategory.emrGaib,
            voice: Voice.malum,
            slot: slot,
            arabic: 'لِ${_muzariMalum(letters, slot, _MuzariMood.majzum)}',
            meaning: '${slot.subjectPhrase} yardim etsin.',
          ),
        )
        ..add(
          _form(
            category: FormCategory.nehyGaib,
            voice: Voice.malum,
            slot: slot,
            arabic: 'لا ${_muzariMalum(letters, slot, _MuzariMood.majzum)}',
            meaning: '${slot.subjectPhrase} yardim etmesin.',
          ),
        )
        ..add(
          _form(
            category: FormCategory.emrGaib,
            voice: Voice.mechul,
            slot: slot,
            arabic: 'لِ${_muzariMechul(letters, slot, _MuzariMood.majzum)}',
            meaning: '${slot.objectPhrase} icin yardim edilsin.',
          ),
        )
        ..add(
          _form(
            category: FormCategory.nehyGaib,
            voice: Voice.mechul,
            slot: slot,
            arabic: 'لا ${_muzariMechul(letters, slot, _MuzariMood.majzum)}',
            meaning: '${slot.objectPhrase} icin yardim edilmesin.',
          ),
        );
    }

    if (slot.isSecondPerson) {
      forms
        ..add(
          _form(
            category: FormCategory.emrHazir,
            voice: Voice.malum,
            slot: slot,
            arabic: _emrHazirMalum(letters, slot),
            meaning: '${slot.subjectPhrase} yardim et.',
          ),
        )
        ..add(
          _form(
            category: FormCategory.nehyHazir,
            voice: Voice.malum,
            slot: slot,
            arabic: 'لا ${_muzariMalum(letters, slot, _MuzariMood.majzum)}',
            meaning: '${slot.subjectPhrase} yardim etme.',
          ),
        )
        ..add(
          _form(
            category: FormCategory.emrHazir,
            voice: Voice.mechul,
            slot: slot,
            arabic: 'لِ${_muzariMechul(letters, slot, _MuzariMood.majzum)}',
            meaning: '${slot.objectPhrase} icin yardim edilsin.',
          ),
        )
        ..add(
          _form(
            category: FormCategory.nehyHazir,
            voice: Voice.mechul,
            slot: slot,
            arabic: 'لا ${_muzariMechul(letters, slot, _MuzariMood.majzum)}',
            meaning: '${slot.objectPhrase} icin yardim edilmesin.',
          ),
        );
    }

    if (slot.isFirstPerson) {
      forms
        ..add(
          _form(
            category: FormCategory.emrGaib,
            voice: Voice.mechul,
            slot: slot,
            arabic: 'لِ${_muzariMechul(letters, slot, _MuzariMood.majzum)}',
            meaning: '${slot.objectPhrase} icin yardim edilsin.',
          ),
        )
        ..add(
          _form(
            category: FormCategory.nehyGaib,
            voice: Voice.mechul,
            slot: slot,
            arabic: 'لا ${_muzariMechul(letters, slot, _MuzariMood.majzum)}',
            meaning: '${slot.objectPhrase} icin yardim edilmesin.',
          ),
        )
        ..add(
          _form(
            category: FormCategory.emrHazir,
            voice: Voice.mechul,
            slot: slot,
            arabic: 'لِ${_muzariMechul(letters, slot, _MuzariMood.majzum)}',
            meaning: '${slot.objectPhrase} icin yardim edilsin.',
          ),
        )
        ..add(
          _form(
            category: FormCategory.nehyHazir,
            voice: Voice.mechul,
            slot: slot,
            arabic: 'لا ${_muzariMechul(letters, slot, _MuzariMood.majzum)}',
            meaning: '${slot.objectPhrase} icin yardim edilmesin.',
          ),
        );
    }
  }

  static ConjugationForm _form({
    required FormCategory category,
    required Voice voice,
    required _Slot slot,
    required String arabic,
    required String meaning,
  }) {
    return ConjugationForm(
      category: category,
      voice: voice,
      person: slot.person,
      number: slot.number,
      gender: slot.gender,
      pronounLabel: slot.pronounLabel,
      arabic: arabic,
      meaning: meaning,
    );
  }

  static String _maziMalum(List<String> letters, _Slot slot) {
    return '${letters[0]}َ${letters[1]}َ${letters[2]}${slot.maziSuffixMalum}';
  }

  static String _maziMechul(List<String> letters, _Slot slot) {
    return '${letters[0]}ُ${letters[1]}ِ${letters[2]}${slot.maziSuffixMechul}';
  }

  static String _muzariMalum(
    List<String> letters,
    _Slot slot,
    _MuzariMood mood,
  ) {
    return '${slot.muzariPrefixMalum}${letters[0]}ْ${letters[1]}ُ${letters[2]}${slot.muzariSuffixMalumFor(mood)}';
  }

  static String _muzariMechul(
    List<String> letters,
    _Slot slot,
    _MuzariMood mood,
  ) {
    return '${slot.muzariPrefixMechul}${letters[0]}ْ${letters[1]}َ${letters[2]}${slot.muzariSuffixMechulFor(mood)}';
  }

  static String _emrHazirMalum(List<String> letters, _Slot slot) {
    return 'اُ${letters[0]}ْ${letters[1]}ُ${letters[2]}${slot.commandSuffix}';
  }
}

class _PrefixedMuzariSpec {
  const _PrefixedMuzariSpec({
    required this.category,
    required this.prefix,
    required this.mood,
    required this.activeMeaning,
    required this.passiveMeaning,
  });

  final FormCategory category;
  final String prefix;
  final _MuzariMood mood;
  final String activeMeaning;
  final String passiveMeaning;
}

enum _MuzariMood { marfu, majzum, mansub }

class _Slot {
  const _Slot({
    required this.person,
    required this.number,
    required this.gender,
    required this.pronounLabel,
    required this.subjectPhrase,
    required this.objectPhrase,
    required this.maziSuffixMalum,
    required this.maziSuffixMechul,
    required this.muzariPrefixMalum,
    required this.muzariPrefixMechul,
    required this.muzariSuffixMalum,
    required this.muzariSuffixMechul,
  });

  final FormPerson person;
  final FormNumber number;
  final FormGender gender;
  final String pronounLabel;
  final String subjectPhrase;
  final String objectPhrase;
  final String maziSuffixMalum;
  final String maziSuffixMechul;
  final String muzariPrefixMalum;
  final String muzariPrefixMechul;
  final String muzariSuffixMalum;
  final String muzariSuffixMechul;

  bool get isThirdPerson => person == FormPerson.third;
  bool get isSecondPerson => person == FormPerson.second;
  bool get isFirstPerson => person == FormPerson.first;

  String muzariSuffixMalumFor(_MuzariMood mood) {
    return _muzariSuffixFor(mood, muzariSuffixMalum);
  }

  String muzariSuffixMechulFor(_MuzariMood mood) {
    return _muzariSuffixFor(mood, muzariSuffixMechul);
  }

  String get commandSuffix {
    if (gender == FormGender.feminine && number == FormNumber.plural) {
      return 'ْنَ';
    }
    if (number == FormNumber.dual) {
      return 'َا';
    }
    if (number == FormNumber.plural && gender == FormGender.masculine) {
      return 'ُوا';
    }
    if (number == FormNumber.singular && gender == FormGender.feminine) {
      return 'ِي';
    }
    return 'ْ';
  }

  String _muzariSuffixFor(_MuzariMood mood, String marfuSuffix) {
    if (mood == _MuzariMood.marfu) {
      return marfuSuffix;
    }
    if (gender == FormGender.feminine && number == FormNumber.plural) {
      return 'ْنَ';
    }
    if (number == FormNumber.dual) {
      return 'َا';
    }
    if (number == FormNumber.plural && gender == FormGender.masculine) {
      return mood == _MuzariMood.majzum ? 'ُوا' : 'ُوا';
    }
    if (isSecondPerson && number == FormNumber.singular && gender == FormGender.feminine) {
      return 'ِي';
    }
    return mood == _MuzariMood.mansub ? 'َ' : 'ْ';
  }
}

const _slots = <_Slot>[
  _Slot(
    person: FormPerson.third,
    number: FormNumber.singular,
    gender: FormGender.masculine,
    pronounLabel: 'O (er.)',
    subjectPhrase: 'O erkek',
    objectPhrase: 'O erkek',
    maziSuffixMalum: 'َ',
    maziSuffixMechul: 'َ',
    muzariPrefixMalum: 'يَ',
    muzariPrefixMechul: 'يُ',
    muzariSuffixMalum: 'ُ',
    muzariSuffixMechul: 'ُ',
  ),
  _Slot(
    person: FormPerson.third,
    number: FormNumber.dual,
    gender: FormGender.masculine,
    pronounLabel: 'O ikisi (er.)',
    subjectPhrase: 'O iki erkek',
    objectPhrase: 'O iki erkek',
    maziSuffixMalum: 'َا',
    maziSuffixMechul: 'َا',
    muzariPrefixMalum: 'يَ',
    muzariPrefixMechul: 'يُ',
    muzariSuffixMalum: 'َانِ',
    muzariSuffixMechul: 'َانِ',
  ),
  _Slot(
    person: FormPerson.third,
    number: FormNumber.plural,
    gender: FormGender.masculine,
    pronounLabel: 'Onlar (er.)',
    subjectPhrase: 'O erkekler',
    objectPhrase: 'O erkekler',
    maziSuffixMalum: 'ُوا',
    maziSuffixMechul: 'ُوا',
    muzariPrefixMalum: 'يَ',
    muzariPrefixMechul: 'يُ',
    muzariSuffixMalum: 'ُونَ',
    muzariSuffixMechul: 'ُونَ',
  ),
  _Slot(
    person: FormPerson.third,
    number: FormNumber.singular,
    gender: FormGender.feminine,
    pronounLabel: 'O (kad.)',
    subjectPhrase: 'O kadin',
    objectPhrase: 'O kadin',
    maziSuffixMalum: 'َتْ',
    maziSuffixMechul: 'َتْ',
    muzariPrefixMalum: 'تَ',
    muzariPrefixMechul: 'تُ',
    muzariSuffixMalum: 'ُ',
    muzariSuffixMechul: 'ُ',
  ),
  _Slot(
    person: FormPerson.third,
    number: FormNumber.dual,
    gender: FormGender.feminine,
    pronounLabel: 'O ikisi (kad.)',
    subjectPhrase: 'O iki kadin',
    objectPhrase: 'O iki kadin',
    maziSuffixMalum: 'َتَا',
    maziSuffixMechul: 'َتَا',
    muzariPrefixMalum: 'تَ',
    muzariPrefixMechul: 'تُ',
    muzariSuffixMalum: 'َانِ',
    muzariSuffixMechul: 'َانِ',
  ),
  _Slot(
    person: FormPerson.third,
    number: FormNumber.plural,
    gender: FormGender.feminine,
    pronounLabel: 'Onlar (kad.)',
    subjectPhrase: 'O kadinlar',
    objectPhrase: 'O kadinlar',
    maziSuffixMalum: 'ْنَ',
    maziSuffixMechul: 'ْنَ',
    muzariPrefixMalum: 'يَ',
    muzariPrefixMechul: 'يُ',
    muzariSuffixMalum: 'ْنَ',
    muzariSuffixMechul: 'ْنَ',
  ),
  _Slot(
    person: FormPerson.second,
    number: FormNumber.singular,
    gender: FormGender.masculine,
    pronounLabel: 'Sen (er.)',
    subjectPhrase: 'Sen erkek',
    objectPhrase: 'Sen erkek',
    maziSuffixMalum: 'ْتَ',
    maziSuffixMechul: 'ْتَ',
    muzariPrefixMalum: 'تَ',
    muzariPrefixMechul: 'تُ',
    muzariSuffixMalum: 'ُ',
    muzariSuffixMechul: 'ُ',
  ),
  _Slot(
    person: FormPerson.second,
    number: FormNumber.dual,
    gender: FormGender.masculine,
    pronounLabel: 'Siz ikiniz (er.)',
    subjectPhrase: 'Siz iki erkek',
    objectPhrase: 'Siz iki erkek',
    maziSuffixMalum: 'ْتُمَا',
    maziSuffixMechul: 'ْتُمَا',
    muzariPrefixMalum: 'تَ',
    muzariPrefixMechul: 'تُ',
    muzariSuffixMalum: 'َانِ',
    muzariSuffixMechul: 'َانِ',
  ),
  _Slot(
    person: FormPerson.second,
    number: FormNumber.plural,
    gender: FormGender.masculine,
    pronounLabel: 'Siz (er.)',
    subjectPhrase: 'Siz erkekler',
    objectPhrase: 'Siz erkekler',
    maziSuffixMalum: 'ْتُمْ',
    maziSuffixMechul: 'ْتُمْ',
    muzariPrefixMalum: 'تَ',
    muzariPrefixMechul: 'تُ',
    muzariSuffixMalum: 'ُونَ',
    muzariSuffixMechul: 'ُونَ',
  ),
  _Slot(
    person: FormPerson.second,
    number: FormNumber.singular,
    gender: FormGender.feminine,
    pronounLabel: 'Sen (kad.)',
    subjectPhrase: 'Sen kadin',
    objectPhrase: 'Sen kadin',
    maziSuffixMalum: 'ْتِ',
    maziSuffixMechul: 'ْتِ',
    muzariPrefixMalum: 'تَ',
    muzariPrefixMechul: 'تُ',
    muzariSuffixMalum: 'ِينَ',
    muzariSuffixMechul: 'ِينَ',
  ),
  _Slot(
    person: FormPerson.second,
    number: FormNumber.dual,
    gender: FormGender.feminine,
    pronounLabel: 'Siz ikiniz (kad.)',
    subjectPhrase: 'Siz iki kadin',
    objectPhrase: 'Siz iki kadin',
    maziSuffixMalum: 'ْتُمَا',
    maziSuffixMechul: 'ْتُمَا',
    muzariPrefixMalum: 'تَ',
    muzariPrefixMechul: 'تُ',
    muzariSuffixMalum: 'َانِ',
    muzariSuffixMechul: 'َانِ',
  ),
  _Slot(
    person: FormPerson.second,
    number: FormNumber.plural,
    gender: FormGender.feminine,
    pronounLabel: 'Siz (kad.)',
    subjectPhrase: 'Siz kadinlar',
    objectPhrase: 'Siz kadinlar',
    maziSuffixMalum: 'ْتُنَّ',
    maziSuffixMechul: 'ْتُنَّ',
    muzariPrefixMalum: 'تَ',
    muzariPrefixMechul: 'تُ',
    muzariSuffixMalum: 'ْنَ',
    muzariSuffixMechul: 'ْنَ',
  ),
  _Slot(
    person: FormPerson.first,
    number: FormNumber.singular,
    gender: FormGender.common,
    pronounLabel: 'Ben',
    subjectPhrase: 'Ben',
    objectPhrase: 'Ben',
    maziSuffixMalum: 'ْتُ',
    maziSuffixMechul: 'ْتُ',
    muzariPrefixMalum: 'أَ',
    muzariPrefixMechul: 'أُ',
    muzariSuffixMalum: 'ُ',
    muzariSuffixMechul: 'ُ',
  ),
  _Slot(
    person: FormPerson.first,
    number: FormNumber.plural,
    gender: FormGender.common,
    pronounLabel: 'Biz',
    subjectPhrase: 'Biz',
    objectPhrase: 'Biz',
    maziSuffixMalum: 'ْنَا',
    maziSuffixMechul: 'ْنَا',
    muzariPrefixMalum: 'نَ',
    muzariPrefixMechul: 'نُ',
    muzariSuffixMalum: 'ُ',
    muzariSuffixMechul: 'ُ',
  ),
];
