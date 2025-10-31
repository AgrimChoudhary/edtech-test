import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/splash_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/profile_setup_screen.dart';
import 'screens/qualifications_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/job_details_screen.dart';
import 'screens/community_screen.dart';
import 'services/auth_service.dart';
import 'services/supabase_service.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://txlavtakcfpdzvlqyeli.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR4bGF2dGFrY2ZwZHp2bHF5ZWxpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE4MzE4NzcsImV4cCI6MjA3NzQwNzg3N30.p3YmxbXDVuonfiBe6ATXhdisufQXNr2svS_-W20N-LY',
  );
  
  runApp(const LakshyaApp());
}

class LakshyaApp extends StatelessWidget {
  const LakshyaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        Provider(create: (_) => SupabaseService()),
      ],
      child: MaterialApp(
        title: 'Lakshya',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2563EB),
            brightness: Brightness.light,
          ),
          textTheme: GoogleFonts.interTextTheme(),
          useMaterial3: true,
        ),
        home: const SplashScreen(),
        routes: {
          '/auth': (context) => const AuthScreen(),
          '/profile-setup': (context) => const ProfileSetupScreen(),
          '/qualifications': (context) => const QualificationsScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          '/job-details': (context) => const JobDetailsScreen(),
          '/community': (context) => const CommunityScreen(),
        },
      ),
    );
  }
}
