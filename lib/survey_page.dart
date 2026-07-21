import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

/// Real integration with CPX Research's survey wall.
///
/// CPX Research (https://www.cpx-research.com) is a survey-wall provider —
/// sign up as a publisher there to get your own APP_ID and SECURE_HASH_KEY.
/// Docs: https://www.cpx-research.com/main/en/publisher
///
/// SETUP REQUIRED before this works:
/// 1. Create a CPX Research publisher account and get approved.
/// 2. Replace `_appId` and `_secureHash` below with your real values from
///    the CPX dashboard.
/// 3. Replace `_getUserId()` with your actual logged-in user's unique ID
///    (e.g. Firebase Auth UID) — CPX needs a stable, unique ext_user_id
///    per user so it can report completions back to the right person.
/// 4. Set up a webhook endpoint on YOUR BACKEND (not in this Flutter app)
///    that CPX calls when a survey is completed/verified. That webhook
///    receives ext_user_id + reward amount + a signed hash, verifies the
///    hash against your secure hash key, and only THEN credits the
///    user's wallet. Never credit the wallet from this Flutter screen —
///    a user could complete zero surveys and still have this webview
///    "look" like it finished, so the source of truth for payment must
///    be CPX's server-to-server callback to your backend, not this app
///    reporting its own completion.
class SurveyPage extends StatefulWidget {
  const SurveyPage({super.key});

  @override
  State<SurveyPage> createState() => _SurveyPageState();
}

class _SurveyPageState extends State<SurveyPage> {
  // TODO: Replace with your real CPX Research App ID (from your CPX
  // publisher dashboard).
  static const String _appId = "YOUR_CPX_APP_ID";

  // TODO: Replace with your real CPX Research Secure Hash Key (from your
  // CPX publisher dashboard). This is used to sign the request so CPX can
  // verify it's really coming from your app.
  static const String _secureHash = "YOUR_CPX_SECURE_HASH_KEY";

  late final WebViewController _webViewController;
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _setupWebView();
  }

  // TODO: Replace with your actual logged-in user's unique, stable ID
  // (e.g. FirebaseAuth.instance.currentUser!.uid). This must be unique
  // per user and never change, since CPX uses it to attribute completed
  // surveys to the correct wallet on your backend.
  String _getUserId() {
    return "REPLACE_WITH_REAL_USER_ID";
  }

  String _buildSurveyWallUrl() {
    final userId = _getUserId();

    // CPX Research requires a hash of ext_user_id + secure hash key to
    // verify requests are legitimate. This matches their documented
    // signature scheme.
    final hashInput = "$userId-$_secureHash";
    final signedHash = md5.convert(utf8.encode(hashInput)).toString();

    return "https://offers.cpx-research.com/index.php"
        "?app_id=$_appId"
        "&ext_user_id=$userId"
        "&secure_hash=$signedHash"
        "&subid_1=mamash_app";
  }

  void _setupWebView() {
    if (_appId == "YOUR_CPX_APP_ID" || _secureHash == "YOUR_CPX_SECURE_HASH_KEY") {
      setState(() {
        _isLoading = false;
        _loadError =
            "Survey provider isn't configured yet. Add your CPX Research App ID and Secure Hash Key in survey_page.dart.";
      });
      return;
    }

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) {
              setState(() {
                _isLoading = true;
                _loadError = null;
              });
            }
          },
          onPageFinished: (_) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onWebResourceError: (error) {
            if (mounted) {
              setState(() {
                _isLoading = false;
                _loadError = "Couldn't load surveys. Check your internet connection.";
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(_buildSurveyWallUrl()));
  }

  @override
  Widget build(BuildContext context) {
    final isConfigured = _appId != "YOUR_CPX_APP_ID" && _secureHash != "YOUR_CPX_SECURE_HASH_KEY";

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Paid Surveys"),
        centerTitle: true,
        backgroundColor: Colors.blue,
        actions: [
          if (isConfigured)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _loadError = null;
                });
                _webViewController.reload();
              },
            ),
        ],
      ),
      body: _loadError != null
          ? _buildErrorState()
          : Stack(
              children: [
                if (isConfigured) WebViewWidget(controller: _webViewController),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator()),
              ],
            ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_late_outlined, size: 60, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              _loadError!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }
}