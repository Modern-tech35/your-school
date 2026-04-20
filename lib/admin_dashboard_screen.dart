import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/lesson.dart';
import 'models/user_profile.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final Stream<DocumentSnapshot> _userStream;
  String _currentUserName = 'User'; // New state variable
  StreamSubscription? _userSubscription; // New subscription variable

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/auth');
        }
      });
      return;
    }
    // Check role
    SharedPreferences.getInstance().then((prefs) {
      final role = prefs.getString('role');
      if (role == 'student') {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/student_home');
          }
        });
        return;
      }
      // Proceed with admin setup
      _userStream = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots();
      // Listen to the stream and update _currentUserName
      _userSubscription = _userStream.listen((DocumentSnapshot snapshot) {
        if (snapshot.exists && snapshot.data() != null) {
          final profile = UserProfile.fromMap(
            snapshot.data() as Map<String, dynamic>,
          );
          if (_currentUserName != profile.name) {
            setState(() {
              _currentUserName = profile.name;
            });
          }
        } else {
          if (_currentUserName != 'User') {
            setState(() {
              _currentUserName = 'User';
            });
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _userSubscription?.cancel(); // Cancel the subscription
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('$_currentUserName Dashboard'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      ),
      drawer: _buildDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(
            MediaQuery.of(context).size.width > 600 ? 16 : 8,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats Cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Lessons',
                      Icons.library_books,
                      _getLessonsCount(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Active Users',
                      Icons.people,
                      _getUsersCount(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Quick Actions
              Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildActionCard(
                      'Upload Media',
                      Icons.cloud_upload,
                      Colors.blue,
                      () => Navigator.pushNamed(context, '/cloudinary_upload'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionCard(
                      'Manage Lessons',
                      Icons.edit,
                      Colors.orange,
                      () => Navigator.pushNamed(context, '/manage_lessons'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionCard(
                      'View Reports',
                      Icons.bar_chart,
                      Colors.green,
                      () => Navigator.pushNamed(context, '/reports'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Recent Lessons
              Text(
                'Recent Lessons',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 16),

              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('lessons')
                    .orderBy('createdAt', descending: true)
                    .limit(5)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final lessons = snapshot.data!.docs
                      .map(
                        (doc) =>
                            Lesson.fromMap(doc.data() as Map<String, dynamic>),
                      )
                      .toList();

                  if (lessons.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.library_books,
                            size: 60,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No lessons created yet',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: lessons.length,
                    itemBuilder: (context, index) {
                      final lesson = lessons[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFF001F3F).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              lesson.contentType == 'video'
                                  ? Icons.play_circle_fill
                                  : lesson.contentType == 'pdf'
                                  ? Icons.picture_as_pdf
                                  : Icons.image,
                              size: 20,
                              color: const Color(0xFF001F3F),
                            ),
                          ),
                          title: Text(lesson.title),
                          subtitle: Text(
                            '${lesson.contentType.toUpperCase()} • ${_formatDate(lesson.createdAt)}',
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) =>
                                _handleLessonAction(value, lesson),
                            itemBuilder: (BuildContext context) =>
                                <PopupMenuEntry<String>>[
                                  const PopupMenuItem<String>(
                                    value: 'edit',
                                    child: Text('Edit'),
                                  ),
                                  const PopupMenuItem<String>(
                                    value: 'delete',
                                    child: Text('Delete'),
                                  ),
                                ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, IconData icon, Future<int> countFuture) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: const Color(0xFF4FC3F7)),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            FutureBuilder<int>(
              future: countFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                }
                return Text(
                  snapshot.data?.toString() ?? '0',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF001F3F),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: color,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(fontSize: 14, color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF4FC3F7)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.school, size: 30, color: Color(0xFF4FC3F7)),
                ),
                SizedBox(height: 16),
                Text(
                  '$_currentUserName Dashboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pop(context);
              // Already on dashboard
            },
          ),
          ListTile(
            leading: const Icon(Icons.library_books),
            title: const Text('Manage Lessons'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/manage_lessons');
            },
          ),
          ListTile(
            leading: const Icon(Icons.cloud_upload),
            title: const Text('Upload to Cloud'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/cloudinary_upload');
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/profile');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pop(context);
              _showLogoutDialog();
            },
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseAuth.instance.signOut();
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (mounted) {
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/auth', (route) => false);
              }
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Future<int> _getLessonsCount() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('lessons')
        .get();
    return snapshot.size;
  }

  Future<int> _getUsersCount() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').get();
    return snapshot.size;
  }

  void _handleLessonAction(String action, Lesson lesson) {
    switch (action) {
      case 'edit':
        Navigator.pushNamed(
          context,
          '/manage_lessons',
          arguments: {'action': 'edit', 'lesson': lesson},
        );
        break;
      case 'delete':
        _showDeleteLessonDialog(lesson);
        break;
    }
  }

  void _showDeleteLessonDialog(Lesson lesson) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Lesson'),
        content: Text('Are you sure you want to delete "${lesson.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteLesson(lesson);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteLesson(Lesson lesson) async {
    try {
      await FirebaseFirestore.instance
          .collection('lessons')
          .doc(lesson.id)
          .delete();
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lesson "${lesson.title}" deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting lesson: $e')));
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
