import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'pages/splash_page.dart';
import 'pages/login_page.dart';
import 'pages/registration_page.dart';
import 'pages/home_page.dart';
import 'pages/cart_page.dart';
import 'models/cart.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Ensure auth persistence on web
  if (kIsWeb) {
    await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  }

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
      if (user != null) {
        // User is logged in, go to main regardless of current page
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
        child = SplashScreen(
          onSplashDone: () {
            final user = _auth.currentUser;
            if (user != null) {
              _goToMain();
            } else {
              _goToLogin();
            }
          },
        );
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartModel()),
      ],
      child: MaterialApp(
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
      routes: {
        '/cart': (_) => const CartPage(),
      },
    ),
    );
  }
}
