import 'package:flutter/material.dart';

import 'choban/choban.dart';
import 'newsstand/newsstand.dart';
import 'theodoi/theodoi.dart';
import 'tinchinh/tinchinh.dart';

class MenuKhungApp extends StatefulWidget {
  const MenuKhungApp({super.key});

  @override
  State<MenuKhungApp> createState() => _MenuKhungAppState();
}

class _MenuKhungAppState extends State<MenuKhungApp> {
  int _selectedIndex = 0;

  void _navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();

    _pages = [
      const ChoBan(),
      const TinChinh(),
      const TheoDoi(),
      const Newsstand(),
    ];
  }

  List<Widget> _pages = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _navigateBottomBar,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), label: 'Cho bạn'),
          BottomNavigationBarItem(
              icon: Icon(Icons.public_outlined), label: 'Tin chính'),
          BottomNavigationBarItem(
              icon: Icon(Icons.grade_outlined), label: 'Theo dõi'),
          BottomNavigationBarItem(
              icon: Icon(Icons.grading_outlined), label: 'Newsstand'),
        ],
      ),
    );
  }
}
