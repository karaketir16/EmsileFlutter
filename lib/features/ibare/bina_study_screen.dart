import 'package:emsile_flutter/features/ibare/bina_study_data.dart';
import 'package:emsile_flutter/shared/widgets/app_page.dart';
import 'package:emsile_flutter/shared/widgets/arabic_text.dart';
import 'package:emsile_flutter/shared/widgets/info_panel.dart';
import 'package:flutter/material.dart';

class BinaStudyScreen extends StatelessWidget {
  const BinaStudyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _StudyScaffold(
      title: 'İbare Çalışması',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const InfoPanel(
            title: 'Metnü’l-Binâ ve’l-Esâs',
            body:
                'Metni kırık mana ve kelime tahliliyle çalış. Bir kelimeye dokunarak sarf ve nahiv bilgilerini görebilirsin.',
          ),
          const SizedBox(height: 18),
          Text('Bölümler', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          for (var index = 0; index < binaPassages.length; index++) ...[
            Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(14),
                leading: CircleAvatar(child: Text('${index + 1}')),
                title: Text(
                  binaPassages[index].title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(binaPassages[index].subtitle),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => BinaPassageScreen(initialIndex: index),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class BinaPassageScreen extends StatefulWidget {
  const BinaPassageScreen({required this.initialIndex, super.key});

  final int initialIndex;

  @override
  State<BinaPassageScreen> createState() => _BinaPassageScreenState();
}

class _BinaPassageScreenState extends State<BinaPassageScreen> {
  late int _index;
  int? _selectedWord;
  bool _showBrokenMeanings = false;
  bool _showTranslation = false;
  bool _showOptionalHarakat = false;

  BinaPassage get passage => binaPassages[_index];

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
  }

  void _move(int change) {
    setState(() {
      _index += change;
      _selectedWord = null;
      _showBrokenMeanings = false;
      _showTranslation = false;
      _showOptionalHarakat = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selectedWord == null
        ? null
        : passage.words[_selectedWord!];

    return _StudyScaffold(
      title: passage.title,
      trailing: Text('${_index + 1}/${binaPassages.length}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(passage.subtitle, style: Theme.of(context).textTheme.bodyLarge),
          if (passage.hasOptionalHarakat) ...[
            const SizedBox(height: 8),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text('Harekeleri göster'),
              subtitle: const Text(
                'Kitapta eksik bırakılan harekeleri tamamlar.',
              ),
              value: _showOptionalHarakat,
              onChanged: (value) =>
                  setState(() => _showOptionalHarakat = value ?? false),
            ),
          ],
          const SizedBox(height: 14),
          _ArabicPassage(
            words: passage.words,
            selectedIndex: _selectedWord,
            showOptionalHarakat: _showOptionalHarakat,
            onSelected: (index) => setState(() => _selectedWord = index),
          ),
          const SizedBox(height: 10),
          Text(
            'Bir kelimeye dokun: türü, çekimi, babı, zamiri ve cümledeki görevi burada görünür.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (selected != null) ...[
            const SizedBox(height: 12),
            _WordAnalysisCard(
              word: selected,
              showOptionalHarakat: _showOptionalHarakat,
            ),
          ],
          const SizedBox(height: 20),
          _RevealCard(
            title: 'Kırık Mana',
            buttonLabel: _showBrokenMeanings ? 'Gizle' : 'Göster',
            shown: _showBrokenMeanings,
            onPressed: () =>
                setState(() => _showBrokenMeanings = !_showBrokenMeanings),
            child: Column(
              children: [
                for (final word in passage.words)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: Text(word.meaning)),
                        const SizedBox(width: 12),
                        Text(
                          word.displayArabic(_showOptionalHarakat),
                          textDirection: TextDirection.rtl,
                          style: arabicTextStyle(22),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _RevealCard(
            title: 'Toparlanmış Mana',
            buttonLabel: _showTranslation ? 'Gizle' : 'Göster',
            shown: _showTranslation,
            onPressed: () =>
                setState(() => _showTranslation = !_showTranslation),
            child: Text(passage.translation),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              if (_index > 0)
                OutlinedButton.icon(
                  onPressed: () => _move(-1),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Önceki'),
                ),
              const Spacer(),
              if (_index < binaPassages.length - 1)
                FilledButton.icon(
                  onPressed: () => _move(1),
                  iconAlignment: IconAlignment.end,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Sonraki'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ArabicPassage extends StatelessWidget {
  const _ArabicPassage({
    required this.words,
    required this.selectedIndex,
    required this.showOptionalHarakat,
    required this.onSelected,
  });

  final List<BinaWord> words;
  final int? selectedIndex;
  final bool showOptionalHarakat;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      color: scheme.surfaceContainerLowest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Wrap(
            alignment: WrapAlignment.start,
            spacing: 6,
            runSpacing: 8,
            children: [
              for (var index = 0; index < words.length; index++)
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => onSelected(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: selectedIndex == index
                          ? scheme.primaryContainer
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: selectedIndex == index
                            ? scheme.primary
                            : Colors.transparent,
                      ),
                    ),
                    child: Text(
                      words[index].displayArabic(showOptionalHarakat),
                      style: arabicTextStyle(27),
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

class _WordAnalysisCard extends StatelessWidget {
  const _WordAnalysisCard({
    required this.word,
    required this.showOptionalHarakat,
  });

  final BinaWord word;
  final bool showOptionalHarakat;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      color: scheme.primaryContainer.withValues(alpha: 0.45),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        word.kind,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(word.meaning),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  word.displayArabic(showOptionalHarakat),
                  textDirection: TextDirection.rtl,
                  style: arabicTextStyle(28),
                ),
              ],
            ),
            const Divider(height: 24),
            for (final fact in word.facts)
              Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 105,
                      child: Text(
                        fact.$1,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.45,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        fact.$2,
                        style: const TextStyle(fontSize: 16, height: 1.45),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RevealCard extends StatelessWidget {
  const _RevealCard({
    required this.title,
    required this.buttonLabel,
    required this.shown,
    required this.onPressed,
    required this.child,
  });

  final String title;
  final String buttonLabel;
  final bool shown;
  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                TextButton(onPressed: onPressed, child: Text(buttonLabel)),
              ],
            ),
            if (shown) ...[const Divider(), child],
          ],
        ),
      ),
    );
  }
}

class _StudyScaffold extends StatelessWidget {
  const _StudyScaffold({
    required this.title,
    required this.child,
    this.trailing,
  });

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AppPage(
          title: title,
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Geri',
          ),
          trailing: trailing,
          child: child,
        ),
      ),
    );
  }
}
