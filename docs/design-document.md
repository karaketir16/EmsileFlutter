# Emsile Flutter Tasarım Dokümanı

## 1. Ürün Vizyonu

Bu uygulama, Zafer ESEN'in "Emsile Ders Notu" içeriğini mobil odaklı, çalışılabilir ve tekrar edilebilir bir öğrenme deneyimine dönüştürmeyi amaçlar.

Hedef, PDF'i sadece okunur hale getirmek değil; emsile tablolarını, şahıs zamirlerini, fiil çekimlerini ve açıklamaları kullanıcının aktif olarak öğrenebileceği bir yapıya taşımaktır.

Mevcut uygulama durumu bu vizyonun ilk çalışan sürümünü karşılıyor: tek fiil (`nasara`) üzerinden dersler, çekim tabloları, muhtelife görünümü ve filtrelenebilir çoktan seçmeli pratik akışı birlikte çalışıyor.

## 2. Hedef Platform

- Öncelik: Mobil
- Geliştirme ortamı: Flutter Web
- Sonraki hedefler: Android ve iOS

Web geliştirme sırasında tüm ekranlar mobil genişlikte tasarlanmalı ve masaüstünde de mobil önizleme mantığı korunmalıdır.

## 3. Hedef Kullanıcı

- Arapça sarf öğrenen başlangıç ve orta seviye öğrenciler
- Emsile metnini takip eden medrese, kurs veya bireysel çalışma kullanıcıları
- Tabloları ezberlemek yerine örnek, tekrar ve alıştırma ile çalışmak isteyen kullanıcılar

## 4. Tasarım İlkeleri

- PDF görünümünü birebir kopyalamak yerine, içeriği mobilde okunabilir küçük parçalara böl.
- Arapça metni ana bilgi olarak konumlandır; Türkçe açıklama destekleyici olmalı.
- Tabloları mobilde yatay sıkıştırmak yerine kartlara, filtrelere ve detay ekranlarına dönüştür.
- Kullanıcıyı her ekranda bir sonraki çalışılabilir adıma yönlendir.
- Görsel dil sade, ciddi ve öğrenme odaklı olmalı.
- Arayüz yoğun ama boğucu olmamalı; özellikle Arapça metin için ferah satır aralıkları kullanılmalı.

## 5. Önerilen Ürün Modeli

Önerilen yaklaşım: İnteraktif sarf tablosu + hafif alıştırma sistemi.

Bu modelde uygulama dört ana bölümden oluşur:

1. Ana Sayfa
2. Dersler
3. Çekim Tablosu
4. Alıştırma

PDF kaynak bölümü ayrıca tutulur.

## 6. Ana Ekranlar

### 6.1 Ana Sayfa

Amaç: Kullanıcıya kaldığı yerden devam etme ve hızlı tekrar imkanı vermek.

İçerik:

- Günün kısa çalışma önerisi
- Son çalışılan konu
- Hızlı tekrar butonu
- Öğrenme ilerlemesi
- En son açılan çekim tablosu

Beklenen bileşenler:

- Üst başlık alanı
- İlerleme göstergesi
- Devam et aksiyonu
- Küçük çalışma kartları

### 6.2 Dersler

Amaç: PDF'teki konu akışını mobil ders listesine dönüştürmek.

Örnek konu başlıkları:

- Emsile-i Muhtelife
- Şahıs Zamirleri
- Fiil-i Mâzi
- Fiil-i Muzâri
- Masdar
- İsm-i Fâil
- İsm-i Mef'ul
- Nefy-i Hâl
- Nefy-i İstikbâl
- Cahd-ı Mutlak
- Cahd-ı Mustağrak
- Emir ve Nehiy

Ders ekranında:

- Kısa açıklama
- Örnek Arapça form
- Türkçe anlam
- İlgili çekim tablosuna geçiş
- İlgili alıştırmalara geçiş

### 6.3 Çekim Tablosu

Amaç: PDF'teki geniş tabloları mobilde gezilebilir hale getirmek.

Temel etkileşim:

- Kullanıcı kök/örnek fiil seçer: örneğin `نصر`
- Kullanıcı kategori seçer: Mâzi, Muzâri, Nefy, Emir, İsimler
- Kullanıcı bina seçer: Malum, Meçhul
- Kullanıcı şahıs seçer: 1., 2., 3. şahıs
- Kullanıcı sayı/cinsiyet seçer: müfred, tesniye, cemi; müzekker, müennes

Çıktı:

- Büyük Arapça form
- Latin/Türkçe açıklama
- Kısa kural notu
- Aynı satırdaki diğer şahıslara geçiş

Mobil tasarım:

- Üstte segment/tab kontrolü
- Ortada büyük Arapça sonuç kartı
- Altta şahıs seçici
- Detayda tüm çekim listesi

### 6.4 Alıştırma

Amaç: Pasif okumayı aktif hatırlamaya dönüştürmek.

Mevcut MVP alıştırması:

- Çoktan seçmeli: verilen şahsa veya anlama göre doğru çekimi seç

