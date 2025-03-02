import 'package:flutter/material.dart';
import '../models/materials.dart';
import '../dummy/materials_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../theme/text_styles.dart';
import '../theme/tab_bar_styles.dart';
import 'book_detail_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  String _selectedBranch = 'Kardiyoloji';
  String _searchQuery = '';
  bool _showTextbooks = true; // true for textbooks, false for guidelines

  List<String> get _branches {
    final branches = MaterialsData.branches;
    branches.sort();
    return branches;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kütüphane'),
      ),
      body: Padding(
        padding: AppTheme.screenPadding(context),
        child: Column(
          children: [
            // Branch Selection Dropdown
            Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedBranch,
                dropdownColor: AppColors.surface,
                menuMaxHeight: MediaQuery.of(context).size.height * 0.4,
                decoration: InputDecoration(
                  labelText: 'Branş Seçiniz',
                  labelStyle: AppTextStyles.titleMedium(context).copyWith(
                    color: AppColors.primary,
                    fontSize: isSmallScreen ? 16 : 18,
                  ),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.04,
                    vertical: size.height * 0.02,
                  ),
                ),
                icon: Icon(
                  Icons.arrow_drop_down_circle,
                  color: AppColors.primary,
                ),
                items: _branches.map((String branch) {
                  return DropdownMenuItem(
                    value: branch,
                    child: Text(
                      branch,
                      style: AppTextStyles.bodyLarge(context).copyWith(
                        color: AppColors.primary,
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedBranch = newValue;
                    });
                  }
                },
                style: AppTextStyles.bodyLarge(context).copyWith(
                  color: AppColors.primary,
                  fontSize: isSmallScreen ? 14 : 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
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
                              branch: _selectedBranch,
                            ),
                          ),
                        );
                      },
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
}
