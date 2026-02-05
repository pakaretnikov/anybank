import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

class AnyBankApp extends StatelessWidget {
  const AnyBankApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AnyBank',
      theme: AppTheme.light,
      home: const Placeholder(),
    );
  }
}

