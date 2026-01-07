import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../civil_db_download/presentation/providers/database_download_provider.dart';

/// 🚀 App Initialization & Splash Screen
class AppInitializationPage extends ConsumerStatefulWidget {
  const AppInitializationPage({super.key});

  @override
  ConsumerState<AppInitializationPage> createState() => _AppInitializationPageState();
}

class _AppInitializationPageState extends ConsumerState<AppInitializationPage> {
  String _statusMessage = 'جاري التهيئة...';

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // Show splash for at least 1.5 seconds
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    setState(() {
      _statusMessage = 'التحقق من قاعدة البيانات...';
    });

    // Explicitly check database (refresh status)
    await ref.read(databaseDownloadProvider.notifier).checkDatabase();

    // Check if database is available
    final dbState = ref.read(databaseDownloadProvider);

    if (dbState.isAvailable) {
      setState(() {
        _statusMessage = 'تم العثور على قاعدة البيانات ✓';
      });
      await Future.delayed(const Duration(milliseconds: 500));

      // Database exists - go to login/dashboard
      // The router will redirect to dashboard if already authenticated
      if (mounted && context.mounted) {
        context.go('/login');
      }
    } else {
      setState(() {
        _statusMessage = 'يجب تسجيل الدخول لتنزيل قاعدة البيانات...';
      });
      await Future.delayed(const Duration(milliseconds: 500));

      // Database doesn't exist - go to login first
      if (mounted && context.mounted) {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primaryContainer,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo/Icon
              Icon(Icons.account_balance, size: 120.sp, color: Colors.white),
              SizedBox(height: 24.h),

              // App Name
              Text(
                'بناء',
                style: TextStyle(
                  fontSize: 48.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8.h),

              // Subtitle
              Text(
                'إدارة المستفيدين - نظام متكامل',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              SizedBox(height: 48.h),

              // Loading Indicator
              SizedBox(
                width: 60.w,
                height: 60.h,
                child: CircularProgressIndicator(
                  strokeWidth: 6.w,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(height: 24.h),

              Text(
                _statusMessage,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
