enum FormCategory {
  mazi('Mâzi'),
  muzari('Muzâri'),
  cahdMutlak('Cahd-ı Mutlak'),
  cahdMustagrak('Cahd-ı Mustağrak'),
  nefyHal('Nefy-i Hâl'),
  nefyIstikbal('Nefy-i İstikbâl'),
  tekidNefyIstikbal("Te'kid-i Nefy-i İstikbâl"),
  emrGaib('Emr-i Gâib'),
  nehyGaib('Nehy-i Gâib'),
  emrHazir('Emr-i Hâzır'),
  nehyHazir('Nehy-i Hâzır');

  const FormCategory(this.label);
  final String label;

  static FormCategory fromJson(String value) {
    return FormCategory.values.firstWhere((category) => category.name == value);
  }
}

enum Voice {
  malum('Malum'),
  mechul('Meçhul');

  const Voice(this.label);
  final String label;

  static Voice fromJson(String value) {
    return Voice.values.firstWhere((voice) => voice.name == value);
  }
}

class AppData {
  const AppData({
    required this.lessons,
    required this.muhtelifeEntries,
    required this.forms,
    required this.practiceQuestions,
  });

  final List<Lesson> lessons;
  final List<MuhtelifeEntry> muhtelifeEntries;
  final List<ConjugationForm> forms;
  final List<PracticeQuestion> practiceQuestions;

  factory AppData.fromJson(Map<String, dynamic> json) {
    return AppData(
      lessons: (json['lessons'] as List<dynamic>)
          .map((item) => Lesson.fromJson(item as Map<String, dynamic>))
          .toList(),
      muhtelifeEntries: ((json['muhtelifeEntries'] as List<dynamic>?) ?? [])
          .map((item) => MuhtelifeEntry.fromJson(item as Map<String, dynamic>))
          .toList(),
      forms: (json['forms'] as List<dynamic>)
          .map((item) => ConjugationForm.fromJson(item as Map<String, dynamic>))
          .toList(),
      practiceQuestions: ((json['practiceQuestions'] as List<dynamic>?) ?? [])
          .map(
            (item) => PracticeQuestion.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  AppData copyWith({
    List<Lesson>? lessons,
    List<MuhtelifeEntry>? muhtelifeEntries,
    List<ConjugationForm>? forms,
    List<PracticeQuestion>? practiceQuestions,
  }) {
    return AppData(
      lessons: lessons ?? this.lessons,
      muhtelifeEntries: muhtelifeEntries ?? this.muhtelifeEntries,
      forms: forms ?? this.forms,
      practiceQuestions: practiceQuestions ?? this.practiceQuestions,
    );
  }
}

class MuhtelifeEntry {
  const MuhtelifeEntry({
    required this.type,
    required this.label,
    required this.arabic,
    required this.meaning,
    required this.sortOrder,
    this.row,
    this.column,
  });

  final String type;
  final String label;
  final String arabic;
  final String meaning;
  final int sortOrder;
  final int? row;
  final String? column;

  factory MuhtelifeEntry.fromJson(Map<String, dynamic> json) {
    return MuhtelifeEntry(
      type: json['type'] as String,
      label: json['label'] as String,
      arabic: json['arabic'] as String,
      meaning: json['meaning'] as String,
      sortOrder: json['sortOrder'] as int,
      row: json['row'] as int?,
      column: json['column'] as String?,
    );
  }
}

class Lesson {
  const Lesson({
    required this.order,
    required this.title,
    required this.summary,
    required this.rule,
    required this.relatedCategory,
  });

  final int order;
  final String title;
  final String summary;
  final String rule;
  final FormCategory relatedCategory;

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      order: json['order'] as int,
      title: json['title'] as String,
      summary: json['summary'] as String,
      rule: json['rule'] as String,
      relatedCategory: FormCategory.fromJson(json['relatedCategory'] as String),
    );
  }
}

class ConjugationForm {
  const ConjugationForm({
    required this.category,
    required this.voice,
    required this.person,
    required this.number,
    required this.gender,
    required this.pronounLabel,
    required this.arabic,
    required this.meaning,
  });

  final FormCategory category;
  final Voice voice;
  final FormPerson person;
  final FormNumber number;
  final FormGender gender;
  final String pronounLabel;
  final String arabic;
  final String meaning;

  String get rule {
    final parts = <String>[
      person.label,
      number.label,
      if (gender != FormGender.common) gender.label,
      category.name,
      voice.name,
      'formudur.',
    ];
    return parts.join(' ');
  }

  factory ConjugationForm.fromJson(Map<String, dynamic> json) {
    return ConjugationForm(
      category: FormCategory.fromJson(json['category'] as String),
      voice: Voice.fromJson(json['voice'] as String),
      person: FormPerson.fromJson(json['person'] as String),
      number: FormNumber.fromJson(json['number'] as String),
      gender: FormGender.fromJson(json['gender'] as String),
      pronounLabel: json['pronounLabel'] as String,
      arabic: json['arabic'] as String,
      meaning: json['meaning'] as String,
    );
  }
}

class PracticeQuestion {
  const PracticeQuestion({
    required this.prompt,
    required this.arabic,
    required this.options,
    required this.answer,
    required this.explanation,
  });

  final String prompt;
  final String arabic;
  final List<String> options;
  final String answer;
  final String explanation;

  factory PracticeQuestion.fromJson(Map<String, dynamic> json) {
    return PracticeQuestion(
      prompt: json['prompt'] as String,
      arabic: json['arabic'] as String,
      options: (json['options'] as List<dynamic>).cast<String>(),
      answer: json['answer'] as String,
      explanation: json['explanation'] as String,
    );
  }
}

enum FormPerson {
  first('1. şahıs'),
  second('2. şahıs'),
  third('3. şahıs');

  const FormPerson(this.label);
  final String label;

  static FormPerson fromJson(String value) {
    return FormPerson.values.firstWhere((person) => person.name == value);
  }
}

enum FormNumber {
  singular('tekil'),
  dual('ikil'),
  plural('çoğul');

  const FormNumber(this.label);
  final String label;

  static FormNumber fromJson(String value) {
    return FormNumber.values.firstWhere((number) => number.name == value);
  }
}

enum FormGender {
  masculine('müzekker'),
  feminine('müennes'),
  common('ortak');

  const FormGender(this.label);
  final String label;

  static FormGender fromJson(String value) {
    return FormGender.values.firstWhere((gender) => gender.name == value);
  }
}
