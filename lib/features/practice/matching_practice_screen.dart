import 'dart:async';
import 'dart:math';
import 'package:emsile_flutter/data/models.dart';
import 'package:emsile_flutter/shared/widgets/app_page.dart';
import 'package:emsile_flutter/shared/widgets/arabic_text.dart';
import 'package:flutter/material.dart';

enum MatchingType {
  wordToMeaning('Arapça ↔ Türkçe Anlam'),
  wordToSiga('Arapça ↔ Sîga Adı'),
  mixed('Karışık');

  const MatchingType(this.label);
  final String label;
}

class _MatchingItem {
  final String id;
  final String text;
  final MuhtelifeEntry entry;
  final bool isArabic;

  _MatchingItem({
    required this.id,
    required this.text,
    required this.entry,
    required this.isArabic,
  });
}

class MatchingPracticeScreen extends StatefulWidget {
  const MatchingPracticeScreen({required this.data, this.random, super.key});

  final AppData data;
  final Random? random;

  @override
  State<MatchingPracticeScreen> createState() => _MatchingPracticeScreenState();
}

class _MatchingPracticeScreenState extends State<MatchingPracticeScreen> {
  // Config & State
  bool _setupMode = true;
  bool _completedMode = false;
  MatchingType _matchingType = MatchingType.wordToMeaning;

  late List<MuhtelifeEntry> _allEntries;
  List<_MatchingItem> _leftItems = [];
  List<_MatchingItem> _rightItems = [];

  // Selections
  _MatchingItem? _selectedLeft;
  _MatchingItem? _selectedRight;

  // Feedback states
  final Set<String> _matchedEntryIds = {};
  _MatchingItem? _failedLeft;
  _MatchingItem? _failedRight;

  // Round & Scoring
  int _round = 1;
  int _mistakes = 0;
  int _correctCount = 0;
  bool _transitioning = false;

  int get _totalRounds => (_allEntries.length / 5).ceil();

  @override
  void initState() {
    super.initState();
    _allEntries = [...widget.data.muhtelifeEntries];
  }

  void _startGame() {
    final random = widget.random ?? Random();
    setState(() {
      _setupMode = false;
      _completedMode = false;
      _round = 1;
      _mistakes = 0;
      _correctCount = 0;
      _selectedLeft = null;
      _selectedRight = null;
      _failedLeft = null;
      _failedRight = null;
      _matchedEntryIds.clear();
      _allEntries.shuffle(random);
      _loadRound();
    });
  }

  void _loadRound() {
    final random = widget.random ?? Random();
    final startIdx = (_round - 1) * 5;
    final endIdx = min(startIdx + 5, _allEntries.length);
    final roundEntries = _allEntries.sublist(startIdx, endIdx);

    final List<_MatchingItem> left = [];
    final List<_MatchingItem> right = [];

    for (final entry in roundEntries) {
      left.add(
        _MatchingItem(
          id: 'left-${entry.type}',
          text: entry.arabic,
          entry: entry,
          isArabic: true,
        ),
      );

      // Determine right text based on mode
      String rightText;
      if (_matchingType == MatchingType.wordToSiga) {
        rightText = entry.label;
      } else if (_matchingType == MatchingType.wordToMeaning) {
        rightText = entry.meaning;
      } else {
        // Mixed mode: randomly pick label or meaning
        rightText = random.nextBool() ? entry.label : entry.meaning;
      }

      right.add(
        _MatchingItem(
          id: 'right-${entry.type}',
          text: rightText,
          entry: entry,
          isArabic: false,
        ),
      );
    }

    // Shuffle left and right columns independently
    left.shuffle(random);
    right.shuffle(random);

    setState(() {
      _leftItems = left;
      _rightItems = right;
      _selectedLeft = null;
      _selectedRight = null;
      _failedLeft = null;
      _failedRight = null;
      _matchedEntryIds.clear();
      _transitioning = false;
    });
  }

  void _onLeftSelected(_MatchingItem item) {
    if (_matchedEntryIds.contains(item.entry.type) || _transitioning) return;

    setState(() {
      if (_selectedLeft?.id == item.id) {
        _selectedLeft = null;
      } else {
        _selectedLeft = item;
        _checkMatch();
      }
    });
  }

  void _onRightSelected(_MatchingItem item) {
    if (_matchedEntryIds.contains(item.entry.type) || _transitioning) return;

    setState(() {
      if (_selectedRight?.id == item.id) {
        _selectedRight = null;
      } else {
        _selectedRight = item;
        _checkMatch();
      }
    });
  }

