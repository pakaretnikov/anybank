import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SmartAssistantWidget extends StatefulWidget {
  const SmartAssistantWidget({
    super.key,
    required this.isOpen,
    required this.onClose,
    required this.onOpenProduct,
    required this.query,
    required this.onQueryChanged,
  });

  final bool isOpen;
  final VoidCallback onClose;
  final ValueChanged<DepositOffer> onOpenProduct;
  final String query;
  final ValueChanged<String> onQueryChanged;

  @override
  State<SmartAssistantWidget> createState() => _SmartAssistantWidgetState();
}

class _SmartAssistantWidgetState extends State<SmartAssistantWidget> {
  final TextEditingController _controller = TextEditingController();
  final ValueNotifier<List<DepositOffer>> _results =
      ValueNotifier<List<DepositOffer>>([]);
  String _termFilter = 'Любой срок';
  String _currencyFilter = 'Любая';
  int? _amountFilter;

  static const List<DepositOffer> _fallbackOffers = [
    DepositOffer(
      bankId: 'gpb',
      bankName: 'Газпромбанк',
      name: 'Вклад «Новые деньги»',
      rateText: 'до 15,1% годовых',
      termText: '2–36 месяцев',
      minAmountText: 'от 10 000 ₽',
      urlQuery: 'Вклад Новые деньги',
      type: OfferType.deposit,
    ),
    DepositOffer(
      bankId: 'gpb',
      bankName: 'Газпромбанк',
      name: 'Вклад «Перспективные сбережения»',
      rateText: 'до 18,5% годовых',
      termText: 'программа долгосрочных сбережений',
      minAmountText: 'уточняйте на сайте',
      urlQuery: 'Вклад Перспективные сбережения',
      type: OfferType.deposit,
    ),
    DepositOffer(
      bankId: 'gpb',
      bankName: 'Газпромбанк',
      name: 'Накопительный счёт',
      rateText: 'до 16,2% годовых',
      termText: 'пополнение и снятие',
      minAmountText: 'от 1 ₽',
      urlQuery: 'Накопительный счет',
      type: OfferType.savingsAccount,
    ),
    DepositOffer(
      bankId: 'gpb',
      bankName: 'Газпромбанк',
      name: 'Накопительный счёт «Лёгкий процент»',
      rateText: 'ставка по условиям',
      termText: 'проценты ежедневно',
      minAmountText: 'от 1 ₽',
      urlQuery: 'Накопительный счет Легкий процент',
      type: OfferType.savingsAccount,
    ),
    DepositOffer(
      bankId: 'gpb',
      bankName: 'Газпромбанк',
      name: 'Накопительный счёт «Ежедневный процент»',
      rateText: 'ставка по условиям',
      termText: 'ежедневное начисление',
      minAmountText: 'от 1 ₽',
      urlQuery: 'Накопительный счет Ежедневный процент',
      type: OfferType.savingsAccount,
    ),
    DepositOffer(
      bankId: 'gpb',
      bankName: 'Газпромбанк',
      name: 'Вклад «Ключевой момент»',
      rateText: 'ставка по условиям',
      termText: 'фиксированная ставка',
      minAmountText: 'от 10 000 ₽',
      urlQuery: 'Вклад Ключевой момент',
      type: OfferType.deposit,
    ),
    DepositOffer(
      bankId: 'gpb',
      bankName: 'Газпромбанк',
      name: 'Вклад «Копить»',
      rateText: 'ставка по условиям',
      termText: 'фиксированная ставка',
      minAmountText: 'от 10 000 ₽',
      urlQuery: 'Вклад Копить',
      type: OfferType.deposit,
    ),
    DepositOffer(
      bankId: 'gpb',
      bankName: 'Газпромбанк',
      name: 'Вклад «В Плюсе»',
      rateText: 'ставка по условиям',
      termText: 'доп. условия для клиентов',
      minAmountText: 'от 10 000 ₽',
      urlQuery: 'Вклад В Плюсе',
      type: OfferType.deposit,
    ),
    DepositOffer(
      bankId: 'gpb',
      bankName: 'Газпромбанк',
      name: 'Вклад в юанях',
      rateText: 'ставка по условиям',
      termText: 'валютный вклад',
      minAmountText: 'от 100 ¥',
      urlQuery: 'Вклад в юанях',
      type: OfferType.deposit,
    ),
    DepositOffer(
      bankId: 'gpb',
      bankName: 'Газпромбанк',
      name: 'Социальный вклад',
      rateText: 'ставка по условиям',
      termText: 'социальные программы',
      minAmountText: 'по условиям банка',
      urlQuery: 'Социальный вклад',
      type: OfferType.deposit,
    ),
  ];

  List<DepositOffer> _offers = [];

