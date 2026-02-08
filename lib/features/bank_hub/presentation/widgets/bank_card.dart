import 'package:flutter/material.dart';
import '../../domain/models/bank.dart';

class BankCardWidget extends StatelessWidget {
  const BankCardWidget({
    super.key,
    required this.bank,
    required this.onTap,
    this.onEdit,
    this.isPrivacyMode = false,
    this.style,
  });

  final Bank bank;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final bool isPrivacyMode;
  final BoxStyle? style;

  static const double cardHeight = 232;

  String _formatCardNumber(String? raw) {
    final digits = (raw ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return '0000 0000 0000 0000';
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i != 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    return buffer.toString().padRight(19, '•');
  }

  Color _darken(Color color, [double amount = 0.2]) {
    final hsl = HSLColor.fromColor(color);
    final dark = hsl.withLightness((hsl.lightness - amount).clamp(0, 1));
    return dark.toColor();
  }

  Color _textColorFor(Color color) {
    return color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final customBase = bank.customColor;
    final gradient = customBase == null
        ? bank.theme.gradient
        : LinearGradient(
            colors: [customBase, _darken(customBase, 0.18)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
    final primaryText =
        customBase == null ? bank.theme.textColor : _textColorFor(customBase);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: style?.margin,
        width: style?.width,
        height: style?.height ?? cardHeight,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Card content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: Card name + Edit
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          bank.cardName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (onEdit != null)
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: onEdit,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.edit_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    bank.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: primaryText.withOpacity(0.85),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatCardNumber(bank.cardNumber),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: primaryText,
                      letterSpacing: 3,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BoxStyle {
  final double? width;
  final double? height;
  final EdgeInsets? margin;

  const BoxStyle({
    this.width,
    this.height,
    this.margin,
  });
}
