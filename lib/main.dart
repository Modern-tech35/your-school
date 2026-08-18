import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'splash_screen.dart';
import 'auth_screen.dart';
import 'role_check_screen.dart';
import 'student_home_screen.dart';
import 'lesson_details_screen.dart';
import 'favorites_screen.dart';
import 'admin_dashboard_screen.dart';
import 'manage_lessons_screen.dart';
import 'cloudinary_upload_screen.dart';
import 'profile_screen.dart';
import 'reports_screen.dart';

// Custom colors - "Modern Tech" brand palette (blue + neutrals)
const Color primaryColor = Color(0xFF4FC3F7); // app blue
const Color secondaryColor = Color(0xFF2196F3); // blue
const Color tertiaryColor = Color(0xFF81D4FA); // light blue
const Color backgroundColor = Color(0xFFF4FAFD); // soft blue-white tint
const Color surfaceColor = Color(0xFFFFFFFF);
const Color textColor = Color(0xFF1E1B2E);
const Color errorColor = Color(0xFFF44336);
const Color accentColor = Color(0xFF0288D1); // dark blue accent
const Color whiteColor = Colors.white;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp(initialRoute: '/',));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required String initialRoute});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Learning App',
      theme: ThemeData(
        colorScheme: const ColorScheme(
          primary: primaryColor,
          onPrimary: surfaceColor,
          secondary: secondaryColor,
          onSecondary: surfaceColor,
          tertiary: tertiaryColor,
          onTertiary: surfaceColor,
          surface: surfaceColor,
          onSurface: textColor,
          error: errorColor,
          onError: surfaceColor,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: backgroundColor,
        useMaterial3: true,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: surfaceColor,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primaryColor,
            side: const BorderSide(color: primaryColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: primaryColor),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryColor,
          foregroundColor: surfaceColor,
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surfaceColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryColor, width: 2),
          ),
        ),
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: primaryColor,
        ),
        drawerTheme: const DrawerThemeData(
          backgroundColor: surfaceColor,
        ),
        dividerTheme: DividerThemeData(color: Colors.grey[200]),
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/': (context) => const AdminDashboardScreen(),
        '/auth': (context) => const AuthScreen(),
        '/role_check': (context) => const RoleCheckScreen(),
        '/student_home': (context) => const StudentHomeScreen(),
        '/lesson_details': (context) => const LessonDetailsScreen(),
        '/favorites': (context) => const FavoritesScreen(),
        '/admin_dashboard': (context) => const AdminDashboardScreen(),
        '/manage_lessons': (context) => const ManageLessonsScreen(),
        '/cloudinary_upload': (context) => const CloudinaryUploadScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/reports': (context) => const ReportsScreen(),
      },
    );
  }
}
