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
  bool _setupMode = true;
  PracticeQuestion? _question;
  String? _selectedAnswer;

  // Selections
  final Set<FormCategory> _selectedCategories = {};
  final Set<Voice> _selectedVoices = {};
  final Set<String> _selectedPronouns = {};

  @override
  void initState() {
    super.initState();
    _initializeSelections();
  }

  void _initializeSelections() {
    _selectedCategories.clear();
    _selectedCategories.addAll(FormCategory.values);
    
    _selectedVoices.clear();
    _selectedVoices.addAll(Voice.values);

    _selectedPronouns.clear();
    final allPronouns = widget.data.forms.map((f) => f.pronounLabel).toSet();
    _selectedPronouns.addAll(allPronouns);
  }

  @override
  void didUpdateWidget(covariant PracticeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _initializeSelections();
      if (!_setupMode) {
        _generateQuestion();
      }
    }
  }

  List<ConjugationForm> get _matchingForms {
    return widget.data.forms.where((form) {
      final categoryMatch = _selectedCategories.contains(form.category);
      final voiceMatch = _selectedVoices.contains(form.voice);
      final pronounMatch = _selectedPronouns.contains(form.pronounLabel);
      return categoryMatch && voiceMatch && pronounMatch;
    }).toList();
  }

  void _generateQuestion() {
    final forms = _matchingForms;
    if (forms.length < 5) {
      setState(() {
        _setupMode = true;
      });
      return;
    }
    _question = PracticeQuestionGenerator.generateSingleQuestion(
      forms,
      widget.random,
    );
    _selectedAnswer = null;
  }

  Widget _buildSectionHeader({
    required String title,
    required VoidCallback onSelectAll,
    required VoidCallback onClearAll,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: onSelectAll,
              borderRadius: BorderRadius.circular(4),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                child: Text(
                  'Tümünü Seç',
                  style: TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const Text('|', style: TextStyle(color: Colors.grey, fontSize: 12)),
            InkWell(
              onTap: onClearAll,
              borderRadius: BorderRadius.circular(4),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                child: Text(
                  'Temizle',
                  style: TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGroupHelperButton({
    required String label,
    required List<String> pronouns,
    required List<String> allPronouns,
  }) {
    final availableInDb = pronouns.where((p) => allPronouns.contains(p)).toList();
    if (availableInDb.isEmpty) return const SizedBox.shrink();

    final allSelected = availableInDb.every((p) => _selectedPronouns.contains(p));

    return OutlinedButton(
      onPressed: () {
        setState(() {
          if (allSelected) {
            _selectedPronouns.removeAll(availableInDb);
          } else {
            _selectedPronouns.addAll(availableInDb);
          }
        });
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11),
      ),
    );
  }

  Widget _buildSetupView(BuildContext context) {
    final allPronouns = widget.data.forms.map((f) => f.pronounLabel).toSet().toList();
    const pronounOrder = [
      'O (er.)', 'O ikisi (er.)', 'Onlar (er.)',
      'O (kad.)', 'O ikisi (kad.)', 'Onlar (kad.)',
      'Sen (er.)', 'Siz ikiniz (er.)', 'Siz (er.)',
      'Sen (kad.)', 'Siz ikiniz (kad.)', 'Siz (kad.)',
      'Ben', 'Biz',
      'Tekil Müzekker', 'İkil Müzekker', 'Çoğul Müzekker (Sâlim)', 'Çoğul Müzekker',
      'Kırık Çoğul Müzekker 1', 'Kırık Çoğul Müzekker 2', 'Kırık Çoğul Müzekker 3',
      'Tekil Müennes', 'İkil Müennes', 'Çoğul Müennes (Sâlim)', 'Çoğul Müennes',
      'Kırık Çoğul Müennes',
      'Tekil', 'İkil', 'Çoğul', 'Kırık Çoğul', 'Kırık Çoğul (Emsile)'
    ];
    allPronouns.sort((a, b) {
      final indexA = pronounOrder.indexOf(a);
      final indexB = pronounOrder.indexOf(b);
      if (indexA == -1 && indexB == -1) return a.compareTo(b);
      if (indexA == -1) return 1;
      if (indexB == -1) return -1;
      return indexA.compareTo(indexB);
    });

    final matchingCount = _matchingForms.length;
    final canStart = matchingCount >= 5;

    return AppPage(
      title: 'Pratik Ayarları',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            title: 'Çekim Tabloları',
            onSelectAll: () {
              setState(() {
                _selectedCategories.addAll(FormCategory.values);
              });
            },
            onClearAll: () {
              setState(() {
                _selectedCategories.clear();
              });
            },
          ),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: FormCategory.values.map((category) {
              final isSelected = _selectedCategories.contains(category);
              return FilterChip(
                label: Text(category.label),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedCategories.add(category);
                    } else {
                      _selectedCategories.remove(category);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          _buildSectionHeader(
            title: 'Çatı (Malum/Meçhul)',
            onSelectAll: () {
              setState(() {
                _selectedVoices.addAll(Voice.values);
              });
            },
            onClearAll: () {
              setState(() {
                _selectedVoices.clear();
              });
            },
          ),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: Voice.values.map((voice) {
              final isSelected = _selectedVoices.contains(voice);
              return FilterChip(
                label: Text(voice.label),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedVoices.add(voice);
                    } else {
                      _selectedVoices.remove(voice);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          _buildSectionHeader(
            title: 'Şahıslar (Zamirler)',
            onSelectAll: () {
              setState(() {
                _selectedPronouns.addAll(allPronouns);
              });
            },
            onClearAll: () {
              setState(() {
                _selectedPronouns.clear();
              });
            },
          ),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              _buildGroupHelperButton(
                label: '3. Şahıs (Gâib/e)',
                pronouns: const ['O (er.)', 'O (kad.)', 'O ikisi (er.)', 'O ikisi (kad.)', 'Onlar (er.)', 'Onlar (kad.)'],
                allPronouns: allPronouns,
              ),
              _buildGroupHelperButton(
                label: '2. Şahıs (Muhatab/a)',
                pronouns: const ['Sen (er.)', 'Sen (kad.)', 'Siz ikiniz (er.)', 'Siz ikiniz (kad.)', 'Siz (er.)', 'Siz (kad.)'],
                allPronouns: allPronouns,
              ),
              _buildGroupHelperButton(
                label: '1. Şahıs (Mütekellim)',
                pronouns: const ['Ben', 'Biz'],
                allPronouns: allPronouns,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: allPronouns.map((pronoun) {
              final isSelected = _selectedPronouns.contains(pronoun);
              return FilterChip(
                label: Text(pronoun),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedPronouns.add(pronoun);
                    } else {
                      _selectedPronouns.remove(pronoun);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 30),

          Card(
            color: canStart ? null : Colors.orange.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Eşleşen Form Sayısı:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '$matchingCount',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: canStart ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  if (!canStart) ...[
                    const SizedBox(height: 10),
                    Text(
                      'Soru üretilebilmesi için en az 5 farklı çekim formu eşleşmelidir. Lütfen seçimlerinizi artırın.',
                      style: TextStyle(
                        color: Colors.red.shade900,
                        fontSize: 13,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: canStart
                        ? () {
                            setState(() {
                              _generateQuestion();
                              _setupMode = false;
                            });
                          }
                        : null,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Pratiğe Başla'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_setupMode) {
      return _buildSetupView(context);
    }

    final question = _question!;
    final isAnswered = _selectedAnswer != null;
    final isCorrect = _selectedAnswer == question.answer;

    return AppPage(
      title: 'Pratik',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Soru Havuzu: ${_matchingForms.length} Form',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
              ),
              IconButton.filledTonal(
                onPressed: () {
                  setState(() {
                    _setupMode = true;
                  });
                },
                icon: const Icon(Icons.settings),
                tooltip: 'Ayarları Değiştir',
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(8),
              ),
            ],
          ),
          const SizedBox(height: 10),
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
