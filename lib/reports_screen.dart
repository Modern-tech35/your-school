import 'package:flutter/material.dart';
import 'gradient_app_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/lesson.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  // Shades of the single brand violet, used for progress bars and activity.
  static const List<List<Color>> _palette = [
    [Color(0xFF4FC3F7), Color(0xFF2196F3)],
    [Color(0xFF1976D2), Color(0xFF81D4FA)],
    [Color(0xFF1565C0), Color(0xFF64B5F6)],
    [Color(0xFF1976D2), Color(0xFF81D4FA)],
    [Color(0xFF4FC3F7), Color(0xFF64B5F6)],
  ];

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: GradientAppBar(
        title: const Text('Reports'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isSmallScreen ? 8 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overview Stats
            Text(
              'Overview',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final isSmall = constraints.maxWidth < 600;
                final overviewCards = [
                  _buildOverviewCard(
                    'Total Students',
                    _getStudentsCount(),
                    const [Color(0xFF4FC3F7), Color(0xFF2196F3)],
                    Icons.people,
                  ),
                  const SizedBox(width: 12, height: 12),
                  _buildOverviewCard(
                    'Total Lessons',
                    _getLessonsCount(),
                    const [Color(0xFF4FC3F7), Color(0xFF2196F3)],
                    Icons.library_books,
                  ),
                  const SizedBox(width: 12, height: 12),
                  _buildOverviewCard(
                    'Total Views',
                    _getTotalViews(),
                    const [Color(0xFF4FC3F7), Color(0xFF2196F3)],
                    Icons.visibility,
                  ),
                ];
                if (isSmall) {
                  return Column(
                    children: [
                      overviewCards[0],
                      overviewCards[1],
                      overviewCards[2],
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(child: overviewCards[0]),
                    overviewCards[1],
                    Expanded(child: overviewCards[2]),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            // Most Watched Lesson
            Text(
              'Most Watched Lesson',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4FC3F7), Color(0xFF2196F3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4FC3F7).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Icon(Icons.emoji_events, color: Colors.white, size: 40),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FutureBuilder<String>(
                      future: _getMostWatchedLesson(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          );
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              snapshot.data ?? 'No data',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Highest engagement',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Lesson Views Chart
            Text(
              'Lesson Views',
              style: TextStyle(
                fontSize: 20,
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

                final maxViews = lessons.isNotEmpty
                    ? lessons.map((l) => l.views).reduce((a, b) => a > b ? a : b)
                    : 1;

                return Column(
                  children: lessons.asMap().entries.map((entry) {
                    final index = entry.key;
                    final lesson = entry.value;
                    final views = lesson.views;
                    final progress = maxViews > 0 ? views / maxViews : 0.0;
                    final gradient = _palette[index % _palette.length];

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    lesson.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(colors: gradient),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '$views views',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 10,
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  gradient.first,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 24),

            // Engagement Circular Progress
            Text(
              'Overall Engagement',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: FutureBuilder<double>(
                future: _getOverallEngagement(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      width: 160,
                      height: 160,
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 3),
                      ),
                    );
                  }
                  final pct = (snapshot.data ?? 0).clamp(0.0, 100.0);
                  return Column(
                    children: [
                      SizedBox(
                        width: 160,
                        height: 160,
                        child: Stack(
                          children: [
                            CircularProgressIndicator(
                              value: pct / 100,
                              strokeWidth: 14,
                              strokeCap: StrokeCap.round,
                              backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF4FC3F7),
                      ),
                            ),
                            Center(
                              child: Container(
                                width: 110,
                                height: 110,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF4FC3F7),
                                      Color(0xFF2196F3),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${pct.round()}%',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const Text(
                                      'Engaged',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Average % of students who viewed a lesson',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // Simple Bar Graph
            Text(
              'Weekly Activity',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildBar('Mon', 0.6, 0),
                        _buildBar('Tue', 0.8, 1),
                        _buildBar('Wed', 0.5, 2),
                        _buildBar('Thu', 0.9, 3),
                        _buildBar('Fri', 0.7, 4),
                        _buildBar('Sat', 0.4, 0),
                        _buildBar('Sun', 0.6, 1),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Activity Level',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard(
    String title,
    Future<int> countFuture,
    List<Color> gradient,
    IconData icon,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(icon, size: 32, color: Colors.white),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 14, color: Colors.white70),
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
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                );
              }
              return Text(
                snapshot.data?.toString() ?? '0',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBar(String label, double height, int paletteIndex) {
    final gradient = _palette[paletteIndex % _palette.length];
    return Column(
      children: [
        Container(
          width: 30,
          height: height * 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  /// Overall engagement: average % of students who opened a lesson,
  /// computed from real view counts (capped at 100%).
  Future<double> _getOverallEngagement() async {
    final lessonsSnapshot =
        await FirebaseFirestore.instance.collection('lessons').get();
    final studentsSnapshot =
        await FirebaseFirestore.instance.collection('users').get();

    final lessons =
        lessonsSnapshot.docs.map((doc) => Lesson.fromMap(doc.data())).toList();
    final totalStudents = studentsSnapshot.size;

    if (lessons.isEmpty || totalStudents == 0) return 0;

    final totalViews = lessons.fold<int>(0, (acc, l) => acc + l.views);
    final avgViewsPerLesson = totalViews / lessons.length;

    return ((avgViewsPerLesson / totalStudents) * 100).clamp(0.0, 100.0);
  }

  Future<int> _getStudentsCount() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').get();
    return snapshot.size;
  }

  Future<int> _getLessonsCount() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('lessons').get();
    return snapshot.size;
  }

  Future<int> _getTotalViews() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('lessons').get();
    final lessons =
        snapshot.docs.map((doc) => Lesson.fromMap(doc.data())).toList();
    return lessons.isNotEmpty
        ? lessons.map((l) => l.views).reduce((a, b) => a + b)
        : 0;
  }

  Future<String> _getMostWatchedLesson() async {
    final lessonsSnapshot =
        await FirebaseFirestore.instance.collection('lessons').get();
    final lessons =
        lessonsSnapshot.docs.map((doc) => Lesson.fromMap(doc.data())).toList();

    if (lessons.isEmpty) return 'No lessons';

    Lesson mostWatched = lessons.first;

    for (final lesson in lessons) {
      if (lesson.views > mostWatched.views) {
        mostWatched = lesson;
      }
    }

    return mostWatched.title;
  }
}
