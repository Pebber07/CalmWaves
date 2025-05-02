// import 'package:calmwaves_app/pages/home_screen.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:calmwaves_app/firebase_options.dart';
import 'package:calmwaves_app/pages/articles_screen.dart';
import 'package:calmwaves_app/pages/chatbot_screen.dart';
import 'package:calmwaves_app/pages/create_event_screen.dart';
import 'package:calmwaves_app/pages/forum_screen.dart';
import 'package:calmwaves_app/pages/home_screen.dart';
import 'package:calmwaves_app/pages/journal_screen.dart';
import 'package:calmwaves_app/pages/mood_screen.dart';
import 'package:calmwaves_app/pages/login_screen.dart';
import 'package:calmwaves_app/pages/notifications_screen.dart';
import 'package:calmwaves_app/pages/profile_screen.dart';
// import 'package:calmwaves_app/pages/login_screen.dart';
import 'package:calmwaves_app/pages/register_screen.dart';
import 'package:calmwaves_app/pages/settings_screen.dart';
import 'package:calmwaves_app/pages/starter_screen.dart';
import 'package:calmwaves_app/pages/welcome_screen.dart';
// import 'package:calmwaves_app/pages/register_screen.dart';
import 'package:calmwaves_app/palette.dart';
import 'package:calmwaves_app/services/notification_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelGroupKey: "basic_channel_group",
        channelKey: "basic_channel",
        channelName: "Basic Notification",
        channelDescription: "Basic Test notifications channel",
        ledColor: Colors.blue,
      ),
    ],
    channelGroups: [
      NotificationChannelGroup(
        channelGroupKey: "basic_channel_group",
        channelGroupName: "Basic Group",
      ),
    ],
  ); // or pass my own icon.
  bool isAllowedToSendNotification =
      await AwesomeNotifications().isNotificationAllowed();
  if (!isAllowedToSendNotification) {
    AwesomeNotifications().requestPermissionToSendNotifications();
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    // --> initialize callback functions
    AwesomeNotifications().setListeners(
        onActionReceivedMethod: NotificationController.onActionReceivedMethod,
        onNotificationCreatedMethod:
            NotificationController.onNotificationCreatedMethod,
        onNotificationDisplayedMethod:
            NotificationController.onNotificationDisplayedMethod,
        onDismissActionReceivedMethod:
            NotificationController.onDismissActionReceivedMethod);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "CalmWaves",
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Pallete.backgroundColor,
      ),
      debugShowCheckedModeBanner: false, // don't show the debug label
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
        "/forum": (context) => const ForumScreen(),
        "/profile": (context) => const ProfileScreen(),
      },
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.data != null) {
            return const HomeScreen();
          }
          return const RegisterScreen();
        },
      ),
    );
  }
}
