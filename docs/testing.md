# Test Stratejisi

Bu doküman uygulamanın nasıl test edildiğini ve hangi komutların hangi riski azalttığını açıklar.

Bu dosya yaşayan test kaydıdır. Test komutları, kapsam, screenshot çıktıları veya doğrulama kriterleri değiştiğinde aynı değişiklikle birlikte güncel tutulmalıdır.

Not: Bu doküman ve diğer proje kayıtları her zaman güncel tutulmalıdır; test kapsamı veya doğrulama adımları değişirse aynı commit içinde burada da güncelleme yapılmalıdır.

## 1. Çalıştırılan Kontroller

### Format

```bash
dart format lib test
```

Amaç:

- Dart kod stilini standart tutmak.
- Gereksiz diff ve okunabilirlik problemlerini azaltmak.

### Statik Analiz

```bash
flutter analyze
```

Amaç:

- Import, lint, tip ve Flutter API kullanım hatalarını yakalamak.
- Asset refactor sonrası kullanılmayan import veya kırık referansları görmek.

### Widget Testleri (Etkileşimli)

```bash
flutter test
```

Kapsam:

- Uygulama JSON asset'i yükleyip ana ekranı render ediyor.
- Seçili sekme index'ine göre Tablo, Pratik, Dersler ve Kaynak ekranları doğru render oluyor.
- Çekim tablosu: Meçhul segment tıklaması doğru formu gösteriyor.
- Çekim tablosu: Muzâri segment tıklaması doğru formu gösteriyor.
- Çekim tablosu: Şahıs chip tıklaması sonuç kartını güncelliyor.
- Pratik: Doğru cevap tıklaması "Doğru" geri bildirimini gösteriyor.
- Pratik: Yanlış cevap tıklaması "Tekrar Bak" geri bildirimini gösteriyor.
- Pratik: Sonraki Soru butonu bir sonraki soruya geçiyor.
- Test fixture'ları yeni `person/number/gender` veri modelini kullanıyor.
- `PracticeQuestionGenerator` unit testleri aynı Arapça form tekrarlarında ayrı şahıs soruları üretildiğini doğruluyor.

Test altyapısı:

- `pumpLoadedApp`: EmsileApp'i gerçek JSON asset'iyle yükler ve ana ekranın hazır olmasını bekler.
- `_IndexedAppShell`: AppShell ile aynı ekran eşleme mantığını kullanarak seçili index'e göre doğru ekranın render edildiğini doğrular.
- `richTestData`: Çekim testleri için birden fazla kategori/bina/şahıs içeren yerel veri seti.
- `multiQuestionData`: "Sonraki Soru" akışını test eden iki soruluk yerel veri seti.

Not:

Widget testleri Playwright'ın yerini tamamen almaz. `flutter test` etkileşim ve durum değişimini doğrular; `npm run visual-check` ise release web çıktısında görsel akışı ve layout'u kontrol eder.

Widget testleri ChromeDriver veya Playwright kurulumu gerektirmez; tüm platformlarda `flutter test` ile çalışır.

### Seed Veri Validasyonu

```bash
npm run validate-seed
```

Amaç:

- `assets/data/emsile_seed.json` dosyasının beklenen kök alanları taşıdığını doğrulamak.
- Ders ve çekim alanlarının boş olmadığını kontrol etmek.
- `category`, `voice`, `person`, `number` ve `gender` alanlarında temel tutarlılığı yakalamak.
- Pratik soruları artık seed JSON'dan değil, uygulama içinde formlardan üretildiği için doğrulama odağı form verisindedir.

### Web Build

```bash
flutter build web
```

Amaç:

- Release web çıktısının üretilebildiğini doğrulamak.
- JSON asset'in web bundle içine doğru girdiğini kontrol etmek.

### Playwright Görsel Kontrol

```bash
npm run visual-check
```

Ön koşul:

```bash
python3 -m http.server 8090 -d build/web
```

veya aynı portta `build/web` servis ediliyor olmalı.

Amaç:

- Release web çıktısında ana akışın gerçekten açıldığını doğrulamak.
- Mobil viewport'ta ana ekran, çekim tablosu ve pratik ekranı screenshot'larını üretmek.
- Console error veya page error durumlarını yakalamak.

## 2. Mevcut Test Sınırları

Henüz yok:

- Repository hata senaryosu testi (`EmsileRepository.load()` başarısız durumu).
- Veri modelleri için ayrı Dart unit testi.
- Form filtreleme mantığı için ayrı unit testi.
- Ders detayından çekim tablosuna/pratiğe hedefli geçiş testi.
- 360px ve 430px viewport genişlik testleri.
- Gerçek `AppShell` alt navigasyon tap akışı için daha doğrudan widget testi.

## 3. Önerilen Test Genişletmeleri

- `assets/data/emsile_seed.json` için daha katı JSON Schema dosyası ekle (ajv ile).
- `EmsileRepository.load()` hata durumunu test edilebilir hale getir.
- Form filtreleme mantığını ayrı unit test ile doğrula.
- Widget testini 360px ve 430px viewport genişlikleriyle çalıştır.
- Ders detayından çekim tablosuna/pratiğe hedefli geçiş testleri ekle.
