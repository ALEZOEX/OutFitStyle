import 'package:flutter/material.dart';

class OutfitStoryCard extends StatelessWidget {
  final String appName;
  final Map<String, dynamic> weather;
  final List<Map<String, dynamic>> lines;

  const OutfitStoryCard({
    super.key,
    this.appName = 'OutfitStyle',
    required this.weather,
    required this.lines,
  });

  @override
  Widget build(BuildContext context) {
    final temp = (weather['temp'] ?? weather['temperature'] ?? '').toString();
    final cond = (weather['condition'] ??
            weather['description'] ??
            weather['weather'] ??
            '')
        .toString();

    return AspectRatio(
      aspectRatio: 9 / 16,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0B1220), Color(0xFF1B2A4A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(appName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        letterSpacing: 0.3,
                      )),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.12)),
                    ),
                    child: Row(
                      children: [
                        Text(
                          temp.isEmpty ? '—' : '$temp°',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            cond.isEmpty ? 'Погода' : cond,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Образ дня',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w900,
                        fontSize: 22),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: lines.take(6).map((e) {
                        final icon = (e['icon_emoji'] ?? '👕').toString();
                        final name = (e['name'] ?? '').toString();
                        final cat = (e['category'] ?? '').toString();
                        return Container(
                          width: 154,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.12)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(icon, style: const TextStyle(fontSize: 26)),
                              const SizedBox(height: 6),
                              Text(
                                name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                cat,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.70),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Собрано автоматически • $appName',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.65),
                        fontWeight: FontWeight.w700,
                        fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
