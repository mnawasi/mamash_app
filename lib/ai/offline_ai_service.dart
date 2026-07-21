/// Offline fallback responder for Mamash's in-app assistant.
///
/// Matches user messages against keyword groups using word-boundary
/// regex (so short keywords like "hi" or "ai" don't falsely match
/// inside other words), then scores each category by number of
/// keyword hits and returns the best match.
class OfflineAIService {
  // Each entry: response text -> keywords that should trigger it.
  // Order doesn't matter anymore since we score instead of
  // first-match-wins, but keeping related categories together
  // makes this easier to maintain.
  static final List<_ResponseRule> _rules = [
    _ResponseRule(
      keywords: ["hello", "hi", "hey"],
      response: "Hello 👋 Welcome to Mamash! How can I help you today?",
    ),
    _ResponseRule(
      keywords: ["wallet", "add money", "deposit"],
      response:
          "To fund your wallet, open the Add Money page and choose Bank Transfer, Card, or USSD.",
    ),
    _ResponseRule(
      keywords: ["register", "signup", "sign up", "account"],
      response:
          "Create your Mamash account using your email, phone number, and password, then verify your email.",
    ),
    _ResponseRule(
      keywords: ["kyc", "verification", "verify"],
      response:
          "Complete face verification and upload the required details to unlock all wallet features.",
    ),
    _ResponseRule(
      keywords: ["survey"],
      response:
          "Survey Rewards allow you to earn money by completing surveys from our partners.",
    ),
    _ResponseRule(
      keywords: ["transfer"],
      response:
          "You can transfer money to other users or bank accounts after wallet funding is enabled.",
    ),
    _ResponseRule(
      keywords: ["airtime"],
      response:
          "Open the Airtime page, enter the phone number, select the network, and complete payment.",
    ),
    _ResponseRule(
      keywords: ["data", "buy data", "mobile data"],
      response: "You can buy mobile data for all supported networks inside Mamash.",
    ),
    _ResponseRule(
      keywords: ["ai", "gemini"],
      response:
          "I'm Mamash AI. Soon I'll be upgraded with Google's Gemini AI for smarter conversations.",
    ),
  ];

  static const String _defaultResponse =
      "Sorry, I don't understand that yet. Once Gemini AI is connected, I'll be able to answer many more questions.";

  /// Returns the best-matching canned response for [message].
  ///
  /// Scores every rule by how many of its keywords appear in the
  /// message (as whole words/phrases), then returns the response
  /// for the highest-scoring rule. Ties go to whichever rule is
  /// listed first. If nothing matches, returns the default response.
  static String getResponse(String message) {
    final text = message.toLowerCase().trim();
    if (text.isEmpty) return _defaultResponse;

    _ResponseRule? bestRule;
    int bestScore = 0;

    for (final rule in _rules) {
      final score = rule.scoreFor(text);
      if (score > bestScore) {
        bestScore = score;
        bestRule = rule;
      }
    }

    return bestRule?.response ?? _defaultResponse;
  }
}

class _ResponseRule {
  final List<String> keywords;
  final String response;

  _ResponseRule({required this.keywords, required this.response});

  /// Counts how many keywords appear in [text] as whole
  /// words/phrases (word-boundary match), so e.g. "ai" won't match
  /// inside "again" or "chair".
  int scoreFor(String text) {
    int score = 0;
    for (final keyword in keywords) {
      final pattern = RegExp(r'\b' + RegExp.escape(keyword) + r'\b');
      if (pattern.hasMatch(text)) {
        score++;
      }
    }
    return score;
  }
}