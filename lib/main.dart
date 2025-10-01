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
import 'models/coffee.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Hive.initFlutter();
  // Register Hive adapters after init
  Hive.registerAdapter(CoffeeAdapter());

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
  // 0: splash, 1: login, 2: main
  int _page = 0;
  final _auth = FirebaseAuth.instance;
  final _cartModel = CartModel();

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  void _checkAuthState() {
    _auth.authStateChanges().listen((User? user) async {
      if (user != null && _page != 3) {
        // User is logged in, load their cart and go to main
        await _cartModel.loadCartFromFirestore();
        _goToMain();
      } else if (user == null && _page == 3) {
        // User logged out, go to login
        _goToLogin();
      }
    });
  }

  void _goToLogin() => setState(() => _page = 1);
  void _goToMain() => setState(() => _page = 2);

  @override
  Widget build(BuildContext context) {
    Widget child;
    switch (_page) {
      case 0:
        child = SplashScreen(
          onSplashDone: () async {
            final user = _auth.currentUser;
            if (user != null) {
              // User is already logged in, load their cart
              await _cartModel.loadCartFromFirestore();
              _goToMain();
            } else {
              _goToLogin();
            }
          },
        );
        break;
      case 1:
        child = LoginPage(
          onLoginSuccess: () async {
            // Load cart when user successfully logs in
            await _cartModel.loadCartFromFirestore();
            _goToMain();
          },
        );
        break;
      case 2:
      default:
        child = const HomePage();
        break;
    }
    return MultiProvider(
      providers: [ChangeNotifierProvider.value(value: _cartModel)],
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
        routes: {'/cart': (_) => const CartPage()},
      ),
    );
  }
}
