import 'package:emsile_flutter/shared/widgets/app_page.dart';
import 'package:emsile_flutter/shared/widgets/info_panel.dart';
import 'package:flutter/material.dart';

class SourceScreen extends StatelessWidget {
  const SourceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPage(
      title: 'Kaynak',
      subtitle: 'İçerik kaynağı ve yerel PDF bilgisi.',
      child: Column(
        children: [
          InfoPanel(
            title: 'Kaynak',
            body:
                'Zafer ESEN tarafından hazırlanan Emsile Ders Notu temel alınmıştır. Güncelleme tarihi: 01.01.2025.',
          ),
          SizedBox(height: 12),
          InfoPanel(
            title: 'Yerel PDF',
            body: 'docs/Emsile_Ders_Notu_Zafer_ESEN_01.01.2025.pdf',
          ),
          SizedBox(height: 12),
          InfoPanel(
            title: 'Kullanım Notu',
            body:
                'Uygulamada kaynak gösterimi korunmalı; içerik genişletilirken PDF verileri elle kontrol edilmelidir.',
          ),
        ],
      ),
    );
  }
}
