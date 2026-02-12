import 'package:flutter/material.dart';

class StyleTipsCarousel extends StatelessWidget {
  final List<String> tips;

  const StyleTipsCarousel({
    Key? key,
    required this.tips,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tips.length,
        itemBuilder: (context, index) {
          return Container(
            width: 280,
            margin: EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [Colors.purple[100]!, Colors.blue[100]!],
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  tips[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
