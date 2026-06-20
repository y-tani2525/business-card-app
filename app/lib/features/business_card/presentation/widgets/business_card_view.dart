import 'package:flutter/material.dart';
import '../../domain/models/business_card.dart';

class BusinessCardView extends StatelessWidget {
  const BusinessCardView({super.key, required this.card});

  final BusinessCard card;

  @override
  // 各Widgetのbuild()メソッドが子Widgetのツリーを戻り値で返す
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(// 縦方向に並べる
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvator(
              radius: 48,
              backgroundImage: AssetImage('assets/boy25.png'),
            ),
            SizeBox(height: 16),
            Text(card.name, style: textTheme.headlineMedium),
            const SizedBox(height: 4),
            Text(card.title, style: textTheme.titleMedium),
            Text(card.company, style: textTheme.bodyLarge),
            const Divider(height: 32),
            _ContactRow(icon: Icons.email_outlined, label: card.email),
            const SizedBox(height: 8),
            _ContactRow(icon: Icons.phone_outlined, label: card.phone),
          ],
        ),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}
