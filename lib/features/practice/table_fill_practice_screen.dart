import 'dart:math';

import 'package:emsile_flutter/data/models.dart';
import 'package:emsile_flutter/features/conjugation/conjugation_screen.dart';
import 'package:emsile_flutter/shared/widgets/app_page.dart';
import 'package:emsile_flutter/shared/widgets/arabic_text.dart';
import 'package:flutter/material.dart';

class TableFillPracticeScreen extends StatefulWidget {
  const TableFillPracticeScreen({required this.data, this.random, super.key});

  final AppData data;
  final Random? random;

  @override
  State<TableFillPracticeScreen> createState() =>
      _TableFillPracticeScreenState();
}

class _TableFillPracticeScreenState extends State<TableFillPracticeScreen> {
  late FormCategory _category;
  bool _pronounMode = false;
  PronounKind _pronounKind = PronounKind.independent;
  Voice _voice = Voice.malum;
  bool _includeBrokenPlurals = true;
  bool _started = false;
  int _round = 0;
  final Map<FormSelection, _PlacedForm> _placed = {};
  final Set<FormSelection> _wrongSlots = {};
  List<_FormToken> _tokens = [];
  final Map<FormSelection, _PlacedPronoun> _placedPronouns = {};
  final Set<FormSelection> _wrongPronounSlots = {};
  List<_PronounToken> _pronounTokens = [];

  List<FormCategory> get _categories => FormCategory.values
      .where(
        (category) =>
            widget.data.forms.any((form) => form.category == category),
      )
      .toList();

  List<ConjugationForm> get _forms => widget.data.forms
      .where(
        (form) =>
            form.category == _category &&
            (_category.isNoun || form.voice == _voice) &&
            (_includeBrokenPlurals || !form.pronounLabel.contains('Kırık')),
      )
      .toList();

  List<PronounEntry> get _pronouns => widget.data.pronouns
      .where((pronoun) => pronoun.kind == _pronounKind)
      .toList();

  @override
  void initState() {
    super.initState();
    _category = _categories.first;
  }

  void _startRound() {
    final random = widget.random ?? Random();
    if (_pronounMode) {
      final pronouns = _pronouns;
      setState(() {
        _round++;
        _placedPronouns.clear();
        _wrongPronounSlots.clear();
        _pronounTokens = [
          for (var index = 0; index < pronouns.length; index++)
            _PronounToken(id: '$_round-$index', pronoun: pronouns[index]),
        ]..shuffle(random);
        _started = true;
      });
      return;
    }
    final forms = _forms;
    setState(() {
      _round++;
      _placed.clear();
      _wrongSlots.clear();
      _tokens = [
        for (var index = 0; index < forms.length; index++)
          _FormToken(id: '$_round-$index', form: forms[index]),
      ]..shuffle(random);
      _started = true;
    });
  }

  void _dropPronoun(_PronounToken token, FormSelection slot) {
    final expected = _pronounFor(slot);
    final previous = _placedPronouns[slot];
    if (expected == null || previous?.isCorrect == true) return;

    final isCorrect = token.pronoun.arabic == expected.arabic;
    setState(() {
      if (previous != null &&
          previous.token.id != token.id &&
          !_pronounTokens.any(
            (candidate) => candidate.id == previous.token.id,
          )) {
        _pronounTokens.add(previous.token);
      }
      if (isCorrect) {
        _wrongPronounSlots.remove(slot);
      } else {
        _wrongPronounSlots.add(slot);
      }
      _placedPronouns[slot] = _PlacedPronoun(
        token: token,
        pronoun: token.pronoun,
        isCorrect: isCorrect,
      );
      _pronounTokens.removeWhere((candidate) => candidate.id == token.id);
    });
  }

  void _releaseWrongPronoun(FormSelection slot) {
    final placed = _placedPronouns[slot];
    if (placed == null || placed.isCorrect) return;
    setState(() {
      _placedPronouns.remove(slot);
      _wrongPronounSlots.remove(slot);
      if (!_pronounTokens.any((token) => token.id == placed.token.id)) {
        _pronounTokens.add(placed.token);
      }
    });
  }

  PronounEntry? _pronounFor(FormSelection selection) {
    for (final pronoun in _pronouns) {
      if (pronoun.person == selection.person &&
          pronoun.number == selection.number &&
          pronoun.gender == selection.gender) {
        return pronoun;
      }
    }
    return null;
  }

