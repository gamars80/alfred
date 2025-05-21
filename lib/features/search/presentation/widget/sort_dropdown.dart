import 'package:flutter/material.dart';

class SortDropdown extends StatefulWidget {
  final void Function(String sortBy, String sortDir) onChanged;

  const SortDropdown({super.key, required this.onChanged});

  @override
  State<SortDropdown> createState() => _SortDropdownState();
}

class _SortDropdownState extends State<SortDropdown> {
  String _selected = 'createdAt_desc';

  final List<Map<String, String>> _options = [
    {'label': '등록일순', 'sortBy': 'createdAt', 'sortDir': 'desc'},
    {'label': '가격 높은순', 'sortBy': 'price', 'sortDir': 'desc'},
    {'label': '가격 낮은순', 'sortBy': 'price', 'sortDir': 'asc'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: DropdownButton<String>(
        value: _selected,
        style: const TextStyle(color: Colors.black87, fontSize: 13),
        dropdownColor: Colors.white, // ✅ 드롭다운 메뉴 배경 흰색 고정
        underline: const SizedBox(),
        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black87),
        items: _options.map((option) {
          final value = '${option['sortBy']}_${option['sortDir']}';
          return DropdownMenuItem(
            value: value,
            child: Text(
              option['label']!,
              style: const TextStyle(color: Colors.black87, fontSize: 13), // ✅ 텍스트 컬러 지정
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
