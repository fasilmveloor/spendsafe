import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/services/preferences_service.dart';
import '../../core/db/database_helper.dart';

import '../../shared/theme/app_theme.dart';
import '../home/home_screen.dart';

/// Onboarding screen
/// Multi-step wizard to set up initial profile
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final PreferencesService _prefs = PreferencesService();
  final DatabaseHelper _db = DatabaseHelper.instance;
  
  int _currentPage = 0;
  bool _isSaving = false;

  // Form controllers
  final _nameController = TextEditingController();
  final _incomeController = TextEditingController();
  final _rentController = TextEditingController(text: '0');
  final _internetController = TextEditingController(text: '0');
  final _startBalanceController = TextEditingController(text: '0');
  
  // State
  // State

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _incomeController.dispose();
    _rentController.dispose();
    _internetController.dispose();
    _startBalanceController.dispose();
    super.dispose();
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _completeSetup() async {
    /*
      TODO: Implement COMPLETE SETUP logic
      1. Create default account with starting balance
      2. Create income source (Salary)
      3. Record first income if applicable (or just rely on balance)
      4. Create fixed expenses (Rent, Internet)
      5. Mark onboarding as complete
      6. Navigate to Home
    */
    setState(() => _isSaving = true);

    try {
      // 1. Create default account
      final accountId = await _db.insert('accounts', {
        'name': 'Main Account',
        'type': 'savings',
        'balance': double.tryParse(_startBalanceController.text) ?? 0.0,
        'icon': 58343, // account_balance_wallet
        'color': 4280391411, // Colors.blue
        'is_default': 1,
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });

      // 2. Create income source
      final salaryAmount = double.tryParse(_incomeController.text) ?? 0.0;
      if (salaryAmount > 0) {
        final sourceId = await _db.insert('income_sources', {
          'name': 'Primary Salary', // Or from separate input if desired
          'account_id': accountId,
          'is_active': 1,
          'created_at': DateTime.now().millisecondsSinceEpoch,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        });

        // Optionally record a starting income if user wants (omitted for simplicity, user starts with balance)
      }

      // 3. Create fixed expenses
      final rent = double.tryParse(_rentController.text) ?? 0.0;
      if (rent > 0) {
        await _db.insert('fixed_expenses', {
          'name': 'Rent',
          'amount': rent,
          'account_id': accountId,
          'due_day': 1, // Default to 1st
          'is_active': 1,
          'created_at': DateTime.now().millisecondsSinceEpoch,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        });
      }

      final internet = double.tryParse(_internetController.text) ?? 0.0;
      if (internet > 0) {
        await _db.insert('fixed_expenses', {
          'name': 'Internet/Phone',
          'amount': internet,
          'account_id': accountId,
          'due_day': 5, // Default to 5th
          'is_active': 1,
          'created_at': DateTime.now().millisecondsSinceEpoch,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        });
      }

      // 4. Save preferences
      final name = _nameController.text.trim();
      if (name.isNotEmpty) {
        await _prefs.setUserName(name);
      }
      await _prefs.setOnboardingCompleted();

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error setting up: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // Disable swipe
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _buildWelcomeStep(),
                  _buildNameStep(),
                  _buildFinancialStep(),
                  _buildExpensesStep(),
                  _buildCompletionStep(),
                ],
              ),
            ),
            
            // Progress dots
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index == _currentPage
                          ? AppTheme.primary
                          : Colors.grey.shade300,
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeStep() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.savings_rounded,
              size: 64,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Welcome to SpendSafe',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'The personal finance app that tells you exactly how much you can spend today without worry.',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: _nextPage,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              ),
            ),
            child: const Text('Get Started'),
          ),
        ],
      ),
    );
  }

  Widget _buildNameStep() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "What's your name?",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'Your Name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              if (_nameController.text.trim().isNotEmpty) {
                _nextPage();
              }
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              ),
            ),
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialStep() {
    return ListView(
      padding: const EdgeInsets.all(32),
      children: [
        const SizedBox(height: 32),
        const Text(
          "Let's set up your finances",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "We'll create a main account for you.",
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 32),
        
        const Text('Current Bank Balance', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: _startBalanceController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            prefixText: '₹ ',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            ),
          ),
        ),
        const SizedBox(height: 24),

        const Text('Monthly Salary (Approx)', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: _incomeController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            prefixText: '₹ ',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            ),
          ),
        ),
        
        const SizedBox(height: 48),
        ElevatedButton(
          onPressed: _nextPage,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            ),
          ),
          child: const Text('Next'),
        ),
      ],
    );
  }

  Widget _buildExpensesStep() {
    return ListView(
      padding: const EdgeInsets.all(32),
      children: [
        const SizedBox(height: 32),
        const Text(
          "Any fixed monthly expenses?",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "These are deducted automatically for Safe Pace calculation.",
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 32),
        
        const Text('Rent / Mortgage', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: _rentController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            prefixText: '₹ ',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            ),
          ),
        ),
        const SizedBox(height: 24),

        const Text('Internet / Phone', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: _internetController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            prefixText: '₹ ',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            ),
          ),
        ),
        
        const SizedBox(height: 48),
        ElevatedButton(
          onPressed: _nextPage,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            ),
          ),
          child: const Text('Calculate My Pace'),
        ),
      ],
    );
  }

  Widget _buildCompletionStep() {
    // Calculate estimated pace for preview
    final balance = double.tryParse(_startBalanceController.text) ?? 0.0;
    final fixed = (double.tryParse(_rentController.text) ?? 0.0) +
        (double.tryParse(_internetController.text) ?? 0.0);
    final daysInMonth = 30; // Approximation for preview
    final dailyPace = (balance - fixed) / daysInMonth;

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              size: 64,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'You are all set!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Based on your inputs, your estimated safe daily spending is:',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 24),
          Text(
            '₹${dailyPace > 0 ? dailyPace.toStringAsFixed(0) : 0}',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w800,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '/ day',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: _isSaving ? null : _completeSetup,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              ),
            ),
            child: _isSaving
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : const Text('Start Using SpendSafe'),
          ),
        ],
      ),
    );
  }
}
