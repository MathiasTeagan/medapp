import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../dummy/materials_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../theme/text_styles.dart';
import '../models/goal.dart';
import '../providers/goals_provider.dart';
import '../providers/read_chapters_provider.dart';

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
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Sayfa açıldığında okunan chapter'ları yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReadChaptersProvider>().loadReadChapters();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleChapterCompletion(String chapter) {
    final readChaptersProvider = context.read<ReadChaptersProvider>();
    readChaptersProvider.toggleChapterReadStatus(
      widget.title,
      chapter,
      widget.branch,
      widget.type,
    );
  }

  void _addToGoals(String chapter) {
    final goal = Goal(
      bookTitle: widget.title,
      chapterName: chapter,
      branch: widget.branch,
      addedDate: DateTime.now(),
      type: widget.type,
      isCompleted: false,
    );
    context.read<GoalsProvider>().addGoal(goal);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Hedeflere eklendi!'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _removeFromGoals(String chapter) {
    final goals = context.read<GoalsProvider>().goals;
    final goalToRemove = goals.firstWhere((goal) =>
        goal.bookTitle == widget.title && goal.chapterName == chapter);
    context.read<GoalsProvider>().removeGoal(goalToRemove);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Hedeflerden çıkarıldı!'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  bool _isInGoals(String chapter, List<Goal> goals) {
    return goals.any((goal) =>
        goal.bookTitle == widget.title && goal.chapterName == chapter);
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
    final goals = context.watch<GoalsProvider>().goals;
    final readChaptersProvider = context.watch<ReadChaptersProvider>();

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
                    final isCompleted = readChaptersProvider.isChapterRead(
                      widget.title,
                      chapter,
                      widget.branch,
                      widget.type,
                    );
                    final isTargeted = _isInGoals(chapter, goals);

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
                                      : isTargeted
                                          ? Colors.orange
                                          : AppColors.primaryText,
                                  fontWeight: isCompleted || isTargeted
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
                            if (isTargeted && !isCompleted)
                              Icon(
                                Icons.flag,
                                color: Colors.orange,
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
    final readChaptersProvider = context.read<ReadChaptersProvider>();
    final isCompleted = readChaptersProvider.isChapterRead(
      widget.title,
      chapter,
      widget.branch,
      widget.type,
    );
    final goals = context.read<GoalsProvider>().goals;
    final isTargeted = _isInGoals(chapter, goals);

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
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isCompleted)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {
                          if (isTargeted) {
                            _removeFromGoals(chapter);
                          } else {
                            _addToGoals(chapter);
                          }
                          Navigator.pop(context);
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor:
                              isTargeted ? Colors.red : Colors.orange,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          alignment: Alignment.center,
                        ),
                        icon: Icon(
                            isTargeted ? Icons.remove_circle : Icons.flag,
                            color: Colors.white),
                        label: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            isTargeted ? 'Hedeflerden Çıkar' : 'Hedeflere Ekle',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.labelLarge(context).copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {
                          _toggleChapterCompletion(chapter);
                          Navigator.pop(context);
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.completedMetric,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          alignment: Alignment.center,
                        ),
                        icon: const Icon(Icons.check, color: Colors.white),
                        label: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Okundu Yap',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.labelLarge(context).copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              else
                FilledButton.icon(
                  onPressed: () {
                    _toggleChapterCompletion(chapter);
                    Navigator.pop(context);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: isCompleted
                        ? AppColors.error
                        : AppColors.completedMetric,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    alignment: Alignment.center,
                  ),
                  icon: Icon(
                    isCompleted ? Icons.close : Icons.check,
                    color: Colors.white,
                  ),
                  label: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      isCompleted ? 'Okunmadı Yap' : 'Okundu Yap',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.labelLarge(context).copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'İptal',
                  style: AppTextStyles.labelLarge(context).copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
