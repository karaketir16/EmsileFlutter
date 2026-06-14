import 'dart:math';
import 'package:emsile_flutter/data/models.dart';
import 'package:emsile_flutter/data/practice_question_generator.dart';
import 'package:emsile_flutter/shared/widgets/app_page.dart';
import 'package:emsile_flutter/shared/widgets/arabic_text.dart';
import 'package:emsile_flutter/shared/widgets/info_panel.dart';
import 'package:flutter/material.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({required this.data, this.random, super.key});

  final AppData data;
  final Random? random;

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  late PracticeQuestion _question;
  String? _selectedAnswer;

  @override
  void initState() {
    super.initState();
    _generateQuestion();
  }

  @override
  void didUpdateWidget(covariant PracticeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _generateQuestion();
    }
  }

  void _generateQuestion() {
    _question = PracticeQuestionGenerator.generateSingleQuestion(
      widget.data.forms,
      widget.random,
    );
    _selectedAnswer = null;
  }

  @override
  Widget build(BuildContext context) {
    final question = _question;
    final isAnswered = _selectedAnswer != null;
    final isCorrect = _selectedAnswer == question.answer;

    // Türkçeden Arapçaya sorularda '؟' (Arapça soru işareti) yerine normal soru işareti 
    // veya soru promptunda belirtilen Arapça karakterleri normal fontta göstermek isteyebiliriz.
    // Ancak formun Arapça kelimesi sorulurken arabicTextStyle(42) gayet güzel duracaktır.
    // Eğer soru tipi '؟' ise onu ortada büyük gösteriyoruz.
    
    return AppPage(
      title: 'Pratik',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(question.prompt),
                  const SizedBox(height: 14),
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      question.arabic,
                      textAlign: TextAlign.center,
                      style: arabicTextStyle(42),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          for (final option in question.options) ...[
            AnswerButton(
              text: option,
              isSelected: _selectedAnswer == option,
              isCorrect: isAnswered && option == question.answer,
              isWrong:
                  isAnswered &&
                  _selectedAnswer == option &&
                  option != question.answer,
              onTap: () => setState(() => _selectedAnswer = option),
            ),
            const SizedBox(height: 10),
          ],
          if (isAnswered) ...[
            const SizedBox(height: 10),
            InfoPanel(
              title: isCorrect ? 'Doğru' : 'Tekrar Bak',
              body: isCorrect
                  ? question.explanation
                  : 'Doğru cevap: ${question.answer}. ${question.explanation}',
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                setState(() {
                  _generateQuestion();
                });
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Sonraki Soru'),
            ),
          ],
        ],
      ),
    );
  }
}

class AnswerButton extends StatelessWidget {
  const AnswerButton({
    required this.text,
    required this.isSelected,
    required this.isCorrect,
    required this.isWrong,
    required this.onTap,
    super.key,
  });

  final String text;
  final bool isSelected;
  final bool isCorrect;
  final bool isWrong;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final Color borderColor;
    final Color backgroundColor;

    if (isCorrect) {
      borderColor = const Color(0xFF2F7D46);
      backgroundColor = const Color(0xFFE8F5EC);
    } else if (isWrong) {
      borderColor = const Color(0xFFB43C3C);
      backgroundColor = const Color(0xFFFFECEC);
    } else if (isSelected) {
      borderColor = scheme.primary;
      backgroundColor = scheme.primaryContainer;
    } else {
      borderColor = const Color(0xFFE6E1D5);
      backgroundColor = Colors.white;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor),
        ),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}
