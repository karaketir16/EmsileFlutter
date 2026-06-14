import 'package:emsile_flutter/app/app_shell.dart';
import 'package:emsile_flutter/data/emsile_repository.dart';
import 'package:emsile_flutter/data/models.dart';
import 'package:emsile_flutter/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

class EmsileApp extends StatelessWidget {
  const EmsileApp({super.key});

  static final Future<AppData> _appData = EmsileRepository.load();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emsile',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: FutureBuilder<AppData>(
        future: _appData,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return LoadErrorScreen(error: snapshot.error.toString());
          }

          if (!snapshot.hasData) {
            return const LoadingScreen();
          }

          return AppShell(data: snapshot.data!);
        },
      ),
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class LoadErrorScreen extends StatelessWidget {
  const LoadErrorScreen({required this.error, super.key});

  final String error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Veri yüklenemedi: $error'),
        ),
      ),
    );
  }
}
