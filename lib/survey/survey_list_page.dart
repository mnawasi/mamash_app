import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'survey_page.dart';

class SurveyQuestion {
  final String type;
  final String prompt;
  final List<String> options;

  SurveyQuestion({required this.type, required this.prompt, this.options = const []});

  factory SurveyQuestion.fromMap(Map<String, dynamic> map) {
    return SurveyQuestion(
      type: map['type'] as String? ?? 'text',
      prompt: map['prompt'] as String? ?? '',
      options: (map['options'] as List?)?.map((e) => e.toString()).toList() ?? const [],
    );
  }
}

class Survey {
  final String id;
  final String title;
  final String description;
  final String provider;
  final double rewardAmount;
  final int estimatedMinutes;
  final List<SurveyQuestion> questions;

  Survey({
    required this.id,
    required this.title,
    required this.description,
    required this.provider,
    required this.rewardAmount,
    required this.estimatedMinutes,
    required this.questions,
  });

  factory Survey.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final questionMaps = (data['questions'] as List?) ?? [];
    return Survey(
      id: doc.id,
      title: data['title'] as String? ?? 'Survey',
      description: data['description'] as String? ?? '',
      provider: data['provider'] as String? ?? 'Partner',
      rewardAmount: (data['rewardAmount'] as num?)?.toDouble() ?? 0.0,
      estimatedMinutes: (data['estimatedMinutes'] as num?)?.toInt() ?? 3,
      questions: questionMaps
          .map((q) => SurveyQuestion.fromMap(Map<String, dynamic>.from(q as Map)))
          .toList(),
    );
  }
}

class SurveyListPage extends StatelessWidget {
  const SurveyListPage({super.key});

  static const Color _bgDark = Color(0xFF121212);
  static const Color _cardDark = Color(0xFF1E1E1E);
  static const Color _accentGreen = Color(0xFF1DBF8A);

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    final uid = _uid;

    return Scaffold(
      backgroundColor: _bgDark,
      appBar: AppBar(
        backgroundColor: _bgDark,
        elevation: 0,
        title: const Text('Survey Rewards', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: uid == null
          ? const Center(
              child: Text('Sign in to see surveys', style: TextStyle(color: Colors.white54)))
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('surveys')
                  .where('active', isEqualTo: true)
                  .snapshots(),
              builder: (context, surveySnap) {
                if (!surveySnap.hasData) {
                  return const Center(
                      child: CircularProgressIndicator(color: _accentGreen));
                }
                final surveys =
                    surveySnap.data!.docs.map((d) => Survey.fromDoc(d)).toList();

                if (surveys.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'No surveys available right now. Check back soon!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
                  );
                }

                return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
                      .collection('surveyResponses')
                      .snapshots(),
                  builder: (context, responseSnap) {
                    final completedIds = (responseSnap.data?.docs ?? [])
                        .map((d) => d.id)
                        .toSet();

                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: surveys.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final survey = surveys[index];
                        final completed = completedIds.contains(survey.id);
                        return _surveyTile(context, survey, completed);
                      },
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _surveyTile(BuildContext context, Survey survey, bool completed) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  survey.title,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _accentGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '₦${survey.rewardAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                      color: _accentGreen, fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${survey.provider} • ~${survey.estimatedMinutes} min',
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 10),
          Text(
            survey.description,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: completed
                  ? null
                  : () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => SurveyPage(survey: survey)),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: completed ? const Color(0xFF2A2A2A) : _accentGreen,
                foregroundColor: completed ? Colors.white38 : Colors.black,
                disabledBackgroundColor: const Color(0xFF2A2A2A),
                disabledForegroundColor: Colors.white38,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              child: Text(
                completed ? 'Completed' : 'Start Survey',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
