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
  
  List<Widget> get _screens => [
    HomeScreen(key: _homeKey),
    const CategoriesScreen(),
    const SizedBox(), // Placeholder for FAB
    const FundsScreen(),
    const InsightsScreen(),
  ];

  void _onTabTapped(int index) {
    if (index == 2) {
      // Middle FAB  - navigate to add expense
      _navigateToAddExpense();
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }
  
  Future<void> _navigateToAddExpense() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => const AddExpenseScreen(),
      ),
    );
    
    // Refresh home screen if expense was added
    if (result == true && _homeKey.currentState != null) {
      // Return to home and refresh
      setState(() {
        _currentIndex = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        selectedItemColor: AppTheme.primary,
        unselectedItemColor: AppTheme.textSecondary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
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
