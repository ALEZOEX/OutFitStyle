import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/trip.dart';
import '../../domain/repositories/trip_repository.dart';
import '../providers/trip_providers.dart';

/// Страница создания/редактирования поездки
class TripCreatePage extends ConsumerStatefulWidget {
  final String? tripId; // Если null - создание, иначе редактирование

  const TripCreatePage({super.key, this.tripId});

  @override
  ConsumerState<TripCreatePage> createState() => _TripCreatePageState();
}

class _TripCreatePageState extends ConsumerState<TripCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _destinationController = TextEditingController();
  final _occasionsController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Если редактирование - загрузить данные
    if (widget.tripId != null) {
      _loadTripData();
    } else {
      // Установить даты по умолчанию
      _startDate = DateTime.now().add(const Duration(days: 1));
      _endDate = DateTime.now().add(const Duration(days: 7));
    }
  }

  Future<void> _loadTripData() async {
    final trip = await ref.read(tripRepositoryProvider).getTripById(widget.tripId!);
    if (trip != null && mounted) {
      setState(() {
        _nameController.text = trip.name;
        _destinationController.text = trip.destination;
        _startDate = trip.startDate;
        _endDate = trip.endDate;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _destinationController.dispose();
    _occasionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.tripId != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(isEditing ? 'Редактировать поездку' : 'Новая поездка'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Название
              _buildSection(
                title: 'Название',
                child: TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Например: Отпуск в Сочи',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введите название поездки';
                    }
                    return null;
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Пункт назначения
              _buildSection(
                title: 'Пункт назначения',
                child: TextFormField(
                  controller: _destinationController,
                  decoration: InputDecoration(
                    hintText: 'Например: Сочи, Россия',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.location_on_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введите пункт назначения';
                    }
                    return null;
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Даты
              _buildSection(
                title: 'Даты поездки',
                child: Row(
                  children: [
                    Expanded(
                      child: _buildDatePicker(
                        label: 'Начало',
                        date: _startDate,
                        onTap: () => _selectDate(isStartDate: true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDatePicker(
                        label: 'Окончание',
                        date: _endDate,
                        onTap: () => _selectDate(isStartDate: false),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Поводы
              _buildSection(
                title: 'Поводы (через запятую)',
                child: TextFormField(
                  controller: _occasionsController,
                  decoration: InputDecoration(
                    hintText: 'Например: Пляж, Ресторан, Прогулка',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  maxLines: 2,
                ),
              ),

              const SizedBox(height: 32),

              // Кнопка сохранения
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveTrip,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(isEditing ? 'Сохранить' : 'Создать поездку'),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF525252),
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              color: date != null ? Colors.blue[600] : Colors.grey[400],
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  date != null
                      ? DateFormat('d MMMM yyyy', 'ru_RU').format(date)
                      : 'Не выбрано',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: date != null ? const Color(0xFF1A1A1A) : Colors.grey[400],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate({required bool isStartDate}) async {
    final initialDate = isStartDate ? _startDate : _endDate;
    final firstDate = isStartDate
        ? DateTime.now()
        : (_startDate ?? DateTime.now());
    final lastDate = isStartDate
        ? (_endDate ?? DateTime.now().add(const Duration(days: 365)))
        : DateTime.now().add(const Duration(days: 365));

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate,
      lastDate: lastDate,
      locale: const Locale('ru', 'RU'),
    );

    if (picked != null && mounted) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          // Если конец раньше начала, сдвигаем конец
          if (_endDate != null && _endDate!.isBefore(picked)) {
            _endDate = picked.add(const Duration(days: 1));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _saveTrip() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      _showError('Выберите даты поездки');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final occasions = _occasionsController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      final request = CreateTripRequest(
        name: _nameController.text.trim(),
        destination: _destinationController.text.trim(),
        startDate: _startDate!,
        endDate: _endDate!,
        occasions: occasions,
      );

      final repository = ref.read(tripRepositoryProvider);
      Trip? trip;

      if (widget.tripId != null) {
        // Редактирование
        trip = await repository.updateTrip(
          widget.tripId!,
          UpdateTripRequest(
            name: request.name,
            destination: request.destination,
            startDate: request.startDate,
            endDate: request.endDate,
            occasions: request.occasions,
          ),
        );
      } else {
        // Создание
        trip = await repository.createTrip(request);
      }

      if (mounted) {
        // Обновляем список в кэше
        if (widget.tripId == null) {
          ref.read(tripListProvider.notifier).addTrip(trip);
        } else {
          ref.read(tripListProvider.notifier).updateTrip(trip);
        }

        context.go('/trips/${trip.id}');
      }
    } catch (e) {
      if (mounted) {
        _showError('Не удалось сохранить поездку: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
