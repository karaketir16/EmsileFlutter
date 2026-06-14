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

    _addNounForms(forms, meta.letters);
    _addTaaccubForms(forms, meta.letters);

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

void _addNounForms(List<ConjugationForm> forms, List<String> letters) {
  // 1. Masdar-ı Gayr-ı Mîmî (masdar)
  forms.add(ConjugationForm(
    category: FormCategory.masdar,
    voice: Voice.malum,
    person: FormPerson.none,
    number: FormNumber.singular,
    gender: FormGender.common,
    pronounLabel: 'Tekil',
    arabic: '${letters[0]}َ${letters[1]}ْ${letters[2]}ًا',
    meaning: 'Yardım etmek.',
  ));
  forms.add(ConjugationForm(
    category: FormCategory.masdar,
    voice: Voice.malum,
    person: FormPerson.none,
    number: FormNumber.dual,
    gender: FormGender.common,
    pronounLabel: 'İkil',
    arabic: '${letters[0]}َ${letters[1]}ْ${letters[2]}َانِ',
    meaning: 'İki kere yardım etmek.',
  ));
  forms.add(ConjugationForm(
    category: FormCategory.masdar,
    voice: Voice.malum,
    person: FormPerson.none,
    number: FormNumber.plural,
    gender: FormGender.common,
    pronounLabel: 'Çoğul',
    arabic: '${letters[0]}َ${letters[1]}َ${letters[2]}َاتٌ',
    meaning: 'Yardımlar.',
  ));

  // 2. İsm-i Fâil (ismFail)
  // Müzekker
  forms.add(ConjugationForm(
    category: FormCategory.ismFail,
    voice: Voice.malum,
    person: FormPerson.none,
    number: FormNumber.singular,
    gender: FormGender.masculine,
    pronounLabel: 'Tekil Müzekker',
    arabic: '${letters[0]}َﺎ${letters[1]}ِ${letters[2]}ٌ',
    meaning: 'Yardım eden bir erkek.',
  ));
  forms.add(ConjugationForm(
    category: FormCategory.ismFail,
    voice: Voice.malum,
    person: FormPerson.none,
    number: FormNumber.dual,
    gender: FormGender.masculine,
    pronounLabel: 'İkil Müzekker',
    arabic: '${letters[0]}َﺎ${letters[1]}ِ${letters[2]}َانِ',
    meaning: 'Yardım eden iki erkek.',
  ));
  forms.add(ConjugationForm(
    category: FormCategory.ismFail,
    voice: Voice.malum,
    person: FormPerson.none,
    number: FormNumber.plural,
    gender: FormGender.masculine,
    pronounLabel: 'Çoğul Müzekker (Sâlim)',
    arabic: '${letters[0]}َﺎ${letters[1]}ِ${letters[2]}ُونَ',
    meaning: 'Yardım eden erkekler.',
  ));
  // Müzekker Kırık Çoğullar
  forms.add(ConjugationForm(
    category: FormCategory.ismFail,
    voice: Voice.malum,
    person: FormPerson.none,
    number: FormNumber.plural,
    gender: FormGender.masculine,
    pronounLabel: 'Kırık Çoğul Müzekker 1',
    arabic: '${letters[0]}ُ${letters[1]}َّﺎ${letters[2]}ٌ',
    meaning: 'Yardım eden erkekler (Kırık Çoğul).',
  ));
  forms.add(ConjugationForm(
    category: FormCategory.ismFail,
    voice: Voice.malum,
    person: FormPerson.none,
    number: FormNumber.plural,
    gender: FormGender.masculine,
    pronounLabel: 'Kırık Çoğul Müzekker 2',
    arabic: '${letters[0]}ُ${letters[1]}َّ${letters[2]}ٌ',
    meaning: 'Yardım eden erkekler (Kırık Çoğul).',
  ));
  forms.add(ConjugationForm(
    category: FormCategory.ismFail,
    voice: Voice.malum,
    person: FormPerson.none,
    number: FormNumber.plural,
    gender: FormGender.masculine,
    pronounLabel: 'Kırık Çoğul Müzekker 3',
    arabic: '${letters[0]}َ${letters[1]}َ${letters[2]}َةٌ',
    meaning: 'Yardım eden erkekler (Kırık Çoğul).',
  ));
  // Müennes
  forms.add(ConjugationForm(
    category: FormCategory.ismFail,
    voice: Voice.malum,
    person: FormPerson.none,
    number: FormNumber.singular,
    gender: FormGender.feminine,
    pronounLabel: 'Tekil Müennes',
    arabic: '${letters[0]}َﺎ${letters[1]}ِ${letters[2]}َةٌ',
    meaning: 'Yardım eden bir kadın.',
  ));
  forms.add(ConjugationForm(
    category: FormCategory.ismFail,
    voice: Voice.malum,
    person: FormPerson.none,
    number: FormNumber.dual,
    gender: FormGender.feminine,
    pronounLabel: 'İkil Müennes',
    arabic: '${letters[0]}َﺎ${letters[1]}ِ${letters[2]}َتَانِ',
    meaning: 'Yardım eden iki kadın.',
  ));
  forms.add(ConjugationForm(
    category: FormCategory.ismFail,
    voice: Voice.malum,
    person: FormPerson.none,
    number: FormNumber.plural,
    gender: FormGender.feminine,
    pronounLabel: 'Çoğul Müennes (Sâlim)',
    arabic: '${letters[0]}َﺎ${letters[1]}ِ${letters[2]}َاتٌ',
    meaning: 'Yardım eden kadınlar.',
  ));
  forms.add(ConjugationForm(
    category: FormCategory.ismFail,
    voice: Voice.malum,
    person: FormPerson.none,
    number: FormNumber.plural,
    gender: FormGender.feminine,
    pronounLabel: 'Kırık Çoğul Müennes',
    arabic: '${letters[0]}َﻮَا${letters[1]}ِ${letters[2]}ُ',
    meaning: 'Yardım eden kadınlar (Kırık Çoğul).',
  ));

  // 3. İsm-i Mef'ûl (ismMeful)
  // Müzekker
  forms.add(ConjugationForm(
    category: FormCategory.ismMeful,
    voice: Voice.mechul,
    person: FormPerson.none,
    number: FormNumber.singular,
    gender: FormGender.masculine,
    pronounLabel: 'Tekil Müzekker',
    arabic: 'مَ${letters[0]}ْ${letters[1]}ُو${letters[2]}ٌ',
    meaning: 'Yardım edilen bir erkek.',
  ));
  forms.add(ConjugationForm(
    category: FormCategory.ismMeful,
    voice: Voice.mechul,
    person: FormPerson.none,
    number: FormNumber.dual,
    gender: FormGender.masculine,
    pronounLabel: 'İkil Müzekker',
    arabic: 'مَ${letters[0]}ْ${letters[1]}ُو${letters[2]}َانِ',
    meaning: 'Yardım edilen iki erkek.',
  ));
  forms.add(ConjugationForm(
    category: FormCategory.ismMeful,
    voice: Voice.mechul,
    person: FormPerson.none,
    number: FormNumber.plural,
    gender: FormGender.masculine,
    pronounLabel: 'Çoğul Müzekker (Sâlim)',
    arabic: 'مَ${letters[0]}ْ${letters[1]}ُو${letters[2]}ُونَ',
    meaning: 'Yardım edilen erkekler.',
  ));
  // Müennes
  forms.add(ConjugationForm(
    category: FormCategory.ismMeful,
    voice: Voice.mechul,
    person: FormPerson.none,
    number: FormNumber.singular,
    gender: FormGender.feminine,
    pronounLabel: 'Tekil Müennes',
    arabic: 'مَ${letters[0]}ْ${letters[1]}ُو${letters[2]}َةٌ',
    meaning: 'Yardım edilen bir kadın.',
  ));
  forms.add(ConjugationForm(
    category: FormCategory.ismMeful,
    voice: Voice.mechul,
    person: FormPerson.none,
    number: FormNumber.dual,
    gender: FormGender.feminine,
    pronounLabel: 'İkil Müennes',
    arabic: 'مَ${letters[0]}ْ${letters[1]}ُو${letters[2]}َتَانِ',
    meaning: 'Yardım edilen iki kadın.',
  ));
  forms.add(ConjugationForm(
    category: FormCategory.ismMeful,
    voice: Voice.mechul,
    person: FormPerson.none,
    number: FormNumber.plural,
    gender: FormGender.feminine,
    pronounLabel: 'Çoğul Müennes (Sâlim)',
    arabic: 'مَ${letters[0]}ْ${letters[1]}ُو${letters[2]}َاتٌ',
    meaning: 'Yardım edilen kadınlar.',
  ));
  // Kırık Çoğul
  forms.add(ConjugationForm(
    category: FormCategory.ismMeful,
    voice: Voice.mechul,
    person: FormPerson.none,
    number: FormNumber.plural,
    gender: FormGender.common,
    pronounLabel: 'Kırık Çoğul',
    arabic: 'مَ${letters[0]}َﺎ${letters[1]}ِﻴ${letters[2]}ُ',
    meaning: 'Yardım edilenler (Kırık Çoğul).',
  ));
  forms.add(ConjugationForm(
    category: FormCategory.ismMeful,
    voice: Voice.mechul,
    person: FormPerson.none,
    number: FormNumber.plural,
    gender: FormGender.common,
    pronounLabel: 'Kırık Çoğul (Emsile)',
    arabic: 'مَ${letters[0]}َﺎ${letters[1]}ِ${letters[2]}ُ',
    meaning: 'Yardım edilenler (Kırık Çoğul).',
  ));

  // 4. İsm-i Zaman / Mekân / Masdar-ı Mîmî (ismZamanMekan)
  forms.add(ConjugationForm(
    category: FormCategory.ismZamanMekan,
    voice: Voice.malum,
    person: FormPerson.none,
    number: FormNumber.singular,
    gender: FormGender.common,
    pronounLabel: 'Tekil',
    arabic: 'مَ${letters[0]}ْ${letters[1]}َ${letters[2]}ٌ',
    meaning: 'Yardım etme zamanı, yeri veya yardım etmek.',
  ));
  forms.add(ConjugationForm(
    category: FormCategory.ismZamanMekan,
    voice: Voice.malum,
    person: FormPerson.none,
    number: FormNumber.dual,
    gender: FormGender.common,
    pronounLabel: 'İkil',
    arabic: 'مَ${letters[0]}ْ${letters[1]}َ${letters[2]}َانِ',
    meaning: 'İki yardım zamanı / yeri.',
  ));
  forms.add(ConjugationForm(
    category: FormCategory.ismZamanMekan,
    voice: Voice.malum,
    person: FormPerson.none,
    number: FormNumber.plural,
    gender: FormGender.common,
    pronounLabel: 'Kırık Çoğul',
    arabic: 'مَ${letters[0]}َﺎ${letters[1]}ِ${letters[2]}ُ',
    meaning: 'Yardım etme zamanları / yerleri.',
  ));

  // 5. İsm-i Âlet (ismAlet)
  forms.add(ConjugationForm(
    category: FormCategory.ismAlet,
    voice: Voice.malum,
    person: FormPerson.none,
    number: FormNumber.singular,
    gender: FormGender.common,
    pronounLabel: 'Tekil',
    arabic: 'مِ${letters[0]}ْ${letters[1]}َ${letters[2]}ٌ',
    meaning: 'Yardım etme aleti.',
  ));
  forms.add(ConjugationForm(
    category: FormCategory.ismAlet,
    voice: Voice.malum,
    person: FormPerson.none,
    number: FormNumber.dual,
    gender: FormGender.common,
    pronounLabel: 'İkil',
    arabic: 'مِ${letters[0]}ْ${letters[1]}َ${letters[2]}َانِ',
    meaning: 'İki yardım aleti.',
  ));
  forms.add(ConjugationForm(
    category: FormCategory.ismAlet,
    voice: Voice.malum,
    person: FormPerson.none,
    number: FormNumber.plural,
    gender: FormGender.common,
    pronounLabel: 'Kırık Çoğul',
    arabic: 'مَ${letters[0]}َﺎ${letters[1]}ِ${letters[2]}ُ',
    meaning: 'Yardım etme aletleri.',
  ));

  // 6. Masdar Bina-i Merre (masdarMerre)
  forms.add(ConjugationForm(
    category: FormCategory.masdarMerre,
    voice: Voice.malum,
    person: FormPerson.none,
    number: FormNumber.singular,
    gender: FormGender.common,
    pronounLabel: 'Tekil',
    arabic: '${letters[0]}َ${letters[1]}ْ${letters[2]}َةً',
    meaning: 'Bir kere yardım etmek.',
  ));
  forms.add(ConjugationForm(
    category: FormCategory.masdarMerre,
    voice: Voice.malum,
    person: FormPerson.none,
    number: FormNumber.dual,
    gender: FormGender.common,
    pronounLabel: 'İkil',
    arabic: '${letters[0]}َ${letters[1]}ْ${letters[2]}َتَيْنِ',
    meaning: 'İki kere yardım etmek.',
  ));
  forms.add(ConjugationForm(
    category: FormCategory.masdarMerre,
    voice: Voice.malum,
    person: FormPerson.none,
    number: FormNumber.plural,
    gender: FormGender.common,
    pronounLabel: 'Çoğul',
    arabic: '${letters[0]}َ${letters[1]}َ${letters[2]}َاتٌ',
    meaning: 'Yardımlar.',
  ));

  // 7. Masdar Bina-i Nev' (masdarNev)
  forms.add(ConjugationForm(
    category: FormCategory.masdarNev,
    voice: Voice.malum,
    person: FormPerson.none,
    number: FormNumber.singular,
    gender: FormGender.common,
    pronounLabel: 'Tekil',
    arabic: '${letters[0]}ِ${letters[1]}ْ${letters[2]}َةً',
    meaning: 'Bir nevi yardım etmek.',
  ));
  forms.add(ConjugationForm(
    category: FormCategory.masdarNev,
    voice: Voice.malum,
    person: FormPerson.none,
    number: FormNumber.dual,
    gender: FormGender.common,
    pronounLabel: 'İkil',
    arabic: '${letters[0]}ِ${letters[1]}ْ${letters[2]}َتَيْنِ',
    meaning: 'İki nevi yardım etmek.',
  ));
  forms.add(ConjugationForm(
    category: FormCategory.masdarNev,
    voice: Voice.malum,
    person: FormPerson.none,
    number: FormNumber.plural,
    gender: FormGender.common,
    pronounLabel: 'Çoğul',
    arabic: '${letters[0]}ِ${letters[1]}ْ${letters[2]}َاتٌ',
    meaning: 'Yardım çeşitleri.',
  ));

  // 8. İsm-i Tasğir (ismTasgir)
  // Müzekker
  forms.add(ConjugationForm(
    category: FormCategory.ismTasgir,
    voice: Voice.malum,
    person: FormPerson.none,
    number: FormNumber.singular,
    gender: FormGender.masculine,
    pronounLabel: 'Tekil Müzekker',
    arabic: '${letters[0]}ُ${letters[1]}َﻴْ${letters[2]}ٌ',
    meaning: 'Küçük yardım eden erkek (yardımcık).',
  ));
  forms.add(ConjugationForm(
    category: FormCategory.ismTasgir,
    voice: Voice.malum,
    person: FormPerson.none,
    number: FormNumber.dual,
    gender: FormGender.masculine,
    pronounLabel: 'İkil Müzekker',
    arabic: '${letters[0]}ُ${letters[1]}َﻴْ${letters[2]}َانِ',
    meaning: 'Küçük yardım eden iki erkek.',
  ));
  forms.add(ConjugationForm(
    category: FormCategory.ismTasgir,
    voice: Voice.malum,
    person: FormPerson.none,
    number: FormNumber.plural,
    gender: FormGender.masculine,
    pronounLabel: 'Çoğul Müzekker',
    arabic: '${letters[0]}ُ${letters[1]}َﻴْ${letters[2]}ُونَ',
    meaning: 'Küçük yardım eden erkekler.',
  ));
  // Müennes
  forms.add(ConjugationForm(
    category: FormCategory.ismTasgir,
    voice: Voice.malum,
    person: FormPerson.none,
    number: FormNumber.singular,
    gender: FormGender.feminine,
    pronounLabel: 'Tekil Müennes',
    arabic: '${letters[0]}ُ${letters[1]}َﻴْ${letters[2]}َةٌ',
    meaning: 'Küçük yardım eden kadın.',
  ));
  forms.add(ConjugationForm(
    category: FormCategory.ismTasgir,
    voice: Voice.malum,
    person: FormPerson.none,
    number: FormNumber.dual,
    gender: FormGender.feminine,
    pronounLabel: 'İkil Müennes',
    arabic: '${letters[0]}ُ${letters[1]}َﻴْ${letters[2]}َتَانِ',
    meaning: 'Küçük yardım eden iki kadın.',
  ));
  forms.add(ConjugationForm(
    category: FormCategory.ismTasgir,
    voice: Voice.malum,
    person: FormPerson.none,
    number: FormNumber.plural,
    gender: FormGender.feminine,
    pronounLabel: 'Çoğul Müennes',
    arabic: '${letters[0]}ُ${letters[1]}َﻴْ${letters[2]}َاتٌ',
    meaning: 'Küçük yardım eden kadınlar.',
  ));

  // 9. İsm-i Mensub (ismMensub)
  // Müzekker
  forms.add(ConjugationForm(
    category: FormCategory.ismMensub,
    voice: Voice.malum,
    person: FormPerson.none,
    number: FormNumber.singular,
    gender: FormGender.masculine,
    pronounLabel: 'Tekil Müzekker',
    arabic: '${letters[0]}َ${letters[1]}ْ${letters[2]}ِيٌّ',
    meaning: 'Yardımla ilgili / yardıma mensup erkek.',
  ));
  forms.add(ConjugationForm(
    category: FormCategory.ismMensub,
    voice: Voice.malum,
    person: FormPerson.none,
    number: FormNumber.dual,
    gender: FormGender.masculine,
    pronounLabel: 'İkil Müzekker',
    arabic: '${letters[0]}َ${letters[1]}ْ${letters[2]}ِيَّانِ',
    meaning: 'Yardımla ilgili iki erkek.',
  ));
  forms.add(ConjugationForm(
    category: FormCategory.ismMensub,
    voice: Voice.malum,
    person: FormPerson.none,
    number: FormNumber.plural,
    gender: FormGender.masculine,
    pronounLabel: 'Çoğul Müzekker',
    arabic: '${letters[0]}َ${letters[1]}ْ${letters[2]}ِيُّونَ',
    meaning: 'Yardımla ilgili erkekler.',
  ));
  // Müennes
  forms.add(ConjugationForm(
    category: FormCategory.ismMensub,
    voice: Voice.malum,
    person: FormPerson.none,
    number: FormNumber.singular,
    gender: FormGender.feminine,
    pronounLabel: 'Tekil Müennes',
    arabic: '${letters[0]}َ${letters[1]}ْ${letters[2]}ِيَّةٌ',
    meaning: 'Yardımla ilgili kadın.',
  ));
  forms.add(ConjugationForm(
    category: FormCategory.ismMensub,
    voice: Voice.malum,
    person: FormPerson.none,
    number: FormNumber.dual,
    gender: FormGender.feminine,
    pronounLabel: 'İkil Müennes',
    arabic: '${letters[0]}َ${letters[1]}ْ${letters[2]}ِيَّتَانِ',
    meaning: 'Yardımla ilgili iki kadın.',
  ));
  forms.add(ConjugationForm(
    category: FormCategory.ismMensub,
    voice: Voice.malum,
    person: FormPerson.none,
    number: FormNumber.plural,
    gender: FormGender.feminine,
    pronounLabel: 'Çoğul Müennes',
    arabic: '${letters[0]}َ${letters[1]}ْ${letters[2]}ِيَّاتٌ',
    meaning: 'Yardımla ilgili kadınlar.',
  ));

  // 10. Mübalağa İsm-i Fâil (mubalagaIsmFail)
  // Müzekker
  forms.add(ConjugationForm(
    category: FormCategory.mubalagaIsmFail,
    voice: Voice.malum,
    person: FormPerson.none,
    number: FormNumber.singular,
    gender: FormGender.masculine,
    pronounLabel: 'Tekil Müzekker',
    arabic: '${letters[0]}َ${letters[1]}َّﺎ${letters[2]}ٌ',
    meaning: 'Çok yardım eden erkek.',
  ));
  forms.add(ConjugationForm(
    category: FormCategory.mubalagaIsmFail,
    voice: Voice.malum,
    person: FormPerson.none,
    number: FormNumber.dual,
    gender: FormGender.masculine,
    pronounLabel: 'İkil Müzekker',
    arabic: '${letters[0]}َ${letters[1]}َّﺎ${letters[2]}َانِ',
    meaning: 'Çok yardım eden iki erkek.',
  ));
  forms.add(ConjugationForm(
    category: FormCategory.mubalagaIsmFail,
    voice: Voice.malum,
    person: FormPerson.none,
    number: FormNumber.plural,
    gender: FormGender.masculine,
    pronounLabel: 'Çoğul Müzekker',
    arabic: '${letters[0]}َ${letters[1]}َّﺎ${letters[2]}ُونَ',
    meaning: 'Çok yardım eden erkekler.',
  ));
  // Müennes
  forms.add(ConjugationForm(
    category: FormCategory.mubalagaIsmFail,
    voice: Voice.malum,
    person: FormPerson.none,
    number: FormNumber.singular,
    gender: FormGender.feminine,
    pronounLabel: 'Tekil Müennes',
    arabic: '${letters[0]}َ${letters[1]}َّﺎ${letters[2]}َةٌ',
    meaning: 'Çok yardım eden kadın.',
  ));
  forms.add(ConjugationForm(
    category: FormCategory.mubalagaIsmFail,
    voice: Voice.malum,
    person: FormPerson.none,
    number: FormNumber.dual,
    gender: FormGender.feminine,
    pronounLabel: 'İkil Müennes',
    arabic: '${letters[0]}َ${letters[1]}َّﺎ${letters[2]}َتَانِ',
    meaning: 'Çok yardım eden iki kadın.',
  ));
  forms.add(ConjugationForm(
    category: FormCategory.mubalagaIsmFail,
    voice: Voice.malum,
    person: FormPerson.none,
    number: FormNumber.plural,
    gender: FormGender.feminine,
    pronounLabel: 'Çoğul Müennes',
    arabic: '${letters[0]}َ${letters[1]}َّﺎ${letters[2]}َاتٌ',
    meaning: 'Çok yardım eden kadınlar.',
  ));

  // 11. İsm-i Tafdil (ismTafdil)
  // Müzekker
  forms.add(ConjugationForm(
    category: FormCategory.ismTafdil,
    voice: Voice.malum,
    person: FormPerson.none,
    number: FormNumber.singular,
    gender: FormGender.masculine,
    pronounLabel: 'Tekil Müzekker',
    arabic: 'أَ${letters[0]}ْ${letters[1]}َ${letters[2]}ُ',
    meaning: 'En çok yardım eden erkek.',
  ));
  forms.add(ConjugationForm(
    category: FormCategory.ismTafdil,
    voice: Voice.malum,
    person: FormPerson.none,
    number: FormNumber.dual,
    gender: FormGender.masculine,
    pronounLabel: 'İkil Müzekker',
    arabic: 'أَ${letters[0]}ْ${letters[1]}َ${letters[2]}َانِ',
    meaning: 'En çok yardım eden iki erkek.',
  ));
  forms.add(ConjugationForm(
    category: FormCategory.ismTafdil,
    voice: Voice.malum,
    person: FormPerson.none,
    number: FormNumber.plural,
    gender: FormGender.masculine,
    pronounLabel: 'Çoğul Müzekker (Sâlim)',
    arabic: 'أَ${letters[0]}ْ${letters[1]}َ${letters[2]}ُونَ',
    meaning: 'En çok yardım eden erkekler.',
  ));
  forms.add(ConjugationForm(
    category: FormCategory.ismTafdil,
    voice: Voice.malum,
    person: FormPerson.none,
    number: FormNumber.plural,
    gender: FormGender.masculine,
    pronounLabel: 'Kırık Çoğul Müzekker',
    arabic: 'أَ${letters[0]}َﺎ${letters[1]}ِ${letters[2]}ُ',
    meaning: 'En çok yardım eden erkekler (Kırık Çoğul).',
  ));
  // Müennes
  forms.add(ConjugationForm(
    category: FormCategory.ismTafdil,
    voice: Voice.malum,
    person: FormPerson.none,
    number: FormNumber.singular,
    gender: FormGender.feminine,
    pronounLabel: 'Tekil Müennes',
    arabic: '${letters[0]}ُ${letters[1]}ْ${letters[2]}َى',
    meaning: 'En çok yardım eden kadın.',
  ));
  forms.add(ConjugationForm(
    category: FormCategory.ismTafdil,
    voice: Voice.malum,
    person: FormPerson.none,
    number: FormNumber.dual,
    gender: FormGender.feminine,
    pronounLabel: 'İkil Müennes',
    arabic: '${letters[0]}ُ${letters[1]}ْ${letters[2]}َيَانِ',
    meaning: 'En çok yardım eden iki kadın.',
  ));
  forms.add(ConjugationForm(
    category: FormCategory.ismTafdil,
    voice: Voice.malum,
    person: FormPerson.none,
    number: FormNumber.plural,
    gender: FormGender.feminine,
    pronounLabel: 'Çoğul Müennes (Sâlim)',
    arabic: '${letters[0]}ُ${letters[1]}ْ${letters[2]}َيَاتٌ',
    meaning: 'En çok yardım eden kadınlar.',
  ));
  forms.add(ConjugationForm(
    category: FormCategory.ismTafdil,
    voice: Voice.malum,
    person: FormPerson.none,
    number: FormNumber.plural,
    gender: FormGender.feminine,
    pronounLabel: 'Kırık Çoğul Müennes',
    arabic: '${letters[0]}ُ${letters[1]}َ${letters[2]}ُ',
    meaning: 'En çok yardım eden kadınlar (Kırık Çoğul).',
  ));
}