  void _checkMatch() {
    final left = _selectedLeft;
    final right = _selectedRight;

    if (left == null || right == null) return;

    if (left.entry.type == right.entry.type) {
      // Correct Match
      setState(() {
        _matchedEntryIds.add(left.entry.type);
        _correctCount++;
        _selectedLeft = null;
        _selectedRight = null;
      });

      // Check if round is finished
      if (_matchedEntryIds.length == _leftItems.length) {
        _transitioning = true;
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (!mounted) return;
          _nextRound();
        });
      }
    } else {
      // Wrong Match
      setState(() {
        _failedLeft = left;
        _failedRight = right;
        _selectedLeft = null;
        _selectedRight = null;
        _mistakes++;
      });

      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        setState(() {
          if (_failedLeft?.id == left.id) _failedLeft = null;
          if (_failedRight?.id == right.id) _failedRight = null;
        });
      });
    }
  }

  void _nextRound() {
    if (_round < _totalRounds) {
      setState(() {
        _round++;
        _loadRound();
      });
    } else {
      setState(() {
        _completedMode = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_setupMode) {
      return _buildSetupScreen();
    }

    if (_completedMode) {
      return _buildCompletedScreen();
    }

    return _buildGameScreen();
  }

  Widget _buildSetupScreen() {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: AppPage(
          title: 'Emsile-i Muhtelife Alıştırması',
          subtitle: 'Emsile-i Muhtelife sîgaları için pratik yap.',
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Geri',
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              const Text(
                'Çalışma Modunu Seçin',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...MatchingType.values.map((type) {
                final isSelected = _matchingType == type;
                IconData icon;
                String desc;
                if (type == MatchingType.wordToSiga) {
                  icon = Icons.label_outline;
                  desc = 'Arapça kelimeleri dilbilgisi sîga adlarıyla eşleştir.';
                } else if (type == MatchingType.wordToMeaning) {
                  icon = Icons.translate_outlined;
                  desc = 'Arapça kelimeleri Türkçe anlamlarıyla eşleştir.';
                } else {
                  icon = Icons.shuffle_outlined;
                  desc = 'Kelime-Sîga ve Kelime-Anlam eşleştirmelerini karışık oyna.';
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: isSelected ? colorScheme.primary : const Color(0xFFD8D1C1),
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () => setState(() => _matchingType = type),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(icon, color: isSelected ? colorScheme.primary : Colors.grey, size: 28),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  type.label,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: isSelected ? colorScheme.primary : null,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  desc,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _startGame,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Eşleştirmeyi Başlat', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameScreen() {
    final colorScheme = Theme.of(context).colorScheme;
    final totalMatched = (_round - 1) * 5 + _matchedEntryIds.length;
    final progress = min(1.0, totalMatched / _allEntries.length);

    return Scaffold(
      body: SafeArea(
        child: AppPage(
          title: 'Emsile-i Muhtelife Alıştırması',
          subtitle: 'Tur $_round / $_totalRounds • Doğru: $totalMatched / ${_allEntries.length}',
          scrollable: false,
          leading: IconButton(
            onPressed: () => setState(() => _setupMode = true),
            icon: const Icon(Icons.close),
            tooltip: 'Çıkış',
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress Bar
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                ),
              ),
              const SizedBox(height: 20),

              // Game Columns
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Left Column (Arabic Words)
                    Expanded(
                      child: Column(
                        children: _leftItems.map((item) => _buildCard(item, true)).toList(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Right Column (Siga / Meaning)
                    Expanded(
                      child: Column(
                        children: _rightItems.map((item) => _buildCard(item, false)).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              // Mistakes Footer
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.redAccent, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'Hata Sayısı: $_mistakes',
                      style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.redAccent),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(_MatchingItem item, bool isLeft) {
    final colorScheme = Theme.of(context).colorScheme;
    final isMatched = _matchedEntryIds.contains(item.entry.type);

    // Calculate card colors
    Color? backgroundColor;
    BorderSide borderSide = const BorderSide(color: Color(0xFFD8D1C1));

    if (isMatched) {
      backgroundColor = const Color(0xFFE8F5E9); // Light green
      borderSide = const BorderSide(color: Colors.green, width: 1.5);
    } else if (isLeft && _selectedLeft?.id == item.id) {
      backgroundColor = colorScheme.primaryContainer.withValues(alpha: 0.4);
      borderSide = BorderSide(color: colorScheme.primary, width: 2);
    } else if (!isLeft && _selectedRight?.id == item.id) {
      backgroundColor = colorScheme.primaryContainer.withValues(alpha: 0.4);
      borderSide = BorderSide(color: colorScheme.primary, width: 2);
    } else if (isLeft && _failedLeft?.id == item.id) {
      backgroundColor = const Color(0xFFFFEBEE); // Light red
      borderSide = const BorderSide(color: Colors.red, width: 2);
    } else if (!isLeft && _failedRight?.id == item.id) {
      backgroundColor = const Color(0xFFFFEBEE); // Light red
      borderSide = const BorderSide(color: Colors.red, width: 2);
    }

    final opacity = isMatched ? 0.35 : 1.0;

    return Expanded(
      child: Opacity(
        opacity: opacity,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          width: double.infinity,
          child: Card(
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: borderSide,
            ),
            color: backgroundColor,
            elevation: isMatched ? 0 : 1,
            child: InkWell(
              onTap: isMatched ? null : () => isLeft ? _onLeftSelected(item) : _onRightSelected(item),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isMatched) ...[
                        const Icon(Icons.check_circle, color: Colors.green, size: 18),
                        const SizedBox(width: 6),
                      ],
                      Expanded(
                        child: Text(
                          item.text,
                          textAlign: TextAlign.center,
                          style: item.isArabic
                              ? arabicTextStyle(21)
                              : Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: item.text.length > 20 ? 12 : 14,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompletedScreen() {
    final totalMatched = _allEntries.length;
    final totalAttempts = totalMatched + _mistakes;
    final accuracy = totalAttempts > 0 ? (totalMatched / totalAttempts * 100).round() : 100;

    return Scaffold(
      body: SafeArea(
        child: AppPage(
          title: 'Tebrikler!',
          subtitle: 'Eşleştirmeyi başarıyla tamamladın.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Center(
                child: Icon(
                  Icons.stars,
                  size: 80,
                  color: Colors.amber,
                ),
              ),
              const SizedBox(height: 24),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildStatRow('Toplam Eşleşme', '$totalMatched'),
                      const Divider(),
                      _buildStatRow('Hata Sayısı', '$_mistakes'),
                      const Divider(),
                      _buildStatRow('Başarı Oranı', '%$accuracy'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _startGame,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Yeniden Oyna', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Pratik Ekranına Dön', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
