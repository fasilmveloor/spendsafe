import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/services/preferences_service.dart';
import '../../core/db/database_helper.dart';

import '../../shared/theme/app_theme.dart';
import '../../app/main_navigation_scaffold.dart';

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
  final _emailController = TextEditingController();
  final _incomeController = TextEditingController();
  String _selectedCurrency = 'USD';
  String? _selectedAvatar;

  final List<String> _avatars = [
    'https://lh3.googleusercontent.com/aida-public/AB6AXuBPv3YpYFZ77NC5RGE8VGFg3JCWA-3lCD7YlgL29l0dcaO6gfmQlfTb9UVK7qxjL9eG5epxx_gBVuCVKbPwTth5P65eOv3xHMeLEl246lLzR2Fq1a4NdzUciZUiRTQMhn61NEFhh5ip_hKjsfxNRD0CczCfMv6Np8DQJqrbhvwlQPzkGa59HsPAzQJ7GpLsGEit1W9HP0XHYive_hxjUjOBdpsb5JOF9Zj5rJ1rVXQodWdOkUKfWLF4rkEoe903qq6MoftVDIKLViA',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuDTXThcfOyp9Euk-i1gwhpdYU6qe-71UUvUedONoYNJli9U97VjDSImnvMUaMhXlum_widEz_XdG8si530K_pbwCXxG5Kn3AbeFh-Rdl4Idt8QpFjB_9m1MHDNXTYNww8gU-wfDe7uY8jE-3JYKTpBu0PcSyQhDt-qQujRMf-g_yvIx2pxOzEBdSoiFKbpG7sWBDy8Jt1gDRx7o1erNjKONkzZBktqcFu1LdZWtFgySPay645VTGQGU8Ti8cE6vtTQ6xpmrEzSyX0w',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuAO2KlT1iIykfqSsKc9Fz_YvwkmCCuf5CQPzxl50NKL9Ws90C1ExDsOEclBJxEVLg7dAA-hTae8sGw4KsM1A_3yqJ2f6BNuiRMfe5F5Xo5t8hQQsUFVAXiH2CJSwk5Riv9T4Gx7auin-zo2V2v7gMM6v9Zm1FL_dNMC5VdVj20LMRC9NkhYHumiiNwdFqkUXJ4sb5qUwORmbLCuZz8t1oJnNA1aNPpEgbPa6e1nNx4U0YpHQdkvkfMFWYL3OwYos8qVJ-dO_BoxHaM',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuDYUuOIngvMfiXnw22ROWrMPwpVO54TJhlvh8hLmWYT4YVp9VAJamjQrLbEJc_0sSDwlTDJsUr7vvfuW8m5Sth1xHZ6dN3CAxqHe2uXmsQb5S6cothbe8BnTfM4DLyK9a7T9u7XFG-bMmnU6IMaomuGMgToir0MZofpJQRWDgm2gHvfmnbqB4pKywNss8DjhUxhI2QkYq87v0eudJp-cwkueiF8T07p_i2nFXth8mJpEdB3HFjK9pR_6sz_XwmA0LFZTL0yoMDib0g',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuCNR6pN00JiWrw1NIaUZFvSuj8VADAMZCHakFDtVLaeoYalZ2ApJ6MmeypGq8uwJNtYdEsdUXdkl-ktEup-sQKuIC-cQCH7rCeEboOgiirOeuPcz9NDlq5dpS8xEm1xLVNrHQv1WzvfAyCfdHOGvOC72WWm4ZwXl74mzQKcNs7yJSN6CwqM3RbbmRoELvzbViEmPxAEaw9fIFBcNk1sJz2B5cvf5e-zPqSVMD-os2tGwu7INZsk4o-ut7EZAfytJA_zbB487aCOINU',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _incomeController.dispose();
    super.dispose();
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _completeSetup() async {
    setState(() => _isSaving = true);

    try {
      // 1. Create default account
      // Note: Assuming starting balance is 0 since input was removed from new flow, or maybe implied?
      // The new flow has Income input. We'll use 0 for start balance for now
      final accountId = await _db.insert('accounts', {
        'name': 'Main Account',
        'type': 'savings',
        'balance': 0.0,
        'icon': 58343, // account_balance_wallet
        'color': 4280391411, // Colors.blue
        'is_default': 1,
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });

      // 2. Create income source from Monthly Income input (hidden for now)
      // final salaryAmount = double.tryParse(_incomeController.text) ?? 0.0;
      // if (salaryAmount > 0) {
      //   await _db.insert('income_sources', {
      //     'name': 'Monthly Income',
      //     'account_id': accountId,
      //     'amount': salaryAmount,
      //     'is_active': 1,
      //     'created_at': DateTime.now().millisecondsSinceEpoch,
      //     'updated_at': DateTime.now().millisecondsSinceEpoch,
      //   });
      // }

      // 3. Save preferences
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();

      if (name.isNotEmpty) await _prefs.setUserName(name);
      if (email.isNotEmpty) await _prefs.setUserEmail(email);
      await _prefs.setCurrency(_selectedCurrency);

      // Save avatar if we had a pref key, skipping for now as not in service

      // 4. Create default categories
      final defaultCategories = [
        {
          'name': 'Groceries',
          'icon': 'shopping_cart',
          'monthly_budget': 8000.0,
        },
        {
          'name': 'Transport',
          'icon': 'directions_car',
          'monthly_budget': 3000.0,
        },
        {
          'name': 'Food & Drink',
          'icon': 'restaurant',
          'monthly_budget': 5000.0,
        },
        {'name': 'Entertainment', 'icon': 'movie', 'monthly_budget': 2000.0},
        {'name': 'Shopping', 'icon': 'shopping_bag', 'monthly_budget': 4000.0},
        {'name': 'Bills', 'icon': 'receipt', 'monthly_budget': 0.0},
        {
          'name': 'Health',
          'icon': 'medical_services',
          'monthly_budget': 2000.0,
        },
        {'name': 'Education', 'icon': 'school', 'monthly_budget': 0.0},
      ];

      for (final category in defaultCategories) {
        await _db.insert('categories', {
          ...category,
          'warning_threshold': 0.8,
          'created_at': DateTime.now().millisecondsSinceEpoch,
        });
      }

      await _prefs.setOnboardingCompleted();

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const MainNavigationScaffold(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error setting up: $e')));
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
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            if (_currentPage > 0)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                    const Spacer(),
                    // Step indicators
                    Row(
                      children: List.generate(3, (index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          width: index == _currentPage ? 24 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: index == _currentPage
                                ? AppTheme.primary
                                : Colors.grey.shade300,
                          ),
                        );
                      }),
                    ),
                    const Spacer(),
                    const SizedBox(width: 48), // Balance for back button
                  ],
                ),
              ),

            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _buildWelcomeStep(),
                  _buildHowItWorksStep(),
                  _buildProfileStep(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Step 1: Welcome
  Widget _buildWelcomeStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Spacer(),
          Container(
            height: 300,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              image: const DecorationImage(
                image: NetworkImage(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuAeLf5MdMqLUjXGA8PJcNjemcWxrjiGnq2AuwOApKyx87bI_J3leweKK4Nvn1cpIu3EfHnJqvIiMW2X6jDg34yf3B54vgB2_6G50CHIIeqD1NUEqI2eNR1f02waaq8vD1qqYksjgWD5VN9qrW3mX8gy3-S9UzG4FubnyXYKYMeCaVYVuBs7exr_PGB7W2t6lyOUuvJgrmscaL8szNNkbe1D4xNdSEMKVyZi6NIL9PRZZC5-M7UOjTRZjClysa0alj00zr0OZUBkBU0',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Know what you can safely spend',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF111418),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Most apps show where money went. SpendSafe shows what’s safe to spend — before you spend it.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: const Color(0xFF637588),
              height: 1.5,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'Next',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // Step 2: How It Works
  Widget _buildHowItWorksStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 24),
          const Text(
            "Control, don't just track",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111418),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Set your limit. We calculate exactly what is Safe to Spend right now so you never overspend by accident.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF637588),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 48),

          // Available to Spend card
          _buildInfoCard(
            icon: Icons.account_balance_wallet,
            iconColor: AppTheme.primary,
            iconBg: Colors.blue.shade50,
            title: 'Available to Spend',
            subtitle: 'Real-time budget tracking',
            content: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'AVAILABLE TO SPEND',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    const Text(
                      '₹2,00,000',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: 0.38,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation(AppTheme.primary),
                    minHeight: 12,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Spent so far',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade400,
                          ),
                        ),
                        const Text(
                          '₹75,000',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: const [
                        Text(
                          'Available',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                          ),
                        ),
                        Text(
                          '₹1,25,000',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primary,
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Safe Pace card
          _buildInfoCard(
            icon: Icons.speed,
            iconColor: Colors.green,
            iconBg: Colors.green.shade50,
            title: 'Safe Pace',
            subtitle: 'Daily spending allowance',
            content: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.backgroundLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SAFE PACE TODAY',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              const Text(
                                '₹6,500',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '/ day',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.green,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'This adjusts automatically as you spend.',
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 48),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required Widget content,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }

  // Step 3: Sign In
  Widget _buildSignInStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: const DecorationImage(
                image: NetworkImage(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuAbv4N_X0Y26yORiu-KiJP_h6dfodlVXkGMbn3E9AKWPgfSNPsjoptcVa2d3DCc7dEybaQGcscHREgIJ9RlloG_1b9yhDSi2DMWeBpb6OG3IP1fttVcZuW7Qq-rMn3F-tYPVKXI2ojpJrQFG1YgdaJQnuXOiGXcfCYbwrIpw2GqjM1O-P-37JwaGRe2gomuH0HjKhZD9MqlVr95b00bq2zl679vusUjHE8jUF9SJbuyZLVTQdQpZO1kZd0zcjOqTcdLwPfW5KIwLOk',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Stay in control of your spending',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111418),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Sign in to sync your expenses across devices and stay on top of your budget.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF637588),
              height: 1.5,
            ),
          ),
          const Spacer(),

          ElevatedButton(
            onPressed: () {
              // Placeholder for Google Sign In
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Google Sign In Mock')),
              );
              _nextPage();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                // Simple mock icon
                Icon(Icons.g_mobiledata, size: 28),
                SizedBox(width: 8),
                Text('Sign in with Google'),
              ],
            ),
          ),

          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey.shade300)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'OR',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
              Expanded(child: Divider(color: Colors.grey.shade300)),
            ],
          ),
          const SizedBox(height: 16),

          TextButton(
            onPressed: _nextPage,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'Skip for now',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111418),
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward, size: 18, color: Colors.grey),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Text(
            'By continuing, you agree to our Terms of Service and Privacy Policy.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // Step 4: Profile Creation
  Widget _buildProfileStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text(
            "Let's get to know you",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111418),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Set up your profile to start tracking expenses in real-time.",
            style: TextStyle(fontSize: 16, color: Color(0xFF637588)),
          ),
          const SizedBox(height: 32),

          // Avatar
          Center(
            child: GestureDetector(
              onTap: _showAvatarSelectionBottomSheet,
              child: Column(
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade100,
                      border: Border.all(
                        color: AppTheme.primary.withOpacity(
                          _selectedAvatar != null ? 1 : 0,
                        ),
                        width: 2,
                      ),
                      image: _selectedAvatar != null
                          ? DecorationImage(
                              image: NetworkImage(_selectedAvatar!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _selectedAvatar == null
                        ? Icon(
                            Icons.person,
                            size: 48,
                            color: Colors.grey.shade400,
                          )
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Choose an avatar (optional)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          TextField(
            controller: _nameController,
            decoration: _inputDecor('Display Name', Icons.person),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _emailController,
            decoration: _inputDecor('Email Address', Icons.mail),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          // Monthly Income field hidden for now - to decide if needed later
          // TextField(
          //   controller: _incomeController,
          //   decoration: _inputDecor(
          //     'Monthly Income (Optional)',
          //     Icons.attach_money,
          //   ),
          //   keyboardType: TextInputType.number,
          // ),
          // const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedCurrency,
            decoration: _inputDecor('Preferred Currency', Icons.expand_more)
                .copyWith(
                  suffixIcon: null,
                ), // Remove default suffix icon to avoid double icons with dropdown arrow
            items: const [
              DropdownMenuItem(
                value: 'USD',
                child: Text('USD - US Dollar (\$)'),
              ),
              DropdownMenuItem(value: 'EUR', child: Text('EUR - Euro (€)')),
              DropdownMenuItem(
                value: 'GBP',
                child: Text('GBP - British Pound (£)'),
              ),
              DropdownMenuItem(
                value: 'JPY',
                child: Text('JPY - Japanese Yen (¥)'),
              ),
              DropdownMenuItem(
                value: 'INR',
                child: Text('INR - Indian Rupee (₹)'),
              ), // Added as user seems to be Indian (timezone)
            ],
            onChanged: (val) => setState(() => _selectedCurrency = val!),
          ),

          const SizedBox(height: 48),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _completeSetup,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'Complete Setup',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showAvatarSelectionBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.only(top: 24),
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            children: [
              Container(
                width: 48,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Select Avatar',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 24,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: _avatars.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Column(
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.grey.shade300,
                                style: BorderStyle.none,
                              ), // Dashed border tricky in vanilla flutter without pkg, using solid grey-light
                              color: Colors.grey.shade50,
                            ),
                            child: const Icon(
                              Icons.add_a_photo,
                              color: AppTheme.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Upload\nphoto',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      );
                    }
                    final url = _avatars[index - 1];
                    final isSelected = _selectedAvatar == url;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedAvatar = url);
                        Navigator.pop(context);
                      },
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: isSelected
                                      ? Border.all(
                                          color: AppTheme.primary,
                                          width: 2,
                                        )
                                      : null,
                                  image: DecorationImage(
                                    image: NetworkImage(url),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: AppTheme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      size: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Option $index',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  InputDecoration _inputDecor(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      suffixIcon: Icon(icon, color: Colors.grey.shade400),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }
}
