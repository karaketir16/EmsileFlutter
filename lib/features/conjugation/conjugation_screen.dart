import 'package:emsile_flutter/data/models.dart';
import 'package:emsile_flutter/shared/widgets/app_page.dart';
import 'package:emsile_flutter/shared/widgets/arabic_result_card.dart';
import 'package:emsile_flutter/shared/widgets/arabic_text.dart';
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
  int _formIndex = 0;

  List<ConjugationForm> get _visibleForms {
    return widget.data.forms
        .where((form) => form.category == _category && form.voice == _voice)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final forms = _visibleForms;
    final activeForm = forms[_formIndex.clamp(0, forms.length - 1)];

    return AppPage(
      title: 'Çekim Tablosu',
      subtitle: 'Nasara örneği üzerinden seç, gör, karşılaştır.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SegmentedButton<FormCategory>(
            segments: const [
              ButtonSegment(
                value: FormCategory.mazi,
                icon: Icon(Icons.history),
                label: Text('Mâzi'),
              ),
              ButtonSegment(
                value: FormCategory.muzari,
                icon: Icon(Icons.update),
                label: Text('Muzâri'),
              ),
            ],
            selected: {_category},
            onSelectionChanged: (value) {
              setState(() {
                _category = value.first;
                _formIndex = 0;
              });
            },
          ),
          const SizedBox(height: 12),
          SegmentedButton<Voice>(
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
              setState(() {
                _voice = value.first;
                _formIndex = 0;
              });
            },
          ),
          const SizedBox(height: 16),
          ArabicResultCard(form: activeForm),
          const SizedBox(height: 16),
          Text('Şahıs Seç', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var index = 0; index < forms.length; index++)
                ChoiceChip(
                  label: Text(forms[index].pronounLabel),
                  selected: index == _formIndex,
                  onSelected: (_) => setState(() => _formIndex = index),
                ),
            ],
          ),
          const SizedBox(height: 18),
          Text('Tüm Formlar', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          for (final form in forms) CompactFormRow(form: form),
        ],
      ),
    );
  }
}

class CompactFormRow extends StatelessWidget {
  const CompactFormRow({required this.form, super.key});

  final ConjugationForm form;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Text(
                form.pronounLabel,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            Expanded(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  form.arabic,
                  textAlign: TextAlign.right,
                  style: arabicTextStyle(24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
