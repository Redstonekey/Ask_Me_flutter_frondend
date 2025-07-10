import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../services/dashboard_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _currentUsername;
  Map<String, dynamic>? _dashboardData;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }
  
  Future<void> _loadDashboard() async {
    try {
      final dashboardData = await DashboardService.getDashboard();
      setState(() {
        _dashboardData = dashboardData;
        _currentUsername = dashboardData['user']['username'];
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading dashboard: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _shareProfile() {
    if (_currentUsername == null) return;
    
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
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    if (_dashboardData == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Failed to load dashboard'),
              ElevatedButton(
                onPressed: _loadDashboard,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    
    final unansweredQuestions = _dashboardData!['unanswered_questions'] as List<dynamic>? ?? [];
    final recentAnswers = _dashboardData!['recent_answers'] as List<dynamic>? ?? [];
    final stats = _dashboardData!['stats'] as Map<String, dynamic>? ?? {};

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('AskMe'),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.go('/user/${_currentUsername ?? ''}'),
            tooltip: 'My Profile',
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'logout') {
                await AuthService.logout();
                context.go('/');
              } else if (value == 'profile') {
                context.go('/user/${_currentUsername ?? ''}');
              } else if (value == 'questions') {
                context.go('/user/${_currentUsername ?? ''}/questions');
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person),
                    SizedBox(width: 8),
                    Text('My Profile'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'questions',
                child: Row(
                  children: [
                    Icon(Icons.question_answer),
                    SizedBox(width: 8),
                    Text('My Questions'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Logout', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth > 600 && constraints.maxWidth <= 1024;
          final isDesktop = constraints.maxWidth > 1024;
          final isMobile = constraints.maxWidth <= 600;
          
          double maxWidth;
          double horizontalPadding;
          
          if (isDesktop) {
            maxWidth = 1400.0;
            horizontalPadding = 60.0;
          } else if (isTablet) {
            maxWidth = 900.0;
            horizontalPadding = 40.0;
          } else {
            maxWidth = double.infinity;
            horizontalPadding = 0.0;
          }
          
          return Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: isMobile 
                      ? _buildMobileLayout(context, unansweredQuestions, recentAnswers, stats)
                      : _buildDesktopLayout(context, unansweredQuestions, recentAnswers, stats, isDesktop),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Desktop layout with side-by-side cards
  Widget _buildDesktopLayout(BuildContext context, List<dynamic> unansweredQuestions, List<dynamic> recentAnswers, Map<String, dynamic> stats, [bool isDesktop = true]) {
    return Column(
      children: [
        SizedBox(height: isDesktop ? 32.0 : 20.0),
        
        // Welcome section for desktop
        if (isDesktop) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 0,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    _currentUsername != null ? _currentUsername!.substring(0, 1).toUpperCase() : 'U',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back, ${_currentUsername ?? 'User'}!',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Manage your questions and engage with your audience',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        
        // Stats and share profile row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats panel
            Expanded(
              flex: isDesktop ? 1 : 2,
              child: _buildStatsCard(context, stats),
            ),
            SizedBox(width: isDesktop ? 24.0 : 20.0),
            
            // Share profile panel
            Expanded(
              flex: isDesktop ? 2 : 3,
              child: _buildShareProfileCard(context),
            ),
          ],
        ),
        
        SizedBox(height: isDesktop ? 24.0 : 20.0),
        
        // Questions row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Unanswered questions
            Expanded(
              child: _buildUnansweredQuestionsSection(context, unansweredQuestions),
            ),
            SizedBox(width: isDesktop ? 24.0 : 20.0),
            
            // Recent answers
            Expanded(
              child: _buildRecentAnswersSection(context, recentAnswers),
            ),
          ],
        ),
        
        // Empty state for desktop
        if (unansweredQuestions.isEmpty && recentAnswers.isEmpty && isDesktop)
          Container(
            margin: const EdgeInsets.only(top: 24),
            padding: const EdgeInsets.all(48),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 0,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  Icons.question_answer_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No questions yet',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Share your profile link with friends to start receiving questions!',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        
        SizedBox(height: isDesktop ? 40.0 : 20.0),
      ],
    );
  }

  // Mobile layout with stacked cards
  Widget _buildMobileLayout(BuildContext context, List<dynamic> unansweredQuestions, List<dynamic> recentAnswers, Map<String, dynamic> stats) {
    return Column(
      children: [
        // Share profile section
        _buildShareProfileCard(context),
        
        // Stats section
        _buildStatsCard(context, stats),

        // New questions section
        _buildUnansweredQuestionsSection(context, unansweredQuestions),

        // Recent answers section
        _buildRecentAnswersSection(context, recentAnswers),

        // Empty state
        if (unansweredQuestions.isEmpty && recentAnswers.isEmpty)
          _buildEmptyState(context),

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildShareProfileCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        color: Theme.of(context).colorScheme.primaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.share,
                  size: 32,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Share your AskMe profile',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Let your friends ask you questions anonymously',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _shareProfile,
                icon: const Icon(Icons.copy),
                label: const Text('Copy Profile Link'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context, Map<String, dynamic> stats) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.bar_chart,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Your Stats',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _StatColumn(
                    icon: Icons.help_outline,
                    label: 'Total Questions',
                    value: '${stats['total_questions'] ?? 0}',
                    color: Colors.blue,
                  ),
                  _StatColumn(
                    icon: Icons.question_mark,
                    label: 'Unanswered',
                    value: '${stats['unanswered_count'] ?? 0}',
                    color: Colors.orange,
                  ),
                  _StatColumn(
                    icon: Icons.check_circle,
                    label: 'Answered',
                    value: '${stats['answered_count'] ?? 0}',
                    color: Colors.green,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUnansweredQuestionsSection(BuildContext context, List<dynamic> unansweredQuestions) {
    if (unansweredQuestions.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.question_mark,
                          color: Colors.orange,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'New Questions (${unansweredQuestions.length})',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () => context.go('/user/${_currentUsername ?? ''}/questions'),
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...unansweredQuestions.take(3).map((question) => 
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _NewQuestionCard(
                    question: question,
                    onAnswer: () => context.go('/user/${_currentUsername ?? ''}/questions'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentAnswersSection(BuildContext context, List<dynamic> recentAnswers) {
    if (recentAnswers.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Recent Answers',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () => context.go('/user/${_currentUsername ?? ''}/questions'),
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...recentAnswers.take(3).map((question) => 
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _AnsweredQuestionCard(question: question),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
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
            'No questions yet!',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
    );
  }
}

class _NewQuestionCard extends StatelessWidget {
  final Map<String, dynamic> question;
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
                  _formatTimestamp(question['created_at']),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              question['question'],
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

class _AnsweredQuestionCard extends StatelessWidget {
  final Map<String, dynamic> question;

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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'ANSWERED',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.green[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  _formatTimestamp(question['answered_at']),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              question['question'],
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
                style: Theme.of(context).textTheme.bodyMedium,
              ),
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

class _StatColumn extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatColumn({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: 32,
          color: color,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

