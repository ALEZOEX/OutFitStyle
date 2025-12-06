import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../models/favorite.dart';
import '../providers/theme_provider.dart';
import '../services/api_service.dart';
import '../services/auth_storage.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late Future<List<FavoriteOutfit>> _favoritesFuture;

  @override
  void initState() {
    super.initState();
    _favoritesFuture = Future.value(<FavoriteOutfit>[]);
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final apiService = context.read<ApiService>();
    final authStorage = context.read<AuthStorage>();
    final userId = await authStorage.readUserId();

    if (!mounted) return;

    if (userId == null) {
      setState(() {
        _favoritesFuture = Future.value(<FavoriteOutfit>[]);
      });
      return;
    }

    setState(() {
      _favoritesFuture = apiService.getFavorites(userId: userId);
    });

    await _favoritesFuture;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Избранные комплекты'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadFavorites,
        child: FutureBuilder<List<FavoriteOutfit>>(
          future: _favoritesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildSkeletonLoader(isDark, theme);
            }
            if (snapshot.hasError) {
              return Center(child: Text('Ошибка: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Нет сохраненных комплектов'));
            }

            final favorites = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                return _FavoriteCard(outfit: favorites[index]);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildSkeletonLoader(bool isDark, ThemeData theme) {
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[850]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 6,
        itemBuilder: (context, index) => Container(
          margin: const EdgeInsets.only(bottom: 16),
          height: 120,
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  final FavoriteOutfit outfit;
  const _FavoriteCard({required this.outfit});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: theme.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on,
                    size: 16, color: theme.textTheme.bodyMedium?.color),
                const SizedBox(width: 4),
                Text(
                  outfit.location,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                const Spacer(),
                Text(
                  outfit.savedAt,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: outfit.items
                      .map((item) => Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      item['icon_emoji'] ?? '?',
                      style: const TextStyle(fontSize: 32),
                    ),
                  ))
                      .toList(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}