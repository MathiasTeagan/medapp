import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/text_styles.dart';
import '../dummy/materials_data.dart';

class BranchSelector extends StatelessWidget {
  final String? selectedBranch;
  final Function(String?) onBranchSelected;
  final bool showLabel;
  final String? labelText;

  const BranchSelector({
    super.key,
    required this.selectedBranch,
    required this.onBranchSelected,
    this.showLabel = true,
    this.labelText,
  });

  List<String> get _branches {
    final branches = MaterialsData.branches;
    branches.sort();
    return branches;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonFormField<String>(
        value: selectedBranch,
        dropdownColor: AppColors.surface,
        menuMaxHeight: MediaQuery.of(context).size.height * 0.4,
        decoration: InputDecoration(
          labelText: showLabel ? (labelText ?? 'Branş Seçiniz') : null,
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
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: size.width * 0.04,
            vertical: size.height * 0.02,
          ),
        ),
        icon: const Icon(
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
        onChanged: onBranchSelected,
        hint: Text(
          'Branş seçiniz',
          style: AppTextStyles.bodyLarge(context).copyWith(
            color: AppColors.primary.withOpacity(0.5),
            fontSize: isSmallScreen ? 14 : 16,
          ),
        ),
      ),
    );
  }
}
