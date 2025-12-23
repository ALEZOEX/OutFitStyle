import 'package:flutter/material.dart';
import '../../../../data/local/app_database.dart';
import 'tinder_swipe_card.dart';

class TinderDeck extends StatelessWidget {
  final List<RecommendationRow> cards; // top-first
  final void Function(RecommendationRow row, SwipeDecision decision) onDecision;
  final Widget Function(RecommendationRow row) cardBuilder;

  /// ключ верхней карты — чтобы кнопки могли вызвать swipeLeft/Right
  final GlobalKey<TinderSwipeCardState> topCardKey;

  const TinderDeck({
    super.key,
    required this.cards,
    required this.onDecision,
    required this.cardBuilder,
    required this.topCardKey,
  });

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) return const SizedBox.shrink();

    final show = cards.take(3).toList(); // максимум 3 в стеке

    return Stack(
      children: [
        for (var i = show.length - 1; i >= 0; i--)
          _DeckLayer(
            indexFromTop: i,
            child: i == 0
                ? TinderSwipeCard(
                    key: topCardKey,
                    onDecision: (d) => onDecision(show[0], d),
                    child: cardBuilder(show[0]),
                  )
                : IgnorePointer(
                    child: cardBuilder(show[i]),
                  ),
          ),
      ],
    );
  }
}

class _DeckLayer extends StatelessWidget {
  final int indexFromTop; // 0 = top
  final Widget child;

  const _DeckLayer({required this.indexFromTop, required this.child});

  @override
  Widget build(BuildContext context) {
    if (indexFromTop == 0) return child;

    final scale = indexFromTop == 1 ? 0.96 : 0.92;
    final dy = indexFromTop == 1 ? 10.0 : 22.0;

    return Transform.translate(
      offset: Offset(0, dy),
      child: Transform.scale(
        scale: scale,
        child: Opacity(opacity: 0.92, child: child),
      ),
    );
  }
}