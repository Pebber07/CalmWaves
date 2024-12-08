// import 'package:calmwaves_app/pages/home_screen.dart';
import 'package:calmwaves_app/firebase_options.dart';
import 'package:calmwaves_app/pages/articles_screen.dart';
import 'package:calmwaves_app/pages/chatbot_screen.dart';
import 'package:calmwaves_app/pages/create_event_screen.dart';
import 'package:calmwaves_app/pages/home_screen.dart';
import 'package:calmwaves_app/pages/journal_screen.dart';
import 'package:calmwaves_app/pages/mood_screen.dart';
import 'package:calmwaves_app/pages/login_screen.dart';
import 'package:calmwaves_app/pages/notifications_screen.dart';
// import 'package:calmwaves_app/pages/login_screen.dart';
import 'package:calmwaves_app/pages/register_screen.dart';
import 'package:calmwaves_app/pages/settings_screen.dart';
import 'package:calmwaves_app/pages/starter_screen.dart';
import 'package:calmwaves_app/pages/welcome_screen.dart';
// import 'package:calmwaves_app/pages/register_screen.dart';
import 'package:calmwaves_app/palette.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "CalmWaves",
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Pallete.backgroundColor,
      ),
      initialRoute: "/starter",
      routes: {
        "/home": (context) => const HomeScreen(),
        "/settings": (context) => const SettingsScreen(),
        "/articles": (context) => const ArticlesScreen(),
        "/events": (context) => const CreateEventScreen(),
        "/mood": (context) => const MoodScreen(),
        "/login": (context) => const LoginScreen(),
        "/register": (context) => const RegisterScreen(),
        "/starter": (context) => const StarterScreen(),
        "/welcome": (context) => const WelcomeScreen(),     
        "/notifications": (context) => const NotificationsScreen(),     
        "/journal": (context) => const JournalScreen(),     
        "/chatbot": (context) => const ChatbotScreen(),     
      },
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.data != null){
            return const HomeScreen();
          }
          return const RegisterScreen();
        },
      ), 
    );
  }
}