  @override
  void initState() {
    super.initState();
    _offers = List<DepositOffer>.from(_fallbackOffers);
    _loadOffers();
    if (widget.query.isNotEmpty) {
      _controller.text = widget.query;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
      _runSearch(widget.query);
    }
  }

  @override
  void didUpdateWidget(covariant SmartAssistantWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.query != oldWidget.query && widget.query != _controller.text) {
      _controller.text = widget.query;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
      if (widget.query.isEmpty) {
        _results.value = [];
      } else {
        _runSearch(widget.query);
      }
    }
  }

  Future<void> _loadOffers() async {
    try {
      final raw = await rootBundle.loadString(
        'assets/data/deposit_offers.json',
      );
      final decoded = jsonDecode(raw) as List<dynamic>;
      final parsed = decoded
          .whereType<Map<String, dynamic>>()
          .map(DepositOffer.fromJson)
          .toList();
      if (parsed.isNotEmpty && mounted) {
        setState(() {
          _offers = parsed;
        });
      }
    } catch (_) {
      // Fallback to bundled defaults
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _results.dispose();
    super.dispose();
  }

  void _runSearch(String rawQuery) {
    final query = rawQuery.trim().toLowerCase();
    if (query.isEmpty) {
      _results.value = [];
      return;
    }

    final wantsDeposit = query.contains('вклад') ||
        query.contains('депозит') ||
        query.contains('приумнож') ||
        query.contains('вложить') ||
        query.contains('сохран') ||
        query.contains('накоп') ||
        query.contains('процент') ||
        query.contains('ставк');

    final amount = _extractAmount(query);
    final longTerm = _isLongTerm(query);
    final currency = _extractCurrencyFromQuery(query);

    if (longTerm && _termFilter == 'Любой срок') {
      setState(() {
        _termFilter = '12+ мес';
      });
    }
    if (currency != null && _currencyFilter == 'Любая') {
      setState(() {
        _currencyFilter = currency;
      });
    }
    if (amount != null && _amountFilter == null) {
      setState(() {
        _amountFilter = amount;
      });
    }

    final matches = _offers.where((offer) {
      if (wantsDeposit) {
        return offer.type == OfferType.deposit ||
            offer.type == OfferType.savingsAccount;
      }
      return true;
    }).toList();

    final filtered = matches.where((offer) {
      if (_termFilter != 'Любой срок') {
        final months = _extractMonths(offer.termText);
        if (months == null && !_isLongTermOffer(offer.termText)) {
          return false;
        }
        if (_termFilter == 'до 6 мес' && months != null && months > 6) {
          return false;
        }
        if (_termFilter == '6–12 мес' &&
            months != null &&
            (months < 6 || months > 12)) {
          return false;
        }
        if (_termFilter == '12+ мес' && months != null && months < 12) {
          return false;
        }
      }

      if (_currencyFilter != 'Любая') {
        final offerCurrency = _extractCurrency(offer.minAmountText);
        if (offerCurrency != _currencyFilter) return false;
      }

      if (_amountFilter != null) {
        final minAmount = _parseMinAmount(offer.minAmountText);
        if (minAmount != null && _amountFilter! < minAmount) {
          return false;
        }
      }

      return true;
    }).toList();

    filtered.sort((a, b) {
      final scoreA = _rankScore(a, longTerm, amount);
      final scoreB = _rankScore(b, longTerm, amount);
      return scoreB.compareTo(scoreA);
    });

    _results.value = filtered.take(8).toList();

    if (amount != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Учту сумму ~${_formatAmount(amount)} ₽ при подборе.'),
        ),
      );
    }
  }

  int? _extractAmount(String query) {
    final match = RegExp(
      r'(\\d+[\\s\\u00A0]*\\d*)(\\s*)(тыс|тысяч|млн|миллион|миллиона)?',
    ).firstMatch(query);
    if (match == null) return null;
    final raw = match.group(1) ?? '';
    final normalized = raw.replaceAll(RegExp(r'[\\s\\u00A0]'), '');
    final value = int.tryParse(normalized);
    if (value == null) return null;
    final unit = match.group(3);
    if (unit == null) return value;
    if (unit.startsWith('тыс')) return value * 1000;
    if (unit.startsWith('млн') || unit.startsWith('миллион')) {
      return value * 1000000;
    }
    return value;
  }

  String _formatAmount(int value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)} млн';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)} тыс';
    }
    return value.toString();
  }

  bool _isLongTerm(String query) {
    return query.contains('длитель') ||
        query.contains('долг') ||
        query.contains('надол') ||
        query.contains('год') ||
        query.contains('лет') ||
        query.contains('срок');
  }

  String? _extractCurrencyFromQuery(String query) {
    if (query.contains('руб')) return '₽';
    if (query.contains('₽')) return '₽';
    if (query.contains('доллар') || query.contains('usd') || query.contains('\$')) {
      return '\$';
    }
    if (query.contains('евро') || query.contains('eur') || query.contains('€')) {
      return '€';
    }
    if (query.contains('юан') || query.contains('cny') || query.contains('¥')) {
      return '¥';
    }
    return null;
  }

  int _rankScore(DepositOffer offer, bool longTerm, int? amount) {
    var score = offer.score;
    if (longTerm) {
      final months = _extractMonths(offer.termText);
      if ((months != null && months >= 12) || _isLongTermOffer(offer.termText)) {
        score += 15;
      }
    }
    if (amount != null) {
      final minAmount = _parseMinAmount(offer.minAmountText);
      if (minAmount != null && amount >= minAmount) score += 5;
    }
    return score;
  }

  int? _extractMonths(String text) {
    final matches = RegExp(r'(\\d+)').allMatches(text);
    if (matches.isEmpty) return null;
    var maxValue = 0;
    for (final match in matches) {
      final value = int.tryParse(match.group(1) ?? '');
      if (value != null && value > maxValue) {
        maxValue = value;
      }
    }
    return maxValue == 0 ? null : maxValue;
  }

  bool _isLongTermOffer(String text) {
    final lower = text.toLowerCase();
    return lower.contains('долгоср') || lower.contains('на долгий срок');
  }

  String? _extractCurrency(String text) {
    if (text.contains('₽')) return '₽';
    if (text.contains('\$')) return '\$';
    if (text.contains('€')) return '€';
    if (text.contains('¥')) return '¥';
    return null;
  }

  int? _parseMinAmount(String text) {
    final match = RegExp(r'(\\d+[\\s\\u00A0]*\\d*)').firstMatch(text);
    if (match == null) return null;
    final raw = match.group(1) ?? '';
    final normalized = raw.replaceAll(RegExp(r'[\\s\\u00A0]'), '');
    final value = int.tryParse(normalized);
    if (value == null) return null;
    return value;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isOpen) return const SizedBox.shrink();

    final suggestions = [
      'У меня есть 100 тыс рублей, как лучше приумножить?',
      'Какие вклады сейчас с лучшей ставкой?',
      'Подбери безопасный вклад на 6 месяцев',
      'Хочу накопительный счёт с возможностью снятия',
    ];

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Backdrop
          GestureDetector(
            onTap: widget.onClose,
            child: Container(
              color: const Color(0xFF0F172A).withOpacity(0.9),
            ),
          ),
          // Modal Window
          Center(
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 700, maxHeight: 600),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B), // slate-900
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFF334155), // slate-800
                ),
              ),
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.auto_awesome,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Умный помощник',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Онлайн • Подбор вкладов',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white.withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: widget.onClose,
                          icon: const Icon(
                            Icons.close,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Content Area
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _controller,
                            style: const TextStyle(color: Colors.white),
                            textInputAction: TextInputAction.search,
                            onChanged: (value) {
                              widget.onQueryChanged(value);
                              _runSearch(value);
                            },
                            onSubmitted: (value) {
                              widget.onQueryChanged(value);
                              _runSearch(value);
                            },
                            decoration: InputDecoration(
                              hintText:
                                  'Например: «у меня есть 100 тыс рублей, какой вклад лучше?»',
                              hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                              ),
                              filled: true,
                              fillColor: const Color(0xFF0F172A),
                              prefixIcon: const Icon(
                                Icons.search,
                                color: Color(0xFF94A3B8),
                              ),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  _controller.clear();
                                  _results.value = [];
                                },
                                icon: const Icon(
                                  Icons.close,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: Color(0xFF334155),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: Color(0xFF334155),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: Color(0xFF6366F1),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Данные: локальный список (gazprombank.ru, tbank.ru)',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.5),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildFilterChips(),
                          const SizedBox(height: 16),
                          ValueListenableBuilder<List<DepositOffer>>(
                            valueListenable: _results,
                            builder: (context, results, _) {
                              if (results.isEmpty) {
                                return Expanded(
                                  child: ListView(
                                    children: [
                                      _buildIntro(),
                                      const SizedBox(height: 24),
                                      ...suggestions.map(
                                        (suggestion) => _buildSuggestion(
                                          suggestion,
                                          () => _runSearch(suggestion),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              return Expanded(
                                child: ListView.separated(
                                  itemCount: results.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final offer = results[index];
                                    return _buildOfferCard(offer);
                                  },
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntro() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFF334155),
            ),
          ),
          child: const Icon(
            Icons.smart_toy,
            size: 40,
            color: Color(0xFF818CF8),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Чем помочь?',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Подберу подходящие вклады и накопительные счета Газпромбанка под вашу задачу.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestion(String text, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF334155),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward,
                size: 16,
                color: Colors.white.withOpacity(0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildChoiceChip(
          label: _termFilter,
          selected: true,
          onTap: () => _showTermSheet(),
        ),
        _buildChoiceChip(
          label: _currencyFilter == 'Любая' ? 'Валюта' : _currencyFilter,
          selected: _currencyFilter != 'Любая',
          onTap: () => _showCurrencySheet(),
        ),
        _buildChoiceChip(
          label: _amountFilter == null
              ? 'Сумма'
              : 'До ${_formatAmount(_amountFilter!)} ₽',
          selected: _amountFilter != null,
          onTap: () => _showAmountSheet(),
        ),
      ],
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF6366F1) : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? const Color(0xFF6366F1) : const Color(0xFF334155),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: selected ? Colors.white : Colors.white.withOpacity(0.7),
          ),
        ),
      ),
    );
  }

  Future<void> _showTermSheet() async {
    final value = await _showSimpleSheet(
      title: 'Срок',
      options: const ['Любой срок', 'до 6 мес', '6–12 мес', '12+ мес'],
      current: _termFilter,
    );
    if (value != null) {
      setState(() {
        _termFilter = value;
      });
      _runSearch(_controller.text);
    }
  }

  Future<void> _showCurrencySheet() async {
    final value = await _showSimpleSheet(
      title: 'Валюта',
      options: const ['Любая', '₽', '\$', '€', '¥'],
      current: _currencyFilter,
    );
    if (value != null) {
      setState(() {
        _currencyFilter = value;
      });
      _runSearch(_controller.text);
    }
  }

  Future<void> _showAmountSheet() async {
    final controller = TextEditingController(
      text: _amountFilter?.toString() ?? '',
    );
    final value = await showModalBottomSheet<int?>(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Максимальная сумма',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Например: 100000',
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                  ),
                  filled: true,
                  fillColor: const Color(0xFF1E293B),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF334155),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF334155),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(null),
                    child: const Text('Сбросить'),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      final parsed = int.tryParse(
                        controller.text.replaceAll(RegExp(r'\\D'), ''),
                      );
                      Navigator.of(context).pop(parsed);
                    },
                    child: const Text('Применить'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (value != null || value == null) {
      setState(() {
        _amountFilter = value;
      });
      _runSearch(_controller.text);
    }
  }

  Future<String?> _showSimpleSheet({
    required String title,
    required List<String> options,
    required String current,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              ...options.map((option) {
                final selected = option == current;
                return ListTile(
                  onTap: () => Navigator.of(context).pop(option),
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    option,
                    style: TextStyle(
                      color: selected ? Colors.white : Colors.white.withOpacity(0.7),
                    ),
                  ),
                  trailing: selected
                      ? const Icon(Icons.check, color: Colors.white)
                      : null,
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOfferCard(DepositOffer offer) {
    return InkWell(
      onTap: () => widget.onOpenProduct(offer),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF334155),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              offer.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildChip(offer.rateText),
                const SizedBox(width: 8),
                _buildChip(offer.termText),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Минимальная сумма: ${offer.minAmountText}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.open_in_new,
                  size: 14,
                  color: Color(0xFF94A3B8),
                ),
                const SizedBox(width: 6),
                Text(
                  'Открыть продукт на сайте',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: const Color(0xFF334155),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: Colors.white.withOpacity(0.7),
        ),
      ),
    );
  }
}

