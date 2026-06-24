enum IbareField {
  structure('structure', 'Yapısı'),
  wordForm('wordForm', 'Kelime biçimi'),
  root('root', 'Kök'),
  singular('singular', 'Tekili'),
  derivedFrom('derivedFrom', 'Türediği fiil'),
  baseForm('baseForm', 'Aslı'),
  bab('bab', 'Bab'),
  pattern('pattern', 'Vezin'),
  morphology('morphology', 'Türü'),
  conjugation('conjugation', 'Çekim'),
  person('person', 'Şahıs'),
  hiddenPronoun('hiddenPronoun', 'Gizli zamir'),
  pronoun('pronoun', 'Zamir'),
  referent('referent', 'Mercii'),
  transitivity('transitivity', 'Geçişlilik'),
  presentForm('presentForm', 'Muzârisi'),
  middleRadical('middleRadical', 'Aynü’l-fiil'),
  numberType('numberType', 'Sayı türü'),
  tamyiz('tamyiz', 'Temyizi'),
  meaning('meaning', 'Anlam'),
  turkish('turkish', 'Türkçesi'),
  term('term', 'Terim'),
  effect('effect', 'Etkisi'),
  syntax('syntax', 'Cümledeki görev'),
  role('role', 'Görevi'),
  construction('construction', 'Tamlama'),
  noun('noun', 'İsim'),
  nasb('nasb', 'Nasb'),
  irab('irab', 'İ‘rab'),
  ellipsis('ellipsis', 'Takdir');

  const IbareField(this.key, this.label);

  final String key;
  final String label;

  static IbareField fromJson(String key) => values.firstWhere(
    (field) => field.key == key,
    orElse: () => throw FormatException('Bilinmeyen ibare alanı: $key'),
  );
}

class IbareDetail {
  const IbareDetail({required this.label, required this.value});

  final String label;
  final String value;

  factory IbareDetail.fromJson(Map<String, dynamic> json) => IbareDetail(
    label: json['label'] as String,
    value: json['value'] as String,
  );
}

class IbareToken {
  const IbareToken({
    required this.id,
    required this.arabic,
    required this.gloss,
    required this.kind,
    required this.fields,
    required this.details,
    this.printedArabic,
    this.punctuation = '',
  });

  final String id;
  final String arabic;
  final String? printedArabic;
  final String punctuation;
  final String gloss;
  final String kind;
  final Map<IbareField, String> fields;
  final List<IbareDetail> details;

  bool get hasOptionalHarakat =>
      printedArabic != null && printedArabic != arabic;

  String displayArabic(bool showHarakat) =>
      '${_preferFathatanOnAlif(showHarakat ? arabic : printedArabic ?? arabic)}$punctuation';

