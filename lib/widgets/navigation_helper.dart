import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';

class NavigationHelper {
  static Widget buildAppBarWithNavigation({
    required BuildContext context,
    required String title,
    bool showBackButton = true,
    String? backRoute,
    List<Widget>? additionalActions,
  }) {
    return AppBar(
      title: Text(title),
      backgroundColor: Colors.white,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (backRoute != null) {
                  context.go(backRoute);
                } else {
                  Navigator.of(context).canPop()
                      ? Navigator.of(context).pop()
                      : context.go('/');
                }
              },
            )
          : null,
      actions: [
        if (additionalActions != null) ...additionalActions,
        if (AuthService.isLoggedIn) ...[
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => context.go('/home'),
            tooltip: 'Home',
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              switch (value) {
                case 'home':
                  context.go('/home');
                  break;
                case 'my_profile':
                  context.go('/user/${AuthService.currentUsername}');
                  break;
                case 'my_questions':
                  context.go('/user/${AuthService.currentUsername}/questions');
                  break;
                case 'logout':
                  await AuthService.logout();
                  context.go('/');
                  break;
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
        ] else ...[
          IconButton(
            icon: const Icon(Icons.login),
            onPressed: () => context.go('/login'),
            tooltip: 'Sign In',
          ),
        ],
      ],
    );
  }

  static Widget buildQuickNavigationButton(BuildContext context) {
    return FloatingActionButton(
      mini: true,
      backgroundColor: Colors.white,
      foregroundColor: Theme.of(context).primaryColor,
      onPressed: () {
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (context) => const QuickNavigationSheet(),
        );
      },
      child: const Icon(Icons.menu),
    );
  }
}

class QuickNavigationSheet extends StatelessWidget {
  const QuickNavigationSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Quick Navigation',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          if (AuthService.isLoggedIn) ...[
            _NavigationTile(
              icon: Icons.home,
              title: 'Home',
              subtitle: 'Dashboard',
              onTap: () {
                Navigator.pop(context);
                context.go('/home');
              },
            ),
            _NavigationTile(
              icon: Icons.person,
              title: 'My Profile',
              subtitle: 'View your profile',
              onTap: () {
                Navigator.pop(context);
                context.go('/user/${AuthService.currentUsername}');
              },
            ),
            _NavigationTile(
              icon: Icons.question_answer,
              title: 'My Questions',
              subtitle: 'Manage your questions',
              onTap: () {
                Navigator.pop(context);
                context.go('/user/${AuthService.currentUsername}/questions');
              },
            ),
            const Divider(),
            _NavigationTile(
              icon: Icons.logout,
              title: 'Logout',
              subtitle: 'Sign out of your account',
              color: Colors.red,
              onTap: () async {
                Navigator.pop(context);
                await AuthService.logout();
                context.go('/');
              },
            ),
          ] else ...[
            _NavigationTile(
              icon: Icons.home,
              title: 'Home',
              subtitle: 'Back to landing page',
              onTap: () {
                Navigator.pop(context);
                context.go('/');
              },
            ),
            _NavigationTile(
              icon: Icons.login,
              title: 'Sign In',
              subtitle: 'Access your account',
              onTap: () {
                Navigator.pop(context);
                context.go('/login');
              },
            ),
            _NavigationTile(
              icon: Icons.person_add,
              title: 'Sign Up',
              subtitle: 'Create new account',
              onTap: () {
                Navigator.pop(context);
                context.go('/signup');
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _NavigationTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? color;

  const _NavigationTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.onSurface;
    
    return ListTile(
      leading: Icon(icon, color: effectiveColor),
      title: Text(
        title,
        style: TextStyle(
          color: effectiveColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: effectiveColor.withOpacity(0.7),
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
