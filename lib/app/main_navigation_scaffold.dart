import 'package:flutter/material.dart';
import '../features/home/home_screen.dart';
import '../features/categories/categories_screen.dart';
import '../features/funds/funds_screen.dart';
import '../features/insights/insights_screen.dart';
import '../features/expenses/add_expense_screen.dart';
import '../shared/theme/app_theme.dart';

/// Main navigation scaffold with bottom navigation bar
class MainNavigationScaffold extends StatefulWidget {
  const MainNavigationScaffold({super.key});

  @override
  State<MainNavigationScaffold> createState() => _MainNavigationScaffoldState();
}

class _MainNavigationScaffoldState extends State<MainNavigationScaffold> {
  int _currentIndex = 0;
  final GlobalKey<State<HomeScreen>> _homeKey = GlobalKey();
  final GlobalKey<State<InsightsScreen>> _insightsKey = GlobalKey();

  List<Widget> get _screens => [
    HomeScreen(key: _homeKey),
    const CategoriesScreen(),
    const SizedBox(), // Placeholder for FAB
    const FundsScreen(),
    InsightsScreen(key: _insightsKey),
  ];

  void _onTabTapped(int index) {
    if (index == 2) {
      // Middle FAB  - navigate to add expense
      _navigateToAddExpense();
    } else {
      setState(() {
        _currentIndex = index;
      });
      // Refresh screens when switching tabs
      if (index == 0) {
        _refreshHomeScreen();
      } else if (index == 4) {
        _refreshInsightsScreen();
      }
    }
  }

  void _refreshHomeScreen() {
    final homeState = _homeKey.currentState;
    if (homeState != null) {
      try {
        (homeState as dynamic).refreshData();
      } catch (_) {}
    }
  }

  void _refreshInsightsScreen() {
    final insightsState = _insightsKey.currentState;
    if (insightsState != null) {
      try {
        (insightsState as dynamic).refreshData();
      } catch (_) {}
    }
  }

  Future<void> _navigateToAddExpense() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
    );

    // Refresh home screen if expense was added
    if (result == true) {
      setState(() {
        _currentIndex = 0;
      });
      _refreshHomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        selectedItemColor: AppTheme.primary,
        unselectedItemColor: AppTheme.textSecondary,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.category_outlined),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline, size: 32),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.savings_outlined),
            label: 'Funds',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insights_outlined),
            label: 'Insights',
          ),
        ],
        onTap: _onTabTapped,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddExpense,
        child: const Icon(Icons.add, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
