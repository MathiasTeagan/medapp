import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'dart:math';
import '../models/goal.dart';
import '../providers/goals_provider.dart';
import '../dummy/materials_data.dart';

class WhatToReadScreen extends StatefulWidget {
  const WhatToReadScreen({super.key});

  @override
  State<WhatToReadScreen> createState() => _WhatToReadScreenState();
}

class _WhatToReadScreenState extends State<WhatToReadScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  String _selectedChapter = 'Tap to Spin!';
  bool _isSpinning = false;
  String _selectedBranch = 'Kardiyoloji';
  final Random _random = Random();
  final List<String> _animatingChapters = [];
  int _currentAnimatingIndex = 0;

  List<String> get _branches => MaterialsData.branches;

  Map<String, List<String>> get _branchChapters {
    final allChapters = <String, List<String>>{};

    // Textbook chapters
    for (final textbook
        in MaterialsData.branchTextbooks[_selectedBranch] ?? []) {
      final chapters = MaterialsData.textbookChapters[textbook] ?? [];
      for (final chapter in chapters) {
        allChapters[textbook] = [
          ...?allChapters[textbook],
          '$textbook - $chapter'
        ];
      }
    }

    // Guideline chapters
    for (final guideline
        in MaterialsData.branchGuidelines[_selectedBranch] ?? []) {
      final chapters = MaterialsData.guidelineChapters[guideline] ?? [];
      for (final chapter in chapters) {
        allChapters[guideline] = [
          ...?allChapters[guideline],
          '$guideline - $chapter'
        ];
      }
    }

    return allChapters;
  }

  List<String> get _allChapters {
    return _branchChapters.values.expand((chapters) => chapters).toList();
  }

  DateTime? _lastUpdate;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutExpo,
    );

    _controller.addListener(() {
      if (_isSpinning) {
        final progress = _controller.value;
        final updateInterval = _calculateUpdateInterval(progress);

        if (_lastUpdate == null ||
            DateTime.now().difference(_lastUpdate!) > updateInterval) {
          _updateAnimatingChapter();
          _lastUpdate = DateTime.now();
        }
      }
    });

    _controller.addStatusListener(_onAnimationStatusChanged);
  }

  Duration _calculateUpdateInterval(double progress) {
    final milliseconds = 20 + (180 * progress * progress);
    return Duration(milliseconds: milliseconds.toInt());
  }

  void _updateAnimatingChapter() {
    final chapters = _allChapters;
    if (chapters.isNotEmpty) {
      setState(() {
        _currentAnimatingIndex = (_currentAnimatingIndex + 1) % chapters.length;
      });
    }
  }

  String _getChapterAt(int index) {
    final chapters = _allChapters;
    if (chapters.isEmpty) return '';

    final normalizedIndex = index % chapters.length;
    return chapters[normalizedIndex];
  }

  Widget _buildSpinnerItem(
      String text, bool isSelected, Size size, bool isSmallScreen) {
    return Container(
      height: size.height * 0.04,
      width: size.width * 0.8,
      margin: EdgeInsets.symmetric(vertical: size.height * 0.002),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
        border: isSelected
            ? Border(
                top: BorderSide(color: Colors.blue.shade200, width: 2),
                bottom: BorderSide(color: Colors.blue.shade200, width: 2),
              )
            : null,
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: isSmallScreen ? 10 : 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.black : Colors.black54,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  void _onAnimationStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      if (mounted) {
        setState(() {
          _isSpinning = false;
          final chapters = _allChapters;
          if (chapters.isNotEmpty) {
            _selectedChapter = chapters[_random.nextInt(chapters.length)];
          }
        });
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_onAnimationStatusChanged);
    _controller.stop();
    _controller.dispose();
    super.dispose();
  }

  void _handleBack() {
    if (_isSpinning) {
      _controller.stop();
      _controller.reset();
      setState(() {
        _isSpinning = false;
      });
    }
    Navigator.of(context).pop();
  }

  void _showSuccessSnackBar(BuildContext context) {
    final size = MediaQuery.of(context).size;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Hedeflere eklendi!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: size.height * 0.1,
          left: size.width * 0.04,
          right: size.width * 0.04,
        ),
      ),
    );
  }

  void _spinWheel() {
    if (!_isSpinning) {
      setState(() {
        _isSpinning = true;
        _lastUpdate = null;
        _animatingChapters.clear();
        _animatingChapters.addAll(_allChapters);
        _currentAnimatingIndex = 0;
      });
      _controller.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ne Okusam?'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (!_isSpinning) {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(size.width * 0.04),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedBranch,
                decoration: const InputDecoration(
                  labelText: 'Branş Seçiniz',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                items: _branches.map((String branch) {
                  return DropdownMenuItem(
                    value: branch,
                    child: Text(branch),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedBranch = newValue;
                      _selectedChapter = 'Tap to Spin!';
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return Container(
                          height: size.height * 0.25,
                          width: size.width * 0.85,
                          margin: EdgeInsets.symmetric(
                              vertical: size.height * 0.01),
                          padding: EdgeInsets.symmetric(
                            vertical: size.height * 0.01,
                            horizontal: size.width * 0.02,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.blue.withOpacity(0.1),
                                Colors.blue.shade50,
                                Colors.blue.shade100,
                                Colors.blue.shade50,
                                Colors.blue.withOpacity(0.1),
                              ],
                            ),
                            border: Border.all(color: Colors.blue, width: 2),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ShaderMask(
                            shaderCallback: (Rect bounds) {
                              return const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black,
                                  Colors.black,
                                  Colors.black,
                                  Colors.transparent,
                                ],
                                stops: [0.0, 0.2, 0.4, 0.8, 1.0],
                              ).createShader(bounds);
                            },
                            blendMode: BlendMode.dstIn,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildSpinnerItem(
                                  _getChapterAt(_currentAnimatingIndex - 2),
                                  false,
                                  size,
                                  isSmallScreen,
                                ),
                                _buildSpinnerItem(
                                  _getChapterAt(_currentAnimatingIndex - 1),
                                  false,
                                  size,
                                  isSmallScreen,
                                ),
                                _buildSpinnerItem(
                                  _getChapterAt(_currentAnimatingIndex),
                                  true,
                                  size,
                                  isSmallScreen,
                                ),
                                _buildSpinnerItem(
                                  _getChapterAt(_currentAnimatingIndex + 1),
                                  false,
                                  size,
                                  isSmallScreen,
                                ),
                                _buildSpinnerItem(
                                  _getChapterAt(_currentAnimatingIndex + 2),
                                  false,
                                  size,
                                  isSmallScreen,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (!_isSpinning && _selectedChapter != 'Tap to Spin!')
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 80),
                child: FilledButton.icon(
                  onPressed: () {
                    final parts = _selectedChapter.split(' - ');
                    final goal = Goal(
                      bookTitle: parts[0],
                      chapterName: parts[1],
                      branch: _selectedBranch,
                      addedDate: DateTime.now(),
                      type: MaterialsData.textbookChapters.containsKey(parts[0])
                          ? 'Textbook'
                          : 'Guideline',
                      isCompleted: false,
                    );
                    context.read<GoalsProvider>().addGoal(goal);
                    _showSuccessSnackBar(context);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: const Size.fromHeight(60),
                  ),
                  icon: Icon(
                    Icons.add_task,
                    size: size.width * 0.06,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Hedeflere Ekle',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 80),
              child: FilledButton.icon(
                onPressed: _isSpinning ? null : _spinWheel,
                style: FilledButton.styleFrom(
                  backgroundColor: _isSpinning
                      ? Colors.grey
                      : Theme.of(context).colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size.fromHeight(60),
                ),
                icon: AnimatedRotation(
                  turns: _animation.value * 10,
                  duration: const Duration(milliseconds: 100),
                  child: Icon(
                    Icons.refresh,
                    size: size.width * 0.06,
                    color: Colors.white,
                  ),
                ),
                label: Text(
                  _isSpinning ? 'Spinning...' : 'Spin!',
                  style: TextStyle(
                    fontSize: size.width * 0.04,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
