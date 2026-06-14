import 'package:emsile_flutter/data/models.dart';
import 'package:emsile_flutter/shared/widgets/arabic_result_card.dart';
import 'package:emsile_flutter/shared/widgets/arabic_text.dart';
import 'package:emsile_flutter/shared/widgets/app_page.dart';
import 'package:emsile_flutter/shared/widgets/info_panel.dart';
import 'package:flutter/material.dart';

class ConjugationScreen extends StatelessWidget {
  const ConjugationScreen({required this.data, super.key});

  final AppData data;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AppPage(
      title: 'Çekim Tablosu',
      scrollable: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            _MenuCard(
              icon: Icons.grid_view_outlined,
              title: 'Çekimler',
              subtitle: 'Fiil ve isim çekim tablolarını incele',
              color: colorScheme.primaryContainer,
              iconColor: colorScheme.primary,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => _ConjugationsPage(data: data),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _MenuCard(
              icon: Icons.badge_outlined,
              title: 'Zamirler',
              subtitle: 'Ayrı ve bitişik şahıs zamirlerini gör',
              color: colorScheme.secondaryContainer,
              iconColor: colorScheme.secondary,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => _PronounsPage(pronouns: data.pronouns),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PronounsPage extends StatefulWidget {
  const _PronounsPage({required this.pronouns});

  final List<PronounEntry> pronouns;

  @override
  State<_PronounsPage> createState() => _PronounsPageState();
}

class _PronounsPageState extends State<_PronounsPage> {
  PronounKind _pronounKind = PronounKind.independent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zamirler'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: AppPage(
          title: 'Zamirler',
          scrollable: false,
          child: PronounsPanel(
            pronouns: widget.pronouns,
            selectedKind: _pronounKind,
            onKindChanged: (kind) => setState(() => _pronounKind = kind),
          ),
        ),
      ),
    );
  }
}

class _ConjugationsPage extends StatefulWidget {
  const _ConjugationsPage({required this.data});

  final AppData data;

  @override
  State<_ConjugationsPage> createState() => _ConjugationsPageState();
}

class _ConjugationsPageState extends State<_ConjugationsPage> {
  FormCategory _category = FormCategory.mazi;
  Voice _voice = Voice.malum;
  FormSelection _selectedForm = const FormSelection(
    person: FormPerson.third,
    number: FormNumber.singular,
    gender: FormGender.masculine,
  );

  @override
  void initState() {
    super.initState();
    if (widget.data.forms.isNotEmpty) {
      final hasCategory = widget.data.forms.any(
        (f) => f.category == _category,
      );
      if (!hasCategory) {
        _category = widget.data.forms.first.category;
      }
    }
  }

  List<ConjugationForm> get _visibleForms {
    if (_category.isNoun) {
      return widget.data.forms
          .where((form) => form.category == _category)
          .toList();
    }
    return widget.data.forms
        .where((form) => form.category == _category && form.voice == _voice)
        .toList();
  }

  ConjugationForm get _activeForm {
    final forms = _visibleForms;
    return forms.firstWhere(_selectedForm.matches, orElse: () => forms.first);
  }

