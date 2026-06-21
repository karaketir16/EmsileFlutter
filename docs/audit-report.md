# Emsile Flutter Uygulama Denetim Raporu

Son güncelleme: 21 Haziran 2026

## 1. Yönetici Özeti

Uygulamanın mevcut ana akışları çalışıyor. Veri üretimi ve tablo mantığı geniş bir
otomatik test setiyle korunuyor; web release çıktısı alınabiliyor ve 360 px ile
430 px genişliklerde yapılan manuel kontrolde taşma veya console hatası görülmedi.

Mevcut doğrulama sonucu:

| Kontrol | Sonuç |
|---|---|
| `npm run validate-seed` | Başarılı |
| `flutter test` | 53/53 başarılı |
| Satır kapsamı | 2425/2731, `%88,8` |
| `flutter build web --release` | Başarılı |
| 360 × 640 manuel web kontrolü | Başarılı |
| 430 × 932 manuel web kontrolü | Başarılı |
| `flutter analyze` | 2 deprecated API bilgisi |
| Format kontrolü | 1 dosya format dışı |

Genel karar:

- Web uygulaması mevcut kapsamıyla kullanılabilir.
- Android/iOS mağaza yayınına hazır değildir.
- Ana teknik borç; yayın yapılandırması, erişilebilirlik, CI kalite kapısı,
  çok-fiilli veri modeli ve doküman doğruluğudur.
- Yeni state-management paketi, veritabanı veya büyük mimari dönüşüm şu an
  gereksizdir. Mevcut `StatefulWidget + yerel JSON` yaklaşımı bu ölçek için yeterlidir.

## 2. Öncelik Tanımları

- **P0 — Yayın engelleyici:** Üretime çıkmadan çözülmeli.
- **P1 — Yüksek:** Kullanıcı deneyimi, güvenilirlik veya büyüme için yakın vadede çözülmeli.
- **P2 — Orta:** Bakım ve kaliteyi iyileştirir.
- **P3 — Düşük:** Ölçüm veya gerçek ihtiyaç oluştuğunda ele alınabilir.

## 3. P0 — Yayın Engelleyiciler

### P0-1 — Mobil uygulama kimlikleri hâlâ örnek değer

Kanıt:

- Android namespace/application ID: `com.example.emsile_flutter`
- iOS bundle ID: `com.example.emsileFlutter`

Etkisi:

- Mağaza kimliği, deep link, imzalama ve sonraki güncellemeler için uygun değildir.
- Yayından sonra application ID değiştirmek yeni uygulama sayılır.

Öneri:

- Kalıcı ters alan adı belirlenmeli.
- Android package dizini ve `MainActivity` paketi birlikte taşınmalı.
- iOS Runner ve test bundle ID'leri birlikte güncellenmeli.

### P0-2 — Android release sürümü debug anahtarıyla imzalanıyor

`android/app/build.gradle.kts` içindeki release yapılandırması doğrudan debug
signing config kullanıyor.

Etkisi:

- Play Store üretim yayını yapılamaz.
- İmza anahtarı yönetimi ve kurtarma planı yoktur.

Öneri:

- Upload keystore oluşturulmalı.
- Parolalar repoya girmeden environment/secret üzerinden okunmalı.
- Release build CI üzerinde ayrıca doğrulanmalı.

### P0-3 — Ana branch doğrudan kalite kontrolü olmadan deploy ediliyor

GitHub Pages workflow'u yalnız bağımlılık yükleyip web build alıyor. Şunlar
deploy öncesi çalışmıyor:

- format kontrolü
- `flutter analyze`
- `flutter test`
- `npm run validate-seed`

Etkisi:

- Testi veya verisi bozuk commit başarılı build aldığı sürece canlıya çıkar.

Öneri:

- Aynı job'a dört hızlı kalite adımı eklenmeli.
- Deploy yalnız hepsi başarılıysa çalışmalı.

### P0-4 — Analitik var, gizlilik bildirimi yok

Web uygulaması localhost dışında Cloudflare Web Analytics beacon'ı yüklüyor.
README, uygulama içi Hakkında ekranı ve `docs/` altında gizlilik metni bulunmuyor.

Etkisi:

- Kullanıcıya veri işleme hakkında şeffaflık sağlanmıyor.
- Yayın bölgesine göre hukuki ve mağaza beyanı riski oluşabilir.

Öneri:

- Hangi verilerin işlendiği doğrulanmalı.
- Kısa bir gizlilik politikası eklenip Hakkında ekranından bağlanmalı.
- Gerekmiyorsa analitik tamamen kaldırılmalı; en kısa ve risksiz seçenek budur.

### P0-5 — Lisans metadatası çelişkili

