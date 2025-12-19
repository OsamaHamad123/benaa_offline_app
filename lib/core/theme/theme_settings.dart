import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 🎨 Theme Settings Provider
final themeSettingsProvider =
    StateNotifierProvider<ThemeSettingsNotifier, ThemeSettings>(
  (ref) => ThemeSettingsNotifier(),
);

/// 🎨 Theme Settings Model
class ThemeSettings {
  final ThemeMode themeMode;
  final Color primaryColor;
  final bool useMaterial3;
  final double fontSize;
  final String fontFamily;

  const ThemeSettings({
    this.themeMode = ThemeMode.system,
    this.primaryColor = Colors.blue,
    this.useMaterial3 = true,
    this.fontSize = 14.0,
    this.fontFamily = 'Cairo',
  });

  ThemeSettings copyWith({
    ThemeMode? themeMode,
    Color? primaryColor,
    bool? useMaterial3,
    double? fontSize,
    String? fontFamily,
  }) {
    return ThemeSettings(
      themeMode: themeMode ?? this.themeMode,
      primaryColor: primaryColor ?? this.primaryColor,
      useMaterial3: useMaterial3 ?? this.useMaterial3,
      fontSize: fontSize ?? this.fontSize,
      fontFamily: fontFamily ?? this.fontFamily,
    );
  }

  Map<String, dynamic> toJson() => {
        'themeMode': themeMode.index,
        'primaryColor': primaryColor.value,
        'useMaterial3': useMaterial3,
        'fontSize': fontSize,
        'fontFamily': fontFamily,
      };

  factory ThemeSettings.fromJson(Map<String, dynamic> json) {
    return ThemeSettings(
      themeMode: ThemeMode.values[json['themeMode'] ?? 0],
      primaryColor: Color(json['primaryColor'] ?? Colors.blue.value),
      useMaterial3: json['useMaterial3'] ?? true,
      fontSize: (json['fontSize'] ?? 14.0).toDouble(),
      fontFamily: json['fontFamily'] ?? 'Cairo',
    );
  }
}

