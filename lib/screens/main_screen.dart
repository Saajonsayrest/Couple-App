import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home/home_screen.dart';
import 'play/play_screen.dart';
import 'reader/book_reader_screen.dart';
import 'timeline/timeline_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool _readerFullscreen = false;

  late final List<Widget> _screens = [
    const HomeScreen(),
    BookReaderScreen(
      isEmbeddedTab: true,
      onFullscreenChanged: (value) => setState(() => _readerFullscreen = value),
    ),
    const PlayScreen(),
    const TimelineScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: _readerFullscreen && _selectedIndex == 1
          ? null
          : Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(0, Icons.favorite_rounded, 'Home'),
                      _buildNavItem(1, Icons.menu_book_rounded, 'Read'),
                      _buildNavItem(2, Icons.auto_awesome_rounded, 'Games'),
                      _buildNavItem(3, Icons.auto_stories_rounded, 'Timeline'),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    final color = isSelected
        ? Theme.of(context).primaryColor
        : Colors.grey.shade400;

    // Four tabs share narrow screens; shrink, never overflow.
    return Expanded(
      child: Center(
        heightFactor: 1,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: _buildNavButton(index, icon, label, isSelected, color),
        ),
      ),
    );
  }

  Widget _buildNavButton(
    int index,
    IconData icon,
    String label,
    bool isSelected,
    Color color,
  ) {
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.varelaRound(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
