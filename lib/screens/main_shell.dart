// ============================================================
//  MAIN SHELL — Login ke baad ki main app (neeche 5 tabs)
//
//  Tab ka naam / icon badalna ho → neeche "destinations"
//  Tab ka order badalna ho → children aur destinations dono
//  me same order rakhein.
// ============================================================
import 'package:flutter/material.dart';

import 'courses_screen.dart';
import 'home_screen.dart';
import 'internships_screen.dart';
import 'meri_padhai_screen.dart';
import 'profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key, this.initialTab = homeTab});

  /// App khulte waqt kaunsa tab khula ho (e.g. payment ke baad Meri Padhai)
  final int initialTab;

  // Tabs ke number (doosri screens se tab kholne ke liye)
  static const int homeTab = 0;
  static const int coursesTab = 1;
  static const int internshipsTab = 2;
  static const int learningTab = 3;
  static const int profileTab = 4;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _index = widget.initialTab;

  void _openTab(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Back dabane pe pehle Home tab pe aao, phir app band ho
      canPop: _index == MainShell.homeTab,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _openTab(MainShell.homeTab);
      },
      child: Scaffold(
        body: IndexedStack(
          index: _index,
          children: [
            HomeScreen(onOpenTab: _openTab),
            const CoursesScreen(),
            const InternshipsScreen(),
            MeriPadhaiScreen(onExplore: () => _openTab(MainShell.coursesTab)),
            const ProfileScreen(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: _openTab,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book_rounded),
              label: 'Courses',
            ),
            NavigationDestination(
              icon: Icon(Icons.work_outline_rounded),
              selectedIcon: Icon(Icons.work_rounded),
              label: 'Internships',
            ),
            NavigationDestination(
              icon: Icon(Icons.school_outlined),
              selectedIcon: Icon(Icons.school_rounded),
              label: 'Meri Padhai',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
