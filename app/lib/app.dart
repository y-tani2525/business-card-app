import 'package:flutter/material.dart';
import 'features/business_card/presentation/pages/home_page.dart';

class BusinessCardApp extends StatelessWidget {
  const BusinessCardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: '名刺',
      home: MyHomePage(title: '名刺'),
    );
  }
}
