import 'package:flutter_test/flutter_test.dart';

import 'package:emsile_flutter/data/models.dart';
import 'package:emsile_flutter/data/practice_question_generator.dart';

void main() {
  group('PracticeQuestionGenerator', () {
    test('generates meaning questions for each form', () {
      final questions = PracticeQuestionGenerator.fromForms(testForms);

      expect(questions, hasLength(testForms.length));

      final meaningQuestion = questions.firstWhere(
        (question) =>
            question.prompt == 'Bu formun anlamı hangisi?' &&
            question.arabic == 'نَصَرَ',
      );
      expect(meaningQuestion.answer, 'O erkek yardım etti.');
      expect(meaningQuestion.options, contains('O erkek yardım etti.'));
      expect(meaningQuestion.options, contains('O iki erkek yardım etti.'));
    });

    test('does not generate pronoun questions', () {
      final questions = PracticeQuestionGenerator.fromForms(
        duplicatedArabicForms,
      );

      expect(
        questions,
        isNot(
          contains(
            isA<PracticeQuestion>().having(
              (question) => question.prompt,
              'prompt',
              contains('şahsa'),
            ),
          ),
        ),
      );
    });
  });
}

const testForms = [
  ConjugationForm(
    category: FormCategory.mazi,
    voice: Voice.malum,
    person: FormPerson.third,
    number: FormNumber.singular,
    gender: FormGender.masculine,
    pronounLabel: 'O (er.)',
    arabic: 'نَصَرَ',
    meaning: 'O erkek yardım etti.',
  ),
  ConjugationForm(
    category: FormCategory.mazi,
    voice: Voice.malum,
    person: FormPerson.third,
    number: FormNumber.dual,
    gender: FormGender.masculine,
    pronounLabel: 'O ikisi (er.)',
    arabic: 'نَصَرَا',
    meaning: 'O iki erkek yardım etti.',
  ),
  ConjugationForm(
    category: FormCategory.mazi,
    voice: Voice.malum,
    person: FormPerson.third,
    number: FormNumber.plural,
    gender: FormGender.masculine,
    pronounLabel: 'Onlar (er.)',
    arabic: 'نَصَرُوا',
    meaning: 'O erkekler yardım etti.',
  ),
  ConjugationForm(
    category: FormCategory.mazi,
    voice: Voice.malum,
    person: FormPerson.third,
    number: FormNumber.singular,
    gender: FormGender.feminine,
    pronounLabel: 'O (kad.)',
    arabic: 'نَصَرَتْ',
    meaning: 'O kadın yardım etti.',
  ),
];

const duplicatedArabicForms = [
  ConjugationForm(
    category: FormCategory.muzari,
    voice: Voice.mechul,
    person: FormPerson.third,
    number: FormNumber.plural,
    gender: FormGender.masculine,
    pronounLabel: 'Onlar (er.)',
    arabic: 'يُنْصَرْنَ',
    meaning: 'Onlara yardım edilir.',
  ),
  ConjugationForm(
    category: FormCategory.muzari,
    voice: Voice.mechul,
    person: FormPerson.third,
    number: FormNumber.singular,
    gender: FormGender.feminine,
    pronounLabel: 'O (kad.)',
    arabic: 'يُنْصَرْنَ',
    meaning: 'O kadına yardım edilir.',
  ),
  ConjugationForm(
    category: FormCategory.muzari,
    voice: Voice.mechul,
    person: FormPerson.second,
    number: FormNumber.plural,
    gender: FormGender.feminine,
    pronounLabel: 'Siz (kad.)',
    arabic: 'تُنْصَرْنَ',
    meaning: 'Size yardım edilir.',
  ),
  ConjugationForm(
    category: FormCategory.muzari,
    voice: Voice.mechul,
    person: FormPerson.third,
    number: FormNumber.plural,
    gender: FormGender.feminine,
    pronounLabel: 'Onlar (kad.)',
    arabic: 'يُنْصَرْنَ',
    meaning: 'O kadınlara yardım edilir.',
  ),
];
