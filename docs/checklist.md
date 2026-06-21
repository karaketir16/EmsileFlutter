# Emsile Flutter Geliştirme Checklist

Son durum: `نصر` fiili üzerinden dersler, çekim/zamir tabloları, çoktan seçmeli pratik ve fiil/isim tablo doldurma alıştırması çalışıyor.

## Tamamlananlar

### Altyapı

- [x] Flutter proje ve Material 3 tema
- [x] Feature/data/shared klasör ayrımı
- [x] Mobil merkezli `AppPage`
- [x] Alt navigasyon ve state koruyan `IndexedStack`
- [x] Katalog + fiil dosyası + runtime generator veri akışı
- [x] Web build ve otomatik test altyapısı

### Veri

- [x] Kaynak ders içeriği doğrulandı
- [x] `catalog.json`
- [x] `verbs/nasara.json`
- [x] Muhtelife satırları
- [x] Ayrı ve bitişik zamirler
- [x] 339 runtime form
- [x] 24 form kategorisi
- [x] Fiil, isim, masdar ve taaccüb üretimi
- [x] Seed/katalog validasyon script'i

### Ana Sayfa

- [x] Uygulamayı tanıtan karşılama
- [x] Dersler, Tablo ve Pratik kullanım açıklamaları

### Dersler

- [x] Emsile-i Muhtelife
- [x] Muhtelife açıklamaları
- [x] Emsile-i Muttaride kategori listesi
- [x] Muttaride açıklamaları
- [x] Tablo menüsüyle ortak fiil/isim tabloları
- [x] Şahıs Zamirleri dersi
- [x] Ayrı ve bitişik zamir tabloları

### Tablo

- [x] Çekimler ve Zamirler ana menüsü
- [x] Fiil kategori ve çatı seçimi
- [x] Şahıs seçimi ve sonuç kartı
- [x] İsim tabloları
- [x] Kırık çoğullar
- [x] Tüm tablolar görünümü
- [x] Karşılığı olmayan koyu hücreler
- [x] Birinci şahıs `Biz` birleşik hücresi
- [x] Ayrı ve bitişik zamirler

### Çoktan Seçmeli Pratik

- [x] İki sütunlu kategori seçimi
- [x] Çatı, şahıs ve isim filtreleri
- [x] Minimum beş form kontrolü
- [x] Arapçadan Türkçeye soru
- [x] Türkçeden Arapçaya soru
- [x] En fazla beş karışık şık
- [x] Doğru için yeşil/tik
- [x] Yanlış için kırmızı/X
- [x] Yanlışta doğru cevabı gizleme
- [x] Sonraki soru

### Tabloyu Doldur

- [x] Fiil kategori ve çatı seçimi
- [x] İsim kategorileri
- [x] Kırık çoğulları dahil etme anahtarı
- [x] Rastgele karıştırılmış token havuzu
- [x] Üç satırlık sabit havuz yüksekliği
- [x] Sabit tam havuz genişliği
- [x] Doğru/yanlış renk ve simgeleri
- [x] Yanlış cevabı yeniden sürükleme
- [x] Yanlış dolu hücrede cevap değiştirme
- [x] Geçersiz bırakmada havuza dönüş
- [x] Aynı yazılışlı çekimleri eşdeğer kabul etme
- [x] Kırık çoğulları kendi aralarında eşdeğer kabul etme
- [x] Yalnız bütün cevaplar doğruysa tamamlanma
- [x] Geri ve konu değiştirme akışı

### Hakkında

- [x] Kaynak atfı
- [x] Blog bağlantısı
- [x] “Faydalanılmıştır” ifadesi

### Kalite

- [ ] `dart format --output=none --set-exit-if-changed lib test` temiz
- [ ] `flutter analyze` temiz (2 deprecated API bilgisi var)
- [x] `flutter test`
- [x] 53 otomatik test
- [x] `%88,8` satır kapsamı
- [x] Repository asset bundle dependency injection
- [x] Domain modellerinin veri katmanından ayrılması
- [x] Çekim tablolarının ekran dosyasından bağımsız widget'lara ayrılması
- [x] Çoktan seçmeli pratiğin filtre/state/cevap bileşenlerine ayrılması
- [x] `flutter build web`
- [x] Playwright görsel kontrol altyapısı

## Sıradaki İşler

- [x] İsim Tabloyu Doldur için doğrudan widget testleri
- [x] Kırık çoğul anahtarı ve eşdeğer hedef testleri
- [x] Birinci şahıs birleşik hücre testi
- [x] Eşleştirme alıştırması (matching practice) testleri
- [x] 360 px ve 430 px manuel viewport kontrolü
- [ ] 360 px ve 430 px otomatik viewport testleri
- [x] Güncel ekran görüntülerini yeniden üretme
- [ ] Özel ve platformlar arası doğrulanmış Arapça fontu
- [x] Repository hata testleri
- [ ] Çok fiilli katalog ve fiil seçici
- [ ] Yeni generated bab profilleri
- [ ] Kalıcı skor ve tekrar geçmişi
- [ ] Derslerden ilgili tablo/pratiğe doğrudan geçiş

## Yayın Öncesi Engeller

- [ ] Android ve iOS production uygulama kimlikleri
- [ ] Android release signing
- [ ] CI içinde format, analyze, test ve seed kalite kapısı
- [ ] GPL/ISC lisans metadata birliği
- [ ] Cloudflare Analytics için gizlilik politikası veya analitiğin kaldırılması
- [ ] Tablo doldurma için erişilebilir dokunma/klavye alternatifi

Ayrıntılar: [Uygulama denetim raporu](audit-report.md)
