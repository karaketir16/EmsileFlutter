# Emsile Flutter Tasarım Dokümanı

## 1. Ürün Vizyonu

Emsile Flutter, Arapça sarf konularını okunabilir derslere, gezilebilir tablolara ve aktif alıştırmalara dönüştürür.

Kaynak içerik mobil kullanım için yeniden yapılandırılır; açıklamalar, çekimler ve pratikler birbirini tamamlar.

## 2. Hedef Kullanıcı ve Platform

- Arapça sarf öğrenen başlangıç ve orta seviye öğrenciler
- Emsile metnini ders, kurs veya bireysel çalışmada takip edenler
- Öncelikli arayüz: mobil
- Mevcut geliştirme ve dağıtım hedefi: Flutter Web
- Kod tabanı Android ve iOS hedefleriyle uyumludur

Web görünümü `AppPage` içindeki `maxWidth: 520` sınırıyla mobil okuma genişliğini korur.

## 3. Tasarım İlkeleri

- Arapça metin ana bilgidir; Türkçe metin açıklayıcıdır.
- Geleneksel sıra ve terminoloji korunur, arayüz mobil kullanım için sadeleştirilir.
- Tablolar aynı görsel dili ve aynı `Çoğul / İkil / Tekil` sırasını kullanır.
- Birinci şahısta Arapçada ikil çekim bulunmadığı için ikil ve çoğul alanı birleşik `Biz` hücresi olarak gösterilir.
- Doğru/yanlış durumları yalnız renkle değil, tik ve X simgeleriyle de anlatılır.
- Karşılığı olmayan tablo hücreleri koyu ve kapalı gösterilir.

## 4. Ana Navigasyon

Alt navigasyon beş bölümdür:

1. Ana
2. Dersler
3. Tablo
4. Pratik
5. Hakkında

`AppShell`, ekranları `IndexedStack` içinde tuttuğu için sekmeler arasında geçişte ekran state'i korunur.

## 5. Ekranlar

### 5.1 Ana

Ana sayfa uygulamanın ne işe yaradığını ve bölümlerin nasıl kullanılacağını açıklar:

- Dersler: konuyu ve açıklamaları oku
- Tablo: çekimleri karşılaştır
- Pratik: çoktan seçmeli veya tablo doldurma alıştırması yap

İlerleme, günlük hedef veya kullanıcı hesabı henüz yoktur.

### 5.2 Dersler

Dersler ekranında üç ana başlık bulunur:

- Emsile-i Muhtelife
- Emsile-i Muttaride
- Şahıs Zamirleri

Muhtelife:

- Emsile sırasındaki kalıplar ve anlamları
- Konuyla ilgili açıklama notları

Muttaride:

- Mevcut tüm fiil ve isim kategorileri
- Kategori açıklaması
- Tablo menüsüyle aynı fiil veya isim tablosu
- Fiillerde malum ve meçhul ayrımı

Şahıs Zamirleri:

- Ayrı zamirler
- Bitişik zamirler
- Bitişik zamirlerin iyelik veya mef‘ûl görevine ilişkin kısa not

### 5.3 Tablo

Tablo menüsü iki alt başlığa ayrılır:

- Çekimler
- Zamirler

Çekimler ekranında:

- Kategori seçilir.
- Fiillerde malum/meçhul seçilir.
- Şahıs veya isim hücresine dokunularak form seçilir.
- Seçili formun Arapçası, anlamı ve kuralı gösterilir.
- Tüm tablolar aynı sayfadan açılabilir.

Fiil tabloları sabit şemayı kullanır:

- Sütunlar: Çoğul, İkil, Tekil
- Satırlar: 3. şahıs müzekker, 3. şahıs müennes, 2. şahıs müzekker, 2. şahıs müennes, 1. şahıs ortak
- 1. şahısta `Biz` hücresi çoğul ve ikil sütunlarını birleştirir

İsim tabloları sayı ve varsa cinsiyete göre düzenlenir. Kırık çoğullar tablonun altında ayrıca gösterilir.

### 5.4 Pratik

Pratik ekranı iki moda ayrılır.

#### Çoktan Seçmeli

- Kategori, çatı, fiil şahısları ve isim özellikleri filtrelenebilir.
- Kategori seçimi iki sütunlu kompakt kartlarla yapılır.
- En az beş eşleşen form gerekir.
- İki soru tipi vardır:
  - Arapça sîgadan Türkçe anlamı bulma
  - Türkçe anlamdan Arapça sîgayı bulma
- Şıklar en fazla beş seçenektir ve karıştırılır.
- Yanlış seçimde yalnız seçilen şık kırmızı/X olur; doğru cevap açıklanmaz.
- Doğru seçimde seçilen şık yeşil/tik olur.
- Sonraki Soru ile yeni rastgele soru üretilir.

#### Tabloyu Doldur

- Fiil veya isim kategorisi seçilir.
- Fiillerde malum/meçhul seçilir.
- İsimlerde kırık çoğullar isteğe bağlı olarak dahil edilir.
- Sîgalar üstte karışık sırada ve üç satırlık sabit havuzda gösterilir.
- Kullanıcı sîgaları tablo hücrelerine sürükler.
- Doğru yerleşim yeşil/tik, yanlış yerleşim kırmızı/X olur.
- Yanlış yerleşim yeniden sürüklenebilir; başka cevap bırakılırsa eski cevap havuza döner.
- Geçersiz alana bırakılan yanlış cevap havuza geri döner.
- Aynı Arapça yazılışa sahip çekimler eşdeğer kabul edilir.
- Kırık çoğullar, aynı kategorideki herhangi bir kırık çoğul alanına bırakılabilir.
- Yalnız bütün cevaplar doğruysa “Tablo tamamlandı” gösterilir.

### 5.5 Hakkında

- İçerik kaynağına ilişkin atıf gösterilir.
- Kaynak bağlantısı dış tarayıcıda açılır.

## 6. Görsel Dil

- Material 3
- Kırık beyaz uygulama zemini
- Derin yeşil ana vurgu
- Beyaz, ince çerçeveli kartlar
- Yeşil/tik: doğru
- Kırmızı/X: yanlış
- Mavi-gri: sürükleme hedefi
- Koyu gri ve blok simgesi: kullanılamayan hücre

## 7. Mevcut Kapsam

- Tek fiil kataloğu: `نصر`
- 24 `FormCategory`
- Generated fiil, isim, masdar ve taaccüb çekimleri
- Muhtelife ve zamir verileri
- Ders, tablo ve iki pratik modu

Henüz yok:

- Çok fiilli katalog
- Kalıcı ilerleme veya skor
- Kullanıcı hesabı
- Sesli okuma
- Arama, favori ve kişisel notlar

## 8. Başarı Kriterleri

- Kullanıcı ayrı bir belge açmadan bir konuyu okuyabilir.
- Bir sîgayı şahıs, sayı, cinsiyet ve çatı bağlamında bulabilir.
- Derslerde gördüğü tabloyu aynı görsel yapıyla pratikte doldurabilir.
- Arapça metin ve harekeler mobil ekranda okunabilir kalır.
- Yanlış ve doğru durumları renk görmeden de ayırt edilebilir.
