import 'package:emsile_flutter/data/models.dart';
import 'package:emsile_flutter/shared/widgets/app_page.dart';
import 'package:emsile_flutter/shared/widgets/arabic_result_card.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({required this.data, super.key});

  final AppData data;

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Emsile',
      subtitle: 'Sarf tablolarını oku, seç, tekrar et.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FeaturedStudyCard(),
          const SizedBox(height: 16),
          Text('Bugünkü Akış', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          const StudyStep(
            icon: Icons.filter_1,
            title: 'Emsile-i Muhtelife',
            body: 'Temel formları ve anlam karşılıklarını gözden geçir.',
          ),
          const StudyStep(
            icon: Icons.filter_2,
            title: 'Fiil-i Mâzi',
            body: 'Malum ve meçhul çekimleri şahıslara göre incele.',
          ),
          const StudyStep(
            icon: Icons.filter_3,
            title: 'Hızlı Pratik',
            body: 'Arapça formdan Türkçe anlama kısa tekrar yap.',
          ),
          const SizedBox(height: 16),
          Text('Örnek Form', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          ArabicResultCard(form: data.forms.first),
        ],
      ),
    );
  }
}

class FeaturedStudyCard extends StatelessWidget {
  const FeaturedStudyCard({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kaldığın Yer',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: scheme.onPrimary.withValues(alpha: 0.82),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Fiil-i Mâzi Bina-i Malum',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: scheme.onPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Bugün hedef: 14 şahıs çekimini tanımak ve 5 kart çözmek.',
            softWrap: true,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: scheme.onPrimary),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: 0.35,
            color: const Color(0xFFE2B84B),
            backgroundColor: scheme.onPrimary.withValues(alpha: 0.24),
            borderRadius: BorderRadius.circular(99),
          ),
        ],
      ),
    );
  }
}

class StudyStep extends StatelessWidget {
  const StudyStep({
    required this.icon,
    required this.title,
    required this.body,
    super.key,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(body),
      ),
    );
  }
}
