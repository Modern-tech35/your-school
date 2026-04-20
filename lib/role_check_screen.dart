import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/user_profile.dart';

class RoleCheckScreen extends StatefulWidget {
  const RoleCheckScreen({super.key});

  @override
  State<RoleCheckScreen> createState() => _RoleCheckScreenState();
}

class _RoleCheckScreenState extends State<RoleCheckScreen> {
  bool _isLoading = true;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final profile = UserProfile.fromMap(doc.data()!);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('role', profile.role);
          
          setState(() {
            _userRole = profile.role;
            _isLoading = false;
          });

          // Navigate to appropriate home screen
          await Future.delayed(const Duration(seconds: 1)); // Brief pause for UX
          if (mounted) {
            if (_userRole == 'admin') {
              Navigator.of(context).pushReplacementNamed('/admin_dashboard');
            } else {
              Navigator.of(context).pushReplacementNamed('/student_home');
            }
          }
        } else {
          // User doesn't have a profile, redirect to profile setup
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/profile');
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading user profile: $e')),
          );
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      // User not authenticated, redirect to auth
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/auth');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
      backgroundColor: const Color(0xFF4FC3F7),
      body: Center(
        child: _isLoading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Checking your access level...',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _userRole == 'admin' ? Icons.admin_panel_settings : Icons.school,
                    size: 80,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _userRole == 'admin' ? 'Admin Access' : 'Student Access',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Redirecting to your dashboard...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
      ),
    ),
    );
  }
}