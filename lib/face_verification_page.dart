import 'package:flutter/material.dart';

class FaceVerificationPage extends StatefulWidget {
  const FaceVerificationPage({super.key});

  @override
  State<FaceVerificationPage> createState() => _FaceVerificationPageState();
}

class _FaceVerificationPageState extends State<FaceVerificationPage> {
  bool _isCapturing = false;

  static const Color _bgDark = Color(0xFF121212);
  static const Color _cardDark = Color(0xFF1E1E1E);
  static const Color _accentGreen = Color(0xFF1DBF8A);

  final List<Map<String, dynamic>> _tips = [
    {'icon': Icons.wb_sunny_outlined, 'text': 'Find a well-lit area'},
    {'icon': Icons.visibility_outlined, 'text': 'Remove glasses or face coverings'},
    {'icon': Icons.center_focus_strong, 'text': 'Keep your face inside the frame'},
    {'icon': Icons.sentiment_satisfied_alt_outlined, 'text': 'Hold still and look straight ahead'},
  ];

  void _startCapture() {
    setState(() => _isCapturing = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isCapturing = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildIntroBanner(),
                    const SizedBox(height: 20),
                    _buildCameraPreview(),
                    const SizedBox(height: 20),
                    _buildTipsCard(),
                    const SizedBox(height: 24),
                    _buildActionButton(),
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const Text(
            'Face Verification',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildIntroBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Verify Your Identity',
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 14),
          ),
          SizedBox(height: 4),
          Text(
            'We just need a quick selfie to confirm it\'s really you',
            style: TextStyle(color: Colors.black54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    return Center(
      child: Container(
        width: 320,
        height: 320,
        decoration: BoxDecoration(
          color: _cardDark,
          shape: BoxShape.circle,
          border: Border.all(
            color: _isCapturing ? _accentGreen : Colors.white24,
            width: 3,
          ),
        ),
        child: Center(
          child: _isCapturing
              ? const CircularProgressIndicator(color: _accentGreen)
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.face_retouching_natural, color: Colors.white38, size: 64),
                    SizedBox(height: 10),
                    Text(
                      'Position your face here',
                      style: TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildTipsCard() {
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
            'Before you start',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          ..._tips.map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFF163A2E),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(tip['icon'], color: _accentGreen, size: 16),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        tip['text'],
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _isCapturing ? null : _startCapture,
          icon: const Icon(Icons.camera_alt_outlined),
          label: Text(_isCapturing ? 'Capturing...' : 'Start Verification'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _accentGreen,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
        ),
      ),
    );
  }
}
