import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../models/favorite.dart';
import '../providers/theme_provider.dart';
import '../services/api_service.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<FavoriteOutfit>> _favoritesFuture;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() {
    setState(() {
      _favoritesFuture = _apiService.getFavorites(userId: 1);
    });
    return _favoritesFuture;
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
              return _buildSkeletonLoader(isDark);
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

  Widget _buildSkeletonLoader(bool isDark) {
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
            color: Colors.white,
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
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(outfit.location,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const Spacer(),
                Text(
                  outfit.savedAt,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
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
                            child: Text(item['icon_emoji'] ?? '?',
                                style: const TextStyle(fontSize: 32)),
                          ))
                      .toList(),
                ),
                // ...
              ],
            ),
          ],
        ),
      ),
    );
  }
}
