import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/bank_hub/presentation/bank_hub_page.dart';

class AnyBankApp extends StatelessWidget {
  const AnyBankApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AnyBank',
      theme: AppTheme.light,
      home: const BankHubPage(),
    );
  }
}

