import 'dart:math';
import 'package:emsile_flutter/data/models.dart';
import 'package:emsile_flutter/data/practice_question_generator.dart';
import 'package:emsile_flutter/features/practice/table_fill_practice_screen.dart';
import 'package:emsile_flutter/features/practice/matching_practice_screen.dart';
import 'package:emsile_flutter/shared/widgets/app_page.dart';
import 'package:emsile_flutter/shared/widgets/arabic_text.dart';
import 'package:flutter/material.dart';

class PracticeScreen extends StatelessWidget {
  const PracticeScreen({required this.data, this.random, super.key});

  final AppData data;
  final Random? random;

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Pratik',
      subtitle: 'Çalışma biçimini seç.',
      child: Column(
        children: [
          _PracticeModeCard(
            icon: Icons.quiz_outlined,
            title: 'Çoktan Seçmeli',
            body:
                'Arapça ve Türkçe anlamlar arasında doğru cevabı seçeneklerden bul.',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => Scaffold(
                  body: SafeArea(
                    child: MultipleChoicePracticeScreen(
                      data: data,
                      random: random,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _PracticeModeCard(
            icon: Icons.view_module_outlined,
            title: 'Tabloyu Doldur',
            body:
                'Karışık verilen çekimleri sürükleyerek doğru tablo hücrelerine yerleştir.',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => Scaffold(
                  body: SafeArea(
                    child: TableFillPracticeScreen(data: data, random: random),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _PracticeModeCard(
            icon: Icons.compare_arrows_outlined,
            title: 'Sîga Eşleştirme',
            body:
                'Arapça sîgaları doğru dilbilgisi adları veya anlamlarıyla eşleştir.',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => MatchingPracticeScreen(
                  data: data,
                  random: random,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PracticeModeCard extends StatelessWidget {
  const _PracticeModeCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String body;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: scheme.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(body),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

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
  static const _verbPronouns = [
    'O (er.)',
    'O ikisi (er.)',
    'Onlar (er.)',
    'O (kad.)',
    'O ikisi (kad.)',
    'Onlar (kad.)',
    'Sen (er.)',
    'Siz ikiniz (er.)',
    'Siz (er.)',
    'Sen (kad.)',
    'Siz ikiniz (kad.)',
    'Siz (kad.)',
    'Ben',
    'Biz',
  ];

  static const _nounOptions = [
    'Tekil',
    'İkil',
    'Çoğul (Kurallı)',
    'Kırık Çoğul',
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
  void didUpdateWidget(covariant MultipleChoicePracticeScreen oldWidget) {
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
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
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
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
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

    return Container(color: const Color(0xFFF4F0E6), child: content);
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

    return Container(color: const Color(0xFFF4F0E6), child: content);
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
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.fill,
          child: _buildPronounCell(plural),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.fill,
          child: _buildPronounCell(dual),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.fill,
          child: _buildPronounCell(singular),
        ),
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
      leading: _practiceBackButton(context),
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
          LayoutBuilder(
            builder: (context, constraints) {
              const spacing = 8.0;
              final itemWidth = (constraints.maxWidth - spacing) / 2;
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  for (final category in FormCategory.values)
                    SizedBox(
                      width: itemWidth,
                      child: _buildCategoryOption(category),
                    ),
                ],
              );
            },
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
                    children: Voice.values.asMap().entries.map((entry) {
                      final index = entry.key;
                      final voice = entry.value;
                      final isSelected = _selectedVoices.contains(voice);
                      final cell = _buildSelectableTableCell(
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
                      if (index == 0) {
                        return cell;
                      }
                      return TableCell(
                        verticalAlignment: TableCellVerticalAlignment.fill,
                        child: cell,
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
                    onLabelTap: () => _togglePronounsGroup(const [
                      'Onlar (er.)',
                      'O ikisi (er.)',
                      'O (er.)',
                    ]),
                  ),
                  _buildPronounRow(
                    label: '3. Şh. Müennes\n(Gâibe)',
                    plural: 'Onlar (kad.)',
                    dual: 'O ikisi (kad.)',
                    singular: 'O (kad.)',
                    onLabelTap: () => _togglePronounsGroup(const [
                      'Onlar (kad.)',
                      'O ikisi (kad.)',
                      'O (kad.)',
                    ]),
                  ),
                  _buildPronounRow(
                    label: '2. Şh. Müzekker\n(Muhatab)',
                    plural: 'Siz (er.)',
                    dual: 'Siz ikiniz (er.)',
                    singular: 'Sen (er.)',
                    onLabelTap: () => _togglePronounsGroup(const [
                      'Siz (er.)',
                      'Siz ikiniz (er.)',
                      'Sen (er.)',
                    ]),
                  ),
                  _buildPronounRow(
                    label: '2. Şh. Müennes\n(Muhataba)',
                    plural: 'Siz (kad.)',
                    dual: 'Siz ikiniz (kad.)',
                    singular: 'Sen (kad.)',
                    onLabelTap: () => _togglePronounsGroup(const [
                      'Siz (kad.)',
                      'Siz ikiniz (kad.)',
                      'Sen (kad.)',
                    ]),
                  ),
                  _buildPronounRow(
                    label: '1. Şh. Ortak\n(Mütekellim)',
                    plural: 'Biz',
                    dual: 'Biz',
                    singular: 'Ben',
                    onLabelTap: () =>
                        _togglePronounsGroup(const ['Biz', 'Ben']),
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
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.fill,
                        child: _buildNounOptionCell('Kırık Çoğul'),
                      ),
                      _buildNounOptionCell('Çoğul (Kurallı)'),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.fill,
                        child: _buildNounOptionCell('İkil'),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.fill,
                        child: _buildNounOptionCell('Tekil'),
                      ),
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

  Widget _buildCategoryOption(FormCategory category) {
    final isSelected = _selectedCategories.contains(category);
    final colorScheme = Theme.of(context).colorScheme;

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
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer.withValues(alpha: 0.55)
              : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? colorScheme.primary : const Color(0xFFD8D1C1),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? Icons.check_box : Icons.check_box_outline_blank,
              size: 20,
              color: isSelected ? colorScheme.primary : colorScheme.outline,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(category.label, style: const TextStyle(fontSize: 12)),
            ),
          ],
        ),
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
      leading: _practiceBackButton(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: IconButton.filledTonal(
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
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    question.prompt,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
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
          ),
          const SizedBox(height: 16),
          for (final option in question.options) ...[
            AnswerButton(
              text: option,
              isSelected: _selectedAnswer == option,
              isCorrect:
                  isAnswered &&
                  _selectedAnswer == option &&
                  option == question.answer,
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
            _AnswerFeedback(isCorrect: isCorrect),
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

class _AnswerFeedback extends StatelessWidget {
  const _AnswerFeedback({required this.isCorrect});

  final bool isCorrect;

  @override
  Widget build(BuildContext context) {
    final accent = isCorrect
        ? const Color(0xFF2F7D46)
        : const Color(0xFFB43C3C);
    final background = isCorrect
        ? const Color(0xFFE8F5EC)
        : const Color(0xFFFFECEC);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: accent,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                isCorrect ? 'Doğru' : 'Tekrar Bak',
                style: TextStyle(
                  color: accent,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget _practiceBackButton(BuildContext context) {
  return IconButton(
    onPressed: () => Navigator.of(context).pop(),
    icon: const Icon(Icons.arrow_back),
    tooltip: 'Geri',
  );
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
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
            ),
            if (isCorrect)
              const Icon(Icons.check_circle, color: Color(0xFF2F7D46))
            else if (isWrong)
              const Icon(Icons.cancel, color: Color(0xFFB43C3C)),
          ],
        ),
      ),
    );
  }
}
