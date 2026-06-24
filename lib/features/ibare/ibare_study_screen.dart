import 'package:emsile_flutter/data/models.dart';
import 'package:emsile_flutter/shared/widgets/app_page.dart';
import 'package:emsile_flutter/shared/widgets/arabic_text.dart';
import 'package:emsile_flutter/shared/widgets/info_panel.dart';
import 'package:flutter/material.dart';

class IbareStudyScreen extends StatelessWidget {
  const IbareStudyScreen({required this.books, super.key});

  final List<IbareBook> books;

  @override
  Widget build(BuildContext context) {
    return _StudyScaffold(
      title: 'İbare Çalışması',
      child: Column(
        children: [
          if (books.isEmpty)
            const InfoPanel(
              title: 'İçerik bulunamadı',
              body: 'Henüz eklenmiş bir ibare kitabı yok.',
            ),
          for (final book in books) ...[
            Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(14),
                leading: const CircleAvatar(
                  child: Icon(Icons.auto_stories_outlined),
                ),
                title: Text(
                  book.title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(book.description),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => IbareBookScreen(book: book),
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

class IbareBookScreen extends StatefulWidget {
  const IbareBookScreen({required this.book, super.key});

  final IbareBook book;

  @override
  State<IbareBookScreen> createState() => _IbareBookScreenState();
}

class _IbareBookScreenState extends State<IbareBookScreen> {
  final _topKey = GlobalKey();

  int _page = 0;

  void _setPage(int page) {
    setState(() => _page = page);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _topKey.currentContext;
      if (context == null) return;
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    final passages = book.passages;
    final pages = _ibarePages(book.sections);
    final visibleSections = pages[_page];
    final pagePassages = {
      for (final section in visibleSections) ...section.passages,
    };
    final start = passages.indexOf(pagePassages.first);

    return _StudyScaffold(
      title: book.shortTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KeyedSubtree(
            key: _topKey,
            child: InfoPanel(title: book.title, body: book.description),
          ),
          const SizedBox(height: 18),
          _IbarePageControls(
            start: start,
            shown: pagePassages.length,
            total: passages.length,
            page: _page,
            totalPages: pages.length,
            onPrevious: _page == 0 ? null : () => _setPage(_page - 1),
            onNext: _page >= pages.length - 1
                ? null
                : () => _setPage(_page + 1),
          ),
          const SizedBox(height: 10),
          for (final section in visibleSections) ...[
            if (section.title.isNotEmpty) ...[
              Text(
                section.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (section.description case final description?)
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Text(description),
                ),
              const SizedBox(height: 10),
            ],
            for (final passage in section.passages.where(
              pagePassages.contains,
            )) ...[
              _PassageOverviewCard(
                key: ValueKey(passage.id),
                passage: passage,
                onOpen: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => IbarePassageScreen(
                      book: book,
                      initialIndex: passages.indexOf(passage),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 10),
          ],
          _IbarePageControls(
            start: start,
            shown: pagePassages.length,
            total: passages.length,
            page: _page,
            totalPages: pages.length,
            onPrevious: _page == 0 ? null : () => _setPage(_page - 1),
            onNext: _page >= pages.length - 1
                ? null
                : () => _setPage(_page + 1),
            keyPrefix: 'bottom',
          ),
        ],
      ),
    );
  }
}

List<List<IbareSection>> _ibarePages(List<IbareSection> sections) {
  final pages = <List<IbareSection>>[];
  var page = <IbareSection>[];
  for (final section in sections) {
    page.add(section);
    if (section.pageBreakAfter) {
      pages.add(page);
      page = <IbareSection>[];
    }
  }
  if (page.isNotEmpty) {
    pages.add(page);
  }
  return pages;
}

class _IbarePageControls extends StatelessWidget {
  const _IbarePageControls({
    required this.start,
    required this.shown,
    required this.total,
    required this.page,
    required this.totalPages,
    required this.onPrevious,
    required this.onNext,
    this.keyPrefix = 'top',
  });

  final int start;
  final int shown;
  final int total;
  final int page;
  final int totalPages;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final String keyPrefix;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            '${start + 1}-${start + shown} / $total',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        IconButton(
          key: ValueKey('ibare_prev_page_$keyPrefix'),
          onPressed: onPrevious,
          tooltip: 'Önceki sayfa',
          icon: const Icon(Icons.chevron_left),
        ),
        Text('${page + 1}/$totalPages'),
        IconButton(
          key: ValueKey('ibare_next_page_$keyPrefix'),
          onPressed: onNext,
          tooltip: 'Sonraki sayfa',
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}

class _PassageOverviewCard extends StatefulWidget {
  const _PassageOverviewCard({
    required this.passage,
    required this.onOpen,
    super.key,
  });

  final IbarePassage passage;
  final VoidCallback onOpen;

  @override
  State<_PassageOverviewCard> createState() => _PassageOverviewCardState();
}

class _PassageOverviewCardState extends State<_PassageOverviewCard> {
  int? _selectedToken;
  bool _showOptionalHarakat = false;
  bool _showPhrase = false;
  int _phraseIndex = 0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final selected = _selectedToken == null
        ? null
        : widget.passage.tokens[_selectedToken!];
    final phrases = selected == null
        ? const <IbarePhrase>[]
        : widget.passage.phrasesForToken(selected.id);
    final activePhrase = _showPhrase && phrases.isNotEmpty
        ? phrases[_phraseIndex]
        : null;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 66, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.passage.title case final title?)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            if (widget.passage.subtitle
                                case final subtitle?) ...[
                              const SizedBox(height: 2),
                              Text(
                                subtitle,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ],
                        ),
                      )
                    else
                      const Spacer(),
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => setState(
                        () => _showOptionalHarakat = !_showOptionalHarakat,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Harekeler'),
                          Checkbox(
                            key: ValueKey('harakat_${widget.passage.id}'),
                            value: _showOptionalHarakat,
                            onChanged: (value) => setState(
                              () => _showOptionalHarakat = value ?? false,
                            ),
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Wrap(
                      alignment: WrapAlignment.start,
                      spacing: 4,
                      runSpacing: 6,
                      children: [
                        for (
                          var index = 0;
                          index < widget.passage.tokens.length;
                          index++
                        )
                          InkWell(
                            key: ValueKey(
                              'overview_${widget.passage.tokens[index].id}',
                            ),
                            borderRadius: BorderRadius.circular(7),
                            onTap: () => setState(() {
                              _selectedToken = _selectedToken == index
                                  ? null
                                  : index;
                              _showPhrase = false;
                              _phraseIndex = 0;
                            }),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _selectedToken == index
                                    ? scheme.primaryContainer
                                    : activePhrase?.tokenIds.contains(
                                            widget.passage.tokens[index].id,
                                          ) ??
                                          false
                                    ? scheme.tertiaryContainer
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: Text(
                                widget.passage.tokens[index].displayArabic(
                                  _showOptionalHarakat,
                                ),
                                style: arabicTextStyle(23),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (selected != null) ...[
                  const SizedBox(height: 10),
                  _TokenAnalysisCard(
                    token: selected,
                    showOptionalHarakat: _showOptionalHarakat,
                  ),
                  if (phrases.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      key: ValueKey('phrase_toggle_${widget.passage.id}'),
                      onPressed: () =>
                          setState(() => _showPhrase = !_showPhrase),
                      icon: Icon(
                        _showPhrase
                            ? Icons.expand_less
                            : Icons.account_tree_outlined,
                      ),
                      label: Text(
                        _showPhrase
                            ? 'Kelime grubunu gizle'
                            : 'Kelime grubunu göster (${phrases.length})',
                      ),
                    ),
                    if (_showPhrase) ...[
                      const SizedBox(height: 8),
                      _PhraseCard(
                        phrase: phrases[_phraseIndex],
                        passage: widget.passage,
                        showOptionalHarakat: _showOptionalHarakat,
                        index: _phraseIndex,
                        count: phrases.length,
                        onPrevious: _phraseIndex > 0
                            ? () => setState(() => _phraseIndex--)
                            : null,
                        onNext: _phraseIndex < phrases.length - 1
                            ? () => setState(() => _phraseIndex++)
                            : null,
                      ),
                    ],
                  ],
                ],
              ],
            ),
          ),
          Positioned(
            top: 0,
            bottom: 0,
            right: 0,
            width: 52,
            child: Semantics(
              button: true,
              label: '${widget.passage.title ?? 'İbare'} ayrıntısını incele',
              child: Material(
                color: scheme.secondaryContainer,
                child: InkWell(
                  key: ValueKey('inspect_${widget.passage.id}'),
                  onTap: widget.onOpen,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chevron_right,
                        color: scheme.onSecondaryContainer,
                      ),
                      const SizedBox(height: 6),
                      RotatedBox(
                        quarterTurns: 3,
                        child: Text(
                          'İncele',
                          style: TextStyle(
                            color: scheme.onSecondaryContainer,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class IbarePassageScreen extends StatefulWidget {
  const IbarePassageScreen({
    required this.book,
    required this.initialIndex,
    super.key,
  });

  final IbareBook book;
  final int initialIndex;

  @override
  State<IbarePassageScreen> createState() => _IbarePassageScreenState();
}

class _IbarePassageScreenState extends State<IbarePassageScreen> {
  late int _index;
  int? _selectedToken;
  bool _showBrokenMeanings = false;
  bool _showTranslation = false;
  bool _showOptionalHarakat = false;
  bool _showPhrase = false;
  int _phraseIndex = 0;

  IbarePassage get passage => widget.book.passages[_index];

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
  }

  void _move(int change) {
    setState(() {
      _index += change;
      _selectedToken = null;
      _showBrokenMeanings = false;
      _showTranslation = false;
      _showOptionalHarakat = false;
      _showPhrase = false;
      _phraseIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selectedToken == null
        ? null
        : passage.tokens[_selectedToken!];
    final phrases = selected == null
        ? const <IbarePhrase>[]
        : passage.phrasesForToken(selected.id);
    final activePhrase = _showPhrase && phrases.isNotEmpty
        ? phrases[_phraseIndex]
        : null;

    return _StudyScaffold(
      title: passage.title ?? 'İbare ${_index + 1}',
      trailing: Text('${_index + 1}/${widget.book.passages.length}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (passage.subtitle case final subtitle?)
            Text(subtitle, style: Theme.of(context).textTheme.bodyLarge),
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
            tokens: passage.tokens,
            selectedIndex: _selectedToken,
            highlightedTokenIds: activePhrase?.tokenIds.toSet() ?? const {},
            showOptionalHarakat: _showOptionalHarakat,
            onSelected: (index) => setState(() {
              _selectedToken = _selectedToken == index ? null : index;
              _showPhrase = false;
              _phraseIndex = 0;
            }),
          ),
          const SizedBox(height: 10),
          Text(
            'Bir kelimeye dokun: türü, çekimi, babı, zamiri ve cümledeki görevi burada görünür.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (selected != null) ...[
            const SizedBox(height: 12),
            _TokenAnalysisCard(
              token: selected,
              showOptionalHarakat: _showOptionalHarakat,
            ),
            if (phrases.isNotEmpty) ...[
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => setState(() => _showPhrase = !_showPhrase),
                icon: Icon(
                  _showPhrase ? Icons.expand_less : Icons.account_tree_outlined,
                ),
                label: Text(
                  _showPhrase
                      ? 'Kelime grubunu gizle'
                      : 'Kelime grubunu göster (${phrases.length})',
                ),
              ),
              if (_showPhrase) ...[
                const SizedBox(height: 8),
                _PhraseCard(
                  phrase: phrases[_phraseIndex],
                  passage: passage,
                  showOptionalHarakat: _showOptionalHarakat,
                  index: _phraseIndex,
                  count: phrases.length,
                  onPrevious: _phraseIndex > 0
                      ? () => setState(() => _phraseIndex--)
                      : null,
                  onNext: _phraseIndex < phrases.length - 1
                      ? () => setState(() => _phraseIndex++)
                      : null,
                ),
              ],
            ],
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
                for (final token in passage.tokens)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: Text(token.gloss)),
                        const SizedBox(width: 12),
                        Text(
                          token.displayArabic(_showOptionalHarakat),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(passage.translation),
                if (passage.editorialCorrection case final correction?) ...[
                  const SizedBox(height: 10),
                  _AnalysisRow(label: 'Tashih', value: correction),
                ],
                for (final note in passage.notes) ...[
                  const SizedBox(height: 10),
                  _AnalysisRow(label: note.label, value: note.text),
                ],
              ],
            ),
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
              if (_index < widget.book.passages.length - 1)
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
    required this.tokens,
    required this.selectedIndex,
    required this.highlightedTokenIds,
    required this.showOptionalHarakat,
    required this.onSelected,
  });

  final List<IbareToken> tokens;
  final int? selectedIndex;
  final Set<String> highlightedTokenIds;
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
              for (var index = 0; index < tokens.length; index++)
                InkWell(
                  key: ValueKey('detail_${tokens[index].id}'),
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
                          : highlightedTokenIds.contains(tokens[index].id)
                          ? scheme.tertiaryContainer
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: selectedIndex == index
                            ? scheme.primary
                            : Colors.transparent,
                      ),
                    ),
                    child: Text(
                      tokens[index].displayArabic(showOptionalHarakat),
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

class _PhraseCard extends StatelessWidget {
  const _PhraseCard({
    required this.phrase,
    required this.passage,
    required this.showOptionalHarakat,
    required this.index,
    required this.count,
    required this.onPrevious,
    required this.onNext,
  });

  final IbarePhrase phrase;
  final IbarePassage passage;
  final bool showOptionalHarakat;
  final int index;
  final int count;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tokenIds = phrase.tokenIds.toSet();
    final arabic = passage.tokens
        .where((token) => tokenIds.contains(token.id))
        .map((token) => token.displayArabic(showOptionalHarakat))
        .join(' ');

    return Card(
      key: ValueKey('phrase_${phrase.id}'),
      color: scheme.tertiaryContainer.withValues(alpha: 0.5),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Terkip (Kelime Grubu)',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Text('${index + 1}/$count'),
                IconButton(
                  onPressed: onPrevious,
                  tooltip: 'Daha küçük terkip',
                  icon: const Icon(Icons.chevron_left),
                ),
                IconButton(
                  onPressed: onNext,
                  tooltip: 'Daha büyük terkip',
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            Text(
              'Küçükten büyüğe; eş düzey yapılar da gösterilir',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                arabic,
                textDirection: TextDirection.rtl,
                style: arabicTextStyle(25),
              ),
            ),
            const Divider(height: 22),
            _AnalysisRow(label: 'Yapı', value: phrase.type),
            _AnalysisRow(label: 'Toplu anlam', value: phrase.meaning),
            if (phrase.explanation case final explanation?)
              _AnalysisRow(label: 'Açıklama', value: explanation),
          ],
        ),
      ),
    );
  }
}

class _TokenAnalysisCard extends StatelessWidget {
  const _TokenAnalysisCard({
    required this.token,
    required this.showOptionalHarakat,
  });

  final IbareToken token;
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
                        token.kind,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(token.gloss),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  token.displayArabic(showOptionalHarakat),
                  textDirection: TextDirection.rtl,
                  style: arabicTextStyle(28),
                ),
              ],
            ),
            const Divider(height: 24),
            for (final field in IbareField.values)
              if (token.fields[field] case final value?)
                _AnalysisRow(label: field.label, value: value),
            for (final detail in token.details)
              _AnalysisRow(label: detail.label, value: detail.value),
          ],
        ),
      ),
    );
  }
}

class _AnalysisRow extends StatelessWidget {
  const _AnalysisRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                height: 1.45,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, height: 1.45),
            ),
          ),
        ],
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
