import 'package:flutter/material.dart';

class BankTheme {
  const BankTheme({
    required this.fromColor,
    required this.toColor,
    required this.textColor,
    required this.accentColor,
  });

  final Color fromColor;
  final Color toColor;
  final Color textColor;
  final Color accentColor;

  LinearGradient get gradient => LinearGradient(
        colors: [fromColor, toColor],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
}

class Bank {
  Bank({
    required this.id,
    required this.name,
    required this.cardName,
    required this.description,
    required this.url,
    required this.theme,
    required this.logoText,
    required this.features,
    this.cardNumber,
    this.customColor,
    this.balance,
    this.currency,
    this.cardHolder,
    this.last4,
  });

  final String id;
  final String name;
  final String cardName;
  final String description;
  final String url;
  final BankTheme theme;
  final String logoText;
  final List<String> features;
  final String? cardNumber;
  final Color? customColor;

  double? balance;
  String? currency;
  String? cardHolder;
  String? last4;

  Bank copyWith({
    String? name,
    String? cardName,
    String? cardNumber,
    Color? customColor,
    double? balance,
    String? currency,
    String? cardHolder,
    String? last4,
  }) {
    return Bank(
      id: id,
      name: name ?? this.name,
      cardName: cardName ?? this.cardName,
      description: description,
      url: url,
      theme: theme,
      logoText: logoText,
      features: features,
      cardNumber: cardNumber ?? this.cardNumber,
      customColor: customColor ?? this.customColor,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      cardHolder: cardHolder ?? this.cardHolder,
      last4: last4 ?? this.last4,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'cardName': cardName,
      'description': description,
      'url': url,
      'logoText': logoText,
      'features': features,
      'cardNumber': cardNumber,
      'customColor': customColor?.value,
      'balance': balance,
      'currency': currency,
      'cardHolder': cardHolder,
      'last4': last4,
      'theme': {
        'fromColor': theme.fromColor.value,
        'toColor': theme.toColor.value,
        'textColor': theme.textColor.value,
        'accentColor': theme.accentColor.value,
      },
    };
  }

  factory Bank.fromJson(Map<String, dynamic> json) {
    final themeData = json['theme'] as Map<String, dynamic>;
    return Bank(
      id: json['id'] as String,
      name: json['name'] as String,
      cardName: (json['cardName'] as String?) ?? (json['name'] as String),
      description: json['description'] as String,
      url: json['url'] as String,
      logoText: json['logoText'] as String,
      features: List<String>.from(json['features'] as List),
      cardNumber: json['cardNumber'] as String?,
      customColor: json['customColor'] == null
          ? null
          : Color(json['customColor'] as int),
      balance: json['balance'] as double?,
      currency: json['currency'] as String?,
      cardHolder: json['cardHolder'] as String?,
      last4: json['last4'] as String?,
      theme: BankTheme(
        fromColor: Color(themeData['fromColor'] as int),
        toColor: Color(themeData['toColor'] as int),
        textColor: Color(themeData['textColor'] as int),
        accentColor: Color(themeData['accentColor'] as int),
      ),
    );
  }
}
