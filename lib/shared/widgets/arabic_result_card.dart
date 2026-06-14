import 'package:emsile_flutter/data/models.dart';
import 'package:emsile_flutter/shared/widgets/arabic_text.dart';
import 'package:flutter/material.dart';

class ArabicResultCard extends StatelessWidget {
  const ArabicResultCard({required this.form, super.key});

  final ConjugationForm form;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${form.category.label} · ${form.voice.label} · ${form.pronounLabel}',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 10),
            Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                form.arabic,
                textAlign: TextAlign.center,
                style: arabicTextStyle(44),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              form.meaning,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              form.rule,
              textAlign: TextAlign.center,
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ],
        ),
      ),
    );
  }
}
