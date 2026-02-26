import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/monitoring/app_monitoring.dart';
import '../../../civil_db_download/presentation/providers/database_download_provider.dart';

/// 🚀 App Initialization & Splash Screen
class AppInitializationPage extends ConsumerStatefulWidget {
  const AppInitializationPage({super.key});

  @override
  ConsumerState<AppInitializationPage> createState() => _AppInitializationPageState();
}

class _AppInitializationPageState extends ConsumerState<AppInitializationPage> with TickerProviderStateMixin {
  String _statusMessage = 'جاري التهيئة...';
  final Stopwatch _initStopwatch = Stopwatch();
  late final AnimationController _ambientController;
  late final AnimationController _contentController;
  late final Animation<double> _fadeIn;
  late final Animation<double> _logoScale;
  late final Animation<Offset> _statusSlide;

  @override
  void initState() {
    super.initState();
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();

    _fadeIn = CurvedAnimation(parent: _contentController, curve: Curves.easeOutCubic);
    _logoScale = Tween<double>(begin: 0.86, end: 1).animate(
      CurvedAnimation(parent: _contentController, curve: const Interval(0.15, 0.75, curve: Curves.easeOutBack)),
    );
    _statusSlide = Tween<Offset>(begin: const Offset(0, 0.18), end: Offset.zero).animate(
      CurvedAnimation(parent: _contentController, curve: const Interval(0.35, 1, curve: Curves.easeOutCubic)),
    );

    _initStopwatch.start();
    _initialize();
  }

  @override
  void dispose() {
    _ambientController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    try {
      await Future.delayed(const Duration(milliseconds: 1500));
      if (!mounted) return;

      setState(() {
        _statusMessage = 'التحقق من قاعدة البيانات...';
      });

      await ref.read(databaseDownloadProvider.notifier).checkDatabase().timeout(const Duration(seconds: 12));
      final dbState = ref.read(databaseDownloadProvider);

      if (dbState.canProceed) {
        setState(() {
          _statusMessage = dbState.isAvailable ? 'تم العثور على قاعدة البيانات ✓' : 'تم تخطي التحميل سابقاً...';
        });
        await Future.delayed(const Duration(milliseconds: 500));

        if (mounted && context.mounted) {
          ref.read(appMonitoringProvider).logEvent(
            'app_init_completed',
            parameters: {
              'duration_ms': _initStopwatch.elapsedMilliseconds,
              'db_available': dbState.isAvailable,
              'db_skipped': dbState.wasSkipped,
              'destination': 'login',
            },
          );
          context.go('/login');
        }
        return;
      }

      setState(() {
        _statusMessage = 'يجب تسجيل الدخول لتنزيل قاعدة البيانات...';
      });
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted && context.mounted) {
        ref.read(appMonitoringProvider).logEvent(
          'app_init_completed',
          parameters: {
            'duration_ms': _initStopwatch.elapsedMilliseconds,
            'db_available': dbState.isAvailable,
            'db_skipped': dbState.wasSkipped,
            'destination': 'login_requires_db',
          },
        );
        context.go('/login');
      }
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _statusMessage = 'تعذر إكمال التهيئة، سيتم المتابعة...';
      });

      await Future.delayed(const Duration(milliseconds: 600));

      if (mounted && context.mounted) {
        ref.read(appMonitoringProvider).logEvent(
          'app_init_failed_fallback',
          parameters: {
            'duration_ms': _initStopwatch.elapsedMilliseconds,
            'error': error.toString(),
            'destination': 'login_fallback',
          },
        );
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _ambientController,
        builder: (context, child) {
          final t = _ambientController.value;
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colorScheme.primary,
                  colorScheme.primaryContainer,
                ],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: (-70 + (t * 38)).h,
                  right: (-45 + (t * 22)).w,
                  child: _buildAmbientOrb(
                    size: 210.r,
                    color: Colors.white.withValues(alpha: 0.11),
                  ),
                ),
                Positioned(
                  bottom: (-90 + ((1 - t) * 32)).h,
                  left: (-60 + (t * 25)).w,
                  child: _buildAmbientOrb(
                    size: 260.r,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                Center(
                  child: FadeTransition(
                    opacity: _fadeIn,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 28.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ScaleTransition(
                            scale: _logoScale,
                            child: Container(
                              width: 122.r,
                              height: 122.r,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
                              ),
                              child: Icon(Icons.account_balance, size: 62.sp, color: Colors.white),
                            ),
                          ),
                          SizedBox(height: 20.h),
                          Text(
                            'بناء',
                            style: TextStyle(
                              fontSize: 48.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'إدارة المستفيدين - نظام متكامل',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.white.withValues(alpha: 0.92),
                            ),
                          ),
                          SizedBox(height: 34.h),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
                            ),
                            child: Column(
                              children: [
                                SizedBox(
                                  width: 56.w,
                                  height: 56.h,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 5.w,
                                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                                SizedBox(height: 14.h),
                                SlideTransition(
                                  position: _statusSlide,
                                  child: Text(
                                    _statusMessage,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white.withValues(alpha: 0.92),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAmbientOrb({required double size, required Color color}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
