import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';

import '../models/history.dart';
import '../providers/theme_provider.dart';
import '../services/api_service.dart';
import '../services/auth_storage.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<HistoryItem>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = Future.value(<HistoryItem>[]);
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final apiService = context.read<ApiService>();
    final authStorage = context.read<AuthStorage>();
    final userId = await authStorage.readUserId();

    if (!mounted) return;

    if (userId == null) {
      setState(() {
        _historyFuture = Future.value(<HistoryItem>[]);
      });
      return;
    }

    setState(() {
      _historyFuture = apiService.getRecommendationHistory(userId: userId);
    });

    await _historyFuture;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('История рекомендаций'),
        backgroundColor: theme.cardColor,
      ),
      body: RefreshIndicator(
        onRefresh: _loadHistory,
        color: theme.primaryColor,
        child: FutureBuilder<List<HistoryItem>>(
          future: _historyFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildSkeletonLoader(isDark, theme);
            }
            if (snapshot.hasError) {
              return Center(child: Text('Ошибка: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Нет истории рекомендаций'));
            }

            final history = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              itemBuilder: (context, index) {
                return _HistoryCard(
                  recommendation: history[index],
                  isDark: isDark,
                );
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

class _HistoryCard extends StatelessWidget {
  final HistoryItem recommendation;
  final bool isDark;

  const _HistoryCard({required this.recommendation, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isDark ? 1 : 4,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                  recommendation.location,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                const Spacer(),
                Text(
                  DateFormat('dd.MM.yyyy HH:mm')
                      .format(recommendation.createdAt),
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
                  children: recommendation.items
                      .map((item) => Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      item['icon_emoji'] ?? '👕',
                      style: const TextStyle(fontSize: 32),
                    ),
                  ))
                      .toList(),
                ),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${recommendation.temperature.round()}°C',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
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