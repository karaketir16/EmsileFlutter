import 'package:emsile_flutter/data/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses fields and sorts passages by order', () {
    final book = IbareBook.fromJson(
      _bookJson([
        _passageJson(id: 'second', order: 2),
        _passageJson(id: 'first', order: 1),
      ]),
    );

    expect(book.passages.map((passage) => passage.id), ['first', 'second']);
    expect(book.passages.first.tokens.single.fields[IbareField.root], 'ف ع ل');
  });

  test('rejects unknown analysis fields', () {
    final token = _tokenJson();
    (token['analysis'] as Map<String, dynamic>)['fields'] = {
      'unknown': 'value',
    };

    expect(
      () => IbareBook.fromJson(
        _bookJson([_passageJson(id: 'first', order: 1, token: token)]),
      ),
      throwsFormatException,
    );
  });

  test('rejects duplicate passage and token ids', () {
    expect(
      () => IbareBook.fromJson(
        _bookJson([
          _passageJson(id: 'same', order: 1),
          _passageJson(id: 'same', order: 2),
        ]),
      ),
      throwsFormatException,
    );

    final passage = _passageJson(id: 'first', order: 1);
    passage['tokens'] = [_tokenJson(), _tokenJson()];
    expect(
      () => IbareBook.fromJson(_bookJson([passage])),
      throwsFormatException,
    );
  });

  test('parses sections and allows passages without headings', () {
    final passage = _passageJson(id: 'plain', order: 1)
      ..remove('title')
      ..remove('subtitle');
    final book = IbareBook.fromJson({
      'schemaVersion': 1,
      'id': 'book',
      'title': 'Book',
      'shortTitle': 'Book',
      'description': 'Description',
      'sections': [
        {
          'id': 'section',
          'order': 1,
          'title': 'Section',
          'passages': [passage],
        },
      ],
    });

    expect(book.sections.single.title, 'Section');
    expect(book.passages.single.title, isNull);
    expect(book.passages.single.subtitle, isNull);
  });

  test('parses nested phrases and orders token matches small to large', () {
    final passage = _passageJson(id: 'first', order: 1);
    passage['tokens'] = [
      _tokenJson(),
      {..._tokenJson(), 'id': 'second_token', 'arabic': 'الْفِعْلِ'},
      {..._tokenJson(), 'id': 'third_token', 'arabic': 'مِنْ'},
    ];
    passage['phrases'] = [
      {
        'id': 'large',
        'tokenIds': ['token', 'second_token', 'third_token'],
        'type': 'Câr-mecrûr',
        'meaning': 'Büyük yapı',
      },
      {
        'id': 'small',
        'tokenIds': ['token', 'second_token'],
        'type': 'İsim tamlaması',
        'meaning': 'Küçük yapı',
        'parentId': 'large',
      },
    ];

    final book = IbareBook.fromJson(_bookJson([passage]));
    expect(
      book.passages.single.phrasesForToken('token').map((item) => item.id),
      ['small', 'large'],
    );
  });

  test('rejects phrase parents that do not contain child tokens', () {
    final passage = _passageJson(id: 'first', order: 1);
    passage['tokens'] = [
      _tokenJson(),
      {..._tokenJson(), 'id': 'second_token'},
    ];
    passage['phrases'] = [
      {
        'id': 'parent',
        'tokenIds': ['second_token'],
        'type': 'Üst yapı',
        'meaning': 'Üst',
      },
      {
        'id': 'child',
        'tokenIds': ['token'],
        'type': 'Alt yapı',
        'meaning': 'Alt',
        'parentId': 'parent',
      },
    ];

    expect(
      () => IbareBook.fromJson(_bookJson([passage])),
      throwsFormatException,
    );
  });

  test('rejects phrase parents without token or meaning growth', () {
    final passage = _passageJson(id: 'first', order: 1);
    passage['tokens'] = [
      _tokenJson(),
      {..._tokenJson(), 'id': 'second_token'},
    ];
    passage['phrases'] = [
      {
        'id': 'parent',
        'tokenIds': ['token', 'second_token'],
        'type': 'Üst yapı',
        'meaning': 'Aynı anlam',
      },
      {
        'id': 'child',
        'tokenIds': ['token', 'second_token'],
        'type': 'Alt yapı',
        'meaning': 'Aynı anlam',
        'parentId': 'parent',
      },
    ];

    expect(
      () => IbareBook.fromJson(_bookJson([passage])),
      throwsFormatException,
    );
  });
}

Map<String, dynamic> _bookJson(List<Map<String, dynamic>> passages) => {
  'schemaVersion': 1,
  'id': 'book',
  'title': 'Book',
  'shortTitle': 'Book',
  'description': 'Description',
  'passages': passages,
};

Map<String, dynamic> _passageJson({
  required String id,
  required int order,
  Map<String, dynamic>? token,
}) => {
  'id': id,
  'order': order,
  'title': id,
  'subtitle': id,
  'translation': id,
  'tokens': [token ?? _tokenJson()],
};

Map<String, dynamic> _tokenJson() => {
  'id': 'token',
  'arabic': 'فَعَلَ',
  'gloss': 'Yaptı',
  'analysis': {
    'kind': 'Fiil',
    'fields': {'root': 'ف ع ل'},
  },
};