  factory IbareToken.fromJson(Map<String, dynamic> json) {
    final analysis =
        (json['analysis'] as Map<String, dynamic>?) ??
        const <String, dynamic>{};
    final fieldsJson =
        (analysis['fields'] as Map<String, dynamic>?) ??
        const <String, dynamic>{};

    return IbareToken(
      id: json['id'] as String,
      arabic: json['arabic'] as String,
      printedArabic: json['printedArabic'] as String?,
      punctuation: (json['punctuation'] as String?) ?? '',
      gloss: json['gloss'] as String,
      kind: analysis['kind'] as String,
      fields: {
        for (final entry in fieldsJson.entries)
          IbareField.fromJson(entry.key): entry.value as String,
      },
      details: ((analysis['details'] as List<dynamic>?) ?? const [])
          .map((item) => IbareDetail.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class IbarePhrase {
  const IbarePhrase({
    required this.id,
    required this.tokenIds,
    required this.type,
    required this.meaning,
    this.parentId,
    this.explanation,
  });

  final String id;
  final List<String> tokenIds;
  final String type;
  final String meaning;
  final String? parentId;
  final String? explanation;

  factory IbarePhrase.fromJson(Map<String, dynamic> json) => IbarePhrase(
    id: json['id'] as String,
    tokenIds: List<String>.from(json['tokenIds'] as List),
    type: json['type'] as String,
    meaning: json['meaning'] as String,
    parentId: json['parentId'] as String?,
    explanation: json['explanation'] as String?,
  );
}

class IbareNote {
  const IbareNote({required this.label, required this.text});

  final String label;
  final String text;

  factory IbareNote.fromJson(Map<String, dynamic> json) =>
      IbareNote(label: json['label'] as String, text: json['text'] as String);
}

class IbarePassage {
  const IbarePassage({
    required this.id,
    required this.order,
    required this.translation,
    required this.tokens,
    required this.phrases,
    required this.notes,
    this.title,
    this.subtitle,
    this.editorialCorrection,
  });

  final String id;
  final int order;
  final String? title;
  final String? subtitle;
  final String? editorialCorrection;
  final String translation;
  final List<IbareToken> tokens;
  final List<IbarePhrase> phrases;
  final List<IbareNote> notes;

  bool get hasOptionalHarakat =>
      tokens.any((token) => token.hasOptionalHarakat);

  List<IbarePhrase> phrasesForToken(String tokenId) =>
      phrases.where((phrase) => phrase.tokenIds.contains(tokenId)).toList()
        ..sort((a, b) {
          final length = a.tokenIds.length.compareTo(b.tokenIds.length);
          return length != 0 ? length : a.id.compareTo(b.id);
        });

  factory IbarePassage.fromJson(Map<String, dynamic> json) {
    final tokens = (json['tokens'] as List<dynamic>)
        .map((item) => IbareToken.fromJson(item as Map<String, dynamic>))
        .toList();
    final phrases = ((json['phrases'] as List<dynamic>?) ?? const [])
        .map((item) => IbarePhrase.fromJson(item as Map<String, dynamic>))
        .toList();
    final tokenIds = tokens.map((token) => token.id).toSet();
    final phraseIds = phrases.map((phrase) => phrase.id).toSet();

    _requireUnique(phrases.map((phrase) => phrase.id), 'Terkip kimlikleri');
    for (final phrase in phrases) {
      if (phrase.tokenIds.isEmpty ||
          phrase.tokenIds.any((tokenId) => !tokenIds.contains(tokenId))) {
        throw FormatException(
          '${phrase.id} yalnız bu ibaredeki token kimliklerini kullanmalıdır.',
        );
      }
      if (phrase.parentId case final parentId?) {
        if (!phraseIds.contains(parentId) || parentId == phrase.id) {
          throw FormatException('${phrase.id} üst terkibi geçersiz: $parentId');
        }
        final parent = phrases.firstWhere((item) => item.id == parentId);
        if (!parent.tokenIds.toSet().containsAll(phrase.tokenIds)) {
          throw FormatException(
            '$parentId, ${phrase.id} terkibinin bütün tokenlarını kapsamalıdır.',
          );
        }
        if (parent.tokenIds.length <= phrase.tokenIds.length) {
          throw FormatException(
            '$parentId, ${phrase.id} terkibinden daha büyük olmalıdır.',
          );
        }
        if (parent.meaning.trim() == phrase.meaning.trim()) {
          throw FormatException(
            '$parentId ve ${phrase.id} aynı toplu anlamı taşıyamaz.',
          );
        }
      }
    }
    for (final phrase in phrases) {
      final visited = <String>{phrase.id};
      var parentId = phrase.parentId;
      while (parentId != null) {
        if (!visited.add(parentId)) {
          throw FormatException(
            'Terkip hiyerarşisinde döngü var: ${phrase.id}',
          );
        }
        parentId = phrases.firstWhere((item) => item.id == parentId).parentId;
      }
    }

    return IbarePassage(
      id: json['id'] as String,
      order: json['order'] as int,
      title: json['title'] as String?,
      subtitle: json['subtitle'] as String?,
      editorialCorrection: json['editorialCorrection'] as String?,
      translation: json['translation'] as String,
      tokens: tokens,
      phrases: phrases,
      notes: ((json['notes'] as List<dynamic>?) ?? const [])
          .map((item) => IbareNote.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class IbareSection {
  const IbareSection({
    required this.id,
    required this.order,
    required this.title,
    required this.passages,
    this.description,
    this.pageBreakAfter = false,
  });

  final String id;
  final int order;
  final String title;
  final String? description;
  final bool pageBreakAfter;
  final List<IbarePassage> passages;

  factory IbareSection.fromJson(Map<String, dynamic> json) {
    final passages =
        (json['passages'] as List<dynamic>)
            .map((item) => IbarePassage.fromJson(item as Map<String, dynamic>))
            .toList()
          ..sort((a, b) => a.order.compareTo(b.order));

    return IbareSection(
      id: json['id'] as String,
      order: json['order'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      pageBreakAfter: (json['pageBreakAfter'] as bool?) ?? false,
      passages: passages,
    );
  }
}

class IbareBook {
  const IbareBook({
    required this.schemaVersion,
    required this.id,
    required this.title,
    required this.shortTitle,
    required this.description,
    required this.sections,
  });

  final int schemaVersion;
  final String id;
  final String title;
  final String shortTitle;
  final String description;
  final List<IbareSection> sections;

  List<IbarePassage> get passages => [
    for (final section in sections) ...section.passages,
  ];

  factory IbareBook.fromJson(Map<String, dynamic> json) {
    final schemaVersion = json['schemaVersion'] as int;
    if (schemaVersion != 1) {
      throw FormatException('Desteklenmeyen ibare şema sürümü: $schemaVersion');
    }

    final List<IbareSection> sections;
    if (json['sections'] case final List<dynamic> sectionsJson) {
      sections =
          sectionsJson
              .map(
                (item) => IbareSection.fromJson(item as Map<String, dynamic>),
              )
              .toList()
            ..sort((a, b) => a.order.compareTo(b.order));
    } else {
      sections = [
        IbareSection(
          id: 'default',
          order: 1,
          title: '',
          passages:
              (json['passages'] as List<dynamic>)
                  .map(
                    (item) =>
                        IbarePassage.fromJson(item as Map<String, dynamic>),
                  )
                  .toList()
                ..sort((a, b) => a.order.compareTo(b.order)),
        ),
      ];
    }
    _requireUnique(
      sections.map((section) => section.id),
      'İbare bölüm kimlikleri',
    );
    final passages = [for (final section in sections) ...section.passages];
    _requireUnique(
      passages.map((passage) => passage.id),
      'İbare pasaj kimlikleri',
    );
    for (final passage in passages) {
      _requireUnique(
        passage.tokens.map((token) => token.id),
        '${passage.id} token kimlikleri',
      );
    }

    return IbareBook(
      schemaVersion: schemaVersion,
      id: json['id'] as String,
      title: json['title'] as String,
      shortTitle: json['shortTitle'] as String,
      description: json['description'] as String,
      sections: sections,
    );
  }
}

void _requireUnique(Iterable<String> values, String field) {
  final seen = <String>{};
  for (final value in values) {
    if (!seen.add(value)) {
      throw FormatException('$field benzersiz olmalıdır: $value');
    }
  }
}

String _preferFathatanOnAlif(String value) => value.replaceAll('ًا', 'اً');