  void _drop(_FormToken token, FormSelection slot) {
    final expected = _formFor(slot);
    final previous = _placed[slot];
    if (expected == null || previous?.isCorrect == true) {
      return;
    }

    final bothBrokenPlurals =
        token.form.category == expected.category &&
        token.form.pronounLabel.contains('Kırık') &&
        expected.pronounLabel.contains('Kırık');
    final isCorrect = token.form.arabic == expected.arabic || bothBrokenPlurals;
    setState(() {
      if (previous != null &&
          previous.token.id != token.id &&
          !_tokens.any((candidate) => candidate.id == previous.token.id)) {
        _tokens.add(previous.token);
      }
      if (isCorrect) {
        _wrongSlots.remove(slot);
      } else {
        _wrongSlots.add(slot);
      }
      _placed[slot] = _PlacedForm(
        token: token,
        form: token.form,
        isCorrect: isCorrect,
      );
      _tokens.removeWhere((candidate) => candidate.id == token.id);
    });
  }

  void _releaseWrong(FormSelection slot) {
    final placed = _placed[slot];
    if (placed == null || placed.isCorrect) return;
    setState(() {
      _placed.remove(slot);
      _wrongSlots.remove(slot);
      if (!_tokens.any((token) => token.id == placed.token.id)) {
        _tokens.add(placed.token);
      }
    });
  }