/// 🎨 Theme Settings Notifier
class ThemeSettingsNotifier extends StateNotifier<ThemeSettings> {
  ThemeSettingsNotifier() : super(const ThemeSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final themeMode = ThemeMode.values[prefs.getInt('themeMode') ?? 0];
    final primaryColor = Color(
      prefs.getInt('primaryColor') ?? Colors.blue.value,
    );
    final useMaterial3 = prefs.getBool('useMaterial3') ?? true;
    final fontSize = prefs.getDouble('fontSize') ?? 14.0;
    final fontFamily = prefs.getString('fontFamily') ?? 'Cairo';

    state = ThemeSettings(
      themeMode: themeMode,
      primaryColor: primaryColor,
      useMaterial3: useMaterial3,
      fontSize: fontSize,
      fontFamily: fontFamily,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
  }

  Future<void> setPrimaryColor(Color color) async {
    state = state.copyWith(primaryColor: color);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('primaryColor', color.value);
  }

  Future<void> setUseMaterial3(bool value) async {
    state = state.copyWith(useMaterial3: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('useMaterial3', value);
  }

  Future<void> setFontSize(double size) async {
    state = state.copyWith(fontSize: size);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSize', size);
  }

  Future<void> setFontFamily(String family) async {
    state = state.copyWith(fontFamily: family);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fontFamily', family);
  }

  Future<void> resetToDefaults() async {
    state = const ThemeSettings();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

/// 🎨 Predefined Color Schemes
class AppColorSchemes {
  static const List<ColorScheme> schemes = [
    // Blue (Default)
    ColorScheme(
      name: 'أزرق',
      primary: Colors.blue,
      secondary: Colors.blueAccent,
    ),
    // Green
    ColorScheme(
      name: 'أخضر',
      primary: Colors.green,
      secondary: Colors.greenAccent,
    ),
    // Purple
    ColorScheme(
      name: 'بنفسجي',
      primary: Colors.purple,
      secondary: Colors.purpleAccent,
    ),
    // Orange
    ColorScheme(
      name: 'برتقالي',
      primary: Colors.orange,
      secondary: Colors.orangeAccent,
    ),
    // Teal
    ColorScheme(
      name: 'أزرق مخضر',
      primary: Colors.teal,
      secondary: Colors.tealAccent,
    ),
    // Red
    ColorScheme(name: 'أحمر', primary: Colors.red, secondary: Colors.redAccent),
    // Indigo
    ColorScheme(
      name: 'نيلي',
      primary: Colors.indigo,
      secondary: Colors.indigoAccent,
    ),
    // Pink
    ColorScheme(
      name: 'وردي',
      primary: Colors.pink,
      secondary: Colors.pinkAccent,
    ),
  ];
}

class ColorScheme {
  final String name;
  final Color primary;
  final Color secondary;

  const ColorScheme({
    required this.name,
    required this.primary,
    required this.secondary,
  });
}

/// 🎨 Theme Customization Dialog
class ThemeCustomizationDialog extends ConsumerWidget {
  const ThemeCustomizationDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(themeSettingsProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.palette, size: 28, color: Colors.blue),
                const SizedBox(width: 12),
                const Text(
                  'تخصيص المظهر',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(height: 32),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Theme Mode
                    const Text(
                      'وضع المظهر',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SegmentedButton<ThemeMode>(
                      segments: const [
                        ButtonSegment(
                          value: ThemeMode.light,
                          label: Text('فاتح'),
                          icon: Icon(Icons.light_mode),
                        ),
                        ButtonSegment(
                          value: ThemeMode.dark,
                          label: Text('داكن'),
                          icon: Icon(Icons.dark_mode),
                        ),
                        ButtonSegment(
                          value: ThemeMode.system,
                          label: Text('تلقائي'),
                          icon: Icon(Icons.auto_mode),
                        ),
                      ],
                      selected: {settings.themeMode},
                      onSelectionChanged: (Set<ThemeMode> newSelection) {
                        ref
                            .read(themeSettingsProvider.notifier)
                            .setThemeMode(newSelection.first);
                      },
                    ),
                    const SizedBox(height: 24),

                    // Primary Color
                    const Text(
                      'اللون الأساسي',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: AppColorSchemes.schemes.map((scheme) {
                        final isSelected =
                            settings.primaryColor.value == scheme.primary.value;
                        return GestureDetector(
                          onTap: () {
                            ref
                                .read(themeSettingsProvider.notifier)
                                .setPrimaryColor(scheme.primary);
                          },
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: scheme.primary,
                              borderRadius: BorderRadius.circular(12),
                              border: isSelected
                                  ? Border.all(color: Colors.white, width: 3)
                                  : null,
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: scheme.primary.withOpacity(0.5),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 32,
                                  )
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Font Size
                    const Text(
                      'حجم الخط',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('صغير'),
                        Expanded(
                          child: Slider(
                            value: settings.fontSize,
                            min: 12.0,
                            max: 20.0,
                            divisions: 8,
                            label: settings.fontSize.toStringAsFixed(0),
                            onChanged: (value) {
                              ref
                                  .read(themeSettingsProvider.notifier)
                                  .setFontSize(value);
                            },
                          ),
                        ),
                        const Text('كبير'),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Material 3
                    SwitchListTile(
                      title: const Text('استخدام Material 3'),
                      subtitle: const Text('تصميم مادي حديث'),
                      value: settings.useMaterial3,
                      onChanged: (value) {
                        ref
                            .read(themeSettingsProvider.notifier)
                            .setUseMaterial3(value);
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Reset Button
            OutlinedButton.icon(
              onPressed: () {
                ref.read(themeSettingsProvider.notifier).resetToDefaults();
              },
              icon: const Icon(Icons.restore),
              label: const Text('استعادة الإعدادات الافتراضية'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
