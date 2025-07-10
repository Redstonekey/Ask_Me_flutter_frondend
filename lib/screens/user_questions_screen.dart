import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../services/question_service.dart';

class UserQuestionsScreen extends StatefulWidget {
  final String username;
  
  const UserQuestionsScreen({super.key, required this.username});

  @override
  State<UserQuestionsScreen> createState() => _UserQuestionsScreenState();
}

class _UserQuestionsScreenState extends State<UserQuestionsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _answerController = TextEditingController();
  
  bool _isLoading = true;
  Map<String, dynamic>? _questionsData;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final questionsData = await UserService.getUserQuestions(widget.username);
      setState(() {
        _questionsData = questionsData;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading questions: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _answerQuestion(int questionId, String answer) async {
    try {
      await QuestionService.answerQuestion(questionId, answer);
      _loadQuestions(); // Refresh the list
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Question answered successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error answering question: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteQuestion(int questionId) async {
    try {
      await QuestionService.deleteQuestion(questionId);
      _loadQuestions(); // Refresh the list
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Question deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting question: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_questionsData == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('${widget.username}\'s Questions'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Failed to load questions'),
              ElevatedButton(
                onPressed: _loadQuestions,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final answeredQuestions = _questionsData!['answered_questions'] as List<dynamic>? ?? [];
    final unansweredQuestions = _questionsData!['unanswered_questions'] as List<dynamic>? ?? [];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('${widget.username}\'s Questions'),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/user/${widget.username}'),
          tooltip: 'Back to Profile',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => context.go('/home'),
            tooltip: 'Home',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'profile') {
                context.go('/user/${widget.username}');
              } else if (value == 'home') {
                context.go('/home');
              } else if (value == 'my_profile' && AuthService.currentUsername != widget.username) {
                context.go('/user/${AuthService.currentUsername}');
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person),
                    SizedBox(width: 8),
                    Text('View Profile'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'home',
                child: Row(
                  children: [
                    Icon(Icons.home),
                    SizedBox(width: 8),
                    Text('Home'),
                  ],
                ),
              ),
              if (AuthService.currentUsername != widget.username)
                const PopupMenuItem(
                  value: 'my_profile',
                  child: Row(
                    children: [
                      Icon(Icons.account_circle),
                      SizedBox(width: 8),
                      Text('My Profile'),
                    ],
                  ),
                ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Unanswered (${unansweredQuestions.length})'),
            Tab(text: 'Answered (${answeredQuestions.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Unanswered questions
          unansweredQuestions.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.question_answer_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No unanswered questions',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: unansweredQuestions.length,
                  itemBuilder: (context, index) {
                    final question = unansweredQuestions[index];
                    return _UnansweredQuestionCard(
                      question: question,
                      onAnswer: (answer) => _answerQuestion(question['id'], answer),
                      onDelete: () => _deleteQuestion(question['id']),
                    );
                  },
                ),

          // Answered questions
          answeredQuestions.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No answered questions',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: answeredQuestions.length,
                  itemBuilder: (context, index) {
                    final question = answeredQuestions[index];
                    return _AnsweredQuestionCard(
                      question: question,
                      onDelete: () => _deleteQuestion(question['id']),
                    );
                  },
                ),
        ],
      ),
    );
  }
}

class _AnsweredQuestionCard extends StatelessWidget {
  final Map<String, dynamic> question;
  final VoidCallback onDelete;

  const _AnsweredQuestionCard({
    required this.question,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'ANSWERED',
                    style: TextStyle(
                      color: Colors.green[800],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  _formatTimestamp(question['answered_at']),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              question['question'],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Text(
                question['answer'],
                style: const TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Spacer(),
                OutlinedButton(
                  onPressed: onDelete,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  child: const Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(String timestamp) {
    final DateTime parsedTime = DateTime.parse(timestamp);
    final now = DateTime.now();
    final difference = now.difference(parsedTime);

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

class _UnansweredQuestionCard extends StatefulWidget {
  final Map<String, dynamic> question;
  final Function(String) onAnswer;
  final VoidCallback onDelete;

  const _UnansweredQuestionCard({
    required this.question,
    required this.onAnswer,
    required this.onDelete,
  });

  @override
  State<_UnansweredQuestionCard> createState() => _UnansweredQuestionCardState();
}

class _UnansweredQuestionCardState extends State<_UnansweredQuestionCard> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showAnswerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Answer Question'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.question['question'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Type your answer here...',
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
              if (_controller.text.trim().isNotEmpty) {
                widget.onAnswer(_controller.text.trim());
                Navigator.of(context).pop();
              }
            },
            child: const Text('Answer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
                    'UNANSWERED',
                    style: TextStyle(
                      color: Colors.orange[800],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  _formatTimestamp(widget.question['created_at']),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              widget.question['question'],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _showAnswerDialog,
                  child: const Text('Answer'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: widget.onDelete,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  child: const Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(String timestamp) {
    final DateTime parsedTime = DateTime.parse(timestamp);
    final now = DateTime.now();
    final difference = now.difference(parsedTime);

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
