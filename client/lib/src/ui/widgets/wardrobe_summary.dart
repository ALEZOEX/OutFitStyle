import 'package:flutter/material.dart';
import 'package:outfitstyle_client/src/domain/entities/clothing_item.dart';

class WardrobeSummary extends StatelessWidget {
  final int totalItemsCount;
  final Map<String, int> categoryCounts;
  final List<ClothingItem> recentItems;

  const WardrobeSummary({
    Key? key,
    required this.totalItemsCount,
    required this.categoryCounts,
    required this.recentItems,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Гардероб',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text('$totalItemsCount предметов'),
              ],
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: categoryCounts.entries.map((entry) {
                return Chip(
                  label: Text('${entry.key}: ${entry.value}'),
                  backgroundColor: Colors.blue[50],
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            Text(
              'Недавние добавления',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            ...recentItems.take(3).map((item) => ListTile(
                  leading: CircleAvatar(
                    child: Icon(Icons.checkroom),
                  ),
                  title: Text(item.name ?? ''),
                  subtitle: Text(item.category?.toString() ?? ''),
                )),
          ],
        ),
      ),
    );
  }
}
