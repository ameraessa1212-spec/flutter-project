import 'package:flutter/material.dart';

class SearchField extends StatelessWidget {
  const SearchField({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F0F9),
        borderRadius: BorderRadius.circular(20),
      ),

      child: const TextField(
        textAlign: TextAlign.right,
        autofocus: true,
        style: TextStyle(fontFamily: 'Cairo', fontSize: 14),
        decoration: InputDecoration(
          hintText: 'ابحث عن فرص تدريب...',
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search, size: 20, color: Colors.grey),
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          hintStyle: TextStyle(fontFamily: 'Cairo', fontSize: 12),
        ),
      ),
    );
  }
}
