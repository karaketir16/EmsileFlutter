# Emsile Flutter

Mobil öncelikli Arapça sarf çalışma uygulaması.

## Özellikler

- Muhtelife, Muttaride ve Şahıs Zamirleri dersleri
- Fiil, isim, masdar ve taaccüb kategorileri için çekim tabloları
- Ayrı ve bitişik zamir tabloları
- Filtrelenebilir çoktan seçmeli pratik
- Fiil ve isim tabloları için sürükle-bırak “Tabloyu Doldur” alıştırması
- Malum/meçhul, şahıs, sayı, cinsiyet ve kırık çoğul desteği

## Veri

Uygulama yerel JSON verisini kullanır:

```text
assets/data/catalog.json
assets/data/verbs/nasara.json
```

`نصر` fiilinin düzenli çekimleri çalışma anında `MuttarideGenerator` tarafından üretilir.

## Çalıştırma

```bash
flutter pub get
flutter run -d chrome
```

Farklı bir tarayıcı kullanmak için:

```bash
flutter run -d web-server
```

Terminalde gösterilen yerel adresi istediğiniz tarayıcıda açabilirsiniz.

## Kontroller

```bash
dart format lib test
flutter analyze
flutter test
flutter build web
npm run validate-seed
```

## Belgeler

- [Tasarım dokümanı](docs/design-document.md)
- [Düşük seviye tasarım](docs/low-level-design.md)
- [Test stratejisi](docs/testing.md)
- [Geliştirme checklist'i](docs/checklist.md)
- [Ölçeklenme planı](docs/scaling-plan.md)

Uygulama hazırlanırken Zafer ESEN tarafından hazırlanan Emsile Ders Notu'ndan faydalanılmıştır.