  void _updateSelection({
    FormCategory? category,
    Voice? voice,
    FormSelection? selectedForm,
  }) {
    setState(() {
      _category = category ?? _category;
      _voice = voice ?? _voice;

      var tempSelection = selectedForm ?? _selectedForm;
      if (category != null || voice != null) {
        // Discard the arabic field because we are changing category/voice
        tempSelection = FormSelection(
          person: tempSelection.person,
          number: tempSelection.number,
          gender: tempSelection.gender,
        );
      }

      final forms = _visibleForms;
      if (forms.isNotEmpty) {
        final match = forms.firstWhere(
          tempSelection.matches,
          orElse: () => forms.first,
        );
        _selectedForm = FormSelection.fromForm(match);
      } else {
        _selectedForm = tempSelection;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final forms = _visibleForms;
    final activeForm = forms.isEmpty ? null : _activeForm;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Çekimler'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: AppPage(
          title: 'Çekimler',
          scrollable: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (activeForm == null) ...[
                const Expanded(
                  child: Center(child: Text('Gösterilecek çekim formu yok.')),
                ),
              ] else ...[
                ArabicResultCard(form: activeForm),
                const SizedBox(height: 10),
                if (_category.isVerb) ...[
                  SegmentedButton<Voice>(
                    expandedInsets: EdgeInsets.zero,
                    segments: const [
                      ButtonSegment(
                        value: Voice.malum,
                        icon: Icon(Icons.record_voice_over),
                        label: Text('Malum'),
                      ),
                      ButtonSegment(
                        value: Voice.mechul,
                        icon: Icon(Icons.visibility_off_outlined),
                        label: Text('Meçhul'),
                      ),
                    ],
                    selected: {_voice},
                    onSelectionChanged: (value) {
                      _updateSelection(voice: value.first);
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        DropdownButtonFormField<FormCategory>(
                          initialValue: _category,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Çekim Grubu',
                            prefixIcon: Icon(Icons.view_list_outlined),
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            for (final category in FormCategory.values)
                              DropdownMenuItem(
                                value: category,
                                child: Text(category.label),
                              ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              _updateSelection(category: value);
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        if (_category.isVerb) ...[
                          Text(
                            'Şahıs Tablosu',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 10),
                          SelectionTable(
                            forms: forms,
                            selectedForm: _selectedForm,
                            onSelect: (selection) =>
                                _updateSelection(selectedForm: selection),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'Seçili Tablo (${_category.label} - ${_voice.label})',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 10),
                          FormsTable(
                            forms: forms,
                            selectedForm: _selectedForm,
                            activeCategory: _category,
                            activeVoice: _voice,
                            onSelect: (selection) =>
                                _updateSelection(selectedForm: selection),
                          ),
                        ] else ...[
                          Text(
                            'Çekim Tablosu',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 10),
                          NounFormsTable(
                            forms: forms,
                            selectedForm: _selectedForm,
                            onSelect: (selection) =>
                                _updateSelection(selectedForm: selection),
                          ),
                        ],
                        const SizedBox(height: 24),
                        OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => _AllMuttarideTablesPage(
                                  data: widget.data,
                                  selectedForm: _selectedForm,
                                  onSelect: _updateSelection,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.table_rows_outlined),
                          label: const Text('Tüm Muttaride Tablolarını Gör'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ConjugationGroup {
  const _ConjugationGroup({
    required this.category,
    required this.voice,
    required this.forms,
  });

  final FormCategory category;
  final Voice voice;
  final List<ConjugationForm> forms;
}

class SelectionTable extends StatelessWidget {
  const SelectionTable({
    required this.forms,
    required this.selectedForm,
    required this.onSelect,
    super.key,
  });

  final List<ConjugationForm> forms;
  final FormSelection selectedForm;
  final ValueChanged<FormSelection> onSelect;

  @override
  Widget build(BuildContext context) {
    final dataColumnWidths = _measureDataColumnWidths(
      context,
      rows: [
        for (final row in pdfRows)
          PdfTableRowData(
            rowLabel: row.label,
            cells: [
              for (final number in pdfColumns)
                _SelectionCellData(
                  form: _findForm(forms, row.selectionFor(number.number)),
                  selection: row.selectionFor(number.number),
                ),
            ],
          ),
      ],
      textForCell: (data) => (data as _SelectionCellData).form?.pronounLabel,
      textStyle: Theme.of(context).textTheme.labelMedium,
    );

    return PdfStyleTable(
      dataColumnWidths: dataColumnWidths,
      rows: [
        for (final row in pdfRows)
          PdfTableRowData(
            rowLabel: row.label,
            cells: [
              for (final number in pdfColumns)
                _SelectionCellData(
                  form: _findForm(forms, row.selectionFor(number.number)),
                  selection: row.selectionFor(number.number),
                ),
            ],
          ),
      ],
      cellBuilder: (context, data) {
        final selectionCell = data as _SelectionCellData;
        if (selectionCell.form == null) {
          return const SizedBox.shrink();
        }

        final isSelected = selectedForm.person == selectionCell.selection.person &&
            selectedForm.number == selectionCell.selection.number &&
            selectedForm.gender == selectionCell.selection.gender;
        final colorScheme = Theme.of(context).colorScheme;

        return InkWell(
          onTap: () => onSelect(selectionCell.selection),
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
            decoration: BoxDecoration(
              color: isSelected ? colorScheme.primaryContainer : Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              selectionCell.form!.pronounLabel,
              textAlign: TextAlign.center,
              maxLines: 1,
              softWrap: false,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? colorScheme.onPrimaryContainer : null,
              ),
            ),
          ),
        );
      },
    );
  }
}

class FormsTable extends StatelessWidget {
  const FormsTable({
    required this.forms,
    required this.selectedForm,
    required this.activeCategory,
    required this.activeVoice,
    required this.onSelect,
    super.key,
  });

  final List<ConjugationForm> forms;
  final FormSelection selectedForm;
  final FormCategory activeCategory;
  final Voice activeVoice;
  final ValueChanged<FormSelection> onSelect;

  @override
  Widget build(BuildContext context) {
    final rows = [
      for (final row in pdfRows)
        PdfTableRowData(
          rowLabel: row.label,
          cells: [
            for (final number in pdfColumns)
              _findForm(forms, row.selectionFor(number.number)),
          ],
        ),
    ];

    final dataColumnWidths = _measureDataColumnWidths(
      context,
      rows: rows,
      textForCell: (data) => (data as ConjugationForm?)?.arabic,
      textStyle: arabicTextStyle(20),
      textDirection: TextDirection.rtl,
    );

    return PdfStyleTable(
      dataColumnWidths: dataColumnWidths,
      rows: rows,
      cellBuilder: (context, data) {
        final form = data as ConjugationForm?;
        if (form == null) {
          return const SizedBox.shrink();
        }

        final isSelected =
            activeCategory == form.category &&
            activeVoice == form.voice &&
            selectedForm.matches(form);
        final colorScheme = Theme.of(context).colorScheme;
        final selection = FormSelection.fromForm(form);

        return InkWell(
          onTap: () => onSelect(selection),
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
            decoration: BoxDecoration(
              color: isSelected
                  ? colorScheme.primaryContainer.withValues(alpha: 0.55)
                  : null,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                form.arabic,
                textAlign: TextAlign.center,
                maxLines: 1,
                softWrap: false,
                style: arabicTextStyle(20),
              ),
            ),
          ),
        );
      },
    );
  }
}

class PronounsPanel extends StatelessWidget {
  const PronounsPanel({
    required this.pronouns,
    required this.selectedKind,
    required this.onKindChanged,
    super.key,
  });

  final List<PronounEntry> pronouns;
  final PronounKind selectedKind;
  final ValueChanged<PronounKind> onKindChanged;

  @override
  Widget build(BuildContext context) {
    final visiblePronouns = pronouns
        .where((pronoun) => pronoun.kind == selectedKind)
        .toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SegmentedButton<PronounKind>(
            expandedInsets: EdgeInsets.zero,
            segments: const [
              ButtonSegment(
                value: PronounKind.independent,
                icon: Icon(Icons.person_outline),
                label: Text('Ayrı'),
              ),
              ButtonSegment(
                value: PronounKind.attached,
                icon: Icon(Icons.link),
                label: Text('Bitişik'),
              ),
            ],
            selected: {selectedKind},
            onSelectionChanged: (value) => onKindChanged(value.first),
          ),
          const SizedBox(height: 14),
          InfoPanel(
            title: selectedKind.label,
            body: selectedKind == PronounKind.independent
                ? 'Şahıs zamirleri, fiil çekimindeki şahıs düzenini okumak için temel tablodur.'
                : 'Bitişik zamirler isim, harf ve fiile eklenir; fiile geldiğinde çoğunlukla mef’ul anlamı verir.',
          ),
          const SizedBox(height: 14),
          if (visiblePronouns.isEmpty)
            const Center(child: Text('Gösterilecek zamir verisi yok.'))
          else
            PronounTable(pronouns: visiblePronouns),
          if (selectedKind == PronounKind.attached) ...[
            const SizedBox(height: 14),
            const InfoPanel(
              title: 'Fiile gelince',
              body:
                  'Örnek: ضَرَبْتُهُ kelimesinde تُ faili, هُ ise fiile bitişen mef’ul zamiridir.',
            ),
          ],
        ],
      ),
    );
  }
}

class PronounTable extends StatelessWidget {
  const PronounTable({required this.pronouns, super.key});

  final List<PronounEntry> pronouns;

  @override
  Widget build(BuildContext context) {
    final rows = [
      for (final row in pdfRows)
        PdfTableRowData(
          rowLabel: row.label,
          cells: [
            for (final number in pdfColumns)
              _findPronoun(pronouns, row.selectionFor(number.number)),
          ],
        ),
    ];

    final dataColumnWidths = _measureDataColumnWidths(
      context,
      rows: rows,
      textForCell: (data) => (data as PronounEntry?)?.arabic,
      textStyle: arabicTextStyle(21),
      textDirection: TextDirection.rtl,
    );

    return PdfStyleTable(
      dataColumnWidths: dataColumnWidths,
      rows: rows,
      cellBuilder: (context, data) {
        final pronoun = data as PronounEntry?;
        if (pronoun == null) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  pronoun.arabic,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  softWrap: false,
                  style: arabicTextStyle(21),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                pronoun.labelTr,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        );
      },
    );
  }
}

class PdfStyleTable extends StatelessWidget {
  const PdfStyleTable({
    required this.rows,
    required this.cellBuilder,
    this.dataColumnWidths,
    super.key,
  });

  final List<PdfTableRowData> rows;
  final Widget Function(BuildContext context, Object? data) cellBuilder;
  final List<double>? dataColumnWidths;

  @override
  Widget build(BuildContext context) {
    final borderColor = const Color(0xFFD8D1C1);
    final labelStyle = Theme.of(
      context,
    ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700);
    final baseDataWidths = dataColumnWidths ?? const [56, 56, 56];
    const baseLabelWidth = 80.0;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columnWidths = _expandTableColumnWidths(
            availableWidth: constraints.maxWidth,
            dataWidths: baseDataWidths,
            labelWidth: baseLabelWidth,
          );

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Table(
              border: TableBorder.all(color: borderColor),
              columnWidths: {
                0: FixedColumnWidth(columnWidths[0]),
                1: FixedColumnWidth(columnWidths[1]),
                2: FixedColumnWidth(columnWidths[2]),
                3: FixedColumnWidth(columnWidths[3]),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                TableRow(
                  decoration: const BoxDecoration(color: Color(0xFFF4F0E6)),
                  children: [
                    _HeaderCell(
                      text: pdfColumns[0].label,
                      width: columnWidths[0],
                    ),
                    _HeaderCell(
                      text: pdfColumns[1].label,
                      width: columnWidths[1],
                    ),
                    _HeaderCell(
                      text: pdfColumns[2].label,
                      width: columnWidths[2],
                    ),
                    _HeaderCell(text: '', width: columnWidths[3]),
                  ],
                ),
                for (final row in rows)
                  TableRow(
                    children: [
                      for (final cell in row.cells)
                        Padding(
                          padding: const EdgeInsets.all(1),
                          child: SizedBox(
                            height: 66,
                            child: Center(child: cellBuilder(context, cell)),
                          ),
                        ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.fill,
                        child: Container(
                          color: const Color(0xFFF4F0E6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 5,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            row.rowLabel,
                            textAlign: TextAlign.center,
                            style: labelStyle,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({required this.text, this.width});

  final String text;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 7),
      child: SizedBox(
        width: width,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }
}

List<double> _measureDataColumnWidths(
  BuildContext context, {
  required List<PdfTableRowData> rows,
  required String? Function(Object? data) textForCell,
  required TextStyle? textStyle,
  TextDirection textDirection = TextDirection.ltr,
}) {
  final widths = [0.0, 0.0, 0.0];

  for (final row in rows) {
    for (var index = 0; index < row.cells.length && index < 3; index++) {
      final text = textForCell(row.cells[index]);
      if (text == null || text.isEmpty) {
        continue;
      }
      final painter = TextPainter(
        text: TextSpan(text: text, style: textStyle),
        textDirection: textDirection,
        maxLines: 1,
      )..layout();
      final width = painter.width + 12;
      if (width > widths[index]) {
        widths[index] = width;
      }
    }
  }

  return [for (final width in widths) width < 54 ? 54 : width];
}

List<double> _expandTableColumnWidths({
  required double availableWidth,
  required List<double> dataWidths,
  required double labelWidth,
}) {
  final baseWidths = [...dataWidths.take(3), labelWidth];
  final intrinsicWidth = baseWidths.reduce((sum, width) => sum + width);

  if (!availableWidth.isFinite || availableWidth <= intrinsicWidth) {
    return baseWidths;
  }

  final extraPerColumn = (availableWidth - intrinsicWidth) / baseWidths.length;
  return [for (final width in baseWidths) width + extraPerColumn];
}

class PdfTableRowData {
  const PdfTableRowData({required this.rowLabel, required this.cells});

  final String rowLabel;
  final List<Object?> cells;
}

class _SelectionCellData {
  const _SelectionCellData({required this.form, required this.selection});

  final ConjugationForm? form;
  final FormSelection selection;
}

class PdfRowSpec {
  const PdfRowSpec({
    required this.person,
    required this.gender,
    required this.label,
  });

  final FormPerson person;
  final FormGender gender;
  final String label;

  FormSelection selectionFor(FormNumber number) {
    return FormSelection(person: person, number: number, gender: gender);
  }
}

class PdfColumnSpec {
  const PdfColumnSpec(this.number, this.label);

  final FormNumber number;
  final String label;
}

class FormSelection {
  const FormSelection({
    required this.person,
    required this.number,
    required this.gender,
    this.arabic,
  });

  final FormPerson person;
  final FormNumber number;
  final FormGender gender;
  final String? arabic;

  factory FormSelection.fromForm(ConjugationForm form) {
    return FormSelection(
      person: form.person,
      number: form.number,
      gender: form.gender,
      arabic: form.arabic,
    );
  }

  bool matches(ConjugationForm form) {
    if (arabic != null && form.arabic != arabic) {
      return false;
    }
    return form.person == person &&
        form.number == number &&
        form.gender == gender;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is FormSelection &&
        other.person == person &&
        other.number == number &&
        other.gender == gender &&
        other.arabic == arabic;
  }

  @override
  int get hashCode => Object.hash(person, number, gender, arabic);
}

ConjugationForm? _findForm(
  List<ConjugationForm> forms,
  FormSelection selection,
) {
  for (final form in forms) {
    if (selection.matches(form)) {
      return form;
    }
  }
  return null;
}

PronounEntry? _findPronoun(
  List<PronounEntry> pronouns,
  FormSelection selection,
) {
  for (final pronoun in pronouns) {
    if (pronoun.person == selection.person &&
        pronoun.number == selection.number &&
        pronoun.gender == selection.gender) {
      return pronoun;
    }
  }
  return null;
}

const pdfColumns = [
  PdfColumnSpec(FormNumber.plural, 'Çoğul'),
  PdfColumnSpec(FormNumber.dual, 'İkil'),
  PdfColumnSpec(FormNumber.singular, 'Tekil'),
];

const pdfRows = [
  PdfRowSpec(
    person: FormPerson.third,
    gender: FormGender.masculine,
    label: '3. Şahıs\nMüzekker',
  ),
  PdfRowSpec(
    person: FormPerson.third,
    gender: FormGender.feminine,
    label: '3. Şahıs\nMüennes',
  ),
  PdfRowSpec(
    person: FormPerson.second,
    gender: FormGender.masculine,
    label: '2. Şahıs\nMüzekker',
  ),
  PdfRowSpec(
    person: FormPerson.second,
    gender: FormGender.feminine,
    label: '2. Şahıs\nMüennes',
  ),
  PdfRowSpec(
    person: FormPerson.first,
    gender: FormGender.common,
    label: '1. Şahıs\nOrtak',
  ),
];

class NounFormsTable extends StatelessWidget {
  const NounFormsTable({
    required this.forms,
    required this.selectedForm,
    required this.onSelect,
    super.key,
  });

  final List<ConjugationForm> forms;
  final FormSelection selectedForm;
  final ValueChanged<FormSelection> onSelect;

  @override
  Widget build(BuildContext context) {
    final hasGender =
        forms.any((f) => f.gender == FormGender.masculine) ||
        forms.any((f) => f.gender == FormGender.feminine);

    final List<PdfTableRowData> tableRows = [];

    if (hasGender) {
      // Müzekker row
      final singularMasc = _findNounForm(
        forms,
        FormGender.masculine,
        FormNumber.singular,
      );
      final dualMasc = _findNounForm(
        forms,
        FormGender.masculine,
        FormNumber.dual,
      );
      final pluralMasc = _findNounForm(
        forms,
        FormGender.masculine,
        FormNumber.plural,
        isSound: true,
      );
      tableRows.add(
        PdfTableRowData(
          rowLabel: 'Müzekker',
          cells: [pluralMasc, dualMasc, singularMasc],
        ),
      );

      // Müennes row
      final singularFem = _findNounForm(
        forms,
        FormGender.feminine,
        FormNumber.singular,
      );
      final dualFem = _findNounForm(
        forms,
        FormGender.feminine,
        FormNumber.dual,
      );
      final pluralFem = _findNounForm(
        forms,
        FormGender.feminine,
        FormNumber.plural,
        isSound: true,
      );
      tableRows.add(
        PdfTableRowData(
          rowLabel: 'Müennes',
          cells: [pluralFem, dualFem, singularFem],
        ),
      );
    } else {
      // Ortak row
      final singular = _findNounForm(
        forms,
        FormGender.common,
        FormNumber.singular,
      );
      final dual = _findNounForm(forms, FormGender.common, FormNumber.dual);
      final plural = _findNounForm(forms, FormGender.common, FormNumber.plural);
      tableRows.add(
        PdfTableRowData(rowLabel: 'Ortak', cells: [plural, dual, singular]),
      );
    }

    // We also want to find if there are any other forms (broken plurals)
    final mainFormsSet = tableRows
        .expand((r) => r.cells)
        .whereType<ConjugationForm>()
        .toSet();
    final otherForms = forms.where((f) => !mainFormsSet.contains(f)).toList();
    final dataColumnWidths = _measureDataColumnWidths(
      context,
      rows: tableRows,
      textForCell: (data) => (data as ConjugationForm?)?.arabic,
      textStyle: arabicTextStyle(20),
      textDirection: TextDirection.rtl,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PdfStyleTable(
          dataColumnWidths: dataColumnWidths,
          rows: tableRows,
          cellBuilder: (context, data) {
            final form = data as ConjugationForm?;
            if (form == null) return const SizedBox.shrink();

            final isSelected = selectedForm.matches(form);
            final colorScheme = Theme.of(context).colorScheme;

            return InkWell(
              onTap: () => onSelect(FormSelection.fromForm(form)),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primaryContainer.withValues(alpha: 0.55)
                      : null,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text(
                    form.arabic,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    softWrap: false,
                    style: arabicTextStyle(20),
                  ),
                ),
              ),
            );
          },
        ),
        if (otherForms.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            'Kırık Çoğullar (Cemi Mükesser)',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: otherForms.map((form) {
              final isSelected = selectedForm.matches(form);
              final colorScheme = Theme.of(context).colorScheme;

              return InkWell(
                onTap: () => onSelect(FormSelection.fromForm(form)),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.primaryContainer
                        : Colors.white,
                    border: Border.all(
                      color: isSelected
                          ? colorScheme.primary
                          : const Color(0xFFD8D1C1),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: Text(form.arabic, style: arabicTextStyle(20)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        form.pronounLabel,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  ConjugationForm? _findNounForm(
    List<ConjugationForm> forms,
    FormGender gender,
    FormNumber number, {
    bool? isSound,
  }) {
    for (final form in forms) {
      if (form.gender == gender && form.number == number) {
        if (isSound != null) {
          final isSoundLabel =
              form.pronounLabel.contains('Sâlim') ||
              !form.pronounLabel.contains('Kırık');
          if (isSoundLabel != isSound) continue;
        }
        return form;
      }
    }
    // Fallback: search ignoring sound/broken distinction if not specified
    for (final form in forms) {
      if (form.gender == gender && form.number == number) {
        return form;
      }
    }
    // Fallback for common gender
    if (gender == FormGender.common) {
      for (final form in forms) {
        if (form.number == number) return form;
      }
    }
    return null;
  }
}

class _AllMuttarideTablesPage extends StatelessWidget {
  const _AllMuttarideTablesPage({
    required this.data,
    required this.selectedForm,
    required this.onSelect,
  });

  final AppData data;
  final FormSelection selectedForm;
  final Function({
    FormCategory? category,
    Voice? voice,
    FormSelection? selectedForm,
  }) onSelect;

  List<_ConjugationGroup> get _groups {
    final groups = <_ConjugationGroup>[];
    for (final category in FormCategory.values) {
      for (final voice in Voice.values) {
        final forms = data.forms
            .where((form) => form.category == category && form.voice == voice)
            .toList();
        if (forms.isNotEmpty) {
          groups.add(
            _ConjugationGroup(category: category, voice: voice, forms: forms),
          );
        }
      }
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tüm Muttaride Tabloları'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: AppPage(
          title: 'Tüm Tablolar',
          scrollable: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final group in _groups) ...[
                Text(
                  group.category.isVerb
                      ? '${group.category.label} (${group.voice.label})'
                      : group.category.label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 6),
                if (group.category.isVerb)
                  FormsTable(
                    forms: group.forms,
                    selectedForm: selectedForm,
                    activeCategory: group.category,
                    activeVoice: group.voice,
                    onSelect: (selection) {
                      onSelect(
                        category: group.category,
                        voice: group.voice,
                        selectedForm: selection,
                      );
                      Navigator.of(context).pop();
                    },
                  )
                else
                  NounFormsTable(
                    forms: group.forms,
                    selectedForm: selectedForm,
                    onSelect: (selection) {
                      onSelect(
                        category: group.category,
                        selectedForm: selection,
                      );
                      Navigator.of(context).pop();
                    },
                  ),
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
