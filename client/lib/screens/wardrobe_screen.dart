import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_wardrobe.dart';
import '../providers/theme_provider.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'add_item_screen.dart';
import '../widgets/search_bar.dart' as custom_search_bar;

class WardrobeScreen extends StatefulWidget {
  const WardrobeScreen({super.key});

  @override
  State<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen> {
  late Future<Map<String, List<WardrobeItem>>> _wardrobeFuture;
  late ApiService _apiService;

  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();

    _apiService = Provider.of<ApiService>(context, listen: false);

    // ИНИЦИАЛИЗАЦИЯ по умолчанию, чтобы не было LateInitializationError
    _wardrobeFuture = Future.value(<String, List<WardrobeItem>>{});

    _loadWardrobe();
  }

  Future<void> _loadWardrobe() async {
    try {
      setState(() {
        _wardrobeFuture = _apiService.getWardrobe(userId: 1);
      });
      await _wardrobeFuture;
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки гардероба: $e')),
      );
    }
  }

  void _addItem() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddItemScreen()),
    );
    if (result == true) {
      _loadWardrobe();
    }
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _cancelSearch() {
    setState(() {
      _isSearching = false;
      _searchQuery = '';
      _searchController.clear();
    });
  }

  void _onSearchQueryChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  Map<String, List<WardrobeItem>> _filterWardrobe(
      Map<String, List<WardrobeItem>> wardrobe) {
    if (_searchQuery.isEmpty) return wardrobe;

    final lowerQuery = _searchQuery.toLowerCase();
    final filtered = <String, List<WardrobeItem>>{};

    wardrobe.forEach((category, items) {
      final filteredItems = items.where((item) {
        return item.customName.toLowerCase().contains(lowerQuery) ||
            category.toLowerCase().contains(lowerQuery);
      }).toList();

      if (filteredItems.isNotEmpty) {
        filtered[category] = filteredItems;
      }
    });

    return filtered;
  }

  Future<void> _deleteItem(int itemId) async {
    if (!await _showDeleteConfirmation()) return;

    try {
      setState(() {
        _isDeleting = true;
      });

      await _apiService.deleteWardrobeItem(itemId);

      setState(() {
        _wardrobeFuture = _apiService.getWardrobe(userId: 1);
      });
      await _wardrobeFuture;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Предмет успешно удален')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при удалении: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  Future<bool> _showDeleteConfirmation() async {
    final result = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Подтверждение удаления'),
            content: const Text(
                'Вы уверены, что хотите удалить этот предмет? Это действие нельзя отменить.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Отмена'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Удалить',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    final isInteractionEnabled = !_isDeleting;

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.backgroundDark : const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: _isSearching
            ? custom_search_bar.SearchBar(
                onQueryChanged: _onSearchQueryChanged,
                onSearchCancelled: _cancelSearch,
              )
            : const Text('Мой гардероб'),
        centerTitle: true,
        leading: _isSearching
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _cancelSearch,
              )
            : null,
        actions: _isSearching
            ? []
            : [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: isInteractionEnabled ? _startSearch : null,
                ),
              ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadWardrobe,
        child: FutureBuilder<Map<String, List<WardrobeItem>>>(
          future: _wardrobeFuture,
          builder: (context, snapshot) {
            if (_isSearching && _searchQuery.isEmpty && !snapshot.hasData) {
              return const Center(child: Text('Введите запрос для поиска'));
            }

            if (!_isSearching &&
                snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Ошибка загрузки: ${snapshot.error}'));
            }

            if (!snapshot.hasData ||
                (_isSearching && _filterWardrobe(snapshot.data!).isEmpty)) {
              return _buildEmptyState();
            }

            final wardrobe =
                _isSearching ? _filterWardrobe(snapshot.data!) : snapshot.data!;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: wardrobe.entries.map((entry) {
                final category = entry.key;
                final items = entry.value;

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ExpansionTile(
                    initiallyExpanded: true,
                    title: Text(
                      '$category (${items.length})',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    children: items.map((item) {
                      return ListTile(
                        leading: Text(
                          item.customIcon,
                          style: const TextStyle(fontSize: 28),
                        ),
                        title: Text(item.customName),
                        trailing: _isDeleting
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : IconButton(
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: Colors.red.withValues(alpha: 0.7),
                                ),
                                onPressed: () => _deleteItem(item.id),
                              ),
                      );
                    }).toList(),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: isInteractionEnabled ? _addItem : null,
        child: _isDeleting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.checkroom_outlined, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Ваш гардероб пуст',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Нажмите "+", чтобы добавить первую вещь',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
