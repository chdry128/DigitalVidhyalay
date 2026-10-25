// ============================================================
//  CATEGORY ICONS — Home screen ki categories ke icons
//
//  courses.json me nayi category daali?
//  → Yahan uska naam aur icon jod do. Agar nahi jodoge to
//    default (kitaab wala) icon dikhega, app nahi rukegi.
//
//  Saare icons dekhne ke liye: https://fonts.google.com/icons
// ============================================================
import 'package:flutter/material.dart';

const Map<String, IconData> _categoryIcons = {
  'Programming': Icons.code_rounded,
  'Computer Science': Icons.memory_outlined,
  'Web Development': Icons.language_outlined,
  'Marketing': Icons.campaign_outlined,
  'Competitive Exam': Icons.emoji_events_outlined,
  'Mathematics': Icons.functions_rounded,
  'View All': Icons.grid_view_rounded,
};

IconData iconForCategory(String category) {
  return _categoryIcons[category] ?? Icons.menu_book_outlined;
}