Repo kökündeki lisans GPL-3.0 iken `package.json` lisansı `ISC`.

Etkisi:

- Dağıtım ve katkı koşulları belirsizleşir.

Öneri:

- Projenin gerçek lisansı seçilip `package.json`, README ve gerekiyorsa uygulama
  içi Hakkında ekranında aynı değer kullanılmalı.

## 4. P1 — Yüksek Öncelikli Bulgular

### P1-1 — Tablo doldurma yalnız sürükle-bırak ile kullanılabiliyor

Fiil, isim ve zamir tablo doldurma akışlarında klavye, ekran okuyucu veya
“seç ve hedefe dokun” alternatifi yok.

Etkisi:

- Motor engelli kullanıcılar ve ekran okuyucu kullanıcıları ana pratik modunu
  tamamlayamaz.
- Web/masaüstünde touchpad ile kullanım gereksiz zorlaşır.

Öneri:

- Token'a dokunarak seçme, ardından hedef hücreye dokunarak bırakma akışı eklenmeli.
- Hücrelere seçili/doğru/yanlış semantic label ve state verilmelidir.
- Bu davranış için en az bir semantics/widget testi eklenmelidir.

### P1-2 — Arapça font platforma bağlı

`arabicTextStyle()` doğrudan `Times New Roman` kullanıyor; font asset olarak
paketlenmemiş.

Etkisi:

- Android, iOS ve Linux/web cihazlarında farklı fallback fontlar kullanılabilir.
- Harekeler, satır yüksekliği ve tablo ölçümleri platforma göre değişebilir.

Öneri:

- Lisansı uygun tek bir Arapça font asset'i eklenmeli.
- Android, iOS ve web üzerinde hareke/ligatür görsel kontrolü yapılmalı.

### P1-3 — Çok-fiilli ölçekleme mevcut generator ile doğru anlam üretemez

Generator Arapça biçimleri `meta.letters` ile kuruyor; fakat Türkçe anlamlar
dosya boyunca “yardım etmek” fiiline sabitlenmiş. `VerbMeta.meaningSummary`
okunuyor ama generator tarafından kullanılmıyor.

Etkisi:

- Aynı baba ait yeni bir fiil eklense Arapçası değişir, Türkçe anlamı “yardım”
  olarak kalır.
- Ölçeklenme dokümanındaki “yeni fiil eklemek veri eklemek olur” hedefi henüz
  gerçekleşmiş değildir.

Öneri:

- Önce ikinci gerçek fiille başarısız bir test yazılmalı.
- Türkçe çekim için yapılandırılmış fiil kökü/çekim bilgisi tanımlanmalı veya
  yeni fiiller açık anlam override'larıyla eklenmeli.
- Bu çözülmeden fiil seçici geliştirilmemeli.

### P1-4 — Çoktan seçmeli başlangıç kontrolü generator koşuluyla aynı değil

Ekrandaki `_canStart`, yalnız kategori ve çatı seçimini kontrol ediyor.
`PracticeQuestionGenerator` ise aynı kategoride en az iki benzersiz seçenek
bulamazsa exception fırlatıyor.

Etkisi:

- Gelecekte az formlu veya override tabanlı kategori eklendiğinde “Pratiğe Başla”
  aktif görünüp uygulama çökebilir.

Öneri:

- `_canStart` içinde mevcut `PracticeQuestionGenerator.canGenerateQuestion`
  kullanılmalı.
- Kullanıcıya “Bu filtrelerle yeterli soru yok” mesajı gösterilmelidir.

### P1-5 — Arapça cevap şıkları Arapça bileşen olarak çizilmiyor

Türkçeden Arapçaya sorularda seçenekler genel `AnswerButton` içinde varsayılan
LTR metin ve sistem fontuyla gösteriliyor. Soru kartında ayrıca yalnız büyük
bir Arapça soru işareti gösteriliyor.

Etkisi:

- Arapça seçeneklerin yönü, fontu ve hareke görünümü ana tablolardan farklıdır.
- Büyük `؟` bilgi taşımadan yer kaplar.

Öneri:

- Soru yönü modele açıkça eklenmeli.
- Arapça seçeneklerde RTL ve ortak Arapça text style kullanılmalı.
- Anlamdan Arapçaya soruda boş `؟` alanı kaldırılmalıdır.

### P1-6 — Alt sayfalarda başlık iki kez gösteriliyor

Çekimler ve Zamirler sayfaları hem `AppBar` hem `AppPage` başlığı kullanıyor.
Mevcut ekran görüntüsünde “Çekimler” iki kez görünmektedir.

Öneri:

- Tek başlık kaynağı bırakılmalı. En küçük değişiklik, bu iki sayfada `AppBar`
  başlığını veya `AppPage` başlığını kaldırmaktır.

