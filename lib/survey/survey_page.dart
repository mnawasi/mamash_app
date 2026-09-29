import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'survey_list_page.dart';

class SurveyPage extends StatefulWidget {
  final Survey survey;

  const SurveyPage({super.key, required this.survey});

  @override
  State<SurveyPage> createState() => _SurveyPageState();
}

class _SurveyPageState extends State<SurveyPage> {
  static const Color _bgDark = Color(0xFF121212);
  static const Color _cardDark = Color(0xFF1E1E1E);
  static const Color _accentGreen = Color(0xFF1DBF8A);

  int _currentStep = 0;
  bool _isSubmitting = false;

  late final List<dynamic> _answers;

  @override
  void initState() {
    super.initState();
    _answers = List<dynamic>.filled(widget.survey.questions.length, null);
  }

  int get _totalSteps => widget.survey.questions.length;

  bool get _canGoNext {
    final q = widget.survey.questions[_currentStep];
    final a = _answers[_currentStep];
    if (q.type == 'text') return true;
    return a != null;
  }

  Future<void> _goNext() async {
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
    } else {
      await _submit();
    }
  }

  Future<void> _submit() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => _isSubmitting = true);

    final db = FirebaseFirestore.instance;
    final userRef = db.collection('users').doc(uid);
    final responseRef =
        userRef.collection('surveyResponses').doc(widget.survey.id);
    final financeRef = userRef.collection('finance').doc('summary');
    final transactionRef = userRef.collection('transactions').doc();

    try {
      await db.runTransaction((tx) async {
        final existing = await tx.get(responseRef);
        if (existing.exists) {
          throw Exception('already_completed');
        }

        final financeSnap = await tx.get(financeRef);
        final currentWallet =
            (financeSnap.data()?['wallet'] as num?)?.toDouble() ?? 0.0;

        tx.set(responseRef, {
          'surveyId': widget.survey.id,
          'title': widget.survey.title,
          'answers': _answers
              .map((a) => a?.toString() ?? '')
              .toList(),
          'rewardAmount': widget.survey.rewardAmount,
          'completedAt': FieldValue.serverTimestamp(),
        });

        tx.set(
          financeRef,
          {'wallet': currentWallet + widget.survey.rewardAmount},
          SetOptions(merge: true),
        );

        tx.set(transactionRef, {
          'title': 'Survey Reward',
          'subtitle': widget.survey.title,
          'amount': widget.survey.rewardAmount,
          'type': 'credit',
          'timestamp': FieldValue.serverTimestamp(),
        });
      });

      if (!mounted) return;
      _showResultDialog(
        success: true,
        message:
            'Survey completed! ₦${widget.survey.rewardAmount.toStringAsFixed(2)} has been added to your wallet.',
      );
    } catch (e) {
      if (!mounted) return;
      final alreadyDone = e.toString().contains('already_completed');
      _showResultDialog(
        success: alreadyDone,
        message: alreadyDone
            ? 'You already completed this survey.'
            : 'Something went wrong submitting your survey. Please try again.',
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showResultDialog({required bool success, required String message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: _cardDark,
        title: Text(
          success ? 'Thank you!' : 'Oops',
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Done', style: TextStyle(color: _accentGreen)),
          ),
        ],
      ),
    );
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
          Expanded(
            child: Text(
              widget.survey.title,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
            ),
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
    final question = widget.survey.questions[_currentStep];

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
            question.prompt,
            style: const TextStyle(
                color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          if (question.type == 'rating') _buildRatingInput(),
          if (question.type == 'choice') ...question.options.map(_choiceTile),
          if (question.type == 'text') _buildTextInput(),
        ],
      ),
    );
  }

  Widget _buildRatingInput() {
    final current = _answers[_currentStep] as int?;
    return Row(
      children: List.generate(5, (i) {
        return IconButton(
          onPressed: () => setState(() => _answers[_currentStep] = i + 1),
          icon: Icon(
            current != null && i < current ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 28,
          ),
        );
      }),
    );
  }

  Widget _choiceTile(String label) {
    final selected = _answers[_currentStep] == label;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => setState(() => _answers[_currentStep] = label),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? _accentGreen.withValues(alpha: 0.12) : const Color(0xFF262626),
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
              Text(label,
                  style: TextStyle(
                      color: selected ? _accentGreen : Colors.white70, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF262626),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        maxLines: 3,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        onChanged: (v) => _answers[_currentStep] = v,
        decoration: const InputDecoration(
          hintText: 'Tell us more...',
          hintStyle: TextStyle(color: Colors.white38),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: (!_canGoNext || _isSubmitting) ? null : _goNext,
          style: ElevatedButton.styleFrom(
            backgroundColor: _accentGreen,
            foregroundColor: Colors.black,
            disabledBackgroundColor: const Color(0xFF2A2A2A),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
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
