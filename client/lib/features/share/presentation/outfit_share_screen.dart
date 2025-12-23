import 'dart:convert';
import 'package:flutter/material.dart';

import '../../../ui/atoms/share_image.dart';
import '../../share/presentation/outfit_story_card.dart';

class OutfitShareScreen extends StatefulWidget {
  final String outfitId;
  final String outfitDataJson;
  final String weatherDataJson;

  const OutfitShareScreen({
    super.key,
    required this.outfitId,
    required this.outfitDataJson,
    required this.weatherDataJson,
  });

  @override
  State<OutfitShareScreen> createState() => _OutfitShareScreenState();
}

class _OutfitShareScreenState extends State<OutfitShareScreen> {
  final _boundaryKey = GlobalKey();

  Map<String, dynamic> _decode(String s) {
    try {
      return (jsonDecode(s) as Map).cast<String, dynamic>();
    } catch (_) {
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    final outfit = _decode(widget.outfitDataJson);
    final weather = _decode(widget.weatherDataJson);
    final lines = (outfit['outfit'] is List)
        ? (outfit['outfit'] as List).whereType<Map>().map((e) => e.cast<String, dynamic>()).toList()
        : <Map<String, dynamic>>[];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Поделиться'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: RepaintBoundary(
            key: _boundaryKey,
            child: SizedBox(
              width: 360,
              child: OutfitStoryCard(weather: weather, lines: lines),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: FilledButton.icon(
            onPressed: () async {
              await ShareImage.sharePngFromBoundary(
                boundaryKey: _boundaryKey,
                fileName: 'outfitstyle_story_${widget.outfitId}.png',
                text: 'OutfitStyle',
              );
            },
            icon: const Icon(Icons.send_rounded),
            label: const Text('Поделиться в Stories'),
          ),
        ),
      ),
    );
  }
}