import 'package:flutter/material.dart';

class ReceiveMoneyPage extends StatelessWidget {
  const ReceiveMoneyPage({super.key});

  static const Color _bgDark = Color(0xFF121212);
  static const Color _cardDark = Color(0xFF1E1E1E);
  static const Color _accentGreen = Color(0xFF1DBF8A);

  static const String _accountNumber = '8137479520';
  static const String _accountName = 'Mamash Wallet';
  static const String _bankName = 'Mamash MFB';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildQrCard(),
                    const SizedBox(height: 16),
                    _buildAccountDetailsCard(context),
                    const SizedBox(height: 16),
                    _buildShareButton(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
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
            'Receive Money',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildQrCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const _QrPlaceholder(size: 180),
          ),
          const SizedBox(height: 16),
          const Text(
            _accountName,
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          const Text(
            'Scan to send money instantly',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountDetailsCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Or share your account details',
            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 14),
          _detailRow(context, 'Bank name', _bankName),
          const SizedBox(height: 12),
          _detailRow(context, 'Account number', _accountNumber, copyable: true),
          const SizedBox(height: 12),
          _detailRow(context, 'Account name', _accountName),
        ],
      ),
    );
  }

  Widget _detailRow(BuildContext context, String label, String value, {bool copyable = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF262626),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13)),
          Row(
            children: [
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
              if (copyable) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Account number copied')),
                    );
                  },
                  child: const Icon(Icons.copy, color: _accentGreen, size: 16),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShareButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.share_outlined, color: _accentGreen, size: 18),
          label: const Text('Share account details', style: TextStyle(color: _accentGreen)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: _accentGreen),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
        ),
      ),
    );
  }
}

class _QrPlaceholder extends StatelessWidget {
  final double size;
  const _QrPlaceholder({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _QrPatternPainter(),
      ),
    );
  }
}

class _QrPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black;
    const cells = 21;
    final cellSize = size.width / cells;
    final rand = List.generate(cells * cells, (i) => (i * 7 + i ~/ 3) % 5 == 0);

    for (int row = 0; row < cells; row++) {
      for (int col = 0; col < cells; col++) {
        final isFinder = (row < 7 && col < 7) ||
            (row < 7 && col >= cells - 7) ||
            (row >= cells - 7 && col < 7);
        if (isFinder) {
          final inBorder = row == 0 || row == 6 || col == 0 || col == 6 ||
              (row < 7 && col < 7 && row >= 2 && row <= 4 && col >= 2 && col <= 4);
          if (row < 7 && col < 7 && (inBorder || (row >= 2 && row <= 4 && col >= 2 && col <= 4))) {
            canvas.drawRect(Rect.fromLTWH(col * cellSize, row * cellSize, cellSize, cellSize), paint);
          }
        } else if (rand[row * cells + col]) {
          canvas.drawRect(Rect.fromLTWH(col * cellSize, row * cellSize, cellSize, cellSize), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
