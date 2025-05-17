// import 'package:calmwaves_app/pages/home_screen.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:calmwaves_app/firebase_options.dart';
import 'package:calmwaves_app/pages/articles_screen.dart';
import 'package:calmwaves_app/pages/chatbot_screen.dart';
import 'package:calmwaves_app/pages/create_event_screen.dart';
import 'package:calmwaves_app/pages/forum_screen.dart';
import 'package:calmwaves_app/pages/home_screen.dart';
import 'package:calmwaves_app/pages/journal_screen.dart';
import 'package:calmwaves_app/pages/manage_users_screen.dart';
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
import 'package:calmwaves_app/widgets/background_tasks.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Enable only standing mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  Locale initialLocale = const Locale('en');
  String initialTheme = 'light';
  bool shouldRegisterNotification = false;

  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final data = doc.data();
    final preferredLanguage = data?['settings']?['preferredLanguage'];
    final preferredTheme = data?['settings']?['theme'];
    final notificationsEnabled =
        data?['settings']?['notificationsEnabled'] ?? true;

    if (preferredLanguage == 'hu' || preferredLanguage == 'en') {
      initialLocale = Locale(preferredLanguage);
    }
    if (preferredTheme == 'dark' || preferredTheme == 'light') {
      initialTheme = preferredTheme;
    }
    shouldRegisterNotification = notificationsEnabled == true;
  }

  await AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelGroupKey: "basic_channel_group",
        channelKey: "basic_channel",
        channelName: "Napi értesítések",
        channelDescription: "Napi mentáhigiénés idézetek",
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

  // Initialize workmanager
  Workmanager()
      .initialize(notificationCallbackDispatcher, isInDebugMode: false);

  if (shouldRegisterNotification) {
    Workmanager().registerPeriodicTask(
      "dailyQuoteTaskId",
      "dailyQuoteTask",
      frequency: const Duration(hours: 24),
      initialDelay: Duration(
        hours: (8 - DateTime.now().hour) % 24,
      ),
      existingWorkPolicy: ExistingWorkPolicy.keep,
    );
  } else {
    Workmanager().cancelByUniqueName("dailyQuoteTaskId");
  }

  bool isAllowedToSendNotification =
      await AwesomeNotifications().isNotificationAllowed();
  if (!isAllowedToSendNotification) {
    AwesomeNotifications().requestPermissionToSendNotifications();
  }
  runApp(MyApp(initialLocale: initialLocale, initialTheme: initialTheme));
}

class MyApp extends StatefulWidget {
  final Locale initialLocale;
  final String initialTheme;

  const MyApp(
      {super.key, required this.initialLocale, required this.initialTheme});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Locale _locale;
  late bool _isDarkTheme;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    // --> initialize callback functions
    _locale = widget.initialLocale;
    _isDarkTheme = widget.initialTheme == 'dark';

    AwesomeNotifications().setListeners(
        onActionReceivedMethod: NotificationController.onActionReceivedMethod,
        onNotificationCreatedMethod:
            NotificationController.onNotificationCreatedMethod,
        onNotificationDisplayedMethod:
            NotificationController.onNotificationDisplayedMethod,
        onDismissActionReceivedMethod:
            NotificationController.onDismissActionReceivedMethod);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startConnectivityListener();
    });
  }

  void _startConnectivityListener() {
    Connectivity().onConnectivityChanged.listen((result) {
      final hasConnection = result != ConnectivityResult.none;

      if (hasConnection && _isOffline) {
        _showSnackBar("Internetkapcsolat helyreállt");
      } else if (!hasConnection && !_isOffline) {
        _showSnackBar("Internetkapcsolat elveszett");
      }

      setState(() {
        _isOffline = !hasConnection;
      });
    });
  }

  void _showSnackBar(String message) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  void toggleTheme(bool isDark) {
    setState(() {
      _isDarkTheme = isDark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: "CalmWaves",
      theme:
          // ThemeData.dark().copyWith(scaffoldBackgroundColor: Pallete.backgroundColor,),
          ThemeData(
        scaffoldBackgroundColor:
            _isDarkTheme ? Colors.blueGrey[900] : Colors.lightBlue[100],
        brightness: _isDarkTheme ? Brightness.dark : Brightness.light,
      ),
      debugShowCheckedModeBanner: false, // don't show the debug label
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('hu'),
      ],
      locale: _locale,

      initialRoute: "/starter",
      routes: {
        "/home": (context) => const HomeScreen(),
        "/settings": (context) => SettingsScreen(
              setLocale: setLocale,
              toggleTheme: toggleTheme,
            ),
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
        "/manage_users": (context) => const ManageUsersScreen(),
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
