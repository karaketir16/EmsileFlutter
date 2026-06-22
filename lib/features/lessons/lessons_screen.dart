import 'package:emsile_flutter/data/models.dart';
import 'package:emsile_flutter/features/conjugation/conjugation_screen.dart';
import 'package:emsile_flutter/features/ibare/bina_study_screen.dart';
import 'package:emsile_flutter/features/practice/matching_practice_screen.dart';
import 'package:emsile_flutter/shared/widgets/app_page.dart';
import 'package:emsile_flutter/shared/widgets/info_panel.dart';
import 'package:flutter/material.dart';

class LessonsScreen extends StatelessWidget {
  const LessonsScreen({required this.data, super.key});

  final AppData data;

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Dersler',
      child: Column(
        children: [
          _MainLessonTile(
            title: 'İbare Çalışması',
            subtitle: 'Metnü’l-Binâ’yı kırık mana ve kelime tahliliyle çalış',
            icon: Icons.touch_app_outlined,
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const BinaStudyScreen())),
          ),
          const SizedBox(height: 10),
          _MainLessonTile(
            title: 'Emsile-i Muhtelife',
            subtitle: 'Aynı kökten türeyen farklı kalıplar ve anlamları',
            icon: Icons.account_tree_outlined,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => _MuhtelifeLessonScreen(data: data),
              ),
            ),
          ),
          const SizedBox(height: 10),
          _MainLessonTile(
            title: 'Emsile-i Muttaride',
            subtitle: 'Kalıpların şahıslara ve sayılara göre çekimleri',
            icon: Icons.table_chart_outlined,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => _MuttarideLessonScreen(data: data),
              ),
            ),
          ),
          const SizedBox(height: 10),
          _MainLessonTile(
            title: 'Şahıs Zamirleri',
            subtitle: 'Ayrı ve bitişik zamirlerin çekim tablosu',
            icon: Icons.badge_outlined,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => _PronounsLessonScreen(pronouns: data.pronouns),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PronounsLessonScreen extends StatefulWidget {
  const _PronounsLessonScreen({required this.pronouns});

  final List<PronounEntry> pronouns;

  @override
  State<_PronounsLessonScreen> createState() => _PronounsLessonScreenState();
}

class _PronounsLessonScreenState extends State<_PronounsLessonScreen> {
  PronounKind _kind = PronounKind.independent;

  @override
  Widget build(BuildContext context) {
    return _LessonScaffold(
      title: 'Şahıs Zamirleri',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoPanel(
            title: 'Zamirler',
            body: _kind == PronounKind.independent
                ? 'Ayrı zamirler tek başına kullanılabilir ve fiilin hangi şahsa ait olduğunu gösterir.'
                : 'Bitişik zamirler kelimenin sonuna eklenir; yerine göre iyelik veya mef‘ûl anlamı taşır.',
          ),
          const SizedBox(height: 16),
          PronounsPanel(
            pronouns: widget.pronouns,
            selectedKind: _kind,
            onKindChanged: (kind) => setState(() => _kind = kind),
          ),
        ],
      ),
    );
  }
}

/// Eski doğrudan ders açma akışıyla uyumluluk için korunur.
class LessonDetailScreen extends StatelessWidget {
  const LessonDetailScreen({
    required this.lesson,
    required this.data,
    super.key,
  });

  final Lesson lesson;
  final AppData data;

  @override
  Widget build(BuildContext context) {
    if (lesson.isMuhtelife) {
      return _MuhtelifeLessonScreen(data: data);
    }
    return _MuttarideDetailScreen(data: data, category: lesson.relatedCategory);
  }
}

class _MuhtelifeLessonScreen extends StatelessWidget {
  const _MuhtelifeLessonScreen({required this.data});

  final AppData data;

