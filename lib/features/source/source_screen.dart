import 'package:emsile_flutter/shared/widgets/app_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SourceScreen extends StatelessWidget {
  const SourceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Hakkında',
      child: Column(
        children: [
          Card(
            child: InkWell(
              onTap: () async {
                final url = Uri.parse('https://arapcadiyari.blogspot.com');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.link, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Hakkında',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Zafer ESEN tarafından hazırlanan Emsile Ders Notu’ndan faydalanılmıştır.',
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'https://arapcadiyari.blogspot.com',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: InkWell(
              onTap: () async {
                final url = Uri.parse('https://github.com/karaketir16');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.code, color: Colors.blue),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bu uygulama Osman Karaketir tarafından geliştirilmiştir.',
                            style: TextStyle(fontSize: 14),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'github.com/karaketir16',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.open_in_new, size: 18),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
