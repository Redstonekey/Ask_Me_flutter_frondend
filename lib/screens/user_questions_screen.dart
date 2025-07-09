import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UserQuestionsScreen extends StatefulWidget {
  final String username;
  
  const UserQuestionsScreen({super.key, required this.username});

  @override
  State<UserQuestionsScreen> createState() => _UserQuestionsScreenState();
}

class _UserQuestionsScreenState extends State<UserQuestionsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _answerController = TextEditingController();
  
  // Mock data
  final List<QuestionItem> _answered = [
    QuestionItem(
      id: '1',
      question: 'What\'s your favorite Flutter widget?',
      answer: 'I love Container and Column widgets. They\'re so versatile!',
      askedBy: 'Anonymous',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    QuestionItem(
      id: '2',
      question: 'How do you handle state management in Flutter?',
      answer: 'I prefer using Provider or BLoC pattern depending on the complexity.',
      askedBy: 'Anonymous',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    QuestionItem(
      id: '3',
      question: 'Tips for Flutter performance optimization?',
      answer: 'Use const constructors, avoid rebuilding widgets unnecessarily, and profile your app!',
      askedBy: 'Anonymous',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  final List<QuestionItem> _unanswered = [
    QuestionItem(
      id: '4',
      question: 'What are your thoughts on Flutter Web?',
      answer: null,
      askedBy: 'Anonymous',
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
    QuestionItem(
      id: '5',
      question: 'Best resources for learning Dart?',
      answer: null,
      askedBy: 'Anonymous',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    QuestionItem(
      id: '6',
      question: 'How do you debug Flutter apps?',
      answer: null,
      askedBy: 'Anonymous',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  void _showAnswerDialog(QuestionItem question) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Answer Question'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                question.question,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _answerController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Your answer...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_answerController.text.trim().isNotEmpty) {
                setState(() {
                  // Move question from unanswered to answered
                  _unanswered.remove(question);
                  _answered.insert(0, QuestionItem(
                    id: question.id,
                    question: question.question,
                    answer: _answerController.text,
                    askedBy: question.askedBy,
                    timestamp: DateTime.now(),
                  ));
                });
                _answerController.clear();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Answer posted!')),
                );
              }
            },
            child: const Text('Post Answer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('@${widget.username}\'s Questions'),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/user/${widget.username}'),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Answered (${_answered.length})'),
            Tab(text: 'Unanswered (${_unanswered.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Answered questions
          _answered.isEmpty
              ? const Center(
                  child: Text('No answered questions yet'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _answered.length,
                  itemBuilder: (context, index) {
                    final question = _answered[index];
                    return _AnsweredQuestionCard(question: question);
                  },
                ),
          
          // Unanswered questions
          _unanswered.isEmpty
              ? const Center(
                  child: Text('No pending questions'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _unanswered.length,
                  itemBuilder: (context, index) {
                    final question = _unanswered[index];
                    return _UnansweredQuestionCard(
                      question: question,
                      onAnswer: () => _showAnswerDialog(question),
                    );
                  },
                ),
        ],
      ),
    );
  }
}

class _AnsweredQuestionCard extends StatelessWidget {
  final QuestionItem question;

  const _AnsweredQuestionCard({required this.question});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question.question,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Asked anonymously',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Answer
            Text(
              question.answer!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const SizedBox(height: 12),

            // Timestamp
            Row(
              children: [
                const Spacer(),
                Text(
                  _formatTimestamp(question.timestamp),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

class _UnansweredQuestionCard extends StatelessWidget {
  final QuestionItem question;
  final VoidCallback onAnswer;

  const _UnansweredQuestionCard({
    required this.question,
    required this.onAnswer,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question.question,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Asked anonymously',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Action buttons
            Row(
              children: [
                Text(
                  _formatTimestamp(question.timestamp),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: onAnswer,
                  child: const Text('Answer'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

class QuestionItem {
  final String id;
  final String question;
  final String? answer;
  final String askedBy;
  final DateTime timestamp;

  QuestionItem({
    required this.id,
    required this.question,
    this.answer,
    required this.askedBy,
    required this.timestamp,
  });
}
