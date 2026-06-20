import 'package:emsile_flutter/data/models.dart';
import 'package:emsile_flutter/shared/widgets/app_page.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({required this.data, super.key});

  final AppData data;

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Emsile',
      subtitle: 'Arapça sarf kalıplarını öğrenme ve tekrar uygulaması',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _WelcomeCard(),
          const SizedBox(height: 22),
          Text(
            'Nasıl kullanılır?',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          const _FeatureCard(
            icon: Icons.menu_book_outlined,
            title: 'Önce konuyu öğren',
            section: 'Dersler',
            body:
                'Emsile-i Muhtelife ve Emsile-i Muttaride konularını, açıklamalar ve düzenli çekim tablolarıyla incele.',
          ),
          const SizedBox(height: 10),
          const _FeatureCard(
            icon: Icons.grid_view_outlined,
            title: 'Çekimleri karşılaştır',
            section: 'Tablo',
            body:
                'Fiil veya isim kalıbını seç; şahıs, sayı, malum ve meçhul çekimlerini tek tabloda karşılaştır.',
          ),
          const SizedBox(height: 10),
          const _FeatureCard(
            icon: Icons.quiz_outlined,
            title: 'Bilgini pekiştir',
            section: 'Pratik',
            body:
                'Çalışmak istediğin konu ve şahısları seç. Arapçadan Türkçeye ve Türkçeden Arapçaya sorular çöz.',
          ),
        ],
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.auto_stories, color: scheme.onPrimary, size: 30),
          const SizedBox(height: 14),
          Text(
            'Emsile’yi adım adım çalış',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: scheme.onPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Uygulama; sarf kalıplarını öğrenmeni, çekimleri karşılaştırmanı ve sorularla tekrar etmeni kolaylaştırır.',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: scheme.onPrimary),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.section,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String section;
  final String body;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: scheme.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 5),
                  Text(body),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
