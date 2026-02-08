import 'package:flutter/material.dart';
import '../../domain/models/bank.dart';

class EditCardModal extends StatefulWidget {
  const EditCardModal({
    super.key,
    required this.bank,
    required this.onClose,
    required this.onSave,
  });

  final Bank bank;
  final VoidCallback onClose;
  final ValueChanged<Bank> onSave;

  @override
  State<EditCardModal> createState() => _EditCardModalState();
}

class _EditCardModalState extends State<EditCardModal> {
  late final TextEditingController _cardNameController;
  late final TextEditingController _bankNameController;
  late final TextEditingController _cardNumberController;
  Color? _selectedColor;

  @override
  void initState() {
    super.initState();
    _cardNameController = TextEditingController(
      text: widget.bank.cardName,
    );
    _bankNameController = TextEditingController(
      text: widget.bank.name,
    );
    _cardNumberController = TextEditingController(
      text: widget.bank.cardNumber ?? '',
    );
    _selectedColor = widget.bank.customColor;
  }

  @override
  void dispose() {
    _cardNameController.dispose();
    _bankNameController.dispose();
    _cardNumberController.dispose();
    super.dispose();
  }

  void _handleSave() {
    widget.onSave(
      widget.bank.copyWith(
        name: _bankNameController.text.trim().isEmpty
            ? widget.bank.name
            : _bankNameController.text.trim(),
        cardName: _cardNameController.text.trim().isEmpty
            ? widget.bank.cardName
            : _cardNameController.text.trim(),
        cardNumber: _formatCardNumberForSave(_cardNumberController.text),
        customColor: _selectedColor,
      ),
    );
    widget.onClose();
  }

  String? _formatCardNumberForSave(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return null;
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i != 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  Widget _buildColorChip(Color? color, String? label) {
    final colors = Theme.of(context).colorScheme;
    final isSelected = color == _selectedColor ||
        (color == null && _selectedColor == null);
    return InkWell(
      onTap: () {
        setState(() {
          _selectedColor = color;
        });
      },
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color ?? colors.background,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected ? colors.primary : Theme.of(context).dividerColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: label != null
            ? Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: colors.onBackground.withOpacity(0.8),
                ),
              )
            : const SizedBox(width: 16, height: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Backdrop
          GestureDetector(
            onTap: widget.onClose,
            child: Container(
              color: Colors.black.withOpacity(0.35),
            ),
          ),
          // Modal Content
          Center(
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 400),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.credit_card,
                              color: Color(0xFF0071E3),
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Редактировать карту',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF111827),
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: widget.onClose,
                          icon: const Icon(
                            Icons.close,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Card name
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Название карты',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _cardNameController,
                          style: const TextStyle(color: Color(0xFF111827)),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: colors.background,
                            prefixIcon: const Icon(
                              Icons.badge,
                              color: Color(0xFF6B7280),
                              size: 20,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF475569),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF475569),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF6366F1),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Bank name
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Банк',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _bankNameController,
                          style: const TextStyle(color: Color(0xFF111827)),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: colors.background,
                            prefixIcon: const Icon(
                              Icons.account_balance,
                              color: Color(0xFF6B7280),
                              size: 20,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF475569),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF475569),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF6366F1),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Card number
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Номер карты',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _cardNumberController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                            color: Color(0xFF111827),
                            letterSpacing: 3,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: colors.background,
                            prefixIcon: const Icon(
                              Icons.credit_card,
                              color: Color(0xFF6B7280),
                              size: 20,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF475569),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF475569),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF6366F1),
                              ),
                            ),
                            hintText: '0000 0000 0000 0000',
                            hintStyle: const TextStyle(
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Color picker
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Цвет карты',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildColorChip(null, 'Цвет банка'),
                            _buildColorChip(const Color(0xFF1E3A8A), null),
                            _buildColorChip(const Color(0xFF2563EB), null),
                            _buildColorChip(const Color(0xFF16A34A), null),
                            _buildColorChip(const Color(0xFFEF4444), null),
                            _buildColorChip(const Color(0xFFF59E0B), null),
                            _buildColorChip(const Color(0xFF8B5CF6), null),
                            _buildColorChip(const Color(0xFF0EA5E9), null),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _handleSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.save, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Сохранить',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