  @override
  Widget build(BuildContext context) {
    final entries = [...data.muhtelifeEntries]
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    return _LessonScaffold(
      title: 'Emsile-i Muhtelife',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoPanel(
            title: 'Emsile-i Muhtelife',
            body:
                'Aynı kökten türeyen, kalıp ve anlam bakımından birbirinden farklı kelime çeşitlerini gösterir.',
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Muhtelife Tablosu',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MatchingPracticeScreen(data: data),
                    ),
                  );
                },
                icon: const Icon(Icons.compare_arrows_outlined),
                label: const Text('Pratik Yap'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (var index = 0; index < entries.length; index++) ...[
            _MuhtelifeCard(index: index + 1, entry: entries[index]),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 8),
          Text('Açıklamalar', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          for (final note in _muhtelifeNotes) ...[
            _NoteCard(text: note),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _MuttarideLessonScreen extends StatelessWidget {
  const _MuttarideLessonScreen({required this.data});

  final AppData data;

  @override
  Widget build(BuildContext context) {
    final available = FormCategory.values
        .where(
          (category) => data.forms.any((form) => form.category == category),
        )
        .toList();

    return _LessonScaffold(
      title: 'Emsile-i Muttaride',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoPanel(
            title: 'Emsile-i Muttaride',
            body:
                'Bir kalıbın şahıs, sayı ve cinsiyete göre düzenli biçimde çekilmesini gösterir.',
          ),
          const SizedBox(height: 18),
          Text(
            'Ders Başlıkları',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          for (var index = 0; index < available.length; index++) ...[
            Card(
              child: ListTile(
                leading: CircleAvatar(child: Text('${index + 1}')),
                title: Text(
                  available[index].label,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(_categoryDescription(available[index])),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => _MuttarideDetailScreen(
                      data: data,
                      category: available[index],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _MuttarideDetailScreen extends StatelessWidget {
  const _MuttarideDetailScreen({required this.data, required this.category});

  final AppData data;
  final FormCategory category;

  @override
  Widget build(BuildContext context) {
    final available = FormCategory.values
        .where(
          (candidate) => data.forms.any((form) => form.category == candidate),
        )
        .toList();
    final index = available.indexOf(category);
    final previousCategory = index > 0 ? available[index - 1] : null;
    final nextCategory = index >= 0 && index < available.length - 1
        ? available[index + 1]
        : null;
    final forms = data.forms
        .where((form) => form.category == category)
        .toList();

    if (forms.isEmpty) {
      return _LessonScaffold(
        title: category.label,
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Çekim tablosu bulunamadı.'),
          ),
        ),
      );
    }

    final voices = category.isNoun
        ? [forms.first.voice]
        : Voice.values
              .where((voice) => forms.any((form) => form.voice == voice))
              .toList();

    return _LessonScaffold(
      title: category.label,
      trailing: previousCategory == null && nextCategory == null
          ? null
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (previousCategory != null)
                  TextButton(
                    onPressed: () =>
                        _replaceMuttarideLesson(context, previousCategory),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      minimumSize: const Size(0, 40),
                    ),
                    child: const Text('Önceki'),
                  ),
                if (nextCategory != null)
                  TextButton(
                    onPressed: () =>
                        _replaceMuttarideLesson(context, nextCategory),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      minimumSize: const Size(0, 40),
                    ),
                    child: const Text('Sonraki'),
                  ),
              ],
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoPanel(title: 'Açıklama', body: _categoryExplanation(category)),
          const SizedBox(height: 18),
          for (final voice in voices) ...[
            Text(
              category.isVerb
                  ? '${category.label} Bina-i ${voice.label}'
                  : category.label,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            if (_voiceExplanation(category, voice) case final explanation?) ...[
              InfoPanel(
                title: voice == Voice.mechul
                    ? 'Meçhulün Yapılışı'
                    : 'Malûm Çekim Notu',
                body: explanation,
              ),
              const SizedBox(height: 10),
            ],
            if (category.isNoun)
              NounFormsTable(
                forms: forms,
                selectedForm: FormSelection.fromForm(forms.first),
                onSelect: (_) {},
                highlightSelection: false,
              )
            else
              FormsTable(
                forms: forms.where((form) => form.voice == voice).toList(),
                selectedForm: FormSelection.fromForm(forms.first),
                activeCategory: category,
                activeVoice: voice,
                onSelect: (_) {},
                highlightSelection: false,
              ),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }

  void _replaceMuttarideLesson(BuildContext context, FormCategory destination) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) =>
            _MuttarideDetailScreen(data: data, category: destination),
      ),
    );
  }
}

class _MuhtelifeCard extends StatelessWidget {
  const _MuhtelifeCard({required this.index, required this.entry});

  final int index;
  final MuhtelifeEntry entry;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(radius: 16, child: Text('$index')),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.label,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 3),
                  Text(entry.meaning),
                  const SizedBox(height: 8),
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      entry.arabic,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.info_outline,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(text)),
          ],
        ),
      ),
    );
  }
}

