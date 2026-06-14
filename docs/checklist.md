# Emsile Flutter Geliştirme Checklist

Son güncelleme: `nasara` için fiil çekimli muttaride grupları PDF kurallarına göre rule-based üretildi ve çekim ekranında tüm tablolar erişilebilir hale getirildi.

Bu dosya yaşayan proje kaydıdır. Kapsam, veri modeli, ekranlar, testler veya tamamlanma durumu değiştiğinde aynı değişiklikle birlikte güncel tutulmalıdır.

## 1. Proje Hazırlığı

- [x] Flutter proje iskeletini oluştur.
- [x] Web hedefini çalıştır.
- [x] Android/iOS hedeflerinin ileride desteklenebileceğini doğrula.
- [x] Temel klasör yapısını oluştur: `lib/features`, `lib/shared`, `lib/data`.
- [x] Lint ve format ayarlarını ekle.
- [x] Playwright görsel kontrol altyapısını ekle.
- [x] İlk commit'i at.

## 2. Tasarım Sistemi

- [x] İlk renk paletini belirle.
- [x] Tema dosyasını uygulama içinde oluştur.
- [x] Kart, segment kontrol, alt navigasyon ve cevap butonu stillerini standartlaştır.
- [x] Mobil öncelikli spacing değerlerini ilk MVP ekranlarında uygula.
- [ ] Türkçe metin fontunu netleştir.
- [ ] Arapça metin fontunu netleştir.
- [x] Tema ve ortak widgetları `lib/shared` altına ayır.

## 3. Veri Hazırlığı

- [x] Yerel PDF kaynağını doğrula: `docs/Emsile_Ders_Notu_Zafer_ESEN_01.01.2025.pdf`.
- [x] PDF kaynak bilgilerini uygulama içinde kullanılacak şekilde kaydet.
- [x] İlk örnek fiili seç: `نصر`.
- [x] İlk ders veri modelini oluştur.
- [x] İlk çekim veri modelini oluştur.
- [x] İlk alıştırma veri modelini oluştur.
- [x] Veriyi koddan çıkarıp JSON asset'e taşı: `assets/data/emsile_seed.json`.
- [x] Fiil-i mâzi malum çekimlerini yapılandır.
- [x] Fiil-i mâzi meçhul çekimlerini yapılandır.
- [x] Fiil-i muzâri malum çekimlerini yapılandır.
- [x] Fiil-i muzâri meçhul çekimlerini yapılandır.
- [x] Her form için Türkçe anlam alanı ekle.
- [x] `person`, `number`, `gender` alanlarını seed veri modeline ekle.
- [x] Alıştırma sorularını formlardan türetilecek şekilde modelle.
- [x] Veri kaynağını `catalog + verbs` yapısına evriltmeye başla.
- [x] İlk fiili ayrı verb dosyasına taşı: `assets/data/verbs/nasara.json`.
- [x] İlk generated `conjugationSource` profilini ekle.
- [x] `nasara` için `muttarideForms` verisini rule-based üretime taşı.
- [x] `nasara` için muhtelife satırlarını PDF'teki sıra ve eşleşmelere göre tamamla.
- [x] `nasara` için fiil çekimli tüm muttaride gruplarını generate et.
- [ ] Şahıs zamirleri veri modelini ayrıca oluştur.
- [x] JSON seed veri validasyon script'i ekle.
- [x] Catalog/verb veri validasyon script'ini yeni yapıya göre güncelle.
- [ ] PDF'ten taşınacak sonraki tabloları elle kontrol et.

## 4. Navigasyon

- [x] Alt navigasyon yapısını kur.
- [x] Ana Sayfa rotasını oluştur.
- [x] Dersler rotasını oluştur.
- [x] Çekim Tablosu rotasını oluştur.
- [x] Alıştırma rotasını oluştur.
- [x] Kaynak rotasını oluştur.
- [x] Uygulama kabuğunu `lib/app` altına taşı.

## 5. Ana Sayfa

- [x] Uygulama başlığını ve kısa durum alanını tasarla.
- [x] Kaldığın yer kartını oluştur.
- [x] Günlük çalışma önerisi alanını ekle.
- [x] Hızlı tekrar akışını temsil eden kartı ekle.
- [x] Mobil ekranlarda taşma ve sıkışma testi yap.
- [ ] Gerçek ilerleme verisi bağla.

## 6. Dersler

- [x] Ders listesi ekranını oluştur.
- [x] Ders kartı bileşenini oluştur.
- [x] Ders detay ekranını oluştur.
- [x] Ders detayında Arapça örnek ve Türkçe açıklama göster.
- [x] Muhtelife ders detayında PDF'e yakın iki sütunlu tabloyu göster.
- [ ] Ders detayından çekim tablosuna hedefli geçiş ekle.
- [ ] Ders detayından alıştırmaya hedefli geçiş ekle.

## 7. Çekim Tablosu

