import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/lesson.dart';

class ManageLessonsScreen extends StatefulWidget {
  final String? action;
  final Lesson? lesson;

  const ManageLessonsScreen({super.key, this.action, this.lesson});

  @override
  State<ManageLessonsScreen> createState() => _ManageLessonsScreenState();
}

class _ManageLessonsScreenState extends State<ManageLessonsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _courseController = TextEditingController();
  final _contentUrlController = TextEditingController();
  final _thumbnailUrlController = TextEditingController();

  String _contentType = 'video';
  bool _isLoading = false;
  Lesson? _editingLesson;
  bool _didChangeDependenciesRun = false;

  @override
  void initState() {
    super.initState();
    if (widget.action == 'edit' && widget.lesson != null) {
      _editingLesson = widget.lesson;
      _titleController.text = _editingLesson!.title;
      _descriptionController.text = _editingLesson!.description;
      _courseController.text = _editingLesson!.course;
      _contentUrlController.text = _editingLesson!.contentUrl;
      _thumbnailUrlController.text = _editingLesson!.thumbnailUrl;
      _contentType = _editingLesson!.contentType;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didChangeDependenciesRun) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.action == null) {
          _checkForEditMode();
        }
      });
      _didChangeDependenciesRun = true;
    }
  }

  void _checkForEditMode() {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic> && args['action'] == 'edit' && args['lesson'] is Lesson) {
      setState(() {
        _editingLesson = args['lesson'];
        _titleController.text = _editingLesson!.title;
        _descriptionController.text = _editingLesson!.description;
        _courseController.text = _editingLesson!.course;
        _contentUrlController.text = _editingLesson!.contentUrl;
        _thumbnailUrlController.text = _editingLesson!.thumbnailUrl;
        _contentType = _editingLesson!.contentType;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _courseController.dispose();
    _contentUrlController.dispose();
    _thumbnailUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveLesson() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final lesson = Lesson(
        id: _editingLesson?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        contentType: _contentType,
        contentUrl: _contentUrlController.text.trim(),
        thumbnailUrl: _thumbnailUrlController.text.trim(),
        createdAt: _editingLesson?.createdAt ?? DateTime.now(),
        createdBy: user.email ?? 'Unknown',
        course: _courseController.text.trim(),
      );

      await FirebaseFirestore.instance
          .collection('lessons')
          .doc(lesson.id)
          .set(lesson.toMap());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_editingLesson != null ? 'Lesson updated successfully' : 'Lesson added successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving lesson: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _titleController.clear();
    _descriptionController.clear();
    _courseController.clear();
    _contentUrlController.clear();
    _thumbnailUrlController.clear();
    _contentType = 'video';
    setState(() {
      _editingLesson = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editingLesson != null ? 'Edit Lesson' : 'Manage Lessons'),
        actions: [
          if (_editingLesson == null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _resetForm,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Form Section
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _editingLesson != null ? 'Edit Lesson Details' : 'Add New Lesson',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Content Type Selector
                      const Text(
                        'Content Type',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: RadioListTile<String>(
                                  title: const Text('Video'),
                                  value: 'video',
                                  groupValue: _contentType,
                                  onChanged: (value) {
                                    setState(() {
                                      _contentType = value!;
                                    });
                                  },
                                ),
                              ),
                              Expanded(
                                child: RadioListTile<String>(
                                  title: const Text('PDF'),
                                  value: 'pdf',
                                  groupValue: _contentType,
                                  onChanged: (value) {
                                    setState(() {
                                      _contentType = value!;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          RadioListTile<String>(
                            title: const Text('Image'),
                            value: 'image',
                            groupValue: _contentType,
                            onChanged: (value) {
                              setState(() {
                                _contentType = value!;
                              });
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Title Field
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Lesson Title',
                          prefixIcon: Icon(Icons.title),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Description Field
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          prefixIcon: Icon(Icons.description),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Content URL Field
                      TextFormField(
                        controller: _contentUrlController,
                        decoration: InputDecoration(
                          labelText: '${_contentType.toUpperCase()} URL',
                          prefixIcon: Icon(
                            _contentType == 'video' ? Icons.video_library :
                            _contentType == 'pdf' ? Icons.picture_as_pdf : Icons.image,
                          ),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a content URL';
                          }
                          // Basic URL validation
                          if (!Uri.parse(value).isAbsolute) {
                            return 'Please enter a valid URL';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Thumbnail URL Field
                      TextFormField(
                        controller: _thumbnailUrlController,
                        decoration: const InputDecoration(
                          labelText: 'Thumbnail URL (optional)',
                          prefixIcon: Icon(Icons.image),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                        validator: (value) {
                          if (value != null && value.isNotEmpty && !Uri.parse(value).isAbsolute) {
                            return 'Please enter a valid URL';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveLesson,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator()
                              : Text(_editingLesson != null ? 'Update Lesson' : 'Add Lesson'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Lessons List Section (only show if not editing)
            if (_editingLesson == null) ...[
              const Text(
                'All Lessons',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('lessons')
                    .orderBy('createdAt', descending: true)
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
                              lesson.contentType == 'video' ? Icons.play_circle_fill :
                              lesson.contentType == 'pdf' ? Icons.picture_as_pdf : Icons.image,
                              size: 20,
                              color: const Color(0xFF001F3F),
                            ),
                          ),
                          title: Text(lesson.title),
                          subtitle: Text(
                            '${lesson.contentType.toUpperCase()} • ${_formatDate(lesson.createdAt)}',
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) => _handleLessonAction(value, lesson),
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Text('Edit'),
                              ),
                              const PopupMenuItem(
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
          ],
        ),
      ),
    );
  }

  void _handleLessonAction(String action, Lesson lesson) {
    switch (action) {
      case 'edit':
        Navigator.pushReplacementNamed(
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
        content: Text('Are you sure you want to delete "${lesson.title}"? This action cannot be undone.'),
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
      await FirebaseFirestore.instance.collection('lessons').doc(lesson.id).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lesson "${lesson.title}" deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting lesson: $e')),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}