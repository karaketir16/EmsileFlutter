# Test Stratejisi

## 1. Temel Komutlar

```bash
dart format lib test
flutter analyze
flutter test
flutter build web
npm run validate-seed
```

Görsel kontrol:

```bash
python3 -m http.server 8090 -d build/web
npm run visual-check
```

## 2. Otomatik Test Kapsamı

Mevcut test paketi `44` test içerir.

### Veri ve Üretici Testleri

`test/data/muttaride_generator_test.dart`

- `nasara` için 339 form üretimi
- 24 kategorinin kapsanması
- Temel mâzi, muzâri, cahd, nefy, emir ve taaccüb örnekleri
- Kaynak tabloda bulunmayan emir hücrelerinin üretilmemesi

`test/data/practice_question_generator_test.dart`

- Her form için anlam sorusu üretimi
- Şahıs sorularının artık üretilmemesi
- Doğru şıkkın seçenekler içinde bulunması
- Runtime sorularında yalnız iki soru yönünün kullanılması
- Şıkların benzersiz ve en fazla beş adet olması
- Aynı Arapça yazılışın distractor olarak tekrarlanmaması

### Widget Testleri

Genel:

- Gerçek JSON asset'iyle uygulamanın yüklenmesi
- Ana sayfanın render edilmesi
- Alt navigasyon ekran eşleşmeleri
- Ders Muhtelife detayının render edilmesi
- Hakkında bağlantısının gösterilmesi

Çekimler:

- Meçhul ve kategori geçişleri
- Şahıs ve form hücresine dokunma
- Kategori/çatı değişiminde seçimin korunması
- Aktif tablonun doğru vurgulanması
- Üst kontroller ve alt scroll ayrımı
- Dar tabloların mevcut genişliği doldurması
- İsim tabloları ve kırık çoğul seçimi
- Ayrı/bitişik zamir tabloları

Çoktan Seçmeli:

- Doğru cevapta `Doğru`
- Yanlış cevapta `Tekrar Bak`
- Yanlış cevapta doğru cevabın ve açıklamanın gizli kalması
- Sonraki soru
- Beş form altı başlangıç engeli
- Kategori, çatı, şahıs ve isim filtreleri
- Satır/sütun toplu seçimleri

Tabloyu Doldur:

- Yanlış bırakmanın kırmızı/X olması
- Doğru bırakmanın yeşil/tik olması
- Karşılığı olmayan hücrenin kapalı olması
- Yanlış token'ın yeniden sürüklenebilmesi
- Yanlış dolu hücre doğru cevapla değiştirildiğinde eski token'ın havuza dönmesi
- İsim kategorisinde çatı seçiminin gizlenmesi
- Kırık çoğulların alıştırmadan çıkarılabilmesi
- Kırık çoğulların eşdeğer hedeflere bırakılabilmesi
- Bütün hedefler doğru dolduğunda başarı kartının gösterilmesi
- Pratik alt ekranındaki geri butonunun mod seçimine dönmesi

Dersler ve ortak tablolar:

- Birinci şahıs ikil/çoğul alanının tek `Biz` hücresi olması
- Dersler içindeki zamir ekranının ayrı/bitişik geçişi

## 3. Determinizm

Pratik ekranları testlerde `Random(1)` gibi sabit random nesneleri alır. Üretim ve karıştırma gerçek uygulamada rastgele, testte tekrarlanabilirdir.

## 4. Seed Validasyonu

`npm run validate-seed`:

- `catalog.json`
- `verbs/*.json`
- ders, zamir, manifest ve Muhtelife alanları
- generated kaynak profili
- enum değerleri

üzerinde temel yapısal kontrol yapar.

## 5. Görsel Kontrol

`npm run visual-check`, release web çıktısında mobil viewport ekran görüntüleri üretir ve console/page hatalarını yakalar.

Mevcut ekran görüntüleri:

```text
docs/screenshots/
  01-home-mobile.png
  02-table-mobile.png
  03-practice-mobile.png
  04-pronouns-mobile.png
```

Bu görüntüler güncel UI'nin garantisi değildir; büyük görsel değişikliklerde yeniden üretilmelidir.

## 6. Eksik Testler

- Bütün token'lar yanlış yerleştiğinde `Tekrar bak` kartı testi
- Repository hata senaryoları
- 360 px ve 430 px viewport testleri
- Erişilebilirlik/semantics testi

## 7. Değişiklik Sonrası Minimum Doğrulama

UI veya veri mantığı değiştiğinde:

1. İlgili hedef test
2. `flutter analyze`
3. `flutter test`

çalıştırılmalıdır.

Tablo, RTL veya layout değişikliğinde ayrıca web build ve görsel kontrol önerilir.
