enum FormCategory {
  mazi('Mâzi'),
  muzari('Muzâri');

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
    required this.forms,
    required this.practiceQuestions,
  });

  final List<Lesson> lessons;
  final List<ConjugationForm> forms;
  final List<PracticeQuestion> practiceQuestions;

  factory AppData.fromJson(Map<String, dynamic> json) {
    return AppData(
      lessons: (json['lessons'] as List<dynamic>)
          .map((item) => Lesson.fromJson(item as Map<String, dynamic>))
          .toList(),
      forms: (json['forms'] as List<dynamic>)
          .map((item) => ConjugationForm.fromJson(item as Map<String, dynamic>))
          .toList(),
      practiceQuestions: (json['practiceQuestions'] as List<dynamic>)
          .map(
            (item) => PracticeQuestion.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
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
    required this.pronounLabel,
    required this.arabic,
    required this.meaning,
    required this.rule,
  });

  final FormCategory category;
  final Voice voice;
  final String pronounLabel;
  final String arabic;
  final String meaning;
  final String rule;

  factory ConjugationForm.fromJson(Map<String, dynamic> json) {
    return ConjugationForm(
      category: FormCategory.fromJson(json['category'] as String),
      voice: Voice.fromJson(json['voice'] as String),
      pronounLabel: json['pronounLabel'] as String,
      arabic: json['arabic'] as String,
      meaning: json['meaning'] as String,
      rule: json['rule'] as String,
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
