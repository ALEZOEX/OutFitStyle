import'package:flutter/material.dart';

class SearchBar extends StatefulWidget {
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onSearchCancelled;
  final String hintText;

  const SearchBar({
    super.key,
    required this.onQueryChanged,
    required this.onSearchCancelled,
    this.hintText = 'Поиск...',
  });

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> { // Fixed class name
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void onTextChanged(String value) {
    widget.onQueryChanged(value.trim());
  }

  void clearSearch() {
    controller.clear();
    onTextChanged('');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: controller, // Fixed variable name
        decoration: InputDecoration(
          hintText: widget.hintText,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: controller.text.isNotEmpty // Fixed variable name
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: clearSearch,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          filled: true,
          fillColor: Theme.of(context).scaffoldBackgroundColor,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
        ),
        onChanged: onTextChanged,
        autofocus: true,
        textInputAction: TextInputAction.search,
      ),
    );
  }
}