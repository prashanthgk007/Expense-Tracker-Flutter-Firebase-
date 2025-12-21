import 'package:expense_tracker_app/Constants/appColors.dart';
import 'package:expense_tracker_app/Helper/router.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<Widget> _widgetOptions = <Widget>[
    AppRoutes.getScreenWidget(AppRoutes.dashboard),
    AppRoutes.getScreenWidget(AppRoutes.listExpense),
  ];

  // Map to easily retrieve the title based on the route index
  final List<String> _titles = [
    "Dashboard",
    "Expenses",
  ];

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String currentTitle = _titles[_selectedIndex];
    
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
                backgroundColor: AppColors.white,
        foregroundColor: AppColors.black,
        title: Text(
          currentTitle,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRoutes.setting),
          ),
        ],
      ),
      
      // ✅ BODY: IndexedStack keeps all child widgets mounted and preserves their state.
      body: IndexedStack(
        index: _selectedIndex, // Show the widget at this index
        children: _widgetOptions, // The list of screen widgets
      ),
      
      // ⬇️ BOTTOM NAVIGATION BAR
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Expenses',
          ),
        ],
      ),
    );
  }
}