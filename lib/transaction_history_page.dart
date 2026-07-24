import 'package:flutter/material.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();

  static const Color _bgDark = Color(0xFF121212);
  static const Color _cardDark = Color(0xFF1E1E1E);
  static const Color _accentGreen = Color(0xFF1DBF8A);

  final List<Map<String, String>> _filters = [
    {'label': 'All'},
    {'label': 'Credit'},
    {'label': 'Debit'},
  ];

  final Map<String, List<Map<String, String>>> _groupedTransactions = {
    'Today': [
      {'title': 'Data Purchase', 'subtitle': 'MTN 1GB', 'amount': '-₦500', 'time': '10:24 AM', 'type': 'debit'},
      {'title': 'Cashback', 'subtitle': 'Data voucher reward', 'amount': '+₦15', 'time': '10:25 AM', 'type': 'credit'},
    ],
    'Yesterday': [
      {'title': 'Wallet Funding', 'subtitle': 'Bank Transfer', 'amount': '+₦20,000', 'time': '3:12 PM', 'type': 'credit'},
      {'title': 'Airtime Purchase', 'subtitle': 'Airtel ₦200', 'amount': '-₦200', 'time': '9:05 AM', 'type': 'debit'},
    ],
    'Jul 20, 2026': [
      {'title': 'Electricity Bill', 'subtitle': 'IKEDC Prepaid', 'amount': '-₦5,000', 'time': '1:18 PM', 'type': 'debit'},
      {'title': 'Transfer to Bank', 'subtitle': 'GTBank •••• 1234', 'amount': '-₦10,000', 'time': '11:02 AM', 'type': 'debit'},
    ],
  };

  List<Map<String, String>> _filteredList(List<Map<String, String>> list) {
    if (_selectedFilter == 'All') return list;
    final type = _selectedFilter == 'Credit' ? 'credit' : 'debit';
    return list.where((tx) => tx['type'] == type).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildSearchField(),
            const SizedBox(height: 12),
            _buildFilterTabs(),
            const SizedBox(height: 12),
            Expanded(child: _buildTransactionsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const Text(
            'Transaction History',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.white54, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Search transactions',
                hintStyle: TextStyle(color: Colors.white38),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: _filters.map((f) {
          final bool selected = f['label'] == _selectedFilter;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () => setState(() => _selectedFilter = f['label']!),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? _accentGreen : _cardDark,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  f['label']!,
                  style: TextStyle(
                    color: selected ? Colors.black : Colors.white70,
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTransactionsList() {
    final entries = _groupedTransactions.entries
        .map((e) => MapEntry(e.key, _filteredList(e.value)))
        .where((e) => e.value.isNotEmpty)
        .toList();

    if (entries.isEmpty) {
      return const Center(
        child: Text('No transactions found', style: TextStyle(color: Colors.white38, fontSize: 14)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final group = entries[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(group.key, style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w600)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: _cardDark,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: group.value.asMap().entries.map((entry) {
                  final isLast = entry.key == group.value.length - 1;
                  return Column(
                    children: [
                      _transactionTile(entry.value),
                      if (!isLast) const Divider(color: Colors.white12, height: 1),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  Widget _transactionTile(Map<String, String> tx) {
    final bool isCredit = tx['type'] == 'credit';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isCredit ? _accentGreen.withOpacity(0.15) : const Color(0xFF3A1212),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
              color: isCredit ? _accentGreen : Colors.redAccent,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx['title']!, style: const TextStyle(color: Colors.white, fontSize: 14)),
                const SizedBox(height: 2),
                Text(tx['subtitle']!, style: const TextStyle(color: Colors.white54, fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                tx['amount']!,
                style: TextStyle(color: isCredit ? _accentGreen : Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(tx['time']!, style: const TextStyle(color: Colors.white38, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}
