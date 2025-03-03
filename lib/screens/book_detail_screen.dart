import 'package:flutter/material.dart';

import '../dummy/materials_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../theme/text_styles.dart';

class BookDetailScreen extends StatefulWidget {
  final String title;
  final String type;
  final String branch;

  const BookDetailScreen({
    super.key,
    required this.title,
    required this.type,
    required this.branch,
  });

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  Set<String> _completedChapters = {};
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleChapterCompletion(String chapter) {
    setState(() {
      if (_completedChapters.contains(chapter)) {
        _completedChapters.remove(chapter);
      } else {
        _completedChapters.add(chapter);
      }
    });
  }

  List<String> _getFilteredChapters(List<String> chapters) {
    if (_searchQuery.isEmpty) return chapters;
    return chapters
        .where((chapter) =>
            chapter.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final chapters = widget.type == 'Textbook'
        ? MaterialsData.textbookChapters[widget.title] ?? []
        : MaterialsData.guidelineChapters[widget.title] ?? [];

    final filteredChapters = _getFilteredChapters(chapters);
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: AppTheme.screenPadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chapters',
              style: AppTextStyles.titleLarge(context),
            ),
            const SizedBox(height: 16),
            // Search Field
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Chapter Ara...',
                hintStyle: AppTextStyles.hintStyle(context),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColors.primary.withOpacity(0.7),
                  size: 24,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: AppColors.primaryIcon,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.grey.shade300,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.grey.shade300,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                filled: true,
                fillColor: AppColors.surface,
              ),
              style: AppTextStyles.bodyLarge(context),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 16),
            if (filteredChapters.isEmpty && _searchQuery.isNotEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Aradığınız chapter bulunamadı.',
                    style: AppTextStyles.bodyLarge(context).copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: filteredChapters.length,
                  itemBuilder: (context, index) {
                    final chapter = filteredChapters[index];
                    final isCompleted = _completedChapters.contains(chapter);

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                chapter,
                                style:
                                    AppTextStyles.bodyLarge(context).copyWith(
                                  fontSize: isSmallScreen ? 14 : 16,
                                  color: isCompleted
                                      ? AppColors.completedMetric
                                      : AppColors.primaryText,
                                  fontWeight: isCompleted
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                            if (isCompleted)
                              Icon(
                                Icons.check_circle,
                                color: AppColors.completedMetric,
                                size: isSmallScreen ? 20 : 24,
                              ),
                          ],
                        ),
                        onTap: () => _showCompletionDialog(chapter),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showCompletionDialog(String chapter) {
    final isCompleted = _completedChapters.contains(chapter);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          isCompleted ? 'Chapter Durumu' : 'Chapterı Tamamla',
          style: AppTextStyles.titleMedium(context),
        ),
        content: Text(
          isCompleted
              ? 'Bu chapterı okunmamış olarak işaretlemek istiyor musunuz?'
              : 'Bu chapterı okundu olarak işaretlemek istiyor musunuz?',
          style: AppTextStyles.bodyLarge(context),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'İptal',
              style: AppTextStyles.labelLarge(context).copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
          FilledButton(
            onPressed: () {
              _toggleChapterCompletion(chapter);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor:
                  isCompleted ? AppColors.error : AppColors.completedMetric,
            ),
            child: Text(
              isCompleted ? 'Okunmadı Yap' : 'Okundu Yap',
              style: AppTextStyles.labelLarge(context).copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
