import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'models/lesson.dart';

class LessonDetailsScreen extends StatefulWidget {
  const LessonDetailsScreen({super.key});

  @override
  State<LessonDetailsScreen> createState() => _LessonDetailsScreenState();
}

class _LessonDetailsScreenState extends State<LessonDetailsScreen> {
  bool _isFavorited = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkIfFavorited();
    _incrementViews();
  }

  Future<void> _checkIfFavorited() async {
    final lesson = ModalRoute.of(context)!.settings.arguments as Lesson;
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('favorites')
          .doc(user.uid)
          .collection('lessons')
          .doc(lesson.id)
          .get();

      if (mounted) {
        setState(() {
          _isFavorited = doc.exists;
        });
      }
    }
  }

  Future<void> _incrementViews() async {
    final lesson = ModalRoute.of(context)!.settings.arguments as Lesson;
    await FirebaseFirestore.instance
        .collection('lessons')
        .doc(lesson.id)
        .update({'views': FieldValue.increment(1)});
  }

  Future<void> _toggleFavorite(Lesson lesson) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final favoriteRef = FirebaseFirestore.instance
        .collection('favorites')
        .doc(user.uid)
        .collection('lessons')
        .doc(lesson.id);

    if (_isFavorited) {
      await favoriteRef.delete();
    } else {
      await favoriteRef.set({
        'lessonId': lesson.id,
        'addedAt': DateTime.now().toIso8601String(),
      });
    }

    setState(() {
      _isFavorited = !_isFavorited;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isFavorited ? 'Added to favorites' : 'Removed from favorites'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lesson = ModalRoute.of(context)!.settings.arguments as Lesson;

    return Scaffold(
      appBar: AppBar(
        title: Text(lesson.title),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorited ? Icons.favorite : Icons.favorite_border,
              color: _isFavorited ? Colors.red : null,
            ),
            onPressed: () => _toggleFavorite(lesson),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width > 600 ? 16 : 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
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
                        Container(
                          width: 50,
                          height: 50,
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
                            size: 30,
                            color: const Color(0xFF001F3F),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lesson.title,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: lesson.contentType == 'video'
                                      ? Colors.blue.withOpacity(0.1)
                                      : lesson.contentType == 'pdf'
                                          ? Colors.red.withOpacity(0.1)
                                          : Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  lesson.contentType.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: lesson.contentType == 'video'
                                        ? Colors.blue
                                        : lesson.contentType == 'pdf'
                                            ? Colors.red
                                            : Colors.green,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      lesson.description,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Content',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            AspectRatio(
              aspectRatio: MediaQuery.of(context).orientation == Orientation.portrait ? 16 / 9 : 9 / 16,
              child: Container(
                decoration: BoxDecoration(
                  color: lesson.contentType == 'image' ? null : Colors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: lesson.contentType == 'video'
                      ? VideoPlayerWidget(videoUrl: lesson.contentUrl)
                      : lesson.contentType == 'pdf'
                          ? PdfViewerWidget(pdfUrl: lesson.contentUrl)
                          : _buildImageViewer(lesson),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfoRow(
                      Icons.calendar_today,
                      'Created: ${_formatDate(lesson.createdAt)}',
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      Icons.person,
                      'Created by: ${lesson.createdBy}',
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

  Widget _buildImageViewer(Lesson lesson) {
    return Image.network(
      lesson.contentUrl,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported,
              size: 80,
              color: Colors.white,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load image',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF001F3F), size: 20),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  const VideoPlayerWidget({super.key, required this.videoUrl});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    _initializeVideoPlayerFuture = _controller.initialize();
    _controller.setLooping(true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Stack(
            alignment: Alignment.center,
            children: [
              VideoPlayer(_controller),
              IconButton(
                icon: Icon(
                  _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 50,
                ),
                onPressed: () {
                  setState(() {
                    if (_controller.value.isPlaying) {
                      _controller.pause();
                    } else {
                      _controller.play();
                    }
                  });
                },
              ),
            ],
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

class PdfViewerWidget extends StatefulWidget {
  final String pdfUrl;
  const PdfViewerWidget({super.key, required this.pdfUrl});

  @override
  State<PdfViewerWidget> createState() => _PdfViewerWidgetState();
}

class _PdfViewerWidgetState extends State<PdfViewerWidget> {
  String? _localPath;
  bool _hasError = false;
  bool _snackbarShown = false;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      final response = await http.get(Uri.parse(widget.pdfUrl));
      if (response.statusCode != 200 || response.bodyBytes.isEmpty) {
        throw Exception('Failed to load PDF: ${response.statusCode}');
      }
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/temp.pdf');
      await file.writeAsBytes(response.bodyBytes);
      setState(() {
        _localPath = file.path;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error loading PDF: $e');
      }
      setState(() {
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      if (!_snackbarShown) {
        _snackbarShown = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Viewer integration needed')),
          );
        });
      }
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 48, color: Colors.red),
            SizedBox(height: 16),
            Text('Viewer integration needed'),
          ],
        ),
      );
    } else if (_localPath != null) {
      return PDFView(
        filePath: _localPath,
      );
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }
}
