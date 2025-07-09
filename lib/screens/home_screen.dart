import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String _currentUsername = 'current_user'; // This would come from auth
  
  // Mock data for current user's questions
  final List<QuestionItem> _recentQuestions = [
    QuestionItem(
      id: '1',
      question: 'What\'s your favorite hobby?',
      answer: null,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isAnswered: false,
    ),
    QuestionItem(
      id: '2',
      question: 'What motivates you every day?',
      answer: null,
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      isAnswered: false,
    ),
    QuestionItem(
      id: '3',
      question: 'Best advice you\'ve ever received?',
      answer: 'Never give up on your dreams, no matter how impossible they seem.',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isAnswered: true,
    ),
    QuestionItem(
      id: '4',
      question: 'What\'s your dream vacation destination?',
      answer: 'I\'d love to visit Japan and experience the culture and beautiful landscapes.',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      isAnswered: true,
    ),
  ];

  void _shareProfile() {
    final profileUrl = 'https://askme.app/user/$_currentUsername';
    Clipboard.setData(ClipboardData(text: profileUrl));
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Profile link copied to clipboard!'),
        action: SnackBarAction(
          label: 'Share',
          onPressed: () {
            // Here you would integrate with native sharing
            // For now, just show the URL
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Share Your Profile'),
                content: SelectableText(profileUrl),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unansweredQuestions = _recentQuestions.where((q) => !q.isAnswered).toList();
    final answeredQuestions = _recentQuestions.where((q) => q.isAnswered).toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('AskMe'),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.go('/user/$_currentUsername'),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                AuthService.logout();
                context.go('/');
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Share profile section
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.share,
                        size: 32,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Share your AskMe profile',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Let your friends ask you questions anonymously',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _shareProfile,
                        icon: const Icon(Icons.copy),
                        label: const Text('Copy Profile Link'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // New questions section
            if (unansweredQuestions.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'New Questions (${unansweredQuestions.length})',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/user/$_currentUsername/questions'),
                      child: const Text('View All'),
                    ),
                  ],
                ),
              ),
              ...unansweredQuestions.take(3).map((question) => 
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: _NewQuestionCard(
                    question: question,
                    onAnswer: () => context.go('/user/$_currentUsername/questions'),
                  ),
                ),
              ),
            ],

            // Recent answers section
            if (answeredQuestions.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Answers',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/user/$_currentUsername/questions'),
                      child: const Text('View All'),
                    ),
                  ],
                ),
              ),
              ...answeredQuestions.take(3).map((question) => 
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: _AnsweredQuestionCard(question: question),
                ),
              ),
            ],

            // Empty state
            if (unansweredQuestions.isEmpty && answeredQuestions.isEmpty) ...[
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.question_answer_outlined,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No questions yet',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Share your profile link with friends so they can ask you questions!',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _NewQuestionCard extends StatelessWidget {
  final QuestionItem question;
  final VoidCallback onAnswer;

  const _NewQuestionCard({
    required this.question,
    required this.onAnswer,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'NEW',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.orange[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  _formatTimestamp(question.timestamp),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              question.question,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
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
            const SizedBox(height: 16),
            Row(
              children: [
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

class _AnsweredQuestionCard extends StatelessWidget {
  final QuestionItem question;

  const _AnsweredQuestionCard({required this.question});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                question.question,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              question.answer!,
              style: Theme.of(context).textTheme.bodyMedium,
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
  final DateTime timestamp;
  final bool isAnswered;

  QuestionItem({
    required this.id,
    required this.question,
    this.answer,
    required this.timestamp,
    required this.isAnswered,
  });
}

