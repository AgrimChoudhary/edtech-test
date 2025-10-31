import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/supabase_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    final authService = context.read<AuthService>();
    final supabaseService = context.read<SupabaseService>();
    
    if (authService.isAuthenticated) {
      // Check if profile is set up
      final profile = await supabaseService.getUserProfile();
      
      if (!mounted) return;
      
      if (profile != null && profile['profile'] != null) {
        final userProfile = profile['profile'];
        if (userProfile['name'] != null && userProfile['name'] != 'User') {
          // Profile complete, check qualifications
          final qualifications = profile['qualifications'] as List<dynamic>?;
          if (qualifications != null && qualifications.isNotEmpty) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else {
            Navigator.pushReplacementNamed(context, '/qualifications');
          }
        } else {
          Navigator.pushReplacementNamed(context, '/profile-setup');
        }
      } else {
        Navigator.pushReplacementNamed(context, '/profile-setup');
      }
    } else {
      Navigator.pushReplacementNamed(context, '/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school,
              size: 100,
              color: Colors.white,
            ),
            const SizedBox(height: 24),
            Text(
              'Lakshya',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your Path to Government Jobs',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 48),
            CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
