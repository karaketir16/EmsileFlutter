# Test Stratejisi

Bu doküman uygulamanın nasıl test edildiğini ve hangi komutların hangi riski azalttığını açıklar.

Bu dosya yaşayan test kaydıdır. Test komutları, kapsam, Playwright akışı, screenshot çıktıları veya doğrulama kriterleri değiştiğinde aynı değişiklikle birlikte güncel tutulmalıdır.

## 1. Çalıştırılan Kontroller

### Format

```bash
dart format lib/main.dart test/widget_test.dart
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

### Widget Testleri

```bash
flutter test
```

Kapsam:

- Uygulama JSON asset'i yükleyip ana ekranı render ediyor.
- Çekim tablosu ekranı mobil genişlikte render oluyor.
- Pratik ekranı mobil genişlikte render oluyor.

Not:

Alt navigasyon davranışı widget test yerine Playwright ile doğrulanıyor. Flutter web/canvas ve Material NavigationBar yapısı widget finder ile her zaman pratik test ergonomisi vermediği için bu ayrım yapıldı.

### Seed Veri Validasyonu

```bash
npm run validate-seed
```

Amaç:

- `assets/data/emsile_seed.json` dosyasının beklenen kök alanları taşıdığını doğrulamak.
- Ders, çekim ve pratik sorusu alanlarının boş olmadığını kontrol etmek.
- `category`, `voice` ve pratik doğru cevabı gibi alanlarda temel tutarlılığı yakalamak.

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

Kapsam:

- Uygulama 390x844 mobil viewport ile açılır.
- Ana ekran screenshot alınır.
- Alt navigasyondan çekim tablosuna geçilir.
- Meçhul seçimi yapılır.
- Çekim tablosu screenshot alınır.
- Pratik ekranına geçilir.
- İlk cevap seçilir.
- Doğru cevap geri bildirimi screenshot alınır.
- Console error veya page error varsa test başarısız olur.

Çıktılar:

```text
docs/screenshots/01-home-mobile.png
docs/screenshots/02-table-mobile.png
docs/screenshots/03-practice-mobile.png
```

## 2. Neden Playwright Kullanıyoruz?

Chrome'un harici diskten headless kullanımı bu ortamda kırılgan davrandı. Playwright kendi Chromium runtime'ını indirip kullandığı için daha tekrarlanabilir sonuç verdi.

Playwright ayrıca sadece screenshot değil, gerçek tıklama akışını da test ediyor. Bu yüzden alt navigasyon, segment kontrol ve pratik cevabı gibi mobil etkileşimler için daha uygun.

## 3. Mevcut Test Sınırları

Henüz yok:

- JSON şema testi
- Daha kapsamlı JSON schema testi
- Repository hata senaryosu testi
- Tüm viewport matrisi: 360, 390, 430
- Alt navigasyon için semantik finder tabanlı test
- Ders detayından hedefli tablo/pratik geçiş testi

## 4. Manuel Görsel İnceleme

Playwright screenshot'ları üretildikten sonra görüntüler elle kontrol edildi.

Kontrol edilenler:

- Ana ekran kartları taşmıyor.
- Arapça formlar büyük ve okunaklı.
- Alt navigasyon erişilebilir ve ekran değiştiriyor.
- Çekim tablosunda Meçhul seçimi doğru veri gösteriyor.
- Pratik ekranında doğru cevap sonrası geri bildirim görünüyor.

Bulunan ve düzeltilen örnek sorun:

- Çekim tablosu alt başlığında Arapça kök ve backtick kullanımı RTL nedeniyle garip görünüyordu. Metin `Nasara örneği üzerinden seç, gör, karşılaştır.` olarak değiştirildi.

## 5. Önerilen Test Genişletmeleri

- `assets/data/emsile_seed.json` için JSON schema validation script'i ekle.
- `assets/data/emsile_seed.json` için daha katı JSON Schema dosyası ekle.
- Playwright script'ini 360px, 390px ve 430px viewportlarda çalıştır.
- Her screenshot için temel piksel/boş ekran kontrolü ekle.
- `EmsileRepository.load()` hata durumunu test edilebilir hale getir.
- Form filtreleme mantığını ayrı unit test ile doğrula.