class _MainLessonTile extends StatelessWidget {
  const _MainLessonTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        onTap: onTap,
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(subtitle),
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class _LessonScaffold extends StatelessWidget {
  const _LessonScaffold({
    required this.title,
    required this.child,
    this.trailing,
  });

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AppPage(
          title: title,
          trailing: trailing,
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Geri',
          ),
          child: child,
        ),
      ),
    );
  }
}

const _muhtelifeNotes = [
  'Emr-i Hâzır formunun başındaki hemze vasıl hemzesidir; kelimeye geçişte okunmaz.',
  'Emr-i Hâzır formunun aslı, emir lâmı ile kurulan “li-tensur” yapısıdır.',
  'İsm-i Zaman, İsm-i Mekân ve Masdar-ı Mîmî “mef‘al” kalıbındandır; “mef‘il” kalıbı da kullanılabilir.',
  'İsm-i Âlet için “mif‘al” yanında “mif‘âl” ve “mif‘ale” kalıpları da kullanılabilir.',
  'İsm-i Mensub, Masdar-ı Gayr-ı Mîmî’den yapılır.',
  'Fiil-i Taaccüb kalıplarının sonundaki zamir ismin yerini tutar; yerine açık bir isim getirilebilir.',
];

String _categoryDescription(FormCategory category) {
  switch (category) {
    case FormCategory.mazi:
      return 'Geçmiş zamanda gerçekleşen işleri bildiren fiil çekimi';
    case FormCategory.muzari:
      return 'Şimdiki, geniş ve gelecek zamandaki işleri bildiren fiil çekimi';
    case FormCategory.masdar:
      return 'Fiilin şahıs ve zamandan bağımsız isim hali';
    case FormCategory.ismFail:
      return 'Eylemi yapan etken özneyi bildiren sıfat kalıbı';
    case FormCategory.ismMeful:
      return 'Eylemden etkilenen edilgen nesneyi bildiren isim kalıbı';
    case FormCategory.cahdMutlak:
      return 'Geçmiş zamanda kesin olumsuzluk çekimi';
    case FormCategory.cahdMustagrak:
      return 'Konuşma anına kadar süren olumsuzluk çekimi';
    case FormCategory.nefyHal:
      return 'Şimdiki zamanın olumsuz çekimi';
    case FormCategory.nefyIstikbal:
      return 'Gelecek zamanın olumsuz çekimi';
    case FormCategory.tekidNefyIstikbal:
      return 'Gelecek zamanın kesin olumsuzluk çekimi';
    case FormCategory.emrGaib:
      return 'Üçüncü şahıslara yapılan emir çekimi';
    case FormCategory.nehyGaib:
      return 'Üçüncü şahıslara yapılan yasaklama çekimi';
    case FormCategory.emrHazir:
      return 'Karşımızdaki muhataba doğrudan yapılan emir çekimi';
    case FormCategory.nehyHazir:
      return 'Karşımızdaki muhataba yapılan yasaklama çekimi';
    case FormCategory.ismZamanMekan:
      return 'Eylemin yapıldığı zaman, mekân veya mimli mastar hali';
    case FormCategory.ismAlet:
      return 'Eylemin yapıldığı aracı/aleti bildiren isim kalıbı';
    case FormCategory.masdarMerre:
      return 'Eylemin kaç defa yapıldığını bildiren mastar';
    case FormCategory.masdarNev:
      return 'Eylemin yapılış tarzını ve çeşidini bildiren mastar';
    case FormCategory.ismTasgir:
      return 'Küçültme, sevgi veya azlık bildiren isim kalıbı';
    case FormCategory.ismMensub:
      return 'Nispet, aitlik veya mensubiyet bildiren isim kalıbı';
    case FormCategory.mubalagaIsmFail:
      return 'Eylemin çokça yapıldığını bildiren abartılı sıfat kalıbı';
    case FormCategory.ismTafdil:
      return 'En veya daha üstünlük bildiren karşılaştırma kalıbı';
    case FormCategory.fiilTaaccubEvvel:
    case FormCategory.fiilTaaccubSani:
      return 'Hayret, şaşırma veya beğeni bildiren taaccüb kalıpları';
  }
}