  ConjugationForm? _formFor(FormSelection selection) {
    for (final form in _forms) {
      if (selection.matches(form)) return form;
    }
    if (selection.person == FormPerson.first &&
        selection.number == FormNumber.dual) {
      for (final form in _forms) {
        if (form.person == FormPerson.first &&
            form.number == FormNumber.plural &&
            form.gender == selection.gender) {
          return form;
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (!_started) return _buildSetup();

    final allPlaced = _pronounMode ? _pronounTokens.isEmpty : _tokens.isEmpty;
    final complete = _pronounMode
        ? allPlaced &&
              _placedPronouns.length == _pronouns.length &&
              _placedPronouns.values.every((placed) => placed.isCorrect)
        : allPlaced &&
              _placed.length == _forms.length &&
              _placed.values.every((placed) => placed.isCorrect);
    return AppPage(
      title: 'Tabloyu Doldur',
      subtitle: _pronounMode
          ? _pronounKind.label
          : _category.isVerb
          ? '${_category.label} - ${_voice.label}'
          : _category.label,
      leading: _backButton(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Kalan: ${_pronounMode ? _pronounTokens.length : _tokens.length}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              TextButton.icon(
                onPressed: () => setState(() => _started = false),
                icon: const Icon(Icons.settings),
                label: const Text('Konuyu Değiştir'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_pronounMode)
            _PronounTokenPool(tokens: _pronounTokens)
          else
            _TokenPool(tokens: _tokens),
          const SizedBox(height: 18),
          if (_pronounMode)
            _PronounFillTable(
              pronouns: _pronouns,
              placed: _placedPronouns,
              wrongSlots: _wrongPronounSlots,
              onDrop: _dropPronoun,
              onWrongDragStarted: _releaseWrongPronoun,
            )
          else if (_category.isVerb)
            _FillTable(
              forms: _forms,
              placed: _placed,
              wrongSlots: _wrongSlots,
              onDrop: _drop,
              onWrongDragStarted: _releaseWrong,
            )
          else
            _NounFillTable(
              forms: _forms,
              placed: _placed,
              wrongSlots: _wrongSlots,
              onDrop: _drop,
              onWrongDragStarted: _releaseWrong,
            ),
          if (allPlaced && !complete) ...[
            const SizedBox(height: 16),
            const Card(
              color: Color(0xFFFFECEC),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.error_outline, color: Color(0xFFB43C3C)),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Tekrar bak. Kırmızı hücrelerdeki cevapları doğru yerlerine taşı.',
                        style: TextStyle(
                          color: Color(0xFF8D2D2D),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (complete) ...[
            const SizedBox(height: 16),
            Card(
              color: const Color(0xFFE8F5EC),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Tablo tamamlandı!',
                      style: TextStyle(
                        color: Color(0xFF2F7D46),
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _startRound,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Yeniden Karıştır'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSetup() {
    final voices = Voice.values
        .where(
          (voice) => widget.data.forms.any(
            (form) => form.category == _category && form.voice == voice,
          ),
        )
        .toList();
    if (!voices.contains(_voice)) _voice = voices.first;

    return AppPage(
      title: 'Tabloyu Doldur',
      subtitle: 'Doldurmak istediğin çekim tablosunu seç.',
      leading: _backButton(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Konu', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _pronounMode ? 'pronouns' : _category.name,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: [
              if (widget.data.pronouns.isNotEmpty)
                const DropdownMenuItem(
                  value: 'pronouns',
                  child: Text('Zamirler'),
                ),
              for (final category in _categories)
                DropdownMenuItem(
                  value: category.name,
                  child: Text(category.label),
                ),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _pronounMode = value == 'pronouns';
                if (!_pronounMode) {
                  _category = FormCategory.values.firstWhere(
                    (category) => category.name == value,
                  );
                }
              });
            },
          ),
          if (_pronounMode) ...[
            const SizedBox(height: 18),
            Text('Zamir Türü', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            SegmentedButton<PronounKind>(
              segments: [
                for (final kind in PronounKind.values)
                  ButtonSegment(value: kind, label: Text(kind.label)),
              ],
              selected: {_pronounKind},
              onSelectionChanged: (selection) {
                setState(() => _pronounKind = selection.first);
              },
            ),
          ] else if (_category.isVerb) ...[
            const SizedBox(height: 18),
            Text('Çatı', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            SegmentedButton<Voice>(
              segments: [
                for (final voice in voices)
                  ButtonSegment(value: voice, label: Text(voice.label)),
              ],
              selected: {_voice},
              onSelectionChanged: (selection) {
                setState(() => _voice = selection.first);
              },
            ),
          ] else if (widget.data.forms.any(
            (form) =>
                form.category == _category &&
                form.pronounLabel.contains('Kırık'),
          )) ...[
            const SizedBox(height: 18),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Kırık Çoğullar'),
              subtitle: const Text('Kırık çoğulları alıştırmaya dahil et.'),
              value: _includeBrokenPlurals,
              onChanged: (value) {
                setState(() => _includeBrokenPlurals = value);
              },
            ),
          ],
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: (_pronounMode ? _pronouns.isEmpty : _forms.isEmpty)
                ? null
                : _startRound,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Tabloyu Başlat'),
          ),
        ],
      ),
    );
  }

  Widget _backButton() {
    return IconButton(
      onPressed: () => Navigator.of(context).pop(),
      icon: const Icon(Icons.arrow_back),
      tooltip: 'Geri',
    );
  }
}

class _TokenPool extends StatelessWidget {
  const _TokenPool({required this.tokens});

  final List<_FormToken> tokens;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          width: double.infinity,
          height: 132,
          child: SingleChildScrollView(
            child: SizedBox(
              width: double.infinity,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final token in tokens)
                    Draggable<_FormToken>(
                      key: ValueKey('token-${token.id}'),
                      data: token,
                      feedback: Material(
                        color: Colors.transparent,
                        child: _ArabicToken(
                          text: token.form.arabic,
                          lifted: true,
                        ),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.25,
                        child: _ArabicToken(text: token.form.arabic),
                      ),
                      child: _ArabicToken(text: token.form.arabic),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PronounTokenPool extends StatelessWidget {
  const _PronounTokenPool({required this.tokens});

  final List<_PronounToken> tokens;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          width: double.infinity,
          height: 132,
          child: SingleChildScrollView(
            child: SizedBox(
              width: double.infinity,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final token in tokens)
                    Draggable<_PronounToken>(
                      key: ValueKey('pronoun-token-${token.id}'),
                      data: token,
                      feedback: Material(
                        color: Colors.transparent,
                        child: _ArabicToken(
                          text: token.pronoun.arabic,
                          lifted: true,
                        ),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.25,
                        child: _ArabicToken(text: token.pronoun.arabic),
                      ),
                      child: _ArabicToken(text: token.pronoun.arabic),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ArabicToken extends StatelessWidget {
  const _ArabicToken({required this.text, this.lifted = false});

  final String text;
  final bool lifted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.primary),
        boxShadow: lifted
            ? const [BoxShadow(blurRadius: 8, color: Colors.black26)]
            : null,
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Text(text, style: arabicTextStyle(20)),
      ),
    );
  }
}

class _FillTable extends StatelessWidget {
  const _FillTable({
    required this.forms,
    required this.placed,
    required this.wrongSlots,
    required this.onDrop,
    required this.onWrongDragStarted,
  });

  final List<ConjugationForm> forms;
  final Map<FormSelection, _PlacedForm> placed;
  final Set<FormSelection> wrongSlots;
  final void Function(_FormToken token, FormSelection slot) onDrop;
  final ValueChanged<FormSelection> onWrongDragStarted;

  ConjugationForm? _find(FormSelection slot) {
    for (final form in forms) {
      if (slot.matches(form)) return form;
    }
    if (slot.person == FormPerson.first && slot.number == FormNumber.dual) {
      for (final form in forms) {
        if (form.person == FormPerson.first &&
            form.number == FormNumber.plural &&
            form.gender == slot.gender) {
          return form;
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          children: [
            Table(
              border: TableBorder.all(color: const Color(0xFFD8D1C1)),
              columnWidths: const {
                0: FixedColumnWidth(82),
                1: FixedColumnWidth(82),
                2: FixedColumnWidth(82),
                3: FixedColumnWidth(92),
              },
              children: [
                TableRow(
                  children: [
                    for (final column in pdfColumns)
                      _TableLabel(text: column.label),
                    const _TableLabel(text: ''),
                  ],
                ),
              ],
            ),
            for (final row in pdfRows)
              if (row.person == FormPerson.first)
                Table(
                  border: TableBorder.all(color: const Color(0xFFD8D1C1)),
                  columnWidths: const {
                    0: FixedColumnWidth(164),
                    1: FixedColumnWidth(82),
                    2: FixedColumnWidth(92),
                  },
                  children: [
                    TableRow(
                      children: [
                        _DropCell(
                          slot: row.selectionFor(FormNumber.plural),
                          expected: _find(row.selectionFor(FormNumber.plural)),
                          placed: placed[row.selectionFor(FormNumber.plural)],
                          isWrong: wrongSlots.contains(
                            row.selectionFor(FormNumber.plural),
                          ),
                          onDrop: onDrop,
                          onWrongDragStarted: onWrongDragStarted,
                        ),
                        _DropCell(
                          slot: row.selectionFor(FormNumber.singular),
                          expected: _find(
                            row.selectionFor(FormNumber.singular),
                          ),
                          placed: placed[row.selectionFor(FormNumber.singular)],
                          isWrong: wrongSlots.contains(
                            row.selectionFor(FormNumber.singular),
                          ),
                          onDrop: onDrop,
                          onWrongDragStarted: onWrongDragStarted,
                        ),
                        _TableLabel(text: row.label),
                      ],
                    ),
                  ],
                )
              else
                Table(
                  border: TableBorder.all(color: const Color(0xFFD8D1C1)),
                  columnWidths: const {
                    0: FixedColumnWidth(82),
                    1: FixedColumnWidth(82),
                    2: FixedColumnWidth(82),
                    3: FixedColumnWidth(92),
                  },
                  children: [
                    TableRow(
                      children: [
                        for (final column in pdfColumns)
                          _DropCell(
                            slot: row.selectionFor(column.number),
                            expected: _find(row.selectionFor(column.number)),
                            placed: placed[row.selectionFor(column.number)],
                            isWrong: wrongSlots.contains(
                              row.selectionFor(column.number),
                            ),
                            onDrop: onDrop,
                            onWrongDragStarted: onWrongDragStarted,
                          ),
                        _TableLabel(text: row.label),
                      ],
                    ),
                  ],
                ),
          ],
        ),
      ),
    );
  }
}

class _PronounFillTable extends StatelessWidget {
  const _PronounFillTable({
    required this.pronouns,
    required this.placed,
    required this.wrongSlots,
    required this.onDrop,
    required this.onWrongDragStarted,
  });

  final List<PronounEntry> pronouns;
  final Map<FormSelection, _PlacedPronoun> placed;
  final Set<FormSelection> wrongSlots;
  final void Function(_PronounToken token, FormSelection slot) onDrop;
  final ValueChanged<FormSelection> onWrongDragStarted;

  PronounEntry? _find(FormSelection slot) {
    for (final pronoun in pronouns) {
      if (pronoun.person == slot.person &&
          pronoun.number == slot.number &&
          pronoun.gender == slot.gender) {
        return pronoun;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          children: [
            Table(
              border: TableBorder.all(color: const Color(0xFFD8D1C1)),
              columnWidths: const {
                0: FixedColumnWidth(82),
                1: FixedColumnWidth(82),
                2: FixedColumnWidth(82),
                3: FixedColumnWidth(92),
              },
              children: const [
                TableRow(
                  children: [
                    _TableLabel(text: 'Çoğul'),
                    _TableLabel(text: 'İkil'),
                    _TableLabel(text: 'Tekil'),
                    _TableLabel(text: ''),
                  ],
                ),
              ],
            ),
            for (final row in pdfRows)
              if (row.person == FormPerson.first)
                Table(
                  border: TableBorder.all(color: const Color(0xFFD8D1C1)),
                  columnWidths: const {
                    0: FixedColumnWidth(164),
                    1: FixedColumnWidth(82),
                    2: FixedColumnWidth(92),
                  },
                  children: [
                    TableRow(
                      children: [
                        _PronounDropCell(
                          slot: row.selectionFor(FormNumber.plural),
                          expected: _find(row.selectionFor(FormNumber.plural)),
                          placed: placed[row.selectionFor(FormNumber.plural)],
                          isWrong: wrongSlots.contains(
                            row.selectionFor(FormNumber.plural),
                          ),
                          onDrop: onDrop,
                          onWrongDragStarted: onWrongDragStarted,
                        ),
                        _PronounDropCell(
                          slot: row.selectionFor(FormNumber.singular),
                          expected: _find(
                            row.selectionFor(FormNumber.singular),
                          ),
                          placed: placed[row.selectionFor(FormNumber.singular)],
                          isWrong: wrongSlots.contains(
                            row.selectionFor(FormNumber.singular),
                          ),
                          onDrop: onDrop,
                          onWrongDragStarted: onWrongDragStarted,
                        ),
                        _TableLabel(text: row.label),
                      ],
                    ),
                  ],
                )
              else
                Table(
                  border: TableBorder.all(color: const Color(0xFFD8D1C1)),
                  columnWidths: const {
                    0: FixedColumnWidth(82),
                    1: FixedColumnWidth(82),
                    2: FixedColumnWidth(82),
                    3: FixedColumnWidth(92),
                  },
                  children: [
                    TableRow(
                      children: [
                        for (final column in pdfColumns)
                          _PronounDropCell(
                            slot: row.selectionFor(column.number),
                            expected: _find(row.selectionFor(column.number)),
                            placed: placed[row.selectionFor(column.number)],
                            isWrong: wrongSlots.contains(
                              row.selectionFor(column.number),
                            ),
                            onDrop: onDrop,
                            onWrongDragStarted: onWrongDragStarted,
                          ),
                        _TableLabel(text: row.label),
                      ],
                    ),
                  ],
                ),
          ],
        ),
      ),
    );
  }
}

class _PronounDropCell extends StatelessWidget {
  const _PronounDropCell({
    required this.slot,
    required this.expected,
    required this.placed,
    required this.isWrong,
    required this.onDrop,
    required this.onWrongDragStarted,
  });

  final FormSelection slot;
  final PronounEntry? expected;
  final _PlacedPronoun? placed;
  final bool isWrong;
  final void Function(_PronounToken token, FormSelection slot) onDrop;
  final ValueChanged<FormSelection> onWrongDragStarted;

  @override
  Widget build(BuildContext context) {
    final dropKey = ValueKey(
      'pronoun-drop-${slot.person.name}-${slot.number.name}-${slot.gender.name}',
    );
    if (expected == null) {
      return Container(
        key: dropKey,
        height: 70,
        color: const Color(0xFF5F625F),
        child: const Icon(Icons.block, color: Colors.white54, size: 18),
      );
    }

    return DragTarget<_PronounToken>(
      onAcceptWithDetails: (details) => onDrop(details.data, slot),
      builder: (context, candidates, rejected) {
        final isCorrect = placed?.isCorrect ?? false;
        final isPlacedWrong = placed != null && !isCorrect;
        final color = isCorrect
            ? const Color(0xFFE0F3E5)
            : isPlacedWrong || isWrong
            ? const Color(0xFFFFDCDC)
            : candidates.isNotEmpty
            ? const Color(0xFFE2E7EA)
            : Colors.white;

        final content = AnimatedContainer(
          key: dropKey,
          duration: const Duration(milliseconds: 180),
          height: 70,
          color: color,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(4),
          child: placed == null
              ? Icon(Icons.add, color: Theme.of(context).colorScheme.outline)
              : Stack(
                  fit: StackFit.expand,
                  children: [
                    Center(
                      child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: Text(
                          placed!.pronoun.arabic,
                          textAlign: TextAlign.center,
                          style: arabicTextStyle(19).copyWith(
                            color: isCorrect
                                ? const Color(0xFF236437)
                                : const Color(0xFF9C2F2F),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Icon(
                        isCorrect ? Icons.check_circle : Icons.cancel,
                        size: 17,
                        color: isCorrect
                            ? const Color(0xFF2F7D46)
                            : const Color(0xFFB43C3C),
                      ),
                    ),
                  ],
                ),
        );

        if (placed == null || isCorrect) return content;
        return Draggable<_PronounToken>(
          data: placed!.token,
          onDragStarted: () => onWrongDragStarted(slot),
          feedback: Material(
            color: Colors.transparent,
            child: _ArabicToken(text: placed!.pronoun.arabic, lifted: true),
          ),
          child: content,
        );
      },
    );
  }
}

class _NounFillTable extends StatelessWidget {
  const _NounFillTable({
    required this.forms,
    required this.placed,
    required this.wrongSlots,
    required this.onDrop,
    required this.onWrongDragStarted,
  });

  final List<ConjugationForm> forms;
  final Map<FormSelection, _PlacedForm> placed;
  final Set<FormSelection> wrongSlots;
  final void Function(_FormToken token, FormSelection slot) onDrop;
  final ValueChanged<FormSelection> onWrongDragStarted;

  @override
  Widget build(BuildContext context) {
    final rows = _buildRows();
    final mainForms = rows
        .expand((row) => row.forms)
        .whereType<ConjugationForm>()
        .toSet();
    final extraForms = forms
        .where((form) => !mainForms.contains(form))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Table(
              border: TableBorder.all(color: const Color(0xFFD8D1C1)),
              columnWidths: const {
                0: FixedColumnWidth(82),
                1: FixedColumnWidth(82),
                2: FixedColumnWidth(82),
                3: FixedColumnWidth(92),
              },
              children: [
                const TableRow(
                  children: [
                    _TableLabel(text: 'Çoğul'),
                    _TableLabel(text: 'İkil'),
                    _TableLabel(text: 'Tekil'),
                    _TableLabel(text: ''),
                  ],
                ),
                for (final row in rows)
                  TableRow(
                    children: [
                      for (final form in row.forms)
                        if (form == null)
                          const _ClosedCell()
                        else
                          _nounDropCell(form),
                      _TableLabel(text: row.label),
                    ],
                  ),
              ],
            ),
          ),
        ),
        if (extraForms.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(
            'Kırık Çoğullar',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final form in extraForms)
                SizedBox(width: 112, child: _nounDropCell(form)),
            ],
          ),
        ],
      ],
    );
  }

  Widget _nounDropCell(ConjugationForm form) {
    final slot = FormSelection.fromForm(form);
    return _DropCell(
      slot: slot,
      expected: form,
      placed: placed[slot],
      isWrong: wrongSlots.contains(slot),
      onDrop: onDrop,
      onWrongDragStarted: onWrongDragStarted,
    );
  }

  List<_NounRow> _buildRows() {
    final hasGender = forms.any((form) => form.gender != FormGender.common);
    final genders = hasGender
        ? const [FormGender.masculine, FormGender.feminine]
        : const [FormGender.common];

    return [
      for (final gender in genders)
        _NounRow(
          label: gender == FormGender.masculine
              ? 'Müzekker'
              : gender == FormGender.feminine
              ? 'Müennes'
              : 'Ortak',
          forms: [
            _findMainForm(gender, FormNumber.plural),
            _findMainForm(gender, FormNumber.dual),
            _findMainForm(gender, FormNumber.singular),
          ],
        ),
    ];
  }

  ConjugationForm? _findMainForm(FormGender gender, FormNumber number) {
    for (final form in forms) {
      final genderMatches =
          form.gender == gender ||
          (gender == FormGender.common && form.gender == FormGender.common);
      final isBroken = form.pronounLabel.contains('Kırık');
      if (genderMatches && form.number == number && !isBroken) {
        return form;
      }
    }
    return null;
  }
}

class _NounRow {
  const _NounRow({required this.label, required this.forms});

  final String label;
  final List<ConjugationForm?> forms;
}

class _ClosedCell extends StatelessWidget {
  const _ClosedCell();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      color: const Color(0xFF5F625F),
      child: const Icon(Icons.block, color: Colors.white54, size: 18),
    );
  }
}

class _DropCell extends StatelessWidget {
  const _DropCell({
    required this.slot,
    required this.expected,
    required this.placed,
    required this.isWrong,
    required this.onDrop,
    required this.onWrongDragStarted,
  });

