import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

class LikeBurstController {
  final ConfettiController controller =
      ConfettiController(duration: const Duration(milliseconds: 260));

  void play() => controller.play();
  void dispose() => controller.dispose();
}

class LikeBurst extends StatelessWidget {
  final ConfettiController controller;
  const LikeBurst({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ConfettiWidget(
        confettiController: controller,
        blastDirectionality: BlastDirectionality.explosive,
        numberOfParticles: 14,
        maxBlastForce: 10,
        minBlastForce: 5,
        gravity: 0.35,
        emissionFrequency: 0.0,
      ),
    );
  }
}
