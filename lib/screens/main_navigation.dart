import 'package:flutter/material.dart';
import 'ebook/ebook_home_screen.dart';
import 'game/adventure_game_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleDarkMode;

  const MainNavigationScreen({
    super.key,
    required this.isDarkMode,
    required this.onToggleDarkMode,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;

    final List<Widget> pages = [
      EbookHomeScreen(
        isDarkMode: widget.isDarkMode,
        onToggleDarkMode: widget.onToggleDarkMode,
      ),
      AdventureGameScreen(
        isDarkMode: widget.isDarkMode,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: isDark ? const Color(0xFF0B132B) : Colors.white,
        selectedItemColor: const Color(0xFF00B4D8),
        unselectedItemColor: isDark ? Colors.white38 : Colors.grey[600],
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'E-Book',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Petualangan',
          ),
        ],
      ),
    );
  }
}