  final FormSelection slot;
  final ConjugationForm? expected;
  final _PlacedForm? placed;
  final bool isWrong;
  final void Function(_FormToken token, FormSelection slot) onDrop;
  final ValueChanged<FormSelection> onWrongDragStarted;

  @override
  Widget build(BuildContext context) {
    final keySuffix = slot.arabic == null ? '' : '-${slot.arabic}';
    final dropKey = ValueKey(
      'drop-${slot.person.name}-${slot.number.name}-${slot.gender.name}$keySuffix',
    );

    if (expected == null) {
      return Container(
        key: dropKey,
        height: 70,
        color: const Color(0xFF5F625F),
        child: const Icon(Icons.block, color: Colors.white54, size: 18),
      );
    }

    return DragTarget<_FormToken>(
      onAcceptWithDetails: (details) => onDrop(details.data, slot),
      builder: (context, candidates, rejected) {
        final isCorrect = placed?.isCorrect ?? false;
        final isPlacedWrong = placed != null && !isCorrect;
        final Color color;
        if (isCorrect) {
          color = const Color(0xFFE0F3E5);
        } else if (isPlacedWrong || isWrong) {
          color = const Color(0xFFFFDCDC);
        } else if (candidates.isNotEmpty) {
          color = const Color(0xFFE2E7EA);
        } else {
          color = Colors.white;
        }

        final content = AnimatedContainer(
          key: dropKey,
          duration: const Duration(milliseconds: 180),
          height: 70,
          color: color,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(4),
          child: placed == null
              ? Icon(
                  Icons.add,
                  color: isWrong
                      ? const Color(0xFFB43C3C)
                      : Theme.of(context).colorScheme.outline,
                )
              : Stack(
                  fit: StackFit.expand,
                  children: [
                    Center(
                      child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: Text(
                          placed!.form.arabic,
                          textAlign: TextAlign.center,
                          style: arabicTextStyle(19).copyWith(
                            color: isCorrect
                                ? const Color(0xFF236437)
                                : const Color(0xFF9C2F2F),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Icon(
                        isCorrect ? Icons.check_circle : Icons.cancel,
                        size: 17,
                        color: isCorrect
                            ? const Color(0xFF2F7D46)
                            : const Color(0xFFB43C3C),
                      ),
                    ),
                  ],
                ),
        );

        if (placed == null || isCorrect) return content;

        return Draggable<_FormToken>(
          data: placed!.token,
          onDragStarted: () => onWrongDragStarted(slot),
          feedback: Material(
            color: Colors.transparent,
            child: _ArabicToken(text: placed!.form.arabic, lifted: true),
          ),
          childWhenDragging: Container(
            height: 70,
            color: Colors.white,
            alignment: Alignment.center,
            child: Icon(
              Icons.add,
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          child: content,
        );
      },
    );
  }
}

class _TableLabel extends StatelessWidget {
  const _TableLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      color: const Color(0xFFF4F0E6),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(4),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _FormToken {
  const _FormToken({required this.id, required this.form});

  final String id;
  final ConjugationForm form;
}

class _PronounToken {
  const _PronounToken({required this.id, required this.pronoun});

  final String id;
  final PronounEntry pronoun;
}

class _PlacedForm {
  const _PlacedForm({
    required this.token,
    required this.form,
    required this.isCorrect,
  });

  final _FormToken token;
  final ConjugationForm form;
  final bool isCorrect;
}

class _PlacedPronoun {
  const _PlacedPronoun({
    required this.token,
    required this.pronoun,
    required this.isCorrect,
  });

  final _PronounToken token;
  final PronounEntry pronoun;
  final bool isCorrect;
}
