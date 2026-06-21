# Düşük Seviye Tasarım

## 1. Proje Yapısı

```text
lib/
  app/
    app_shell.dart
    emsile_app.dart
  domain/
    conjugation/
      form_selection.dart
    models/
      app_data.dart
      conjugation_form.dart
      content.dart
      grammar.dart
      practice_question.dart
  data/
    catalog_models.dart
    emsile_repository.dart
    models.dart
    muttaride_generator.dart
    generators/
      nasara_muttaride_generator.dart
    practice_question_generator.dart
  features/
    conjugation/
      conjugation_screen.dart
      widgets/
        conjugation_grid.dart
        forms_tables.dart
        noun_forms_table.dart
        pronouns_panel.dart
    practice/
      practice_screen.dart
      matching_practice_screen.dart
      table_fill_practice_screen.dart
      multiple_choice/
    home/home_screen.dart
    lessons/lessons_screen.dart
    source/source_screen.dart
  shared/
    theme/app_theme.dart
    widgets/
      app_page.dart
      arabic_result_card.dart
      arabic_text.dart
      info_panel.dart
      navigation_card.dart
assets/data/
  catalog.json
  verbs/nasara.json
test/
  data/
    emsile_repository_test.dart
    muttaride_generator_test.dart
    practice_question_generator_test.dart
  matching_practice_test.dart
  widget_test.dart
```

## 2. Başlatma ve Veri Akışı

1. `main()` → `EmsileApp`
2. `EmsileRepository().load()`
3. `catalog.json` yüklenir.
4. `defaultVerbId` ile `verbs/nasara.json` yüklenir.
5. `MuttarideGenerator.fromVerbEntry()` runtime `ConjugationForm` listesini üretir.
6. Dersler, zamirler, Muhtelife satırları ve formlar `AppData` içinde birleştirilir.
7. `PracticeQuestionGenerator.fromForms()` geriye dönük soru listesi üretir.
8. `AppShell` beş ana ekranı `IndexedStack` içinde gösterir.

Yükleme sırasında `LoadingScreen`, hata halinde `LoadErrorScreen` kullanılır.

## 3. Veri Modeli

### AppData

- `lessons`
- `pronouns`
- `muhtelifeEntries`
- `forms`
- `practiceQuestions`

### ConjugationForm

- `category`
- `voice`
- `person`
- `number`
- `gender`
- `pronounLabel`
- `arabic`
- `meaning`
- alanlardan türetilen `rule`

Fiil anlamları Türkçe kişi ve hâl uyumuyla üretilir. Generator her şahıs için:

- yalın/özne: `İkiniz (kadın)`
- yönelme: `İkinize (kadın)`
- iyelik: `İkinizin (kadın)`

biçimlerini bilir. Etken anlamlarda fiil kişiyle çekimlenir
(`yardım ettiniz`), edilgen anlamlarda yönelme hâli kullanılır
(`İkinize (kadın) yardım edildi`).

### FormCategory

Toplam 24 kategori vardır. Mâzi, muzâri, nefy, cahd, emir, nehiy, masdar, isim türevleri ve taaccüb biçimlerini kapsar. `isVerb` ve `isNoun` getter'ları UI ayrımında kullanılır.

### PronounEntry

- `kind`: `independent` veya `attached`
- `person`, `number`, `gender`
- `labelTr`, `arabic`, `meaning`

### MuhtelifeEntry

- `type`, `label`, `arabic`, `meaning`
- `sortOrder`
- opsiyonel `row`, `column`

## 4. Muttaride Üretimi

`MuttarideGenerator`, şu an yalnız:

```text
family: sulasi_mujarrad
verbClass: sahih_salim
bab: nasara_yansuru
```

profilini destekler.

Üretilen toplam form sayısı: `339`.

Üretim kapsamı:

- Mâzi ve muzâri, malum/meçhul
- Cahd ve nefy kategorileri
- Emr-i Gâib, Nehy-i Gâib, Emr-i Hâzır, Nehy-i Hâzır
- Masdar ve isim türevleri
- Fiil-i Taaccüb

Kaynak tabloda bulunmayan şahıs çekimleri üretilmez.

Birinci şahıs için ayrı ikil çekim yoktur. Veri yalnız `Ben` ve `Biz` formu üretir. Tablo widget'ı 1. şahıs satırında çoğul ve ikil sütunlarını görsel olarak birleştirir.

## 5. Ortak Tablo Modeli

Çekim özelliği public API'yi `conjugation_screen.dart` üzerinden dışarı açar;
uygulama ise sorumlulukları ayrı dosyalarda tutar:

- `FormsTable`
- `NounFormsTable`
- `PronounsPanel`
- `FormSelection`

Ortak satır/sütun şeması ve form arama kuralları
`domain/conjugation/form_selection.dart` içindedir. Böylece tablo gösterimi ile
tablo doldurma alıştırması aynı seçim ve birinci şahıs fallback kuralını kullanır.

`LessonsScreen`, Muttaride detaylarında aynı `FormsTable` ve `NounFormsTable` bileşenlerini kullanır. Böylece Dersler ve Tablo menüsü görsel olarak ayrışmaz.

