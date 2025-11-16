import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../models/favorite.dart';
import '../providers/theme_provider.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'package:intl/intl.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late Future<List<FavoriteOutfit>> _favoritesFuture;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() {
    setState(() {
      _favoritesFuture = ApiService().getFavorites(userId: 1);
    });
    return _favoritesFuture;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text('Избранные комплекты'),
        backgroundColor: isDark ? AppTheme.cardDark : Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _loadFavorites,
        color: isDark ? AppTheme.primary : const Color(0xFF007bff),
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
                return _FavoriteCard(outfit: favorites[index], isDark: isDark);
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
  final bool isDark;

  const _FavoriteCard({required this.outfit, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isDark ? 1 : 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(outfit.location, style: const TextStyle(fontWeight: FontWeight.w600)),
                const Spacer(),
                Text(
                  DateFormat('dd.MM.yyyy').format(DateTime.parse(outfit.savedAt)),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: outfit.items.map((item) => 
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(item['icon_emoji'] ?? '?', style: const TextStyle(fontSize: 32)),
                    )
                  ).toList(),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.withOpacity(isDark ? AppTheme.primary : const Color(0xFF007bff), 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${outfit.temperature.round()}°C',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppTheme.primary : const Color(0xFF007bff),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}