enum OfferType { deposit, savingsAccount }

class DepositOffer {
  const DepositOffer({
    required this.bankId,
    required this.bankName,
    required this.name,
    required this.rateText,
    required this.termText,
    required this.minAmountText,
    required this.urlQuery,
    required this.type,
  });

  final String bankId;
  final String bankName;
  final String name;
  final String rateText;
  final String termText;
  final String minAmountText;
  final String urlQuery;
  final OfferType type;

  factory DepositOffer.fromJson(Map<String, dynamic> json) {
    return DepositOffer(
      bankId: json['bankId'] as String,
      bankName: json['bankName'] as String,
      name: json['name'] as String,
      rateText: json['rateText'] as String,
      termText: json['termText'] as String,
      minAmountText: json['minAmountText'] as String,
      urlQuery: json['urlQuery'] as String,
      type: _offerTypeFromString(json['type'] as String),
    );
  }

  int get score {
    if (rateText.contains('18,5')) return 90;
    if (rateText.contains('16,2')) return 80;
    if (rateText.contains('15,1')) return 75;
    return 50;
  }
}

OfferType _offerTypeFromString(String raw) {
  switch (raw) {
    case 'deposit':
      return OfferType.deposit;
    case 'savingsAccount':
      return OfferType.savingsAccount;
    default:
      return OfferType.deposit;
  }
}
