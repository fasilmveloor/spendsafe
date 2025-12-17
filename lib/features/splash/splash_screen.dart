import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Theme Detection
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

    // 2. Exact Colors from your Tailwind Config
    final bg = isDark ? const Color(0xFF101922) : const Color(0xFFF6F7F8);
    final primary = const Color(0xFF137FEC);
    final textTitle = isDark ? Colors.white : const Color(0xFF111418);
    final textSub = isDark ? const Color(0xFF93AEBF) : const Color(0xFF637588);
    final textVer = isDark ? const Color(0xFF586370) : const Color(0xFF9BA6B3);
    final loaderBg = isDark ? const Color(0xFF2A3441) : const Color(0xFFDBE0E6);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 0,
        systemOverlayStyle: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      ),
      body: SafeArea(
        child: SizedBox(
          width: double.infinity, // Ensures horizontal centering across full screen
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // This spacer pushes the logo down to the center
              const Spacer(flex: 2),

              // --- CENTER LOGO GROUP ---
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon Container
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: primary.withOpacity(isDark ? 0.2 : 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.account_balance_wallet,
                      size: 48,
                      color: primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Title
                  Text(
                    'SpendSafe',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: textTitle,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Subtitle
                  Text(
                    'Spend safely, plan ahead',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: textSub,
                    ),
                  ),
                ],
              ),

              // This spacer pushes the version group to the bottom
              const Spacer(flex: 2),

              // --- BOTTOM VERSION GROUP ---
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 24),
                  Text(
                    'v1.0',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                      color: textVer,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48), // Bottom padding (pb-12)
            ],
          ),
        ),
      ),
    );
  }
}
