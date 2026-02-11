import 'package:flutter/material.dart';

class QuickActions extends StatelessWidget {
  final List<QuickActionItem> actions;

  const QuickActions({
    Key? key,
    required this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: actions.length,
        separatorBuilder: (context, index) => SizedBox(width: 16),
        itemBuilder: (context, index) {
          final action = actions[index];
          return Container(
            width: 80,
            child: ElevatedButton.icon(
              onPressed: action.onPressed,
              icon: Icon(action.icon, size: 24),
              label: Text(
                action.label,
                style: TextStyle(fontSize: 12),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          );
        },
      ),
    );
  }
}

class QuickActionItem {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  QuickActionItem({
    required this.label,
    required this.icon,
    required this.onPressed,
  });
}
