import 'package:emsile_flutter/data/models.dart';
import 'package:emsile_flutter/features/conjugation/conjugation_screen.dart';
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
    if (lesson.title == 'Emsile-i Muhtelife') {
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
          Text(
            'Muhtelife Tablosu',
            style: Theme.of(context).textTheme.titleLarge,
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
                'Bir kalıbın şahıs, sayı ve cinsiyete göre düzenli biçimde çekilmesini gösterir. Bu nedenle şahıs zamirlerinin bilinmesi gerekir.',
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
    final forms = data.forms
        .where((form) => form.category == category)
        .toList();
    final voices = category.isNoun
        ? [forms.first.voice]
        : Voice.values
              .where((voice) => forms.any((form) => form.voice == voice))
              .toList();

    return _LessonScaffold(
      title: category.label,
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
  const _LessonScaffold({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AppPage(
          title: title,
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
      return 'Geçmiş zamanın malum ve meçhul çekimleri';
    case FormCategory.muzari:
      return 'Şimdiki, geniş ve gelecek zaman çekimleri';
    case FormCategory.masdar:
      return 'Fiilin şahıs ve zamandan bağımsız isim hali';
    default:
      return '${category.label} tablosu ve açıklaması';
  }
}

String _categoryExplanation(FormCategory category) {
  switch (category) {
    case FormCategory.mazi:
      return 'Fiil-i Mâzi geçmişte gerçekleşen işi bildirir. Meçhul çekimde sondan bir önceki harf kesralı, ondan önceki harekeli harfler dammeli okunur.';
    case FormCategory.muzari:
      return 'Fiil-i Muzâri, mâzi fiilin başına şahsa göre أ، ت، ي، ن muzaraat harflerinden biri getirilerek yapılır. Meçhulünde sondan bir önceki harf fethalı, muzaraat harfi dammeli olur.';
    case FormCategory.cahdMutlak:
      return '“Lem” muzâri fiili olumsuz yapar, anlamını geçmiş zamana çevirir ve fiili cezm eder.';
    case FormCategory.cahdMustagrak:
      return '“Lemmâ”, işin konuşma anına kadar yapılmadığını; sonrasında yapılmasının mümkün veya beklendiğini bildirir.';
    case FormCategory.nefyHal:
      return '“Mâ” edatı muzâri fiili lafzen değiştirmeden şimdiki zamanda olumsuz yapar.';
    case FormCategory.nefyIstikbal:
      return '“Lâ” edatı muzâri fiili lafzen değiştirmeden gelecek zamanda olumsuz yapar.';
    case FormCategory.tekidNefyIstikbal:
      return '“Len” gelecek zamanı kuvvetli biçimde olumsuz yapar ve muzâri fiili nasb eder.';
    case FormCategory.emrGaib:
      return 'Hazır olmayan şahsa bir işin yapılmasını emretmek için muzâri fiile emir lâmı getirilir.';
    case FormCategory.nehyGaib:
      return 'Hazır olmayan şahsın bir işi yapmasını yasaklamak için muzâri fiile nehiy “lâ”sı getirilir.';
    case FormCategory.emrHazir:
      return 'Karşımızdaki şahsa emir verir. Muzâri fiil cezm edilir, muzaraat harfi kaldırılır; gerekirse başına vasıl hemzesi getirilir.';
    case FormCategory.nehyHazir:
      return 'Karşımızdaki şahsın bir işi yapmasını yasaklamak için muhatap muzâri çekiminin başına nehiy “lâ”sı getirilir.';
    case FormCategory.masdarMerre:
      return 'Bir işin kaç defa yapıldığını bildiren masdardır.';
    case FormCategory.masdarNev:
      return 'Bir işin yapılış biçimini veya çeşidini bildiren masdardır; daha çok tekil biçimi kullanılır.';
    case FormCategory.ismTasgir:
      return 'Küçültme veya azlık anlamı verir. Üç, dört ve beş harfli isimler için farklı vezinleri vardır.';
    case FormCategory.ismMensub:
      return 'Bir işe, yere veya şeye mensubiyet ve alâka bildirir.';
    case FormCategory.mubalagaIsmFail:
      return 'İşi çokça yapanı bildirir; modern Arapçada alet ismi olarak da kullanılabilir.';
    case FormCategory.fiilTaaccubEvvel:
    case FormCategory.fiilTaaccubSani:
      return 'Hayret ve şaşırma bildirir. Çekimi fiilin kendisiyle değil bitişik zamirlerle yapılır; meçhulü kullanılmaz.';
    default:
      return '${category.label}, aynı kökten türeyen düzenli çekim kalıplarından biridir. Aşağıdaki tabloda tekil, ikil ve çoğul biçimleri gösterilir.';
  }
}
