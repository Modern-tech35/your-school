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

// Custom colors
const Color primaryColor = Color(0xFF4FC3F7);
const Color secondaryColor = Color(0xFF81C784);
const Color backgroundColor = Color(0xFFFAFAFA);
const Color surfaceColor = Color(0xFFFFFFFF);
const Color textColor = Color(0xFF212121);
const Color errorColor = Color(0xFFF44336);
const Color accentColor = Color(0xFFFFEB3B);
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: primaryColor,
          foregroundColor: surfaceColor,
          elevation: 0,
        ),
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
