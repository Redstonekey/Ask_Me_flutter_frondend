import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:html' as html;
import '../services/auth_service.dart';

class AuthCallbackScreen extends StatefulWidget {
  const AuthCallbackScreen({super.key});

  @override
  State<AuthCallbackScreen> createState() => _AuthCallbackScreenState();
}

class _AuthCallbackScreenState extends State<AuthCallbackScreen> {
  @override
  void initState() {
    super.initState();
    _handleAuthCallback();
  }

  Future<void> _handleAuthCallback() async {
    try {
      final fragment = html.window.location.hash;
      
      if (fragment.isNotEmpty && fragment.contains('access_token=')) {
        // Parse the fragment to extract tokens
        final params = _parseFragment(fragment);
        final accessToken = params['access_token'];
        final refreshToken = params['refresh_token'];
        
        if (accessToken != null && refreshToken != null) {
          // Handle the successful authentication
          await AuthService.handleAuthCallback(accessToken, refreshToken);
          
          // Clear the URL fragment
          html.window.history.replaceState({}, '', html.window.location.pathname);
          
          // Navigate to home
          if (mounted) {
            context.go('/home');
          }
        } else {
          throw Exception('Missing tokens in callback');
        }
      } else if (fragment.contains('error=')) {
        // Handle error
        final params = _parseFragment(fragment);
        final error = params['error'] ?? 'Authentication failed';
        throw Exception(error);
      } else {
        // No valid callback data, redirect to landing
        if (mounted) {
          context.go('/');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Authentication failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        context.go('/');
      }
    }
  }

  Map<String, String> _parseFragment(String fragment) {
    final params = <String, String>{};
    
    // Remove the leading '#' if present
    final cleanFragment = fragment.startsWith('#') ? fragment.substring(1) : fragment;
    
    // Split by '&' and parse key-value pairs
    final pairs = cleanFragment.split('&');
    for (final pair in pairs) {
      final keyValue = pair.split('=');
      if (keyValue.length == 2) {
        params[keyValue[0]] = Uri.decodeComponent(keyValue[1]);
      }
    }
    
    return params;
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Completing authentication...'),
          ],
        ),
      ),
    );
  }
}
