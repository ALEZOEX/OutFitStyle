import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';

class CitySearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSearch;

  const CitySearchBar({
    super.key,
    required this.controller,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: isDark ? AppTheme.cardGradientDark : AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              style: TextStyle(
                color: isDark
                    ? Colors.white
                    : theme.textTheme.bodyLarge?.color ?? AppTheme.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Введите город...',
                hintStyle: TextStyle(
                  color: isDark
                      ? Colors.grey[400]
                      : theme.textTheme.bodyMedium?.color
                      ?.withOpacity(0.7) ??
                      AppTheme.textSecondary,
                ),
                prefixIcon: const Icon(
                  Icons.location_city,
                  color: AppTheme.primary,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              onSubmitted: (_) => onSearch(),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: onSearch,
            ),
          ),
        ],
      ),
    );
  }
}