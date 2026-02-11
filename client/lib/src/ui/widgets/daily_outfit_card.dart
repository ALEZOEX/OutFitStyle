import 'package:flutter/material.dart';
import 'package:outfitstyle_client/src/domain/entities/outfit.dart';

class DailyOutfitCard extends StatelessWidget {
  final Outfit? outfit;
  final VoidCallback? onTap;

  const DailyOutfitCard({
    Key? key,
    this.outfit,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (outfit == null) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Рекомендованный образ недоступен'),
        ),
      );
    }

    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ваш образ на сегодня',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Icon(Icons.check_circle_outline),
                ],
              ),
              SizedBox(height: 8),
              Text((outfit!.occasions?.isNotEmpty == true
                  ? outfit!.occasions!.first.displayName
                  : 'Casual')),
              SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: outfit!.clothingItemIds
                    .map((id) => Chip(
                          label: Text('Эл. $id'),
                          backgroundColor: Colors.grey[200],
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
