import 'package:flutter/material.dart';

/// Виджет слайдера для оценки рекомендаций от -10 до +10
/// -10 до -1: красный (плохо)
/// 0: серый (нейтрально/не оценено)
/// +1 до +10: зелёный (хорошо)
class RatingSlider extends StatefulWidget {
  /// Начальное значение рейтинга (-10 до +10)
  final int initialRating;

  /// Callback при изменении рейтинга
  final ValueChanged<int> onRatingChanged;

  /// Заголовок слайдера
  final String? title;

  /// Показывать ли текстовые метки
  final bool showLabels;

  /// Высота слайдера
  final double sliderHeight;

  const RatingSlider({
    super.key,
    this.initialRating = 0,
    required this.onRatingChanged,
    this.title,
    this.showLabels = true,
    this.sliderHeight = 60,
  });

  @override
  State<RatingSlider> createState() => _RatingSliderState();
}

class _RatingSliderState extends State<RatingSlider>
    with SingleTickerProviderStateMixin {
  late int _currentRating;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.initialRating;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Конвертирует рейтинг (-10 до +10) в значение слайдера (0 до 1)
  double _ratingToSlider(int rating) {
    return (rating + 10) / 20;
  }

  /// Конвертирует значение слайдера (0 до 1) в рейтинг (-10 до +10)
  int _sliderToRating(double value) {
    return (value * 20 - 10).round();
  }

  /// Получить цвет для значения рейтинга
  Color _getRatingColor(int rating) {
    if (rating < 0) {
      // Красный градиент от тёмного к светлому
      final intensity = (rating.abs() / 10).clamp(0.0, 1.0);
      return Color.lerp(
        Colors.red.shade900,
        Colors.red.shade400,
        intensity,
      )!;
    } else if (rating > 0) {
      // Зелёный градиент от тёмного к светлому
      final intensity = (rating / 10).clamp(0.0, 1.0);
      return Color.lerp(
        Colors.green.shade900,
        Colors.green.shade400,
        intensity,
      )!;
    } else {
      // Серый для нейтрального
      return Colors.grey.shade600;
    }
  }

  /// Получить иконку для значения рейтинга
  IconData _getRatingIcon(int rating) {
    if (rating <= -7) return Icons.sentiment_very_dissatisfied;
    if (rating <= -4) return Icons.sentiment_dissatisfied;
    if (rating <= -1) return Icons.thumb_down;
    if (rating == 0) return Icons.remove;
    if (rating <= 3) return Icons.thumb_up;
    if (rating <= 6) return Icons.sentiment_satisfied;
    return Icons.sentiment_very_satisfied;
  }

  /// Получить текстовое описание для значения рейтинга
  String _getRatingLabel(int rating) {
    if (rating <= -7) return 'Ужасно';
    if (rating <= -4) return 'Плохо';
    if (rating <= -1) return 'Не нравится';
    if (rating == 0) return 'Нейтрально';
    if (rating <= 3) return 'Нормально';
    if (rating <= 6) return 'Хорошо';
    if (rating <= 9) return 'Отлично';
    return 'Превосходно';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Заголовок
          if (widget.title != null) ...[
            Text(
              widget.title!,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
          ],

          // Текущее значение с иконкой
          AnimatedScale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: _getRatingColor(_currentRating).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _getRatingColor(_currentRating).withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getRatingIcon(_currentRating),
                    color: _getRatingColor(_currentRating),
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _currentRating > 0 ? '+$_currentRating' : '$_currentRating',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _getRatingColor(_currentRating),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Текстовая метка
          if (widget.showLabels)
            Text(
              _getRatingLabel(_currentRating),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: _getRatingColor(_currentRating),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),

          const SizedBox(height: 16),

          // Слайдер
          _buildCustomSlider(theme),

          // Метки -10, 0, +10
          if (widget.showLabels) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '-10',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '0',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '+10',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCustomSlider(ThemeData theme) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        final box = context.findRenderObject() as RenderBox?;
        if (box == null) return;

        final dx = details.localPosition.dx;
        final width = box.size.width;
        final value = (dx / width).clamp(0.0, 1.0);
        final newRating = _sliderToRating(value);

        if (newRating != _currentRating) {
          setState(() {
            _currentRating = newRating;
          });
          _animationController.forward(from: 0);
          widget.onRatingChanged(newRating);
        }
      },
      child: Container(
        height: widget.sliderHeight,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.red.shade700,
              Colors.red.shade400,
              Colors.grey.shade500,
              Colors.green.shade400,
              Colors.green.shade700,
            ],
            stops: const [0.0, 0.45, 0.5, 0.55, 1.0],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Центральная линия
            Positioned(
              left: 0,
              right: 0,
              child: Container(
                height: 2,
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
            // Индикатор текущего значения
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                final position = _ratingToSlider(_currentRating);
                return Positioned(
                  left: '${(position * 100).clamp(5.0, 95.0)}%',
                  child: Transform.translate(
                    offset: const Offset(-16, 0),
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _getRatingColor(_currentRating),
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          _getRatingIcon(_currentRating),
                          size: 18,
                          color: _getRatingColor(_currentRating),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact версия слайдера для использования в карточках
class CompactRatingSlider extends StatelessWidget {
  final int rating;
  final ValueChanged<int>? onRatingChanged;
  final double height;

  const CompactRatingSlider({
    super.key,
    required this.rating,
    this.onRatingChanged,
    this.height = 40,
  });

  Color _getRatingColor(int rating) {
    if (rating < 0) {
      final intensity = (rating.abs() / 10).clamp(0.0, 1.0);
      return Color.lerp(Colors.red.shade900, Colors.red.shade400, intensity)!;
    } else if (rating > 0) {
      final intensity = (rating / 10).clamp(0.0, 1.0);
      return Color.lerp(Colors.green.shade900, Colors.green.shade400, intensity)!;
    } else {
      return Colors.grey.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.red.shade700,
            Colors.red.shade400,
            Colors.grey.shade500,
            Colors.green.shade400,
            Colors.green.shade700,
          ],
          stops: const [0.0, 0.45, 0.5, 0.55, 1.0],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 0,
            right: 0,
            child: Container(
              height: 1,
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ),
          if (onRatingChanged != null)
            GestureDetector(
              onHorizontalDragUpdate: (details) {
                final box = context.findRenderObject() as RenderBox?;
                if (box == null) return;

                final dx = details.localPosition.dx;
                final width = box.size.width;
                final value = (dx / width).clamp(0.0, 1.0);
                final newRating = (value * 20 - 10).round();
                if (newRating != rating) {
                  onRatingChanged!(newRating);
                }
              },
              child: Container(
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          Positioned(
            left: '${((rating + 10) / 20 * 100).clamp(5.0, 95.0)}%',
            child: Transform.translate(
              offset: const Offset(-6, 0),
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _getRatingColor(rating),
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
