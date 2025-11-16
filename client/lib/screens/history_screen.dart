import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../models/recommendation.dart';
import '../providers/theme_provider.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<Recommendation>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() {
    setState(() {
      _historyFuture = ApiService().getRecommendationHistory(userId: 1);
    });
    return _historyFuture;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text('История рекомендаций'),
        backgroundColor: isDark ? AppTheme.cardDark : Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _loadHistory,
        color: isDark ? AppTheme.primary : const Color(0xFF007bff),
        child: FutureBuilder<List<Recommendation>>(
          future: _historyFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildSkeletonLoader(isDark);
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
                return _HistoryCard(recommendation: history[index], isDark: isDark);
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

class _HistoryCard extends StatelessWidget {
  final Recommendation recommendation;
  final bool isDark;

  const _HistoryCard({required this.recommendation, required this.isDark});

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
                Text(recommendation.location, style: const TextStyle(fontWeight: FontWeight.w600)),
                const Spacer(),
                Text(
                  DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now()),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: recommendation.items.map((item) => 
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(item.iconEmoji, style: const TextStyle(fontSize: 32)),
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
                    '${recommendation.temperature.round()}°C',
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