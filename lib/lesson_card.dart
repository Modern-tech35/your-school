import 'package:flutter/material.dart';
import 'models/lesson.dart';

/// Shared lesson card used on both the admin and student screens:
/// thumbnail image, content-type / course / views chips and date.
/// Plain white card (no gradient).
class LessonCard extends StatelessWidget {
  const LessonCard({
    super.key,
    required this.lesson,
    this.trailing,
    this.onTap,
  });

  final Lesson lesson;
  final Widget? trailing;
  final VoidCallback? onTap;

  (Color, IconData) get _typeInfo {
    final icon = switch (lesson.contentType) {
      'video' => Icons.play_circle_fill,
      'pdf' => Icons.picture_as_pdf,
      _ => Icons.image,
    };
    return (const Color(0xFF4FC3F7), icon);
  }

  Widget _thumbnailFallback(Color color, IconData icon) {
    return Container(
      color: color,
      child: Center(child: Icon(icon, color: Colors.white, size: 36)),
    );
  }

  Widget _infoChip({
    required IconData icon,
    required String label,
    required Color color,
    Color? textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor ?? Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor ?? Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final (fallbackColor, typeIcon) = _typeInfo;
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 96,
                  height: 96,
                  child: lesson.thumbnailUrl.isNotEmpty
                      ? Image.network(
                          lesson.thumbnailUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Container(
                              color: fallbackColor,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stack) =>
                              _thumbnailFallback(fallbackColor, typeIcon),
                        )
                      : _thumbnailFallback(fallbackColor, typeIcon),
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (lesson.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        lesson.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _infoChip(
                          icon: typeIcon,
                          label: lesson.contentType.toUpperCase(),
                          color: fallbackColor,
                        ),
                        if (lesson.course.isNotEmpty)
                          _infoChip(
                            icon: Icons.menu_book,
                            label: lesson.course,
                            color: Colors.blueGrey,
                          ),
                        _infoChip(
                          icon: Icons.visibility,
                          label: '${lesson.views} views',
                          color: Colors.grey.shade300,
                          textColor: Colors.grey.shade800,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 12,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(lesson.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Optional trailing (menu / arrow)
              if (trailing != null) ...[
                const SizedBox(width: 4),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
