import 'package:flutter/material.dart';
import 'package:nhakhach/Account/SettingScreen.dart';
import 'package:nhakhach/MealReportScreen.dart';
import 'package:nhakhach/StatisticScreen.dart';

import 'Data/DataManager.dart';

void main() {
  runApp(const TabbarScreen());
}

class TabbarScreen extends StatefulWidget {
  const TabbarScreen({super.key});

  @override
  State<TabbarScreen> createState() => _TabbarScreenState();
}

class _TabbarScreenState extends State<TabbarScreen> {
  int _currentIndex = 0;

  // Các màn hình của từng tab – sẽ KHÔNG bị reload do IndexedStack
  final List<Widget> _screens = [
    MealReportScreen(),
    StatisticScreen(),
    SettingScreen(),
  ];

  // ---------------------- BOTTOM BAR ----------------------
  Widget buildBottomBar() {
    return BottomNavigationBar(
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.home), label: "Trang chủ"),
        BottomNavigationBarItem(
            icon: Icon(Icons.event), label: "Hoạt động"),
        BottomNavigationBarItem(
            icon: Icon(Icons.people), label: "Tài khoản"),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    DataManager().currentContext = context;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: _screens.length,
        child: Scaffold(
          bottomNavigationBar: buildBottomBar(),
          body: IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
        ),
      ),
    );
  }
}