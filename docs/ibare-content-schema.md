# İbare İçerik Şeması

İbare ekranları kitap veya ders adına bağlı kod içermez. Yeni içerik:

1. `assets/data/ibare/` altında bir JSON dosyası oluşturularak,
2. `assets/data/catalog.json` içindeki `ibareBooks` listesine eklenerek

uygulamaya alınır. Başlangıç şablonu:
[ibare-content-template.json](ibare-content-template.json).

## Yapı

```text
kitap
└── sections[]
    └── passages[]
        ├── tokens[]
        │   └── analysis
        │       ├── fields
        │       └── details[]
        └── phrases[]
```

- `arabic`: Öğrenciye “Harekeleri göster” açıkken sunulan tam biçim.
- `printedArabic`: Kitapta basıldığı biçim. Verilmezse `arabic` kullanılır.
- `punctuation`: Kelimenin ardından gelen noktalama.
- `gloss`: Kırık mana.
- `translation`: Pasajın toparlanmış manası.
- `sections[].title`: Kitap içinde yön bulmayı sağlayan bölüm başlığı.
- `passage.title` ve `passage.subtitle`: İsteğe bağlıdır; yalnız gerektiğinde kullanılır.
- `analysis.kind`: Kelimenin üst başlığı.
- `analysis.fields`: Uygulamanın tanıdığı standart tahlil alanları.
- `analysis.details`: Kitaba özgü, standart dışı açıklamalar.
- `phrases`: Bir veya daha fazla tokenın oluşturduğu terkip/cümle katmanları.
- `phrases[].tokenIds`: Terkibin kapsadığı token kimlikleri.
- `phrases[].type`: Sıfat tamlaması, izafet, câr-mecrûr, fiil cümlesi gibi yapı.
- `phrases[].meaning`: Kelime grubunun toplu anlamı.
- `phrases[].parentId`: Varsa bu terkibi kapsayan bir üst katman.
- `phrases[].explanation`: İsteğe bağlı öğretici dilbilgisi açıklaması.

Bir token birden fazla terkibin içinde bulunabilir. Arayüz bu terkipleri token
sayısına göre küçükten büyüğe sıralar. Üst terkip, alt terkibin bütün
tokenlarını ve en az bir ek tokenı kapsamalıdır. Çocuk ve üst terkip aynı
toplu anlamı taşıyamaz; her katman anlam veya cümle işlevindeki büyümeyi
göstermelidir. Doğrudan iç içe JSON nesnesi kullanılmaz.

## Standart Tahlil Alanları

Alanlar JSON'da sabit anahtarlarla yazılır; Türkçe etiketleri uygulama üretir.

| Anahtar | Gösterilen etiket |
|---|---|
| `structure` | Yapısı |
| `wordForm` | Kelime biçimi |
| `root` | Kök |
| `singular` | Tekili |
| `derivedFrom` | Türediği fiil |
| `baseForm` | Aslı |
| `bab` | Bab |
| `pattern` | Vezin |
| `morphology` | Türü |
| `conjugation` | Çekim |
| `person` | Şahıs |
| `hiddenPronoun` | Gizli zamir |
| `pronoun` | Zamir |
| `referent` | Mercii |
| `transitivity` | Geçişlilik |
| `presentForm` | Muzârisi |
| `middleRadical` | Aynü’l-fiil |
| `numberType` | Sayı türü |
| `tamyiz` | Temyizi |
| `meaning` | Anlam |
| `turkish` | Türkçesi |
| `term` | Terim |
| `effect` | Etkisi |
| `syntax` | Cümledeki görev |
| `role` | Görevi |
| `construction` | Tamlama |
| `noun` | İsim |
| `nasb` | Nasb |
| `irab` | İ‘rab |
| `ellipsis` | Takdir |

Yeni standart alan gerekiyorsa önce `IbareField` enum'una eklenir. Tek kitaba
özgü alanlar için enum genişletilmez; `details` kullanılır.

## Kimlik ve Sıralama Kuralları

- Kitap, bölüm, pasaj, token ve terkip kimlikleri kendi kapsamlarında benzersizdir.
- Pasajlar `order` alanına göre sıralanır.
- Token sırası JSON dizisindeki sıradır.
- `parentId` döngü oluşturamaz ve mevcut bir üst terkibe işaret etmelidir.
- `schemaVersion` şu an `1` olmalıdır.
- Bölüm başlığı, Arapça metin, kırık mana veya tahlil türü boş olamaz.

`npm run validate-seed` manifesti, dosya yollarını, kimlikleri ve alan
anahtarlarını doğrular.
