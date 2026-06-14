import 'package:emsile_flutter/data/models.dart';
import 'package:emsile_flutter/shared/widgets/arabic_result_card.dart';
import 'package:emsile_flutter/shared/widgets/arabic_text.dart';
import 'package:emsile_flutter/shared/widgets/app_page.dart';
import 'package:flutter/material.dart';

class ConjugationScreen extends StatefulWidget {
  const ConjugationScreen({required this.data, super.key});

  final AppData data;

  @override
  State<ConjugationScreen> createState() => _ConjugationScreenState();
}

class _ConjugationScreenState extends State<ConjugationScreen> {
  FormCategory _category = FormCategory.mazi;
  Voice _voice = Voice.malum;
  FormSelection _selectedForm = const FormSelection(
    person: FormPerson.third,
    number: FormNumber.singular,
    gender: FormGender.masculine,
  );

  List<ConjugationForm> get _visibleForms {
    return widget.data.forms
        .where((form) => form.category == _category && form.voice == _voice)
        .toList();
  }

  List<_ConjugationGroup> get _groups {
    final groups = <_ConjugationGroup>[];
    for (final category in FormCategory.values) {
      for (final voice in Voice.values) {
        final forms = widget.data.forms
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
      _selectedForm = selectedForm ?? _selectedForm;

      final forms = _visibleForms;
      if (!forms.any(_selectedForm.matches)) {
        _selectedForm = FormSelection.fromForm(forms.first);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final forms = _visibleForms;
    final activeForm = _activeForm;

    return AppPage(
      title: 'Çekim Tablosu',
      scrollable: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          const SizedBox(height: 10),
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
          ArabicResultCard(form: activeForm),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                    onSelect: (selection) =>
                        _updateSelection(selectedForm: selection),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Tüm Fiil Muttaride Tabloları',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  for (final group in _groups) ...[
                    Text(
                      '${group.category.label} (${group.voice.label})',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 6),
                    FormsTable(
                      forms: group.forms,
                      selectedForm: _selectedForm,
                      onSelect: (selection) => _updateSelection(
                        category: group.category,
                        voice: group.voice,
                        selectedForm: selection,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
          ),
        ],
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
    return PdfStyleTable(
      headerTitle: 'ŞAHIS ZAMİRLERİ',
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

        final isSelected = selectedForm == selectionCell.selection;
        final colorScheme = Theme.of(context).colorScheme;

        return InkWell(
          onTap: () => onSelect(selectionCell.selection),
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
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
    required this.onSelect,
    super.key,
  });

  final List<ConjugationForm> forms;
  final FormSelection selectedForm;
  final ValueChanged<FormSelection> onSelect;

  @override
  Widget build(BuildContext context) {
    return PdfStyleTable(
      headerTitle: '${forms.first.category.label} ${forms.first.voice.label}',
      rows: [
        for (final row in pdfRows)
          PdfTableRowData(
            rowLabel: row.label,
            cells: [
              for (final number in pdfColumns)
                _findForm(forms, row.selectionFor(number.number)),
            ],
          ),
      ],
      cellBuilder: (context, data) {
        final form = data as ConjugationForm?;
        if (form == null) {
          return const SizedBox.shrink();
        }

        final isSelected = selectedForm.matches(form);
        final colorScheme = Theme.of(context).colorScheme;
        final selection = FormSelection.fromForm(form);

        return InkWell(
          onTap: () => onSelect(selection),
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? colorScheme.primaryContainer.withValues(alpha: 0.55)
                  : null,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  form.arabic,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  softWrap: false,
                  style: arabicTextStyle(18),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class PdfStyleTable extends StatelessWidget {
  const PdfStyleTable({
    required this.headerTitle,
    required this.rows,
    required this.cellBuilder,
    super.key,
  });

  final String headerTitle;
  final List<PdfTableRowData> rows;
  final Widget Function(BuildContext context, Object? data) cellBuilder;

  @override
  Widget build(BuildContext context) {
    final borderColor = const Color(0xFFD8D1C1);
    final labelStyle = Theme.of(
      context,
    ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: constraints.maxWidth,
              ),
              child: Table(
                border: TableBorder.all(color: borderColor),
                columnWidths: const {
                  0: IntrinsicColumnWidth(),
                  1: IntrinsicColumnWidth(),
                  2: IntrinsicColumnWidth(),
                  3: FixedColumnWidth(94),
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  TableRow(
                    decoration: const BoxDecoration(color: Color(0xFFF4F0E6)),
                    children: [
                      _HeaderCell(text: pdfColumns[0].label),
                      _HeaderCell(text: pdfColumns[1].label),
                      _HeaderCell(text: pdfColumns[2].label),
                      _HeaderCell(text: headerTitle),
                    ],
                  ),
                  for (final row in rows)
                    TableRow(
                      children: [
                        for (final cell in row.cells)
                          Padding(
                            padding: const EdgeInsets.all(4),
                            child: SizedBox(
                              height: 40,
                              child: Center(child: cellBuilder(context, cell)),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            row.rowLabel,
                            textAlign: TextAlign.center,
                            style: labelStyle,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
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
  });

  final FormPerson person;
  final FormNumber number;
  final FormGender gender;

  factory FormSelection.fromForm(ConjugationForm form) {
    return FormSelection(
      person: form.person,
      number: form.number,
      gender: form.gender,
    );
  }

  bool matches(ConjugationForm form) {
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
        other.gender == gender;
  }

  @override
  int get hashCode => Object.hash(person, number, gender);
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
