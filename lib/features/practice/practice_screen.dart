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
  static const _verbPronouns = [
    'O (er.)', 'O ikisi (er.)', 'Onlar (er.)',
    'O (kad.)', 'O ikisi (kad.)', 'Onlar (kad.)',
    'Sen (er.)', 'Siz ikiniz (er.)', 'Siz (er.)',
    'Sen (kad.)', 'Siz ikiniz (kad.)', 'Siz (kad.)',
    'Ben', 'Biz'
  ];

  static const _nounOptions = [
    'Tekil', 'İkil', 'Çoğul (Kurallı)', 'Kırık Çoğul'
  ];

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
    _selectedPronouns.addAll(_verbPronouns);
    _selectedPronouns.addAll(_nounOptions);
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
      
      final String mappedPronoun;
      if (form.category.isNoun) {
        final label = form.pronounLabel;
        if (label.contains('Kırık')) {
          mappedPronoun = 'Kırık Çoğul';
        } else if (label.contains('Tekil') || label == 'Tekil') {
          mappedPronoun = 'Tekil';
        } else if (label.contains('İkil') || label == 'İkil') {
          mappedPronoun = 'İkil';
        } else if (label.contains('Çoğul') || label == 'Çoğul') {
          mappedPronoun = 'Çoğul (Kurallı)';
        } else {
          mappedPronoun = label;
        }
      } else {
        mappedPronoun = form.pronounLabel;
      }
      
      final pronounMatch = _selectedPronouns.contains(mappedPronoun);
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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

  Widget _buildTableContainer({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD8D1C1)),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }

  Widget _buildSelectableTableCell({
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        color: isSelected
            ? colorScheme.primaryContainer.withValues(alpha: 0.55)
            : null,
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? colorScheme.primary : null,
            ),
          ),
        ),
      ),
    );
  }

  void _togglePronounsGroup(List<String> pronouns) {
    final allSelected = pronouns.every((p) => _selectedPronouns.contains(p));
    setState(() {
      if (allSelected) {
        _selectedPronouns.removeAll(pronouns);
      } else {
        _selectedPronouns.addAll(pronouns);
      }
    });
  }

  Widget _buildHeaderCell(String text, {VoidCallback? onTap}) {
    final hasTap = onTap != null;
    Widget content = Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: hasTap ? Theme.of(context).colorScheme.primary : null,
            ),
      ),
    );

    if (hasTap) {
      content = InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: content,
        ),
      );
    } else {
      content = Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: content,
      );
    }

    return Container(
      color: const Color(0xFFF4F0E6),
      child: content,
    );
  }

  Widget _buildLabelCell(String text, {VoidCallback? onTap}) {
    final hasTap = onTap != null;
    Widget content = Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: hasTap ? Theme.of(context).colorScheme.primary : null,
            ),
      ),
    );

    if (hasTap) {
      content = InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: content,
        ),
      );
    } else {
      content = Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: content,
      );
    }

    return Container(
      color: const Color(0xFFF4F0E6),
      child: content,
    );
  }

  TableRow _buildPronounRow({
    required String label,
    required String plural,
    required String dual,
    required String singular,
    required VoidCallback onLabelTap,
  }) {
    return TableRow(
      children: [
        _buildPronounCell(plural),
        _buildPronounCell(dual),
        _buildPronounCell(singular),
        _buildLabelCell(label, onTap: onLabelTap),
      ],
    );
  }

  Widget _buildPronounCell(String pronoun) {
    final isSelected = _selectedPronouns.contains(pronoun);
    return _buildSelectableTableCell(
      text: pronoun,
      isSelected: isSelected,
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedPronouns.remove(pronoun);
          } else {
            _selectedPronouns.add(pronoun);
          }
        });
      },
    );
  }

  Widget _buildNounOptionCell(String option) {
    final isSelected = _selectedPronouns.contains(option);
    return _buildSelectableTableCell(
      text: option,
      isSelected: isSelected,
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedPronouns.remove(option);
          } else {
            _selectedPronouns.add(option);
          }
        });
      },
    );
  }


  Widget _buildSetupView(BuildContext context) {
    final showVerbs = _selectedCategories.isEmpty
        ? widget.data.forms.any((f) => f.category.isVerb)
        : _selectedCategories.any((cat) => cat.isVerb);
    final showNouns = _selectedCategories.isEmpty
        ? widget.data.forms.any((f) => f.category.isNoun)
        : _selectedCategories.any((cat) => cat.isNoun);
    final showVoice = showVerbs;

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
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: FormCategory.values.map((category) {
              final isSelected = _selectedCategories.contains(category);
              return InkWell(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedCategories.remove(category);
                    } else {
                      _selectedCategories.add(category);
                    }
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: Checkbox(
                          value: isSelected,
                          onChanged: (selected) {
                            setState(() {
                              if (selected == true) {
                                _selectedCategories.add(category);
                              } else {
                                _selectedCategories.remove(category);
                              }
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          category.label,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          if (showVoice) ...[
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
            _buildTableContainer(
              child: Table(
                border: const TableBorder(
                  verticalInside: BorderSide(color: Color(0xFFD8D1C1)),
                ),
                children: [
                  TableRow(
                    children: Voice.values.map((voice) {
                      final isSelected = _selectedVoices.contains(voice);
                      return _buildSelectableTableCell(
                        text: voice.label,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedVoices.remove(voice);
                            } else {
                              _selectedVoices.add(voice);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          if (showVerbs) ...[
            _buildSectionHeader(
              title: 'Şahıslar (Fiiller)',
              onSelectAll: () {
                setState(() {
                  _selectedPronouns.addAll(_verbPronouns);
                });
              },
              onClearAll: () {
                setState(() {
                  _selectedPronouns.removeAll(_verbPronouns);
                });
              },
            ),
            _buildTableContainer(
              child: Table(
                border: const TableBorder(
                  horizontalInside: BorderSide(color: Color(0xFFD8D1C1)),
                  verticalInside: BorderSide(color: Color(0xFFD8D1C1)),
                ),
                columnWidths: const {
                  0: FlexColumnWidth(1),
                  1: FlexColumnWidth(1),
                  2: FlexColumnWidth(1),
                  3: FixedColumnWidth(96),
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  TableRow(
                    decoration: const BoxDecoration(color: Color(0xFFF4F0E6)),
                    children: [
                      _buildHeaderCell(
                        'Çoğul',
                        onTap: () => _togglePronounsGroup(const [
                          'Onlar (er.)',
                          'Onlar (kad.)',
                          'Siz (er.)',
                          'Siz (kad.)',
                          'Biz',
                        ]),
                      ),
                      _buildHeaderCell(
                        'İkil',
                        onTap: () => _togglePronounsGroup(const [
                          'O ikisi (er.)',
                          'O ikisi (kad.)',
                          'Siz ikiniz (er.)',
                          'Siz ikiniz (kad.)',
                          'Biz',
                        ]),
                      ),
                      _buildHeaderCell(
                        'Tekil',
                        onTap: () => _togglePronounsGroup(const [
                          'O (er.)',
                          'O (kad.)',
                          'Sen (er.)',
                          'Sen (kad.)',
                          'Ben',
                        ]),
                      ),
                      _buildHeaderCell('Şahıs'),
                    ],
                  ),
                  _buildPronounRow(
                    label: '3. Şh. Müzekker\n(Gâib)',
                    plural: 'Onlar (er.)',
                    dual: 'O ikisi (er.)',
                    singular: 'O (er.)',
                    onLabelTap: () => _togglePronounsGroup(const ['Onlar (er.)', 'O ikisi (er.)', 'O (er.)']),
                  ),
                  _buildPronounRow(
                    label: '3. Şh. Müennes\n(Gâibe)',
                    plural: 'Onlar (kad.)',
                    dual: 'O ikisi (kad.)',
                    singular: 'O (kad.)',
                    onLabelTap: () => _togglePronounsGroup(const ['Onlar (kad.)', 'O ikisi (kad.)', 'O (kad.)']),
                  ),
                  _buildPronounRow(
                    label: '2. Şh. Müzekker\n(Muhatab)',
                    plural: 'Siz (er.)',
                    dual: 'Siz ikiniz (er.)',
                    singular: 'Sen (er.)',
                    onLabelTap: () => _togglePronounsGroup(const ['Siz (er.)', 'Siz ikiniz (er.)', 'Sen (er.)']),
                  ),
                  _buildPronounRow(
                    label: '2. Şh. Müennes\n(Muhataba)',
                    plural: 'Siz (kad.)',
                    dual: 'Siz ikiniz (kad.)',
                    singular: 'Sen (kad.)',
                    onLabelTap: () => _togglePronounsGroup(const ['Siz (kad.)', 'Siz ikiniz (kad.)', 'Sen (kad.)']),
                  ),
                  _buildPronounRow(
                    label: '1. Şh. Ortak\n(Mütekellim)',
                    plural: 'Biz',
                    dual: 'Biz',
                    singular: 'Ben',
                    onLabelTap: () => _togglePronounsGroup(const ['Biz', 'Ben']),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          if (showNouns) ...[
            _buildSectionHeader(
              title: 'Dil Bilgisi (İsimler)',
              onSelectAll: () {
                setState(() {
                  _selectedPronouns.addAll(_nounOptions);
                });
              },
              onClearAll: () {
                setState(() {
                  _selectedPronouns.removeAll(_nounOptions);
                });
              },
            ),
            _buildTableContainer(
              child: Table(
                border: const TableBorder(
                  verticalInside: BorderSide(color: Color(0xFFD8D1C1)),
                ),
                columnWidths: const {
                  0: FlexColumnWidth(1),
                  1: FlexColumnWidth(1),
                  2: FlexColumnWidth(1),
                  3: FlexColumnWidth(1),
                },
                children: [
                  TableRow(
                    children: [
                      _buildNounOptionCell('Kırık Çoğul'),
                      _buildNounOptionCell('Çoğul (Kurallı)'),
                      _buildNounOptionCell('İkil'),
                      _buildNounOptionCell('Tekil'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
          const SizedBox(height: 10),

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
