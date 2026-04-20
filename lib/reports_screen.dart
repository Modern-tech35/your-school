import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/lesson.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
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
                return isSmall
                    ? Column(
                        children: [
                          _buildOverviewCard('Total Students', _getStudentsCount()),
                          const SizedBox(height: 12),
                          _buildOverviewCard('Total Lessons', _getLessonsCount()),
                          const SizedBox(height: 12),
                          _buildOverviewCard('Total Views', _getTotalViews()),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: _buildOverviewCard('Total Students', _getStudentsCount()),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildOverviewCard('Total Lessons', _getLessonsCount()),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildOverviewCard('Total Views', _getTotalViews()),
                          ),
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
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    FutureBuilder<String>(
                      future: _getMostWatchedLesson(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        return Text(
                          snapshot.data ?? 'No data',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Highest engagement',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
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
                    .map((doc) => Lesson.fromMap(doc.data() as Map<String, dynamic>))
                    .toList();

                final maxViews = lessons.isNotEmpty ? lessons.map((l) => l.views).reduce((a, b) => a > b ? a : b) : 1;

                return Column(
                  children: lessons.map((lesson) {
                    final views = lesson.views;
                    final progress = maxViews > 0 ? views / maxViews : 0.0;

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lesson.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    backgroundColor: Colors.grey[300],
                                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF001F3F)),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '$views views',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
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
              child: SizedBox(
                width: 150,
                height: 150,
                child: Stack(
                  children: [
                    CircularProgressIndicator(
                      value: 0.75, // 75% engagement
                      strokeWidth: 12,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF001F3F)),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            '75%',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Engaged',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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
                        _buildBar('Mon', 0.6),
                        _buildBar('Tue', 0.8),
                        _buildBar('Wed', 0.5),
                        _buildBar('Thu', 0.9),
                        _buildBar('Fri', 0.7),
                        _buildBar('Sat', 0.4),
                        _buildBar('Sun', 0.6),
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

  Widget _buildOverviewCard(String title, Future<int> countFuture) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
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

  Widget _buildBar(String label, double height) {
    return Column(
      children: [
        Container(
          width: 30,
          height: height * 100,
          decoration: BoxDecoration(
            color: const Color(0xFF001F3F),
            borderRadius: BorderRadius.circular(4),
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

  Future<int> _getStudentsCount() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').get();
    return snapshot.size;
  }

  Future<int> _getLessonsCount() async {
    final snapshot = await FirebaseFirestore.instance.collection('lessons').get();
    return snapshot.size;
  }

  Future<int> _getTotalViews() async {
    final snapshot = await FirebaseFirestore.instance.collection('lessons').get();
    final lessons = snapshot.docs.map((doc) => Lesson.fromMap(doc.data())).toList();
    return lessons.isNotEmpty ? lessons.map((l) => l.views).reduce((a, b) => a + b) : 0;
  }

  Future<String> _getMostWatchedLesson() async {
    final lessonsSnapshot = await FirebaseFirestore.instance.collection('lessons').get();
    final lessons = lessonsSnapshot.docs.map((doc) => Lesson.fromMap(doc.data())).toList();

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