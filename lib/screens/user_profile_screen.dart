import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../services/question_service.dart';

class UserProfileScreen extends StatefulWidget {
  final String username;
  
  const UserProfileScreen({super.key, required this.username});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _questionController = TextEditingController();
  bool _isAsking = false;
  bool _isLoading = true;
  Map<String, dynamic>? _userProfile;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final profileData = await UserService.getProfile(widget.username);
      setState(() {
        _userProfile = profileData;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitQuestion() async {
    if (_questionController.text.trim().isEmpty) return;

    // Prevent self-questioning
    if (AuthService.currentUsername == widget.username) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You cannot ask yourself a question!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isAsking = true;
    });

    try {
      await QuestionService.submitQuestion(
        widget.username,
        _questionController.text.trim(),
      );

      _questionController.clear();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Question submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting question: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAsking = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('@${widget.username}'),
        backgroundColor: Colors.white,
        leading: AuthService.isLoggedIn 
            ? IconButton(
                icon: const Icon(Icons.home),
                onPressed: () => context.go('/home'),
                tooltip: 'Home',
              )
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go('/'),
                tooltip: 'Back to Landing',
              ),
        actions: [
          if (AuthService.isLoggedIn && AuthService.currentUsername == widget.username)
            IconButton(
              icon: const Icon(Icons.question_answer),
              onPressed: () => context.go('/user/${widget.username}/questions'),
              tooltip: 'My Questions',
            ),
          if (AuthService.isLoggedIn && AuthService.currentUsername != widget.username)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'home') {
                  context.go('/home');
                } else if (value == 'my_profile') {
                  context.go('/user/${AuthService.currentUsername}');
                } else if (value == 'my_questions') {
                  context.go('/user/${AuthService.currentUsername}/questions');
                }
              },
              itemBuilder: (context) => [
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
                const PopupMenuItem(
                  value: 'my_profile',
                  child: Row(
                    children: [
                      Icon(Icons.person),
                      SizedBox(width: 8),
                      Text('My Profile'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'my_questions',
                  child: Row(
                    children: [
                      Icon(Icons.question_answer),
                      SizedBox(width: 8),
                      Text('My Questions'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _userProfile == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('User not found'),
                      ElevatedButton(
                        onPressed: _loadUserProfile,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      // Profile header
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            // Profile picture
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              child: Text(
                                widget.username.substring(0, 2).toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Name and username
                            Text(
                              _userProfile!['user']['username'],
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '@${widget.username}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            Text(
                              'Member since ${_formatJoinDate(_userProfile!['user']['created_at'])}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Stats
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _StatItem(
                                  label: 'Questions',
                                  value: '${(_userProfile!['answered_questions'] as List).length}',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Ask question section - only show for other users
                      if (AuthService.currentUsername != widget.username) ...[
                        Container(
                          color: Colors.white,
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ask ${widget.username} a question',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              
                              if (AuthService.isLoggedIn) ...[
                                // Show question form for logged in users
                                TextField(
                                  controller: _questionController,
                                  maxLines: 3,
                                  decoration: const InputDecoration(
                                    hintText: 'What would you like to ask?',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Anonymous question',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: _isAsking ? null : _submitQuestion,
                                      child: _isAsking 
                                          ? const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(strokeWidth: 2),
                                            )
                                          : const Text('Ask'),
                                    ),
                                  ],
                                ),
                              ] else ...[
                                // Show login prompt for non-logged in users
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey[300]!),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.lock_outline,
                                        size: 48,
                                        color: Colors.grey[500],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'You need to be logged in to ask questions',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: Colors.grey[600],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () => context.go('/login'),
                                            child: const Text('Sign In'),
                                          ),
                                          const SizedBox(width: 12),
                                          OutlinedButton(
                                            onPressed: () => context.go('/signup'),
                                            child: const Text('Sign Up'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],

                      // Recent answers section
                      if ((_userProfile!['answered_questions'] as List).isNotEmpty) ...[
                        Container(
                          color: Colors.white,
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Recent Answers',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (AuthService.isLoggedIn)
                                    TextButton(
                                      onPressed: () => context.go('/user/${widget.username}/questions'),
                                      child: const Text('View All'),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              
                              ...(_userProfile!['answered_questions'] as List).map((question) => 
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _QuestionAnswerCard(
                                    question: question['question'],
                                    answer: question['answer'],
                                    timestamp: question['answered_at'],
                                    showAnswerToLoggedIn: AuthService.isLoggedIn,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        Container(
                          color: Colors.white,
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              Icon(
                                Icons.question_answer_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No answers yet',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Be the first to ask ${widget.username} a question!',
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
      floatingActionButton: AuthService.isLoggedIn && 
                              AuthService.currentUsername != widget.username
          ? FloatingActionButton.extended(
              onPressed: () {
                // Scroll to the question section
                // You could also implement a quick question dialog here
              },
              icon: const Icon(Icons.help_outline),
              label: const Text('Ask Question'),
            )
          : null,
    );
  }

  String _formatJoinDate(String dateString) {
    final date = DateTime.parse(dateString);
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.year}';
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

class UserProfile {
  final String username;
  final String displayName;
  final String bio;
  final int questionCount;
  final int answerCount;
  final DateTime joinDate;
  final List<String> recentQuestions;
  final List<String> recentAnswers;

  UserProfile({
    required this.username,
    required this.displayName,
    required this.bio,
    required this.questionCount,
    required this.answerCount,
    required this.joinDate,
    required this.recentQuestions,
    required this.recentAnswers,
  });
}

class _QuestionAnswerCard extends StatelessWidget {
  final String question;
  final String answer;
  final String timestamp;
  final bool showAnswerToLoggedIn;

  const _QuestionAnswerCard({
    required this.question,
    required this.answer,
    required this.timestamp,
    required this.showAnswerToLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              question,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Answer
          if (showAnswerToLoggedIn) ...[
            Text(
              answer,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.lock_outline,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Login to see answer',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            'Answered on ${_formatTimestamp(timestamp)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[500],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(String timestamp) {
    final dateTime = DateTime.parse(timestamp);
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 8) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inDays == 8) {
      return 'Last week';
    } else if (difference.inDays > 1) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inHours > 1) {
      return '${difference.inHours} hours ago';
    } else if (difference.inHours == 1) {
      return 'An hour ago';
    } else if (difference.inMinutes > 1) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}
