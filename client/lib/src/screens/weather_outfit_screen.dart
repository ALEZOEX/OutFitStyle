import 'package:flutter/material.dart';

class WeatherOutfitScreen extends StatelessWidget {
  const WeatherOutfitScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Рекомендации'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('Экран рекомендаций outfits'),
      ),
    );
  }
}