### P1-7 — Veri yükleme hatası son kullanıcıya ham exception gösteriyor

`LoadErrorScreen`, `snapshot.error.toString()` değerini doğrudan gösteriyor ve
yeniden deneme sunmuyor.

Etkisi:

- Teknik dosya/parse bilgileri kullanıcıya sızar.
- Geçici yükleme sorunundan kurtulmak için uygulamayı kapatmak gerekir.

Öneri:

- Kullanıcı dostu sabit mesaj ve “Tekrar Dene” eklenmeli.
- Teknik ayrıntı yalnız debug logunda tutulmalıdır.

### P1-8 — Görsel kontrol script'i kırılgan ve yıkıcı

Script:

- yalnız 390 × 844 viewport kullanıyor,
- erişilebilir locator yerine sabit koordinatlarla ilerliyor,
- çalışmanın başında mevcut ekran görüntülerini siliyor,
- piksel/golden karşılaştırması yapmıyor; yalnız ekran görüntüsü üretip console
  hatalarını topluyor.

Etkisi:

- Küçük layout değişikliğinde yanlış ekrana dokunabilir.
- Yarıda kalan çalıştırma doküman ekran görüntülerini silebilir.
- “Visual check passed” görsel regresyon olmadığı anlamına gelmez.

Öneri:

- Önce temp dizine üretip başarı sonunda dosyaları taşımalı.
- Semantics/test ID tabanlı locator kullanılmalı.
- En az 360, 390 ve 430 px viewport kapsanmalı.

## 5. P2 — Orta Öncelikli Bulgular

### P2-1 — Analyzer ve format durumu temiz değil

- `DropdownButtonFormField.value` için iki deprecated kullanım var.
- `table_fill_practice_screen.dart` format kontrolünden geçmiyor.

Öneri:

- `initialValue` geçişi yapılmalı.
- CI format kontrolü eklenerek tekrar oluşması engellenmeli.

### P2-2 — Kullanılmayan runtime soru listesi üretiliyor

Repository her açılışta 339 `practiceQuestions` üretiyor; güncel çoktan seçmeli
ekran soruları doğrudan `forms` üzerinden anlık üretiyor.

Etkisi:

- Gereksiz model alanı, başlangıç işi ve test yükü oluşuyor.

Öneri:

- Geriye dönük uyumluluk gerekmiyorsa `AppData.practiceQuestions`,
  `PracticeQuestionGenerator.fromForms()` ve ilgili test kaldırılmalı.
- Uyumluluk gerekiyorsa kullanım amacı belgelenmelidir.

### P2-3 — Eski seed asset'i paketlenmeye devam ediyor

`assets/data/emsile_seed.json` aktif repository tarafından okunmuyor fakat
`pubspec.yaml` içinde asset olarak paketleniyor.

Öneri:

- Harici uyumluluk gerekmiyorsa asset kaydı ve dosya kaldırılmalı.
- Gerekiyorsa `legacy` amacı ve kaldırma tarihi belgelenmelidir.

### P2-4 — İş mantığı metinsel etiketlere bağlı

Örnekler:

- kırık çoğul: `pronounLabel.contains('Kırık')`
- Muhtelife dersi: `title == 'Emsile-i Muhtelife'`
- birinci şahıs satırı: label prefix kontrolü

Etkisi:

- Görünen metin değişikliği sessizce davranış değişikliğine dönüşebilir.

Öneri:

- Yalnız yeni veri şeması çalışması sırasında `formKind`, `lessonType` ve satır
  metadata alanları eklenmeli. Sırf refactor için bugün büyük model dönüşümü
  yapılmamalıdır.

### P2-5 — Seed validasyonu ilişkisel kuralları tam denetlemiyor

Eksik örnekler:

- manifest ID ile verb `meta.id` eşleşmesi
- manifest root/group ile verb metadata eşleşmesi
- benzersiz verb ID ve asset path
- `root == letters.join()`
- benzersiz Muhtelife type/sort order
- desteklenen generated profile ile lemma tutarlılığı

Öneri:

- Yeni fiil eklenmeden önce mevcut Node script'ine bu kontroller eklenmeli.

### P2-6 — Hakkında bağlantılarında başarısızlık geri bildirimi yok

`canLaunchUrl` false döner veya `launchUrl` başarısız olursa kullanıcı hiçbir
mesaj görmüyor.

Öneri:

- Sonuca göre kısa bir `SnackBar` gösterilmeli.
- URL launcher mock testi eklenmelidir.

### P2-7 — Tema renkleri özellik dosyalarında tekrar ediyor

Doğru/yanlış, sınır ve hücre renkleri çok sayıda widget içinde sabit kodlanmış.

Etkisi:

