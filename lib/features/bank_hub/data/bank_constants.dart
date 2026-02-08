import 'package:flutter/material.dart';

import '../domain/models/bank.dart';

final List<Bank> initialBanks = [
  Bank(
    id: 'gpb',
    name: 'Gazprombank',
    cardName: 'Основная карта',
    description: 'Energy of finance. Reliability and growth.',
    url: 'https://ib.online.gpb.ru/login',
    theme: const BankTheme(
      fromColor: Color(0xFF1E3A8A), // blue-900
      toColor: Color(0xFF3730A3), // indigo-800
      textColor: Color(0xFFDBEAFE), // blue-100
      accentColor: Color(0xFF2563EB), // blue-600
    ),
    logoText: 'GPB',
    features: ['Premium Banking', 'Investment', 'Gas Cashback'],
    cardNumber: '4521 0000 0000 4521',
    balance: 142500,
    currency: '₽',
    cardHolder: 'ALEXANDER IVANOV',
    last4: '4521',
  ),
  Bank(
    id: 'alfa',
    name: 'Alfa Bank',
    cardName: 'Основная карта',
    description: 'Bank for smart and free people.',
    url:
        'https://private.auth.alfabank.ru/passport/cerberus-mini-blue/dashboard-blue/phone_auth?response_type=code&client_id=newclick-web&scope=openid%20newclick-web&redirect_uri=https%3A%2F%2Fweb.alfabank.ru%2Fopenid%2Fauthorize%2Fnewclick-web%3Fredirect_to%3Dhttps___web.alfabank.ru%2F&acr_values=phone_auth:sms&non_authorized_user=true',
    theme: const BankTheme(
      fromColor: Color(0xFFB91C1C), // red-700
      toColor: Color(0xFFEA580C), // orange-600
      textColor: Color(0xFFFEE2E2), // red-100
      accentColor: Color(0xFFEF4444), // red-500
    ),
    logoText: 'A',
    features: ['Instant Transfers', 'Super Cashback', 'Family Account'],
    cardNumber: '8812 0000 0000 8812',
    balance: 5300.50,
    currency: '₽',
    cardHolder: 'ALEXANDER IVANOV',
    last4: '8812',
  ),
  Bank(
    id: 'vtb',
    name: 'VTB',
    cardName: 'Основная карта',
    description: 'More than just a bank.',
    url: 'https://online.vtb.ru/login',
    theme: const BankTheme(
      fromColor: Color(0xFF075985), // sky-800
      toColor: Color(0xFF2563EB), // blue-600
      textColor: Color(0xFFE0F2FE), // sky-100
      accentColor: Color(0xFF0EA5E9), // sky-500
    ),
    logoText: 'VTB',
    features: ['Multicard', 'Auto Loans', 'Pension'],
    cardNumber: '1092 0000 0000 1092',
    balance: 850,
    currency: '\$',
    cardHolder: 'ALEXANDER IVANOV',
    last4: '1092',
  ),
];

final List<Bank> marketplaceBanks = [
  Bank(
    id: 'tbank',
    name: 'T-Bank',
    cardName: 'Новая карта',
    description: 'Online ecosystem based on financial lifestyle.',
    url: 'https://www.tbank.ru/login/',
    theme: const BankTheme(
      fromColor: Color(0xFFFACC15), // yellow-400
      toColor: Color(0xFFCA8A04), // yellow-600
      textColor: Color(0xFF0F172A), // yellow-950
      accentColor: Color(0xFF000000), // black
    ),
    logoText: 'T',
    features: ['Lifestyle Banking', 'Travel', 'Investments'],
    cardNumber: '0000 0000 0000 0000',
    balance: 0,
    currency: '₽',
    cardHolder: 'YOUR NAME',
    last4: '0000',
  ),
  Bank(
    id: 'sber',
    name: 'SberBank',
    cardName: 'Новая карта',
    description: 'Always there for you.',
    url: 'https://online.sberbank.ru/CSAFront/default.do',
    theme: const BankTheme(
      fromColor: Color(0xFF059669), // emerald-600
      toColor: Color(0xFF15803D), // green-700
      textColor: Color(0xFFECFDF5), // emerald-50
      accentColor: Color(0xFF10B981), // emerald-500
    ),
    logoText: 'SBER',
    features: ['Ecosystem', 'Bonuses', 'Prime'],
    cardNumber: '0000 0000 0000 0000',
    balance: 0,
    currency: '₽',
    cardHolder: 'YOUR NAME',
    last4: '0000',
  ),
  Bank(
    id: 'otp',
    name: 'OTP Bank',
    cardName: 'Новая карта',
    description: 'Trust and reliability.',
    url: 'https://online.otpbank.ru/login',
    theme: const BankTheme(
      fromColor: Color(0xFF0D9488), // teal-600
      toColor: Color(0xFF065F46), // emerald-800
      textColor: Color(0xFFF0FDFA), // teal-50
      accentColor: Color(0xFF14B8A6), // teal-500
    ),
    logoText: 'OTP',
    features: ['Consumer Loans', 'Credit Cards', 'Savings'],
    cardNumber: '0000 0000 0000 0000',
    balance: 0,
    currency: '₽',
    cardHolder: 'YOUR NAME',
    last4: '0000',
  ),
  Bank(
    id: 'raif',
    name: 'Raiffeisen',
    cardName: 'Новая карта',
    description: 'Difference is in attitude.',
    url: 'https://online.raiffeisen.ru/login',
    theme: const BankTheme(
      fromColor: Color(0xFFFDE047), // yellow-300
      toColor: Color(0xFF000000), // black
      textColor: Color(0xFF0F172A), // slate-900
      accentColor: Color(0xFFFACC15), // yellow-400
    ),
    logoText: 'R',
    features: ['Premium Service', 'Business', 'Reliability'],
    cardNumber: '0000 0000 0000 0000',
    balance: 0,
    currency: '₽',
    cardHolder: 'YOUR NAME',
    last4: '0000',
  ),
  Bank(
    id: 'open',
    name: 'Otkritie',
    cardName: 'Новая карта',
    description: 'Bank for confident growth.',
    url: 'https://ib.open.ru/login',
    theme: const BankTheme(
      fromColor: Color(0xFF60A5FA), // blue-400
      toColor: Color(0xFF2563EB), // blue-600
      textColor: Color(0xFFFFFFFF), // white
      accentColor: Color(0xFF3B82F6), // blue-500
    ),
    logoText: 'OPEN',
    features: ['Business', 'Mortgage', 'Growth'],
    cardNumber: '0000 0000 0000 0000',
    balance: 0,
    currency: '₽',
    cardHolder: 'YOUR NAME',
    last4: '0000',
  ),
];
