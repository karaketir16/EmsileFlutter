import 'dart:math';

import 'package:emsile_flutter/data/models.dart';
import 'package:emsile_flutter/data/practice_question_generator.dart';
import 'package:emsile_flutter/features/practice/multiple_choice/practice_answer.dart';
import 'package:emsile_flutter/features/practice/multiple_choice/practice_filters.dart';
import 'package:emsile_flutter/shared/widgets/app_page.dart';
import 'package:emsile_flutter/shared/widgets/arabic_text.dart';
import 'package:flutter/material.dart';

class MultipleChoicePracticeScreen extends StatefulWidget {
  const MultipleChoicePracticeScreen({
    required this.data,
    this.random,
    super.key,
  });

  final AppData data;
  final Random? random;

  @override
  State<MultipleChoicePracticeScreen> createState() =>
      _MultipleChoicePracticeScreenState();
}

class _MultipleChoicePracticeScreenState
    extends State<MultipleChoicePracticeScreen> {
  bool _setupMode = true;
  PracticeQuestion? _question;
  String? _selectedAnswer;
  Set<FormCategory> _categories = FormCategory.values.toSet();
  Set<Voice> _voices = Voice.values.toSet();
  bool _includeBrokenPlurals = true;

  List<ConjugationForm> get _matchingForms => widget.data.forms.where((form) {
    return _categories.contains(form.category) &&
        (form.category.isNoun || _voices.contains(form.voice)) &&
        (_includeBrokenPlurals || !form.isBrokenPlural);
  }).toList();

  bool get _canStart {
    if (_categories.isEmpty) return false;
    final hasSelectedVerb = _categories.any((category) => category.isVerb);
    return !hasSelectedVerb || _voices.isNotEmpty;
  }

  @override
  void didUpdateWidget(covariant MultipleChoicePracticeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _resetFilters();
      if (!_setupMode) _generateQuestion();
    }
  }

  void _resetFilters() {
    _categories = FormCategory.values.toSet();
    _voices = Voice.values.toSet();
    _includeBrokenPlurals = true;
  }

  void _generateQuestion() {
    final forms = _matchingForms;
    if (!_canStart) {
      _setupMode = true;
      return;
    }
    _question = PracticeQuestionGenerator.generateSingleQuestion(
      forms,
      widget.random,
    );
    _selectedAnswer = null;
  }

  void _start() {
    setState(() {
      _generateQuestion();
      _setupMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _setupMode ? _buildSetup(context) : _buildQuestion(context);
  }

  Widget _buildSetup(BuildContext context) {
    final canStart = _canStart;
    return AppPage(
      title: 'Pratik Ayarları',
      leading: _backButton(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PracticeFilters(
            availableForms: widget.data.forms,
            categories: _categories,
            voices: _voices,
            includeBrokenPlurals: _includeBrokenPlurals,
            onCategoriesChanged: (value) {
              setState(() => _categories = value);
            },
            onVoicesChanged: (value) {
              setState(() => _voices = value);
            },
            onIncludeBrokenPluralsChanged: (value) {
              setState(() => _includeBrokenPlurals = value);
            },
          ),
          const SizedBox(height: 30),
          _StartPanel(
            canStart: canStart,
            validationMessage: _categories.isEmpty
                ? 'Pratiğe başlamak için en az bir çekim tablosu seç.'
                : 'Fiil kategorileri için en az bir çatı seç.',
            onStart: _start,
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion(BuildContext context) {
    final question = _question!;
    final answered = _selectedAnswer != null;
    final correct = _selectedAnswer == question.answer;
    return AppPage(
      title: 'Pratik',
      leading: _backButton(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: IconButton.filledTonal(
              onPressed: () => setState(() => _setupMode = true),
              icon: const Icon(Icons.settings),
              tooltip: 'Ayarları Değiştir',
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(8),
            ),
          ),
          const SizedBox(height: 10),
          _QuestionCard(question: question),
          const SizedBox(height: 16),
          for (final option in question.options) ...[
            AnswerButton(
              text: option,
              isSelected: _selectedAnswer == option,
              isCorrect:
                  answered &&
                  _selectedAnswer == option &&
                  option == question.answer,
              isWrong:
                  answered &&
                  _selectedAnswer == option &&
                  option != question.answer,
              onTap: () => setState(() => _selectedAnswer = option),
            ),
            const SizedBox(height: 10),
          ],
          if (answered) ...[
            const SizedBox(height: 10),
            PracticeAnswerFeedback(isCorrect: correct),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => setState(_generateQuestion),
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Sonraki Soru'),
            ),
          ],
        ],
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({required this.question});

  final PracticeQuestion question;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              question.prompt,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
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
    );
  }
}

class _StartPanel extends StatelessWidget {
  const _StartPanel({
    required this.canStart,
    required this.validationMessage,
    required this.onStart,
  });

  final bool canStart;
  final String validationMessage;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: canStart ? null : Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!canStart) ...[
              Text(
                validationMessage,
                style: TextStyle(color: Colors.red.shade900, fontSize: 13),
              ),
              const SizedBox(height: 16),
            ],
            FilledButton.icon(
              onPressed: canStart ? onStart : null,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Pratiğe Başla'),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _backButton(BuildContext context) {
  return IconButton(
    onPressed: () => Navigator.of(context).pop(),
    icon: const Icon(Icons.arrow_back),
    tooltip: 'Geri',
  );
}
