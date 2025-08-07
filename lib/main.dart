import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'splash_screen.dart';
import 'login_page.dart';
import 'registration_page.dart';
import 'home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Set full screen mode
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // 0: splash, 1: login, 2: register, 3: main
  int _page = 0;
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  void _checkAuthState() {
    _auth.authStateChanges().listen((User? user) {
      if (user != null && _page == 1) {
        // User is logged in and we're on login page, go to main
        _goToMain();
      }
    });
  }

  void _goToLogin() => setState(() => _page = 1);
  void _goToRegister() => setState(() => _page = 2);
  void _goToMain() => setState(() => _page = 3);

  @override
  Widget build(BuildContext context) {
    Widget child;
    switch (_page) {
      case 0:
        child = SplashScreen(onSplashDone: _goToLogin);
        break;
      case 1:
        child = LoginPage(
          onRegisterTap: _goToRegister,
          onLoginSuccess: _goToMain,
        );
        break;
      case 2:
        child = RegistrationPage(
          onLoginTap: _goToLogin,
          onRegisterSuccess: _goToMain,
        );
        break;
      case 3:
      default:
        child = HomePage(
          onLogout: () async {
            await _auth.signOut();
            setState(() => _page = 1);
          },
        );
        break;
    }
    return MaterialApp(
      title: 'Amaya Coffee',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B4513),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: child,
    );
  }
}