void _addTaaccubForms(List<ConjugationForm> forms, List<String> letters) {
  for (final slot in _slots) {
    final evvelSuffix = _attachedPronounFor(slot.person, slot.number, slot.gender);
    final evvelArabic = 'مَا أَ${letters[0]}ْ${letters[1]}َ${letters[2]}َ$evvelSuffix';

    final saniSuffix = _saniSuffixFor(slot.person, slot.number, slot.gender);
    final saniArabic = 'أَ${letters[0]}ْ${letters[1]}ِ${letters[2]}ْ $saniSuffix';

    forms.add(ConjugationForm(
      category: FormCategory.fiilTaaccubEvvel,
      voice: Voice.malum,
      person: slot.person,
      number: slot.number,
      gender: slot.gender,
      pronounLabel: slot.pronounLabel,
      arabic: evvelArabic,
      meaning: 'O ne garip yardım etti (${slot.subjectPhrase.toLowerCase()}).',
    ));

    forms.add(ConjugationForm(
      category: FormCategory.fiilTaaccubSani,
      voice: Voice.malum,
      person: slot.person,
      number: slot.number,
      gender: slot.gender,
      pronounLabel: slot.pronounLabel,
      arabic: saniArabic,
      meaning: 'Ne acayip yardım etti (${slot.subjectPhrase.toLowerCase()}).',
    ));
  }
}

