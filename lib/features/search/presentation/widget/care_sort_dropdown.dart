import 'package:flutter/material.dart';

class CareSortDropdown extends StatefulWidget {
  final void Function(String sortBy, String sortDir) onChanged;

  const CareSortDropdown({super.key, required this.onChanged});

  @override
  State<CareSortDropdown> createState() => _CareSortDropdownState();
}

class _CareSortDropdownState extends State<CareSortDropdown> {
  String _selected = 'createdAt_desc';

  final List<Map<String, String>> _options = [
    {'label': '등록일순', 'sortBy': 'createdAt', 'sortDir': 'desc'},
    {'label': '가격 높은순', 'sortBy': 'price', 'sortDir': 'desc'},
    {'label': '가격 낮은순', 'sortBy': 'price', 'sortDir': 'asc'},
    {'label': '리뷰 많은순', 'sortBy': 'reviewCount', 'sortDir': 'desc'},
    {'label': '인기순', 'sortBy': 'popularity', 'sortDir': 'desc'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: DropdownButton<String>(
        value: _selected,
        style: const TextStyle(color: Colors.black87, fontSize: 13),
        dropdownColor: Colors.white,
        underline: const SizedBox(),
        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black87),
        items: _options.map((option) {
          final value = '${option['sortBy']}_${option['sortDir']}';
          return DropdownMenuItem(
            value: value,
            child: Text(
              option['label']!,
              style: const TextStyle(color: Colors.black87, fontSize: 13),
            ),
          );
        }).toList(),
        onChanged: (value) {
          if (value == null) return;
          setState(() => _selected = value);
          final parts = value.split('_');
          widget.onChanged(parts[0], parts[1]);
        },
      ),
    );
  }
} 