Planlanan sonraki alıştırmalar:

- Kart çevirme: Arapça form -> anlam
- Boşluk doldurma: eksik harf veya ek tamamla
- Eşleştirme: şahıs zamiri -> çekim formu

Alıştırma ekranında:

- Başlamadan önce kategori/çatı/şahıs-zamir filtreleri
- Kısa soru
- Büyük Arapça metin
- Cevap seçenekleri
- Sonuç geri bildirimi
- Bir sonraki soru

### 6.5 Kaynak ve PDF

Amaç: Orijinal kaynağı ve kullanım şartlarını açıkça göstermek.

İçerik:

- Kaynak: Zafer ESEN, Emsile Ders Notu
- Güncelleme tarihi: 01.01.2025
- Yerel PDF: `docs/Emsile_Ders_Notu_Zafer_ESEN_01.01.2025.pdf`
- Kaynak bağlantısı ve iletişim bilgisi
- PDF'i uygulama içinde açma veya dışarıda görüntüleme seçeneği

Not: İçerik uygulamaya dönüştürülürken kaynak gösterimi korunmalı, ticari kullanım veya içerik değişikliği planlanıyorsa izin konusu ayrıca netleştirilmelidir.

## 7. Navigasyon Modeli

Alt navigasyon önerisi:

- Ana Sayfa
- Dersler
- Tablo
- Alıştırma
- Kaynak

Mobilde bu yapı hızlı erişim sağlar. Web geliştirme sırasında da aynı alt navigasyon korunabilir.

## 8. Görsel Dil

Genel ton:

- Sade
- Okunaklı
- Ders/defter hissi veren
- Modern ama gösterişsiz

Renk önerisi:

- Arka plan: kırık beyaz veya çok açık gri
- Ana vurgu: derin yeşil veya lacivert
- İkincil vurgu: altın/sarımsı küçük detaylar
- Uyarı/geri bildirim: yeşil, kırmızı, amber

Tipografi:

- Türkçe metin için modern sans-serif
- Arapça metin için okunaklı, harekeleri iyi gösteren font
- Arapça formlar kart içinde büyük ve sağdan sola hizalı olmalı

## 9. Veri Modeli Taslağı

Mevcut sürümde içerikler yerel JSON asset'lerinde tutulur ve repository tarafından runtime modele dönüştürülür.

Not: Çok fiilli ve tüm `Emsile-i Muhtelife` hedefi için önerilen ölçeklenebilir veri mimarisi ayrı olarak [docs/scaling-plan.md](/Users/karaketir16/Documents/EmsileFlutter/docs/scaling-plan.md) içinde tutulur. Bu dosya ürün/tasarım bakışını, `scaling-plan.md` ise veri ve genişleme mimarisini detaylandırır.

UI'nin beslendiği runtime yapı örneği:

```json
{
  "id": "fiil_mazi_malum",
  "title": "Fiil-i Mâzi Bina-i Malum",
  "category": "mazi",
  "voice": "malum",
  "description": "Geçmiş zamanda yapılan fiili ifade eder.",
  "forms": [
    {
      "person": "third",
      "number": "singular",
      "gender": "masculine",
      "arabic": "نَصَرَ",
      "meaning": "Yardım etti."
    }
  ]
}
```

## 10. MVP Kapsamı

Tamamlanan ilk sürüm kapsamı:

- Mobil odaklı Flutter proje iskeleti
- Ana sayfa
- Ders listesi ve ders detay ekranı
- Muhtelife tablosu görünümü
- İnteraktif çekim tablosu
- Filtrelenebilir çoktan seçmeli alıştırma
- Kaynak ekranı
- Örnek veri seti: `نصر` fiili üzerinden fiil, isim ve taaccüb formları

MVP dışında bırakılacaklar:

- Kullanıcı hesabı
- Bulut senkronizasyonu
- Sesli okuma
- Tam PDF veri çıkarımı
- Gelişmiş istatistik ve seviye sistemi
- Çok fiilli katalog gezgini

## 11. Riskler ve Dikkat Edilecekler

- Arapça metinlerde sağdan sola yazım ve hareke gösterimi dikkatle test edilmeli.
- PDF'ten çıkarılan metin doğrudan güvenilir veri gibi kullanılmamalı; elle kontrol edilerek yapılandırılmalı.
- Tablolar mobilde okunmaz hale gelmemeli; kart ve filtre yaklaşımı korunmalı.
- Kaynak gösterimi uygulama içinde görünür olmalı.
- İçerik lisansı ve izin şartları uygulamanın yayınlanma planına göre tekrar değerlendirilmeli.

## 12. Başarı Kriterleri

- Kullanıcı bir çekimi PDF açmadan bulabiliyor.
- Kullanıcı bir konuyu okuyup hemen o konuyla ilgili alıştırma çözebiliyor.
- Arapça metinler mobil ekranda net ve hatasız görünüyor.
- Uygulama ilk açılışta ne yapılacağını açıkça hissettiriyor.
- Tasarım mobilde tek elle kullanılabilir kalıyor.
