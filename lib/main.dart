import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'core/database/database_manager.dart';
import 'core/services/session_manager.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/auth/screens/home_screen.dart';
import 'features/auth/services/auth_service.dart';
import 'features/catalog/screens/categories_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Vérifier que l'application n'est pas lancée sur Web
  // Cette application est MOBILE uniquement (Android/iOS)
  if (kIsWeb) {
    runApp(const _UnsupportedPlatformApp());
    return;
  }

  // Initialiser la base de données SQLite
  await _initializeDatabase();

  // Initialiser le gestionnaire de session
  await _initializeSession();

  runApp(const MyApp());
}

/// Initialise la base de données SQLite
/// 
/// Crée toutes les tables au premier démarrage
Future<void> _initializeDatabase() async {
  final DatabaseManager dbManager = DatabaseManager();
  await dbManager.database; // Force l'initialisation
}

/// Initialise le gestionnaire de session
/// 
/// Prépare SharedPreferences pour stocker la session
Future<void> _initializeSession() async {
  final SessionManager sessionManager = SessionManager();
  await sessionManager.init();
}

/// Application affichée lorsque la plateforme Web est détectée
/// 
/// Cette application est MOBILE uniquement (Android/iOS)
class _UnsupportedPlatformApp extends StatelessWidget {
  const _UnsupportedPlatformApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Micro Learning App',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.phone_android,
                  size: 80,
                  color: Colors.orange,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Application Mobile Uniquement',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Cette application fonctionne uniquement sur Android et iOS.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'SQLite n\'est pas supporté sur Flutter Web.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                const Text(
                  'Pour tester l\'application :',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '• Connectez un appareil Android\n'
                  '• Ou lancez un émulateur Android\n'
                  '• Puis exécutez: flutter run',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Micro Learning App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      // Navigation basée sur l'état d'authentification
      home: const AuthWrapper(),
      // Routes nommées pour la navigation
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const CategoriesListScreen(),
      },
    );
  }
}

/// Wrapper d'authentification
/// 
/// Vérifie l'état de connexion et redirige vers l'écran approprié
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  /// Vérifie si un utilisateur est connecté
  /// 
  /// Redirige vers l'écran d'accueil si connecté, sinon vers le login
  Future<void> _checkAuthStatus() async {
    final bool isLoggedIn = await _authService.isLoggedIn();
    setState(() {
      _isAuthenticated = isLoggedIn;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Navigation basée sur l'état d'authentification
    if (_isAuthenticated) {
      return const CategoriesListScreen();
    } else {
      return const LoginScreen();
    }
  }
}
