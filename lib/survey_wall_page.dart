import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SurveyWallPage extends StatefulWidget {
  const SurveyWallPage({super.key});

  @override
  State<SurveyWallPage> createState() => _SurveyWallPageState();
}

class _SurveyWallPageState extends State<SurveyWallPage> {
  // TODO: replace with your actual CPX Research App ID once approved
  static const String _cpxAppId = '36211';

  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();

    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'unknown_user';

    // CPX's standard survey list URL format
    final surveyUrl =
        'https://offers.cpx-research.com/index.php'
        '?app_id=$_cpxAppId'
        '&ext_user_id=$uid';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _loading = true),
          onPageFinished: (_) => setState(() => _loading = false),
        ),
      )
      ..loadRequest(Uri.parse(surveyUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Earn Rewards', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFF1DBF8A)),
            ),
        ],
      ),
    );
  }
}
