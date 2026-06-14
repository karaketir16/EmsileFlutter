import 'package:emsile_flutter/data/models.dart';
import 'package:emsile_flutter/shared/widgets/arabic_text.dart';
import 'package:flutter/material.dart';

class ArabicResultCard extends StatelessWidget {
  const ArabicResultCard({required this.form, super.key});

  final ConjugationForm form;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 82,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Sol: Arapça metin
              Directionality(
                textDirection: TextDirection.rtl,
                child: Text(form.arabic, style: arabicTextStyle(30)),
              ),
              const SizedBox(width: 16),
              VerticalDivider(
                thickness: 1,
                width: 1,
                color: colorScheme.outlineVariant,
              ),
              const SizedBox(width: 16),
              // Sağ: Bilgiler (scroll edilebilir)
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${form.category.label} · ${form.voice.label} · ${form.pronounLabel}',
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(form.meaning, style: textTheme.titleSmall),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
