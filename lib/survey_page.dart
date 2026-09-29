import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SurveyPage extends StatefulWidget {
  const SurveyPage({super.key});

  @override
  State<SurveyPage> createState() => _SurveyPageState();
}

enum _QType { rating, choice, text }

class _SurveyQuestion {
  final String title;
  final _QType type;
  final List<String>? options;
  const _SurveyQuestion(this.title, this.type, {this.options});
}

class _SurveyPageState extends State<SurveyPage> {
  static const Color _bgDark = Color(0xFF121212);
  static const Color _cardDark = Color(0xFF1E1E1E);
  static const Color _accentGreen = Color(0xFF1DBF8A);

  int _currentStep = 0;
  bool _submitting = false;

  final List<_SurveyQuestion> _questions = const [
    _SurveyQuestion('How would you rate your experience?', _QType.rating),
    _SurveyQuestion(
      'What did you like most?',
      _QType.choice,
      options: ['Ease of use', 'Customer support', 'Pricing', 'Speed'],
    ),
    _SurveyQuestion(
      'How likely are you to recommend Mamash Pay?',
      _QType.choice,
      options: ['Very likely', 'Likely', 'Not sure', 'Unlikely'],
    ),
    _SurveyQuestion('Any additional feedback?', _QType.text),
  ];

  int get _totalSteps => _questions.length;

  // answers[stepIndex] = int (rating) | String (choice) | String (text)
  final Map<int, dynamic> _answers = {};

  final TextEditingController _feedbackController = TextEditingController();

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _goNext() async {
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
    } else {
      await _submitSurvey();
    }
  }

  Future<void> _submitSurvey() async {
    setState(() => _submitting = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('Not signed in');

      await FirebaseFirestore.instance.collection('survey_responses').add({
        'userId': uid,
        'answers': _answers.map((k, v) => MapEntry(k.toString(), v)),
        'submittedAt': FieldValue.serverTimestamp(),
      });

      // TODO: trigger your survey rewards backend here
      // e.g. await FirebaseFunctions.instance
      //     .httpsCallable('grantSurveyReward')
      //     .call({'userId': uid});

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Submission failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildProgressBar(),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildQuestionCard(),
                ),
              ),
            ),
            _buildNextButton(),
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
            'Customer Feedback Survey',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = (_currentStep + 1) / _totalSteps;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Question ${_currentStep + 1} of $_totalSteps',
              style: const TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: const Color(0xFF2A2A2A),
              valueColor: const AlwaysStoppedAnimation<Color>(_accentGreen),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildQuestionCard() {
    final q = _questions[_currentStep];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            q.title,
            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 14),
          if (q.type == _QType.rating) _buildRating(),
          if (q.type == _QType.choice) ...q.options!.expand((o) => _choiceTile(o)),
          if (q.type == _QType.text) _buildTextField(),
        ],
      ),
    );
  }

  Widget _buildRating() {
    final current = (_answers[_currentStep] ?? 0) as int;
    return Row(
      children: List.generate(5, (i) {
        return IconButton(
          onPressed: () => setState(() => _answers[_currentStep] = i + 1),
          icon: Icon(
            i < current ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 28,
          ),
        );
      }),
    );
  }

  Widget _buildTextField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF262626),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: _feedbackController,
        maxLines: 3,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: const InputDecoration(
          hintText: 'Tell us more...',
          hintStyle: TextStyle(color: Colors.white38),
          border: InputBorder.none,
        ),
        onChanged: (val) => _answers[_currentStep] = val,
      ),
    );
  }

  List<Widget> _choiceTile(String label) {
    final bool selected = _answers[_currentStep] == label;
    return [
      InkWell(
        onTap: () => setState(() => _answers[_currentStep] = label),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? _accentGreen.withOpacity(0.12) : const Color(0xFF262626),
            borderRadius: BorderRadius.circular(10),
            border: selected ? Border.all(color: _accentGreen) : null,
          ),
          child: Row(
            children: [
              Icon(
                selected ? Icons.check_circle : Icons.circle_outlined,
                color: selected ? _accentGreen : Colors.white38,
                size: 18,
              ),
              const SizedBox(width: 10),
              Text(label, style: TextStyle(color: selected ? _accentGreen : Colors.white70, fontSize: 13)),
            ],
          ),
        ),
      ),
    ];
  }

  Widget _buildNextButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _submitting ? null : _goNext,
          style: ElevatedButton.styleFrom(
            backgroundColor: _accentGreen,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: _submitting
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                )
              : Text(
                  _currentStep < _totalSteps - 1 ? 'Next' : 'Submit',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
        ),
      ),
    );
  }
}
