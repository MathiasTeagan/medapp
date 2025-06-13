import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'dart:math';
import '../models/goal.dart';
import '../providers/goals_provider.dart';
import '../providers/user_provider.dart';
import '../dummy/materials_data.dart';

class WhatToReadScreen extends StatefulWidget {
  const WhatToReadScreen({super.key});

  @override
  State<WhatToReadScreen> createState() => _WhatToReadScreenState();
}

class _WhatToReadScreenState extends State<WhatToReadScreen>
    with TickerProviderStateMixin {
  late AnimationController _spinnerController;
  late Animation<double> _spinnerAnimation;

  String _selectedMaterial = '';
  String _selectedChapter = '';
  bool _isSpinning = false;
  String? _selectedBranch;
  final Random _random = Random.secure();
  List<String> _animatingItems = [];
  int _currentIndex = 0;
  List<String> _previousSelections = [];
  Map<String, bool> _selectedMaterials = {};
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    super.initState();
    _spinnerController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _spinnerAnimation = CurvedAnimation(
      parent: _spinnerController,
      curve: Curves.easeOutExpo,
    );

    _spinnerController.addListener(_onSpinnerAnimationTick);
    _spinnerController.addStatusListener(_onSpinnerAnimationStatusChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = context.read<UserProvider>();
      if (userProvider.specialty.isNotEmpty) {
        setState(() {
          _selectedBranch = userProvider.specialty;
          _updateSelectedMaterials();
        });
      }
    });
  }

  void _updateSelectedMaterials() {
    if (_selectedBranch == null) return;

    final materials = <String>[];
    materials.addAll(MaterialsData.branchTextbooks[_selectedBranch] ?? []);
    materials.addAll(MaterialsData.branchGuidelines[_selectedBranch] ?? []);

    for (final material in materials) {
      if (!_selectedMaterials.containsKey(material)) {
        _selectedMaterials[material] = true;
      }
    }
  }

  void _updateMaterialSelection(String material, bool? value) {
    setState(() {
      _selectedMaterials[material] = value ?? true;
    });
    if (_overlayEntry != null) {
      _hideMaterialsOverlay();
      _showMaterialsOverlay();
    }
  }

  List<String> get _branches => MaterialsData.branches;

  List<String> get _allItems {
    if (_selectedBranch == null) return [];

    final items = <String>[];
    final materials = <String>[];
    materials.addAll(MaterialsData.branchTextbooks[_selectedBranch] ?? []);
    materials.addAll(MaterialsData.branchGuidelines[_selectedBranch] ?? []);

    for (final material in materials) {
      if (_selectedMaterials[material] == true) {
        final chapters = MaterialsData.textbookChapters.containsKey(material)
            ? MaterialsData.textbookChapters[material] ?? []
            : MaterialsData.guidelineChapters[material] ?? [];

        for (final chapter in chapters) {
          items.add('$material - $chapter');
        }
      }
    }
    return items;
  }

  DateTime? _lastUpdate;

  @override
  void dispose() {
    _hideMaterialsOverlay();
    _spinnerController.removeListener(_onSpinnerAnimationTick);
    _spinnerController.dispose();
    super.dispose();
  }

  Duration _calculateUpdateInterval(double progress) {
    final milliseconds = 20 + (180 * progress * progress);
    return Duration(milliseconds: milliseconds.toInt());
  }

  void _onSpinnerAnimationTick() {
    if (_isSpinning) {
      final progress = _spinnerController.value;
      final updateInterval = _calculateUpdateInterval(progress);

      if (_lastUpdate == null ||
          DateTime.now().difference(_lastUpdate!) > updateInterval) {
        _updateAnimatingItem();
        _lastUpdate = DateTime.now();
      }
    }
  }

  String _getRandomItem(List<String> items) {
    if (items.isEmpty) return '';
    if (items.length == 1) return items[0];

    final availableItems =
        items.where((item) => !_previousSelections.contains(item)).toList();

    if (availableItems.isEmpty) {
      _previousSelections.clear();
      return items[_random.nextInt(items.length)];
    }

    final selectedItem = availableItems[_random.nextInt(availableItems.length)];
    _previousSelections.add(selectedItem);

    if (_previousSelections.length > 3) {
      _previousSelections.removeAt(0);
    }

    return selectedItem;
  }

  void _updateAnimatingItem() {
    if (_animatingItems.isEmpty) return;
    setState(() {
      _currentIndex = (_currentIndex + 1) % _animatingItems.length;
    });
  }

  void _onSpinnerAnimationStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      if (mounted) {
        setState(() {
          _isSpinning = false;
          final items = _allItems;
          if (items.isNotEmpty) {
            final selectedItem = _getRandomItem(items);
            final parts = selectedItem.split(' - ');
            if (parts.length == 2) {
              _selectedMaterial = parts[0];
              _selectedChapter = parts[1];
            }
          }
        });
      }
    }
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
    if (!_isSpinning && _selectedBranch != null) {
      final items = _allItems;
      if (items.isEmpty) return;

      setState(() {
        _isSpinning = true;
        _lastUpdate = null;

        _animatingItems = List<String>.from(items);
        for (var i = _animatingItems.length - 1; i > 0; i--) {
          var j = _random.nextInt(i + 1);
          var temp = _animatingItems[i];
          _animatingItems[i] = _animatingItems[j];
          _animatingItems[j] = temp;
        }

        _currentIndex = 0;
        _selectedMaterial = '';
        _selectedChapter = '';
      });

      _spinnerController.forward(from: 0.0);
    }
  }

  void _showMaterialsOverlay() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideMaterialsOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _hideMaterialsOverlay,
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          Positioned(
            width: size.width * 0.9,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: const Offset(0, 60),
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 200,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              if (MaterialsData.branchTextbooks[_selectedBranch]
                                      ?.isNotEmpty ??
                                  false) ...[
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  child: Text(
                                    'Textbooklar',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                                ...(MaterialsData
                                            .branchTextbooks[_selectedBranch] ??
                                        [])
                                    .map(
                                  (material) => CheckboxListTile(
                                    title: Text(material),
                                    value: _selectedMaterials[material] ?? true,
                                    onChanged: (bool? value) =>
                                        _updateMaterialSelection(
                                            material, value),
                                    dense: true,
                                  ),
                                ),
                              ],
                              if (MaterialsData
                                      .branchGuidelines[_selectedBranch]
                                      ?.isNotEmpty ??
                                  false) ...[
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  child: Text(
                                    'Guidelinelar',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                                ...(MaterialsData.branchGuidelines[
                                            _selectedBranch] ??
                                        [])
                                    .map(
                                  (material) => CheckboxListTile(
                                    title: Text(material),
                                    value: _selectedMaterials[material] ?? true,
                                    onChanged: (bool? value) =>
                                        _updateMaterialSelection(
                                            material, value),
                                    dense: true,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedBranch,
                  isExpanded: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  borderRadius: BorderRadius.circular(12),
                  hint: const Text('Branş seçiniz'),
                  items: _branches.map((String branch) {
                    return DropdownMenuItem<String>(
                      value: branch,
                      child: Text(branch),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedBranch = newValue;
                      _updateSelectedMaterials();
                    });
                  },
                ),
              ),
            ),
            if (_selectedBranch != null) ...[
              const SizedBox(height: 16),
              CompositedTransformTarget(
                link: _layerLink,
                child: InkWell(
                  onTap: () {
                    if (_overlayEntry == null) {
                      _showMaterialsOverlay();
                    } else {
                      _hideMaterialsOverlay();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Materyaller',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        Icon(
                          _overlayEntry == null
                              ? Icons.keyboard_arrow_down
                              : Icons.keyboard_arrow_up,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 40),
            if (_selectedBranch != null) ...[
              Expanded(
                child: Center(
                  child: Container(
                    height: size.height * 0.3,
                    width: size.width * 0.9,
                    margin: EdgeInsets.symmetric(
                        horizontal: size.width * 0.02,
                        vertical: size.height * 0.01),
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
                            _getItemAt(_currentIndex - 2),
                            false,
                            size,
                            isSmallScreen,
                          ),
                          _buildSpinnerItem(
                            _getItemAt(_currentIndex - 1),
                            false,
                            size,
                            isSmallScreen,
                          ),
                          _buildSpinnerItem(
                            _getItemAt(_currentIndex),
                            true,
                            size,
                            isSmallScreen,
                          ),
                          _buildSpinnerItem(
                            _getItemAt(_currentIndex + 1),
                            false,
                            size,
                            isSmallScreen,
                          ),
                          _buildSpinnerItem(
                            _getItemAt(_currentIndex + 2),
                            false,
                            size,
                            isSmallScreen,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (!_isSpinning &&
                  _selectedMaterial.isNotEmpty &&
                  _selectedChapter.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 80),
                  child: FilledButton.icon(
                    onPressed: () {
                      final goal = Goal(
                        bookTitle: _selectedMaterial,
                        chapterName: _selectedChapter,
                        branch: _selectedBranch!,
                        addedDate: DateTime.now(),
                        type: MaterialsData.textbookChapters
                                .containsKey(_selectedMaterial)
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
                    turns: _spinnerAnimation.value * 10,
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
            ] else
              Expanded(
                child: Center(
                  child: Text(
                    'Lütfen bir branş seçiniz',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 16 : 18,
                      color: Colors.grey,
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

  Widget _buildSpinnerItem(
      String text, bool isSelected, Size size, bool isSmallScreen) {
    return Container(
      height: size.height * 0.04,
      margin: EdgeInsets.symmetric(vertical: size.height * 0.002),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white.withOpacity(0.1) : Colors.transparent,
        border: isSelected
            ? Border(
                top: BorderSide(color: Colors.white.withOpacity(0.3), width: 2),
                bottom:
                    BorderSide(color: Colors.white.withOpacity(0.3), width: 2),
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

  String _getItemAt(int index) {
    if (_animatingItems.isEmpty) return '';
    final effectiveIndex = index % _animatingItems.length;
    final normalizedIndex =
        ((_currentIndex + effectiveIndex) % _animatingItems.length +
                _animatingItems.length) %
            _animatingItems.length;
    return _animatingItems[normalizedIndex];
  }
}
