import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/bank_constants.dart';
import '../data/bank_storage_service.dart';
import '../domain/models/bank.dart';
import 'widgets/bank_card.dart';
import 'widgets/active_session.dart';
import 'widgets/edit_card_modal.dart';
import 'widgets/marketplace.dart';
import 'widgets/smart_assistant.dart';

class BankHubPage extends StatefulWidget {
  const BankHubPage({super.key});

  @override
  State<BankHubPage> createState() => _BankHubPageState();
}

class _BankHubPageState extends State<BankHubPage> {
  final BankStorageService _storageService = BankStorageService();
  final TextEditingController _searchController = TextEditingController();
  
  Bank? _selectedBank;
  String _viewMode = 'stack'; // 'stack' or 'grid'
  List<Bank> _myBanks = [];
  bool _isPrivacyMode = false;
  bool _isMarketplaceOpen = false;
  Bank? _editingBank;
  int? _hoveredCardIndex;
  String _searchQuery = '';
  List<DepositOffer> _productOffers = [];

  @override
  void initState() {
    super.initState();
    _loadBanks();
    _loadProductOffers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBanks() async {
    final banks = await _storageService.loadBanks();
    setState(() {
      _myBanks = banks;
    });
  }

  Future<void> _saveBanks() async {
    await _storageService.saveBanks(_myBanks);
  }

  Future<void> _loadProductOffers() async {
    try {
      final raw =
          await rootBundle.loadString('assets/data/deposit_offers.json');
      final decoded = jsonDecode(raw) as List<dynamic>;
      final parsed = decoded
          .whereType<Map<String, dynamic>>()
          .map(DepositOffer.fromJson)
          .toList();
      if (mounted) {
        setState(() {
          _productOffers = parsed;
        });
      }
    } catch (_) {
      // Keep empty list if load fails
    }
  }


  int? _parseMinAmount(String text) {
    final match = RegExp(r'(\d+[\\s\\u00A0]*\\d*)').firstMatch(text);
    if (match == null) return null;
    final raw = match.group(1) ?? '';
    final normalized = raw.replaceAll(RegExp(r'[\\s\\u00A0]'), '');
    final value = int.tryParse(normalized);
    if (value == null) return null;
    return value;
  }

  int? _extractMonths(String text) {
    final match = RegExp(r'(\\d+)').firstMatch(text);
    if (match == null) return null;
    return int.tryParse(match.group(1) ?? '');
  }

  List<DepositOffer> get _smartFilteredOffers {
    final query = _searchQuery.trim().toLowerCase();
    final longTerm = _isLongTermQuery(query);
    final amount = _extractAmountFromQuery(query);

    final matches = _productOffers.where((offer) {
      if (query.isEmpty) return true;
      final haystack = [
        offer.name,
        offer.bankName,
        offer.rateText,
        offer.termText,
        offer.minAmountText,
      ].join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList();

    matches.sort((a, b) {
      final scoreA = _rankOffer(a, longTerm, amount);
      final scoreB = _rankOffer(b, longTerm, amount);
      return scoreB.compareTo(scoreA);
    });

    return matches;
  }

  bool _isLongTermQuery(String query) {
    return query.contains('длитель') ||
        query.contains('долг') ||
        query.contains('надол') ||
        query.contains('год') ||
        query.contains('лет') ||
        query.contains('срок');
  }

  int? _extractAmountFromQuery(String query) {
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

  int _rankOffer(DepositOffer offer, bool longTerm, int? amount) {
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

  bool _isLongTermOffer(String text) {
    final lower = text.toLowerCase();
    return lower.contains('долгоср') || lower.contains('на долгий срок');
  }

  List<Bank> get _availableBanks {
    return marketplaceBanks
        .where((mBank) => !_myBanks.any((myBank) => myBank.id == mBank.id))
        .toList();
  }

  void _handleAddBank(Bank bank) {
    setState(() {
      _myBanks = [..._myBanks, bank];
      _viewMode = 'stack';
      _isMarketplaceOpen = false;
    });
    _saveBanks();
  }

  void _handleUpdateBank(Bank updatedBank) {
    setState(() {
      _myBanks = _myBanks
          .map((b) => b.id == updatedBank.id ? updatedBank : b)
          .toList();
      _editingBank = null;
    });
    _saveBanks();
  }

  void _openProductFromOffer(DepositOffer offer) {
    Bank? bankRef;
    for (final bank in _myBanks) {
      if (bank.id == offer.bankId) {
        bankRef = bank;
        break;
      }
    }
    bankRef ??= initialBanks.firstWhere(
      (bank) => bank.id == offer.bankId,
      orElse: () => initialBanks.first,
    );
    if (bankRef.id != offer.bankId) {
      bankRef = marketplaceBanks.firstWhere(
        (bank) => bank.id == offer.bankId,
        orElse: () => bankRef!,
      );
    }

    final query = Uri.encodeComponent(offer.urlQuery);
    final url = offer.bankId == 'tbank'
        ? 'https://www.tbank.ru/search/?query=$query'
        : 'https://www.gazprombank.ru/search/?q=$query';

    setState(() {
      _selectedBank = Bank(
        id: '${offer.bankId}-${offer.urlQuery}',
        name: '${bankRef?.name ?? offer.bankName} • ${offer.name}',
        cardName: offer.name,
        description: offer.name,
        url: url,
        theme: bankRef!.theme,
        logoText: bankRef.logoText,
        features: bankRef.features,
        cardNumber: bankRef.cardNumber,
        customColor: bankRef.customColor,
        balance: bankRef.balance,
        currency: bankRef.currency,
        cardHolder: bankRef.cardHolder,
        last4: bankRef.last4,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          // Main Content
          AnimatedOpacity(
            opacity: _selectedBank != null ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: Column(
              children: [
                // Header
                Container(
                  decoration: BoxDecoration(
                    color: colors.surface,
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      child: Row(
                        children: [
                          // Logo
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6366F1), // indigo-600
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.account_balance_wallet,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'AnyBank',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: colors.onBackground,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          // Controls
                          Row(
                            children: [
                              // Privacy Toggle
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _isPrivacyMode = !_isPrivacyMode;
                                  });
                                },
                                icon: Icon(
                                  _isPrivacyMode
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: _isPrivacyMode
                                      ? colors.primary
                                      : colors.onBackground.withOpacity(0.6),
                                ),
                                tooltip: _isPrivacyMode
                                    ? 'Show sensitive data'
                                    : 'Hide sensitive data',
                              ),
                              // View Toggle
                              Container(
                                decoration: BoxDecoration(
                                  color: colors.surface,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Theme.of(context).dividerColor,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    _buildViewToggleButton(
                                      icon: Icons.layers,
                                      mode: 'stack',
                                      tooltip: 'Wallet View',
                                    ),
                                    _buildViewToggleButton(
                                      icon: Icons.grid_view,
                                      mode: 'grid',
                                      tooltip: 'Grid View',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Main Content
                Expanded(
                  child: DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        const TabBar(
                          tabs: [
                            Tab(text: 'Банки'),
                            Tab(text: 'Продукты'),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              // Banks tab
                              SingleChildScrollView(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Все твои банки',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        color: colors.onBackground,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _viewMode == 'stack'
                                          ? 'Нажмите на карту, чтобы открыть защищённый доступ к банку.'
                                          : 'Выберите банк для безопасного доступа к финансам.',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: colors.onBackground.withOpacity(0.6),
                                      ),
                                    ),
                                    const SizedBox(height: 32),
                                    _viewMode == 'grid'
                                        ? _buildGridView()
                                        : _buildStackView(),
                                    const SizedBox(height: 32),
                                    _buildSecurityOverview(),
                                  ],
                                ),
                              ),
                              // Products tab
                              SingleChildScrollView(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Продукты банков',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        color: colors.onBackground,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Сравните условия вкладов и накопительных счетов.',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: colors.onBackground.withOpacity(0.6),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    _buildSearchField(),
                                    const SizedBox(height: 16),
                                    if (_productOffers.isEmpty)
                                      Text(
                                        'Список продуктов пока не загружен.',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: colors.onBackground.withOpacity(0.5),
                                        ),
                                      )
                                    else if (_smartFilteredOffers.isEmpty)
                                      Text(
                                        'Нет продуктов по запросу.',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: colors.onBackground.withOpacity(0.5),
                                        ),
                                      )
                                    else
                                      Column(
                                        children: _smartFilteredOffers
                                            .map(_buildProductPreview)
                                            .toList(),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Active Session (WebView)
          if (_selectedBank != null)
            ActiveSessionWidget(
              bank: _selectedBank!,
              onClose: () {
                setState(() {
                  _selectedBank = null;
                });
              },
            ),
          // Edit Card Modal
          if (_editingBank != null)
            EditCardModal(
              bank: _editingBank!,
              onClose: () {
                setState(() {
                  _editingBank = null;
                });
              },
              onSave: _handleUpdateBank,
            ),
          // Marketplace
          MarketplaceWidget(
            isOpen: _isMarketplaceOpen,
            onClose: () {
              setState(() {
                _isMarketplaceOpen = false;
              });
            },
            availableBanks: _availableBanks,
            onAddBank: _handleAddBank,
          ),
          // Smart Assistant (moved inline to products tab)
        ],
      ),
    );
  }

  Widget _buildViewToggleButton({
    required IconData icon,
    required String mode,
    required String tooltip,
  }) {
    final colors = Theme.of(context).colorScheme;
    final isSelected = _viewMode == mode;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _viewMode = mode;
            });
          },
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isSelected
                  ? colors.primary.withOpacity(0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              size: 20,
              color: isSelected
                  ? colors.primary
                  : colors.onBackground.withOpacity(0.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    final colors = Theme.of(context).colorScheme;
    return TextField(
      controller: _searchController,
      style: TextStyle(color: colors.onBackground),
      textInputAction: TextInputAction.search,
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
      onTap: () {},
      decoration: InputDecoration(
        hintText: 'Поиск по продуктам и задачам...',
        hintStyle: TextStyle(
          fontSize: 14,
          color: colors.onBackground.withOpacity(0.4),
        ),
        filled: true,
        fillColor: colors.surface,
        prefixIcon: Icon(
          Icons.auto_awesome,
          size: 16,
          color: colors.onBackground.withOpacity(0.6),
        ),
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: Theme.of(context).dividerColor,
              ),
            ),
            child: Text(
              'AI',
              style: TextStyle(
                fontSize: 10,
                color: colors.onBackground.withOpacity(0.6),
              ),
            ),
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colors.primary,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
    );
  }

  // Filters moved into Smart Assistant

  Widget _buildProductPreview(DepositOffer offer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _openProductFromOffer(offer),
        borderRadius: BorderRadius.circular(16),
        child: _buildProductCard(offer),
      ),
    );
  }

  Widget _buildProductCard(DepositOffer offer) {
    final theme = _themeForBankId(offer.bankId);
    final gradient = theme?.gradient ??
        const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    final textColor = theme?.textColor ?? Colors.white;

    return Container(
      height: BankCardWidget.cardHeight,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.12),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  offer.bankName,
                  style: TextStyle(
                    fontSize: 12,
                    color: textColor,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  offer.rateText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            offer.name,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            offer.termText,
            style: TextStyle(
              fontSize: 13,
              color: textColor.withOpacity(0.85),
            ),
          ),
          const Spacer(),
          Text(
            'Минимальная сумма: ${offer.minAmountText}',
            style: TextStyle(
              fontSize: 12,
              color: textColor.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  BankTheme? _themeForBankId(String bankId) {
    for (final bank in _myBanks) {
      if (bank.id == bankId) return bank.theme;
    }
    for (final bank in initialBanks) {
      if (bank.id == bankId) return bank.theme;
    }
    for (final bank in marketplaceBanks) {
      if (bank.id == bankId) return bank.theme;
    }
    return null;
  }

  Widget _buildGridView() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.586,
      ),
      itemCount: _myBanks.length + 1,
      itemBuilder: (context, index) {
        if (index == _myBanks.length) {
          // "Add New" Placeholder Card
          return LayoutBuilder(
            builder: (context, constraints) {
              return InkWell(
                onTap: () {
                  setState(() {
                    _isMarketplaceOpen = true;
                  });
                },
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).dividerColor,
                      style: BorderStyle.solid,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.background,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.add,
                          size: 28,
                          color: Theme.of(context)
                              .colorScheme
                              .onBackground
                              .withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Добавить новый банк',
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onBackground
                              .withOpacity(0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
        return LayoutBuilder(
          builder: (context, constraints) {
            return BankCardWidget(
              bank: _myBanks[index],
              style: BoxStyle(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
              ),
              onTap: () {
                setState(() {
                  _selectedBank = _myBanks[index];
                });
              },
              onEdit: () {
                setState(() {
                  _editingBank = _myBanks[index];
                });
              },
              isPrivacyMode: _isPrivacyMode,
            );
          },
        );
      },
    );
  }

  static const double _stackCardPeek = 64;
  static const double _stackHoverScale = 1.015;
  static const Duration _stackHoverDuration = Duration(milliseconds: 320);
  static const double _stackButtonGap = 12;
  static const double _stackButtonHeight = 96;

  Widget _buildStackView() {
    if (_myBanks.isEmpty) {
      return const SizedBox.shrink();
    }

    final n = _myBanks.length;
    final cardHeight = BankCardWidget.cardHeight;
    final stackHeight = cardHeight + (n - 1) * _stackCardPeek;
    final buttonTop = stackHeight + _stackButtonGap;
    final contentHeight = buttonTop + _stackButtonHeight;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: SizedBox(
          height: contentHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
            // Cards stack with slight overlap
            ...(() {
              final entries = _myBanks.asMap().entries.toList();
                return entries.map((entry) {
                final index = entry.key;
                final bank = entry.value;
                final isHovered = index == _hoveredCardIndex;
                  final top = index * _stackCardPeek;
                  return Positioned(
                    top: top,
                    left: 0,
                    right: 0,
                    child: MouseRegion(
                      onEnter: (_) {
                        if (_hoveredCardIndex != index) {
                          setState(() {
                            _hoveredCardIndex = index;
                          });
                        }
                      },
                      onExit: (_) {
                        setState(() {
                          _hoveredCardIndex = null;
                        });
                      },
                      child: GestureDetector(
                        onTapDown: (_) {
                          setState(() {
                            _hoveredCardIndex = index;
                          });
                        },
                        onTapUp: (_) {
                          setState(() {
                            _hoveredCardIndex = null;
                          });
                        },
                        onTapCancel: () {
                          setState(() {
                            _hoveredCardIndex = null;
                          });
                        },
                        child: AnimatedScale(
                          duration: _stackHoverDuration,
                          curve: Curves.easeOutQuart,
                          scale: isHovered ? _stackHoverScale : 1,
                          alignment: Alignment.topCenter,
                          child: BankCardWidget(
                            bank: bank,
                            onTap: () {
                              setState(() {
                                _selectedBank = bank;
                              });
                            },
                            onEdit: () {
                              setState(() {
                                _editingBank = bank;
                              });
                            },
                            isPrivacyMode: _isPrivacyMode,
                          ),
                        ),
                      ),
                    ),
                  );
              }).toList();
            })(),
              // "Add to Wallet" Button
              Positioned(
                top: buttonTop,
                left: 0,
                right: 0,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _isMarketplaceOpen = true;
                    });
                  },
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  child: Container(
                    height: _stackButtonHeight,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      border: Border(
                        top: BorderSide(
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add,
                          color: Theme.of(context)
                              .colorScheme
                              .onBackground
                              .withOpacity(0.6),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Добавить новый банк',
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onBackground
                                .withOpacity(0.6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityOverview() {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Безопасность',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: colors.onBackground,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSecurityCard(
                  icon: Icons.shield,
                  title: 'Шифрование',
                  description: 'Соединения защищены TLS банковского уровня.',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSecurityCard(
                  icon: Icons.credit_card,
                  title: 'Приватность',
                  description: 'Данные доступа не хранятся на устройстве.',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSecurityCard(
                  icon: Icons.account_balance_wallet,
                  title: 'Проверено',
                  description: 'Только официальные банковские шлюзы.',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: colors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: colors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: colors.onBackground.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}
