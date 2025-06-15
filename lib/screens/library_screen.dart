import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../models/materials.dart';
import '../dummy/materials_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../theme/text_styles.dart';
import '../theme/tab_bar_styles.dart';
import '../widgets/branch_selector.dart';
import 'book_detail_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  String? _selectedBranch;
  String _searchQuery = '';
  bool _showTextbooks = true; // true for textbooks, false for guidelines

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = context.read<UserProvider>();
      if (userProvider.specialty.isNotEmpty) {
        setState(() {
          _selectedBranch = userProvider.specialty;
        });
      }
    });
  }

  List<String> get _branches {
    final branches = MaterialsData.branches;
    branches.sort();
    return branches;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Padding(
      padding: AppTheme.screenPadding(context),
      child: Column(
        children: [
          // Branch Selection Dropdown
          BranchSelector(
            selectedBranch: _selectedBranch,
            onBranchSelected: (String? newValue) {
              setState(() {
                _selectedBranch = newValue;
              });
            },
          ),
          const SizedBox(height: 16),
          // Search Bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Ara...',
              hintStyle: AppTextStyles.hintStyle(context),
              prefixIcon: Icon(
                Icons.search,
                color: AppColors.primary.withOpacity(0.7),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            style: AppTextStyles.bodyLarge(context),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 16),
          // Toggle Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showTextbooks = true;
                    });
                  },
                  style: TabBarStyles.getTabButtonStyle(
                    context: context,
                    isSelected: _showTextbooks,
                    isLeftButton: true,
                  ),
                  child: Text(
                    'Textbooks',
                    style: TabBarStyles.getTabTextStyle(
                      context: context,
                      isSelected: _showTextbooks,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showTextbooks = false;
                    });
                  },
                  style: TabBarStyles.getTabButtonStyle(
                    context: context,
                    isSelected: !_showTextbooks,
                    isLeftButton: false,
                  ),
                  child: Text(
                    'Guidelines',
                    style: TabBarStyles.getTabTextStyle(
                      context: context,
                      isSelected: !_showTextbooks,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Materials List
          if (_selectedBranch != null) // Only show list if a branch is selected
            Expanded(
              child: ListView.builder(
                itemCount: _showTextbooks
                    ? Textbook.branchTextbooks[_selectedBranch]?.length ?? 0
                    : Guideline.branchGuidelines[_selectedBranch]?.length ?? 0,
                itemBuilder: (context, index) {
                  final materials = _showTextbooks
                      ? Textbook.branchTextbooks[_selectedBranch] ?? []
                      : Guideline.branchGuidelines[_selectedBranch] ?? [];
                  final material = materials[index];

                  if (_searchQuery.isNotEmpty &&
                      !material
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase())) {
                    return const SizedBox.shrink();
                  }

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text(
                        material,
                        style: AppTextStyles.titleMedium(context).copyWith(
                          fontSize: isSmallScreen ? 16 : 18,
                        ),
                      ),
                      trailing: Icon(
                        _showTextbooks ? Icons.book : Icons.description,
                        color: _showTextbooks
                            ? AppColors.primary
                            : AppColors.tertiary,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookDetailScreen(
                              title: material,
                              type: _showTextbooks ? 'Textbook' : 'Guideline',
                              branch: _selectedBranch!,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            )
          else
            Expanded(
              child: Center(
                child: Text(
                  'Lütfen bir branş seçiniz',
                  style: AppTextStyles.titleMedium(context).copyWith(
                    color: AppColors.primary.withOpacity(0.5),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