- Benzer fakat farklı tonlar oluşuyor.
- Karanlık tema veya kontrast düzenlemesi pahalılaşıyor.

Öneri:

- Tema extension veya birkaç ortak sabit, yalnız erişilebilirlik/tema çalışması
  yapılırken eklenmeli. Bugün ayrı bir tasarım sistemi paketi gereksizdir.

### P2-8 — Büyük değişiklik odakları

| Dosya | Satır |
|---|---:|
| `nasara_muttaride_generator.dart` | 1571 |
| `table_fill_practice_screen.dart` | 1284 |
| `widget_test.dart` | 2209 |
| `lessons_screen.dart` | 695 |

Satır sayısı tek başına hata değildir. Ancak bu dosyalarda değişiklik yaparken
regresyon ve merge riski yüksektir.

Öneri:

- Dosyaları yalnız ilgili özellik değişikliği geldiğinde doğal sınırlarından
  ayırın. Sırf küçültmek için refactor yapmayın.

### P2-9 — Ürün metni mevcut filtrelerle uyuşmuyor

Ana sayfa “konu ve şahısları seç” diyor; güncel çoktan seçmeli pratikte şahıs
filtresi yok.

Öneri:

- Metin “konu ve çatıları seç” şeklinde düzeltilmeli veya şahıs filtresi gerçekten
  ürün gereksinimiyse ayrıca tasarlanmalıdır.

### P2-10 — İçerik doğruluğu uzman onayı gerektiriyor

Testler mevcut Arapça/Türkçe verinin değişmediğini iyi koruyor; ancak dilbilgisel
doğruluğu bağımsız olarak ispatlamıyor.

Öneri:

- Yeni fiil/bab eklemelerinde Arapça sarf uzmanı onay listesi kullanılmalı.
- Kaynak sayfa/başlık referansları mümkünse veri kaydına eklenmelidir.

## 6. P3 — Düşük Öncelikli / Ölçüme Bağlı Konular

- Karanlık tema
- Arama, favori ve kişisel notlar
- Kalıcı skor, tekrar geçmişi ve spaced repetition
- Derslerden ilgili tablo/pratiğe deep link
- Uygulama içi sürüm/build bilgisi
- Changelog ve release notu
- Web ilk yükleme performansı: release dizini 36 MB, `main.dart.js` yaklaşık
  2,3 MB. Gerçek kullanıcı ölçümü olmadan renderer veya mimari optimizasyon
  yapılmamalıdır.
- `flutter_launcher_icons` 0.13.1 → 0.14.4 güncellemesi. Mevcut ikon üretimi
  çalışıyorsa acil değildir.

## 7. Test Açıkları

Yakın vadede en değerli testler:

1. CI içinde format/analyze/test/seed kontrolü
2. 360 ve 430 px otomatik viewport kontrolü
3. 200% text scale ve büyük erişilebilirlik fontu
4. Semantics ve klavye ile tablo doldurma
5. Matching modlarının üçünün ayrı testi
6. URL launcher başarı/başarısızlık testi
7. Veri yükleme retry ve kullanıcı dostu hata ekranı
8. İkinci fiil üzerinden generator anlam testi
9. Çoktan seçmelide yetersiz benzersiz seçenek filtresi
10. Android release ve iOS archive smoke build

Mevcut `%88,8` satır kapsamı güçlüdür. Hedefi keyfi olarak yükseltmek yerine,
eksik davranışları kapsayan testler eklenmelidir.

## 8. Önerilen Uygulama Sırası

### Faz 1 — Yayın güvenliği

1. Kalıcı Android/iOS kimlikleri
2. Release signing
3. Lisans birliği
4. Analitik kaldırma veya gizlilik politikası
5. CI kalite kapısı

### Faz 2 — Erişilebilirlik ve görünür kalite

1. Paketlenmiş Arapça font
2. Sürükle-bırak için dokunma/klavye alternatifi
3. Arapça çoktan seçmeli şıklar
4. Çift başlık ve hata geri bildirimleri
5. Text scale/semantics testleri

### Faz 3 — Veri büyümesi

1. İkinci fiille generator testi
2. Türkçe anlam modelinin genelleştirilmesi
3. İlişkisel seed validasyonu
4. Ancak bundan sonra fiil seçici ve yeni bab profilleri

## 9. Bilerek Önerilmeyenler

Şu an önerilmiyor:

- Riverpod/BLoC gibi yeni state-management bağımlılığı
- SQLite geçişi
- backend veya kullanıcı hesabı
- microservice/API katmanı
- dosyaları yalnız satır sayısı için parçalama
- yüzde hedefi uğruna anlamsız test ekleme

Mevcut ürün bunlara ihtiyaç duyacak ölçeğe henüz gelmemiştir.