Fiil tablo şeması:

```text
Çoğul | İkil | Tekil | Şahıs
```

1. şahıs satırında ilk iki sütun tek `Biz` hücresine dönüşür.

İsimler için `NounFormsTable`:

- Müzekker/müennes veya ortak satır
- Çoğul/ikil/tekil sütun
- Ana tablonun dışında kırık çoğul kartları

## 6. Ekran State'leri

### Çekimler

`_ConjugationsPageState`:

- `_category`
- `_voice`
- `_selectedForm`

Kategori/çatı değişiminde `person + number + gender` korunur. Aynı seçim yoksa görünür ilk forma düşülür.

### Çoktan Seçmeli

Çoktan seçmeli pratik üç parçaya ayrılır:

- `multiple_choice_practice_screen.dart`: akış ve ekran state'i
- `practice_filters.dart`: kategori, çatı ve kırık çoğul filtreleri
- `practice_answer.dart`: cevap butonu ve geri bildirim görünümü

En az bir kategori seçilmelidir. Fiil kategorisi seçiliyse malum veya meçhul
çatılarından en az biri seçilmelidir.

`PracticeQuestionGenerator.generateSingleQuestion()`:

1. Filtreli listeden, aynı kategoride en az iki seçenek üretebilen form seçer.
2. İki soru yönünden birini rastgele seçer.
3. Yanlış şıkları yalnız hedefle aynı kategoriden seçer.
4. Aynı Arapça yazılışa sahip kardeşleri yanlış şık adayından çıkarır.
5. Mevcut kaliteli aday sayısına göre 2-5 benzersiz şık üretir ve karıştırır.

Soru tipleri:

- `Bu sîganın anlamı hangisi?`
- `Hangisi bu anlama gelir: "..."?`

Şahıs sorusu üretilmez.

`AppData.practiceQuestions` repository yüklemesinde hâlâ üretilir; ancak güncel
çoktan seçmeli ekran bu listeyi kullanmaz ve soruyu filtrelenmiş `forms`
üzerinden anlık üretir. Alan geriye dönük uyumluluk dışında kaldırılabilir.

### Tabloyu Doldur

`_TableFillPracticeScreenState`:

- `_category`
- `_voice`
- `_includeBrokenPlurals`
- `_started`
- `_round`
- `_placed`
- `_wrongSlots`
- `_tokens`

Başlangıçta seçili formlar `_FormToken` listesine dönüştürülür ve `shuffle()` edilir.

Yerleşim kuralları:

- Aynı Arapça yazım doğru kabul edilir.
- Aynı kategorideki kırık çoğullar birbirinin alanına bırakılabilir.
- Doğru yerleşim kilitlenir.
- Yanlış yerleşim yeniden sürüklenebilir.
- Yanlış dolu hücreye yeni token bırakılırsa eski token havuza döner.
- Kullanılmayan hedefe bırakılan token havuza döner.

Tamamlanma:

```dart
tokens.isEmpty &&
placed.length == forms.length &&
placed.values.every((item) => item.isCorrect)
```

Fiiller `_FillTable`, isimler `_NounFillTable` ile çizilir.

## 7. Dersler

`LessonsScreen` üç sabit ana ders sunar:

- Muhtelife
- Muttaride
- Şahıs Zamirleri

`catalog.lessons` modeli geriye dönük uyumlulukta ve test fixture'larında bulunur; mevcut ana ders navigasyonu kod içindeki bu üç başlıktan kurulur.

Muhtelife notları ve kategori açıklamaları şu an `lessons_screen.dart` içinde sabit metinlerdir. Tablo verileri `AppData` üzerinden gelir.

## 8. UI Altyapısı

`AppPage`:

- maksimum 520 px içerik genişliği
- varsayılan `CustomScrollView`
- opsiyonel sabit başlık + ayrı gövde scroll'u
- opsiyonel geri butonu

Tema:

- Material 3
- `seedColor: #1F6F5B`
- zemin `#F7F6F0`
- beyaz, ince çerçeveli kartlar

Arapça:

- `Directionality.rtl`
- `arabicTextStyle()`
- mevcut font ailesi `Times New Roman`

## 9. Bilinen Sınırlar

- Tek fiil ve tek generated profil
- Generator Türkçe anlamları `نصر / yardım etmek` fiiline sabitler;
  `meaningSummary` henüz çekim üretiminde kullanılmaz
- Kalıcı skor/ilerleme yok
- Repository `AssetBundle` üzerinden enjekte edilebilir ve izole test edilebilir
- Veri parse hataları alan bazında kullanıcı dostu raporlanmıyor
- Özel Arapça fontu paketlenmiş değil
- `emsile_seed.json` eski seed/uyumluluk asset'i olarak pakette kalıyor; repository aktif olarak katalog yapısını kullanıyor
- Çekimler ve Zamirler alt sayfalarında `AppBar` ve `AppPage` başlığı birlikte
  kullanıldığı için başlık iki kez görünür
