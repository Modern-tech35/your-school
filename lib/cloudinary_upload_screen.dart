import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';

class CloudinaryUploadScreen extends StatefulWidget {
  const CloudinaryUploadScreen({super.key});

  @override
  State<CloudinaryUploadScreen> createState() => _CloudinaryUploadScreenState();
}

class _CloudinaryUploadScreenState extends State<CloudinaryUploadScreen> {
  bool _isUploading = false;
  String? _uploadedUrl;
  String? _uploadError;
  List<Map<String, String>> _recentUploads = [];

  // Cloudinary configuration
  static const String cloudName = 'dptxm0zv0';
  static const String uploadPreset = 'ju9sb0sv'; // Using unsigned preset for uploads

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload to Cloudinary'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
            const Text(
              'Upload Media Files',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Upload videos, PDFs, and images to Cloudinary for use in lessons',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),

            // Upload Options
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
                    const Text(
                      'Select File Type',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildUploadOption(
                            'Video',
                            Icons.video_library,
                            Colors.blue,
                            () => _pickAndUploadFile('video'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildUploadOption(
                            'PDF',
                            Icons.picture_as_pdf,
                            Colors.red,
                            () => _pickAndUploadFile('pdf'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildUploadOption(
                            'Image',
                            Icons.image,
                            Colors.green,
                            () => _pickAndUploadFile('image'),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Upload Status
                    if (_isUploading) ...[
                      const Center(
                        child: Column(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Uploading...'),
                          ],
                        ),
                      ),
                    ] else if (_uploadedUrl != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.green),
                                SizedBox(width: 8),
                                Text(
                                  'Upload Successful',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'URL: $_uploadedUrl',
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    await Clipboard.setData(ClipboardData(text: _uploadedUrl!));
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('URL copied to clipboard')),
                                      );
                                    }
                                  },
                                  icon: const Icon(Icons.copy),
                                  label: const Text('Copy URL'),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _uploadedUrl = null;
                                      _uploadError = null;
                                    });
                                  },
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Upload Another'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ] else if (_uploadError != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.error, color: Colors.red),
                                SizedBox(width: 8),
                                Text(
                                  'Upload Failed',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _uploadError!,
                              style: const TextStyle(fontSize: 12, color: Colors.red),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _uploadError = null;
                                });
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('Try Again'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.cloud_upload,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Select a file type above to start uploading',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Recent Uploads
            const Text(
              'Recent Uploads',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              height: 300,
              child: _recentUploads.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history,
                            size: 48,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No recent uploads',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _recentUploads.length,
                      itemBuilder: (context, index) {
                        final upload = _recentUploads[index];
                        return _buildRecentUploadItem(
                          upload['name']!,
                          upload['type']!,
                          upload['time']!,
                          upload['url']!,
                        );
                      },
                    ),
            ),
          ],
        ),
    );
  }

  Widget _buildUploadOption(String title, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: _isUploading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color.withOpacity(0.3)),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentUploadItem(String name, String type, String time, String url) {
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
            type == 'Video' ? Icons.video_library :
            type == 'PDF' ? Icons.picture_as_pdf : Icons.image,
            size: 20,
            color: const Color(0xFF001F3F),
          ),
        ),
        title: Text(name),
        subtitle: Text('$type • $time'),
        trailing: IconButton(
          icon: const Icon(Icons.copy),
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: url));
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('URL copied: $url')),
              );
            }
          },
        ),
      ),
    );
  }

  Future<void> _pickAndUploadFile(String fileType) async {
    debugPrint('DEBUG: Starting file pick for type: $fileType');
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: _getFileType(fileType),
        allowMultiple: false,
        allowedExtensions: fileType == 'pdf' ? ['pdf'] : null,
      );

      debugPrint('DEBUG: File picker result: ${result != null ? 'success' : 'null'}');
      if (result != null) {
        debugPrint('DEBUG: Files count: ${result.files.length}');
        debugPrint('DEBUG: File path: ${result.files.single.path}');
        debugPrint('DEBUG: File name: ${result.files.single.name}');
        debugPrint('DEBUG: File size: ${result.files.single.size}');
        debugPrint('DEBUG: File extension: ${result.files.single.extension}');
      }

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        debugPrint('DEBUG: File exists: ${file.existsSync()}');
        debugPrint('DEBUG: File length: ${file.lengthSync()}');
        await _uploadToCloudinary(file, fileType, result.files.single.name);
      } else {
        debugPrint('DEBUG: No file selected or path is null');
      }
    } catch (e) {
      debugPrint('DEBUG: Error picking file: $e');
      setState(() {
        _uploadError = 'Error picking file: $e';
      });
    }
  }

  FileType _getFileType(String fileType) {
    switch (fileType) {
      case 'video':
        return FileType.video;
      case 'pdf':
        return FileType.custom;
      case 'image':
        return FileType.image;
      default:
        return FileType.any;
    }
  }

  Future<void> _uploadToCloudinary(File file, String fileType, String fileName) async {
    debugPrint('DEBUG: Starting Cloudinary upload');
    debugPrint('DEBUG: File path: ${file.path}');
    debugPrint('DEBUG: File type: $fileType');
    debugPrint('DEBUG: File name: $fileName');
    debugPrint('DEBUG: Cloud name: $cloudName');
    debugPrint('DEBUG: Upload preset: $uploadPreset');

    setState(() {
      _isUploading = true;
      _uploadedUrl = null;
      _uploadError = null;
    });

    try {
      final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/auto/upload');
      debugPrint('DEBUG: Upload URI: $uri');

      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      debugPrint('DEBUG: Sending request...');
      final streamedResponse = await request.send().timeout(const Duration(seconds: 600));
      debugPrint('DEBUG: Response status: ${streamedResponse.statusCode}');

      final responseBody = await streamedResponse.stream.bytesToString();
      debugPrint('DEBUG: Response body: $responseBody');

      final jsonResponse = json.decode(responseBody);
      debugPrint('DEBUG: Parsed JSON response');

      if (streamedResponse.statusCode == 200 && jsonResponse['secure_url'] != null) {
        final url = jsonResponse['secure_url'];
        debugPrint('DEBUG: Upload successful, URL: $url');
        setState(() {
          _uploadedUrl = url;
          _isUploading = false;
        });

        // Add to recent uploads
        _addToRecentUploads(fileName, fileType, url);
      } else {
        debugPrint('DEBUG: Upload failed - Status: ${streamedResponse.statusCode}, Error: ${jsonResponse['error']?['message']}');
        throw Exception(jsonResponse['error']?['message'] ?? 'Upload failed');
      }
    } catch (e) {
      debugPrint('DEBUG: Upload error: $e');
      setState(() {
        _uploadError = 'Upload failed: $e';
        _isUploading = false;
      });
    }
  }

  void _addToRecentUploads(String fileName, String fileType, String url) {
    final now = DateTime.now();
    final timeString = '${now.hour}:${now.minute.toString().padLeft(2, '0')} today';

    setState(() {
      _recentUploads.insert(0, {
        'name': fileName,
        'type': fileType == 'video' ? 'Video' : fileType == 'pdf' ? 'PDF' : 'Image',
        'time': timeString,
        'url': url,
      });

      // Keep only last 10 uploads
      if (_recentUploads.length > 10) {
        _recentUploads = _recentUploads.sublist(0, 10);
      }
    });
  }
}