String _attachedPronounFor(FormPerson person, FormNumber number, FormGender gender) {
  if (person == FormPerson.third) {
    if (number == FormNumber.singular) {
      return gender == FormGender.masculine ? 'هُ' : 'هَا';
    } else if (number == FormNumber.dual) {
      return 'هُمَا';
    } else {
      return gender == FormGender.masculine ? 'هُمْ' : 'هُنَّ';
    }
  } else if (person == FormPerson.second) {
    if (number == FormNumber.singular) {
      return gender == FormGender.masculine ? 'كَ' : 'كِ';
    } else if (number == FormNumber.dual) {
      return 'كُمَا';
    } else {
      return gender == FormGender.masculine ? 'كُمْ' : 'كُنَّ';
    }
  } else {
    return number == FormNumber.singular ? 'نِي' : 'نَا';
  }
}

String _saniSuffixFor(FormPerson person, FormNumber number, FormGender gender) {
  if (person == FormPerson.third) {
    if (number == FormNumber.singular) {
      return gender == FormGender.masculine ? 'بِهِ' : 'بِهَا';
    } else if (number == FormNumber.dual) {
      return 'بِهِمَا';
    } else {
      return gender == FormGender.masculine ? 'بِهِمْ' : 'بِهِنَّ';
    }
  } else if (person == FormPerson.second) {
    if (number == FormNumber.singular) {
      return gender == FormGender.masculine ? 'بِكَ' : 'بِكِ';
    } else if (number == FormNumber.dual) {
      return 'بِكُمَا';
    } else {
      return gender == FormGender.masculine ? 'بِكُمْ' : 'بِكُنَّ';
    }
  } else {
    return number == FormNumber.singular ? 'بِي' : 'بِنَا';
  }
}
