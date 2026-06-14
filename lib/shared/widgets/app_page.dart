import 'package:flutter/material.dart';

class AppPage extends StatelessWidget {
  const AppPage({
    required this.title,
    this.subtitle,
    required this.child,
    this.leading,
    this.scrollable = true,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? leading;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final header = Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 4)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(subtitle!, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: scrollable
            ? CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: header),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    sliver: SliverToBoxAdapter(child: child),
                  ),
                ],
              )
            : Column(
                children: [
                  header,
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      child: child,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
