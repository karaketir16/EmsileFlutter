import 'package:emsile_flutter/data/models.dart';
import 'package:emsile_flutter/shared/widgets/app_page.dart';
import 'package:emsile_flutter/shared/widgets/arabic_result_card.dart';
import 'package:emsile_flutter/shared/widgets/info_panel.dart';
import 'package:flutter/material.dart';

class LessonsScreen extends StatelessWidget {
  const LessonsScreen({required this.data, super.key});

  final AppData data;

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Dersler',
      subtitle: 'PDF akışını mobil çalışma başlıklarına böldük.',
      child: Column(
        children: data.lessons
            .map(
              (lesson) => LessonTile(
                lesson: lesson,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          LessonDetailScreen(lesson: lesson, data: data),
                    ),
                  );
                },
              ),
            )
            .toList(),
      ),
    );
  }
}

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
    final relatedForms = data.forms
        .where((form) => form.category == lesson.relatedCategory)
        .take(4)
        .toList();

    return Scaffold(
      body: SafeArea(
        child: AppPage(
          title: lesson.title,
          subtitle: lesson.summary,
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Geri',
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InfoPanel(title: 'Kural Notu', body: lesson.rule),
              const SizedBox(height: 16),
              Text('Örnekler', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 10),
              for (final form in relatedForms) ...[
                ArabicResultCard(form: form),
                const SizedBox(height: 10),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class LessonTile extends StatelessWidget {
  const LessonTile({required this.lesson, required this.onTap, super.key});

  final Lesson lesson;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(lesson.order.toString()),
        ),
        title: Text(
          lesson.title,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(lesson.summary),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
