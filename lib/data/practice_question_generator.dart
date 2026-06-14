import 'dart:math';
import 'models.dart';

class PracticeQuestionGenerator {
  const PracticeQuestionGenerator._();

  /// Rastgele tek bir soru üretir (Runtime için).
  static PracticeQuestion generateSingleQuestion(List<ConjugationForm> forms, [Random? randomOverride]) {
    if (forms.isEmpty) {
      throw StateError('Forms list cannot be empty.');
    }

    final random = randomOverride ?? Random();
    // Rastgele bir form seçelim
    final form = forms[random.nextInt(forms.length)];

    // Şıklarda iki doğru cevap çakışmaması (homonimlerin elenmesi) için:
    // Yanlış şık adaylarının Arapça yazımı bu formla birebir aynı olmamalıdır!
    final siblings = forms
        .where((candidate) => candidate.arabic != form.arabic)
        .toList();
    siblings.shuffle(random);

    // 3 farklı soru tipinden birini rastgele seçelim:
    // 0: Arapçadan Türkçeye anlam sorusu
    // 1: Arapçadan şahıs sorusu
    // 2: Türkçeden Arapçaya form sorusu
    final questionType = random.nextInt(3);

    if (questionType == 0) {
      // Arapçadan Türkçeye Anlam Sorusu
      return PracticeQuestion(
        prompt: 'Bu formun anlamı hangisi?',
        arabic: form.arabic,
        options: _buildMeaningOptions(form, siblings, random),
        answer: form.meaning,
        explanation: form.category.isNoun
            ? '${form.arabic} ${form.category.label} ${form.pronounLabel.toLowerCase()} formudur.'
            : '${form.arabic} ${form.category.label} ${form.voice.label} ${form.pronounLabel.toLowerCase()} formudur.',
      );
    } else if (questionType == 1) {
      // Arapçadan Şahıs Sorusu
      return PracticeQuestion(
        prompt: form.category.isNoun
            ? 'Bu formun dil bilgisi özelliği hangisidir?'
            : 'Bu form hangi şahsa aittir?',
        arabic: form.arabic,
        options: _buildPronounOptions(form, siblings, random),
        answer: form.pronounLabel,
        explanation: form.category.isNoun
            ? '${form.arabic} ${form.pronounLabel.toLowerCase()} özelliğine sahiptir.'
            : '${form.arabic} ${form.pronounLabel.toLowerCase()} için kullanılır.',
      );
    } else {
      // Türkçeden Arapçaya Soru
      return PracticeQuestion(
        prompt: 'Hangisi bu anlama gelir: "${form.meaning}"?',
        arabic: '؟', // Ekrandaki büyük Arapça alanı için soru işareti
        options: _buildArabicOptions(form, siblings, random),
        answer: form.arabic,
        explanation:
            '"${form.meaning}" anlamı ${form.arabic} formuna aittir.',
      );
    }
  }

  /// Geriye dönük uyumluluk ve testler için toplu soru üreteci.
  static List<PracticeQuestion> fromForms(List<ConjugationForm> forms) {
    final questions = <PracticeQuestion>[];
    final random = Random();

    for (final form in forms) {
      // Çakışmayı önlemek için yine aynı Arapça yazılımları eliyoruz
      final siblings = forms
          .where((candidate) => candidate.arabic != form.arabic)
          .toList();
      siblings.shuffle(random);

      questions.add(
        PracticeQuestion(
          prompt: 'Bu formun anlamı hangisi?',
          arabic: form.arabic,
          options: _buildMeaningOptions(form, siblings, random),
          answer: form.meaning,
          explanation: form.category.isNoun
              ? '${form.arabic} ${form.category.label} ${form.pronounLabel.toLowerCase()} formudur.'
              : '${form.arabic} ${form.category.label} ${form.voice.label} ${form.pronounLabel.toLowerCase()} formudur.',
        ),
      );

      questions.add(
        PracticeQuestion(
          prompt: form.category.isNoun
              ? 'Bu formun dil bilgisi özelliği hangisidir?'
              : 'Bu form hangi şahsa aittir?',
          arabic: form.arabic,
          options: _buildPronounOptions(form, siblings, random),
          answer: form.pronounLabel,
          explanation: form.category.isNoun
              ? '${form.arabic} ${form.pronounLabel.toLowerCase()} özelliğine sahiptir.'
              : '${form.arabic} ${form.pronounLabel.toLowerCase()} için kullanılır.',
        ),
      );
    }

    return questions;
  }

  static List<String> _buildMeaningOptions(
    ConjugationForm form,
    List<ConjugationForm> siblings,
    Random random,
  ) {
    final options = <String>[form.meaning];

    for (final candidate in siblings) {
      if (!options.contains(candidate.meaning)) {
        options.add(candidate.meaning);
      }
      if (options.length == 5) {
        break;
      }
    }

    options.shuffle(random);
    return options;
  }

  static List<String> _buildPronounOptions(
    ConjugationForm form,
    List<ConjugationForm> siblings,
    Random random,
  ) {
    final options = <String>[form.pronounLabel];

    for (final candidate in siblings) {
      if (!options.contains(candidate.pronounLabel)) {
        options.add(candidate.pronounLabel);
      }
      if (options.length == 5) {
        break;
      }
    }

    options.shuffle(random);
    return options;
  }

  static List<String> _buildArabicOptions(
    ConjugationForm form,
    List<ConjugationForm> siblings,
    Random random,
  ) {
    final options = <String>[form.arabic];

    for (final candidate in siblings) {
      if (!options.contains(candidate.arabic)) {
        options.add(candidate.arabic);
      }
      if (options.length == 5) {
        break;
      }
    }

    options.shuffle(random);
    return options;
  }
}
