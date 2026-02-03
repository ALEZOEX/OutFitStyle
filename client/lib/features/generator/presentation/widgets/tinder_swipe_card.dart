import 'dart:math' as math;
import 'package:flutter/material.dart';

enum SwipeDecision { like, dislike }

class TinderSwipeCard extends StatefulWidget {
  final Widget child;
  final void Function(SwipeDecision decision) onDecision;

  const TinderSwipeCard({
    super.key,
    required this.child,
    required this.onDecision,
  });

  @override
  State<TinderSwipeCard> createState() => TinderSwipeCardState();
}

class TinderSwipeCardState extends State<TinderSwipeCard>
    with SingleTickerProviderStateMixin {
  Offset _offset = Offset.zero;
  late final AnimationController _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 220));
  Animation<Offset>? _anim;

  static const _threshold = 110.0;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void swipeLeft() => _commit(SwipeDecision.dislike);
  void swipeRight() => _commit(SwipeDecision.like);

  void _commit(SwipeDecision decision) {
    final size = MediaQuery.of(context).size;
    final target = decision == SwipeDecision.like
        ? Offset(size.width * 1.2, _offset.dy)
        : Offset(-size.width * 1.2, _offset.dy);

    _animateTo(target, onEnd: () {
      widget.onDecision(decision);
      if (mounted) setState(() => _offset = Offset.zero);
    });
  }

  void _animateTo(Offset target, {VoidCallback? onEnd}) {
    _anim = Tween<Offset>(begin: _offset, end: target).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
    _ctrl
      ..reset()
      ..forward().whenComplete(() => onEnd?.call());

    _ctrl.addListener(() {
      if (!mounted || _anim == null) return;
      setState(() => _offset = _anim!.value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final angle = (_offset.dx / 420.0).clamp(-0.18, 0.18);
    final likeOpacity = (_offset.dx / 160.0).clamp(0.0, 1.0);
    final nopeOpacity = (-_offset.dx / 160.0).clamp(0.0, 1.0);

    return GestureDetector(
      onPanUpdate: (d) => setState(() => _offset += d.delta),
      onPanEnd: (_) {
        if (_offset.dx > _threshold) {
          _commit(SwipeDecision.like);
        } else if (_offset.dx < -_threshold) {
          _commit(SwipeDecision.dislike);
        } else {
          _animateTo(Offset.zero);
        }
      },
      child: Transform.translate(
        offset: _offset,
        child: Transform.rotate(
          angle: angle * math.pi,
          child: Stack(
            children: [
              widget.child,
              Positioned(
                top: 16,
                left: 16,
                child: Opacity(
                  opacity: likeOpacity,
                  child: _Badge(text: 'LIKE', color: Colors.green),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: Opacity(
                  opacity: nopeOpacity,
                  child: _Badge(text: 'NOPE', color: Colors.redAccent),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;

  const _Badge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 3),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}