- [x] Kategori seçici oluştur: Mâzi, Muzâri.
- [x] Bina seçici oluştur: Malum, Meçhul.
- [x] Şahıs seçici oluştur.
- [x] Kategori/bina geçişlerinde seçili şahsı koru.
- [x] Seçime göre Arapça formu büyük göster.
- [x] Türkçe anlam ve kısa kural notu göster.
- [x] Tüm formları listeleyen detay görünümü ekle.
- [x] Tüm formlar tablosundan da aktif şahıs seçilebilsin.
- [x] Şahıs seçimini PDF düzenine yakın tablo görünümüne taşı.
- [x] Tüm formları PDF düzenine yakın tablo görünümüne taşı.
- [x] Üst seçim alanını sabitle, tabloları ayrı scroll alanında göster.
- [x] Nefy, cahd, emir ve nehy fiil gruplarını çekim ekranına ekle.
- [x] Tüm fiil muttaride tablolarını tek ekrandan erişilebilir yap.
- [x] Sağdan sola yazım davranışını Playwright screenshot ile test et.
- [ ] İsim ve masdar türev tablolarını çekim ekranına ayrı bölüm olarak ekle.
- [ ] Sayı/cinsiyet seçiciyi ayrı filtre olarak modelle.
- [ ] Boş veri durumlarını tasarla.

## 8. Alıştırma

- [ ] Kart çevirme alıştırmasını oluştur.
- [x] Çoktan seçmeli alıştırmayı oluştur.
- [x] Cevap kontrol mekanizmasını ekle.
- [x] Doğru/yanlış geri bildirimlerini tasarla.
- [x] Sonraki soru akışını ekle.
- [x] İlk alıştırma veri setini `نصر` üzerinden otomatik üret.
- [ ] Boşluk doldurma alıştırmasını ekle.
- [ ] Eşleştirme alıştırmasını ekle.
- [ ] Skor/ilerleme modelini ekle.

## 9. Kaynak Ekranı

- [x] Zafer ESEN kaynak bilgisini göster.
- [x] Belge güncelleme tarihini göster: 01.01.2025.
- [x] Kullanım notunu kısa ve açık şekilde göster.
- [x] Yerel PDF yolunu göster.
- [ ] Kaynak bağlantısını tıklanabilir hale getir.
- [ ] PDF açma veya dış bağlantı alanı ekle.

## 10. Mobil/Web Kalite Kontrol

- [ ] 360px genişlikte ekran testi yap.
- [x] 390px genişlikte ekran testi yap.
- [ ] 430px genişlikte ekran testi yap.
- [x] Masaüstü web önizlemede mobil merkezli görünümü doğrula.
- [x] Arapça metinlerin kritik ekranlarda taşmadığını doğrula.
- [x] Buton metinlerinin kritik ekranlarda sığdığını doğrula.
- [x] Alt navigasyonun küçük ekranlarda kullanılabilir olduğunu doğrula.
- [x] Playwright screenshot çıktıları üret: `docs/screenshots`.

## 11. Teknik Kalite

- [x] `dart format` çalıştır.
- [x] `flutter analyze` çalıştır.
- [x] `flutter test` çalıştır.
- [x] `flutter build web` çalıştır.
- [x] `npm run validate-seed` çalıştır.
- [x] `npm run visual-check` çalıştır.
- [x] Seed veri alanları için temel validasyon ekle.
- [x] Seed veri alanlarında `person/number/gender` doğrulaması ekle.
- [ ] Veri modelleri için ayrı Dart unit test ekle.
- [x] Pratik soru üreticisi için ayrı Dart unit test ekle.
- [x] Çekim ve pratik ekranları için widget test ekle.
- [x] Seçili sekme ekran eşleşmeleri için widget test ekle.
- [x] Pratik cevap etkileşimleri için widget test ekle.
- [ ] Repository hata durumları için test ekle.

## 12. MVP Tamamlanma Kriterleri

- [x] Uygulama webde açılıyor.
- [x] Ana navigasyon çalışıyor.
- [x] En az bir ders okunabiliyor.
- [x] `نصر` için mâzi ve muzâri çekimleri görüntülenebiliyor.
- [x] En az bir alıştırma tamamlanabiliyor.
- [x] Kaynak bilgisi görünür.
- [x] Mobil görünümde kritik taşma yok.

## 13. Sıradaki Mantıklı İşler

- [x] Kod organizasyonunu `lib/data`, `lib/features`, `lib/shared` klasörlerine böl.
- [x] JSON veri şemasını büyütmeden önce temel alan adlarını sabitle.
- [x] Scalable veri tasarım dokümanını ekle.
- [ ] PDF'teki şahıs zamirleri tablosunu JSON'a taşı.
- [x] Fiil-i mâzi ve muzâri için 14 şahıslık tam tabloyu tamamla.
- [ ] `daraba`, `fataha` gibi yeni bablar için generated conjugation profilleri ekle.
- [ ] Muhtelife explorer için ders detayından ayrı, filtrelenebilir bağımsız ekran ekle.
- [ ] Fiil listesi/katalog ekranını ekle.
- [x] Nefy, cahd, emir ve nehy fiil kategorileri için aynı tablo genişletmesini yap.
- [ ] İsim/masdar türevleri için sayı-cinsiyet tablolarını ayrı muttaride bölümü olarak ekle.
- [ ] Üretilen pratik sorularına zorluk/karıştırma stratejisi ekle.
- [ ] Playwright testini 360px ve 430px viewportlarla genişlet.