String _categoryExplanation(FormCategory category) {
  switch (category) {
    case FormCategory.mazi:
      return 'Fiil-i Mâzi geçmişte gerçekleşen işi bildirir.';
    case FormCategory.muzari:
      return 'Fiil-i Muzâri, mâzi fiilin başına şahsa göre أ، ت، ي، ن harflerinden biri getirilerek yapılır. Bunlara muzaraat harfleri denir.';
    case FormCategory.masdar:
      return 'Masdar-ı Gayr-ı Mîmî, fiilin şahıs ve zamana bağlı olmayan isim hâlidir. Tekil, ikil ve çoğul biçimleri bulunur.';
    case FormCategory.ismFail:
      return 'İsm-i Fâil, işi yapanı bildirir.'
          '\n\n• Semâî olarak kullanılan on kuralsız kırık çoğul kalıbı vardır.'
          '\n• Tabloda bu kırık çoğulların yalnız kullanılan örnekleri gösterilir.';
    case FormCategory.ismMeful:
      return 'İsm-i Mef‘ûl, işten etkileneni bildirir.'
          '\n\n• Kırık çoğulu Emsile kitaplarında مَنَاصِرُ şeklinde geçer.'
          '\n• Kullanımda مَنَاصِيرُ şekline de rastlanır.';
    case FormCategory.cahdMutlak:
      return 'لَمْ, geçmişte hükmü sona ermiş bir işi olumsuz yapmak için kullanılır. Muzâri fiilin anlamını geçmiş zamana çevirir.'
          '\n\n• Müennes çoğul nûnu dışında ikil, müzekker çoğul ve müennes tekil muhatap nûnlarını düşürür.'
          '\n• Sonu sahih harf olan müfred fiili cezm eder; sonu illetli ise son harfi düşürür.'
          '\n• Allah Teâlâ hakkında kullanıldığında geçici bir zaman sınırlaması bildirmez.';
    case FormCategory.cahdMustagrak:
      return 'لَمَّا, işin konuşma anına kadar yapılmadığını; sonrasında yapılmasının mümkün veya beklendiğini bildirir.'
          '\n\n• Muzâri fiili olumsuz yapar ve anlamını geçmiş zamana çevirir.'
          '\n• Müennes çoğul nûnu dışında ikil, müzekker çoğul ve müennes tekil muhatap nûnlarını düşürür.'
          '\n• Sonu sahih harf olan müfred fiili cezm eder; sonu illetli ise son harfi düşürür.';
    case FormCategory.nefyHal:
      return 'مَا, muzâri fiili şimdiki zamana tahsis ederek olumsuz yapar.'
          '\n\n• Fiilin lafzında ve harekelerinde değişiklik yapmaz.';
    case FormCategory.nefyIstikbal:
      return 'لَا, muzâri fiili gelecek zamana tahsis ederek olumsuz yapar.'
          '\n\n• Fiilin lafzında ve harekelerinde değişiklik yapmaz.';
    case FormCategory.tekidNefyIstikbal:
      return 'لَنْ, gelecek zamanı kuvvetli biçimde olumsuz yapar.'
          '\n\n• Müennes çoğul nûnu dışında ikil, müzekker çoğul ve müennes tekil muhatap nûnlarını düşürür.'
          '\n• Müfred fiillerin sonunu nasb eder.';
    case FormCategory.emrGaib:
      return 'Emr-i Gâib, hazır olmayan şahsa bir işin yapılmasını emretmektir. Muzârinin gâib ve gâibe biçimlerinin başına emir lâmı لِ getirilir.'
          '\n\n• Malûm çekimde yalnız gâib ve gâibe biçimleri kullanılır.'
          '\n• Müennes çoğul nûnu dışında ikil ve müzekker çoğul nûnları düşer.'
          '\n• Sonu sahih harf olan müfred fiil cezm edilir; sonu illetli ise son harfi düşer.'
          '\n• Anlam haber kipinden emir kipine ve gelecek zamana döner.';
    case FormCategory.nehyGaib:
      return 'Nehy-i Gâib, hazır olmayan şahsın bir işi yapmasını yasaklamaktır. Muzârinin gâib ve gâibe biçimlerinin başına nehiy lâsı لَا getirilir.'
          '\n\n• Malûm çekimde yalnız gâib ve gâibe biçimleri kullanılır.'
          '\n• Müennes çoğul nûnu dışında ikil ve müzekker çoğul nûnları düşer.'
          '\n• Sonu sahih harf olan müfred fiil cezm edilir; sonu illetli ise son harfi düşer.'
          '\n• Fiil olumsuzlaşır; anlam haber kipinden yasaklama kipine ve gelecek zamana döner.';
    case FormCategory.emrHazir:
      return 'Emr-i Hâzır, karşımızda bulunan şahsa emir vermektir. Malûm çekimde yalnız muhatap ve muhataba biçimleri kullanılır.'
          '\n\n• Önce muzâri fiil cezm edilir, ardından muzaraat harfi kaldırılır.'
          '\n• Kalan ilk harf cezimli ise başına vasıl hemzesi getirilir.'
          '\n• Sondan bir önceki harf dammeli ise vasıl hemzesi dammeli, değilse kesralı okunur.'
          '\n• Müennes çoğul nûnu dışında ikil, müennes tekil ve müzekker çoğul nûnları düşer.'
          '\n• Sonu illetli müfred fiillerde son harf düşer.';
    case FormCategory.nehyHazir:
      return 'Nehy-i Hâzır, karşımızda bulunan şahsın bir işi yapmasını yasaklamaktır. Muhatap ve muhataba muzâri biçimlerinin başına لَا getirilir.'
          '\n\n• Malûm çekimde yalnız muhatap ve muhataba biçimleri kullanılır.'
          '\n• Müennes çoğul nûnu dışında ikil, müennes tekil ve müzekker çoğul nûnları düşer.'
          '\n• Sonu sahih harf olan müfred fiil cezm edilir; sonu illetli ise son harfi düşer.'
          '\n• Fiil olumsuzlaşır ve anlam yasaklama kipine döner.';
    case FormCategory.ismZamanMekan:
      return 'İsm-i Zaman, İsm-i Mekân ve Masdar-ı Mîmî مَفْعَلٌ kalıbındandır; مَفْعِلٌ kalıbı da kullanılabilir.'
          '\n\n• Yapılma zamanını, yapılma yerini veya fiilin mîmli masdarını bildirir.';
    case FormCategory.ismAlet:
      return 'İsm-i Âlet, işin yapıldığı aracı bildirir.'
          '\n\n• مِفْعَلٌ kalıbından yapılır.'
          '\n• مِفْعَالٌ ve مِفْعَلَةٌ kalıpları da kullanılabilir.';
    case FormCategory.masdarMerre:
      return 'Kemmiyete, yani bir işin kaç defa yapıldığına delâlet eden masdardır.';
    case FormCategory.masdarNev:
      return 'Keyfiyete, yani bir işin yapılış biçimine veya çeşidine delâlet eden masdardır.'
          '\n\n• Kullanımda daha çok tekil biçimi tercih edilir.';
    case FormCategory.ismTasgir:
      return 'İsm-i Tasğir küçültme veya azlık anlamı verir.'
          '\n\n• Üç harfli isimlerde فُعَيْلٌ vezni kullanılır.'
          '\n• Dört harfli isimlerde فُعَيْعِلٌ vezni kullanılır.'
          '\n• Beş harfli isimlerde فُعَيْعِيلٌ vezni kullanılır.'
          '\n• Emsile kitabında müennes çekimleri yer almaz.';
    case FormCategory.ismMensub:
      return 'İsm-i Mensub, bir işe, yere veya şeye mensubiyet ve alâka bildirir. Türkçedeki “-sal/-sel” ve yerine göre “-lı/-li” eklerine yaklaşır.'
          '\n\n• Mimsiz masdarın sonuna şeddeli يّ eklenir; önceki son harf kesralı yapılır.'
          '\n• Şahıs isminden yapılırsa münasebet bildirir: مُحَمَّدِيٌّ.'
          '\n• Yer isminden yapılırsa mahal bildirir: إِسْتَانْبُولِيٌّ.'
          '\n• Diğer isimlerden yapılırsa hâl bildirir: رَحْمِيٌّ.';
    case FormCategory.mubalagaIsmFail:
      return 'Mübalağa İsm-i Fâil, işi çokça yapanı bildirir.'
          '\n\n• Modern Arapçada alet ismi olarak da kullanılır.'
          '\n• Örnek: بَرَّادٌ “buzdolabı”, غَسَّالَةٌ “çamaşır makinesi”.';
    case FormCategory.ismTafdil:
      return 'İsm-i Tafdil, iki şey arasında üstünlük veya en üstünlük bildirir. Türkçede “daha” ve “en” anlamlarını verir.'
          '\n\n• Müzekker ve müennes biçimleri ile kurallı ve kırık çoğulları bulunur.';
    case FormCategory.fiilTaaccubEvvel:
      return 'Hayret ve şaşırma bildirir. Çekimi fiilin kendisiyle değil bitişik zamirlerle yapılır.'
          '\n\n• Malûmdan olup meçhulü gelmez.'
          '\n• Sonundaki zamir ismin yerini tutar; yerine açık bir isim getirilebilir.';
    case FormCategory.fiilTaaccubSani:
      return 'Hayret ve şaşırma bildirir. Çekimi fiilin kendisiyle değil bitişik zamirlerle yapılır.'
          '\n\n• Malûmdan olup meçhulü gelmez.'
          '\n• Sonundaki zamir ismin yerini tutar; yerine açık bir isim getirilebilir.'
          '\n• هُ, هُمَا, هُمْ ve هُنَّ zamirlerindeki ه, öncesinde kesra veya sakin ي varsa kesralı okunur.';
  }
}

String? _voiceExplanation(FormCategory category, Voice voice) {
  if (voice != Voice.mechul) return null;

  switch (category) {
    case FormCategory.mazi:
      return '• Sondan bir önceki harf kesralı yapılır.'
          '\n• Bu harften önceki harekeli harfler dammeli yapılır.'
          '\n• Cezimli harflerin harekesi değiştirilmez.';
    case FormCategory.muzari:
      return '• Sondan bir önceki harf fethalı yapılır.'
          '\n• Muzaraat harfi dammeli yapılır.';
    case FormCategory.cahdMutlak:
    case FormCategory.cahdMustagrak:
    case FormCategory.nefyHal:
    case FormCategory.nefyIstikbal:
    case FormCategory.tekidNefyIstikbal:
      return 'Meçhul çekim, Fiil-i Muzârinin meçhule dönüşümü gibi yapılır:'
          '\n\n• Sondan bir önceki harf fethalı yapılır.'
          '\n• Muzaraat harfi dammeli yapılır.';
    case FormCategory.emrGaib:
    case FormCategory.nehyGaib:
      return '• Meçhul çekim, Fiil-i Muzârinin meçhule dönüşümü gibi yapılır.'
          '\n• Malûm çekime ek olarak mütekellim biçimleri de çekilir.';
    case FormCategory.emrHazir:
      return '• Meçhul çekimde emir lâmı kullanılır.'
          '\n• Fiil-i Muzârinin meçhule dönüşüm kuralları uygulanır.'
          '\n• Malûm çekime ek olarak mütekellim biçimleri de çekilir.';
    case FormCategory.nehyHazir:
      return '• Meçhul çekim, Nehy-i Gâibin meçhule dönüşümü gibi yapılır.'
          '\n• Malûm çekime ek olarak mütekellim biçimleri de çekilir.';
    case FormCategory.masdar:
    case FormCategory.ismFail:
    case FormCategory.ismMeful:
    case FormCategory.ismZamanMekan:
    case FormCategory.ismAlet:
    case FormCategory.masdarMerre:
    case FormCategory.masdarNev:
    case FormCategory.ismTasgir:
    case FormCategory.ismMensub:
    case FormCategory.mubalagaIsmFail:
    case FormCategory.ismTafdil:
    case FormCategory.fiilTaaccubEvvel:
    case FormCategory.fiilTaaccubSani:
      return null;
  }
}
