import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 💾 Auto-Save Manager - Smart Auto-Save System
///
/// Features:
/// ✅ Auto-save every 30 seconds
/// ✅ Debounced saves to avoid excessive writes
/// ✅ Visual indicator (saving/saved states)
/// ✅ Pause/resume functionality
/// ✅ Save on app lifecycle changes
class AutoSaveManager {
  final Duration saveInterval;
  final Duration debounceDelay;
  final Future<void> Function() onSave;
  final VoidCallback? onSaveStart;
  final VoidCallback? onSaveComplete;
  final Function(dynamic error)? onSaveError;

  Timer? _saveTimer;
  Timer? _debounceTimer;
  bool _isPaused = false;
  bool _isSaving = false;
  DateTime? _lastSaveTime;
  int _saveCount = 0;

  AutoSaveManager({
    this.saveInterval = const Duration(seconds: 30),
    this.debounceDelay = const Duration(seconds: 2),
    required this.onSave,
    this.onSaveStart,
    this.onSaveComplete,
    this.onSaveError,
  });

  /// Start auto-save timer
  void start() {
    if (_saveTimer != null) return;

    _saveTimer = Timer.periodic(saveInterval, (_) {
      if (!_isPaused && !_isSaving) {
        _performSave();
      }
    });
  }

  /// Stop auto-save timer
  void stop() {
    _saveTimer?.cancel();
    _saveTimer = null;
    _debounceTimer?.cancel();
    _debounceTimer = null;
  }

  /// Pause auto-save (e.g., during user input)
  void pause() {
    _isPaused = true;
  }

  /// Resume auto-save
  void resume() {
    _isPaused = false;
  }

  /// Trigger immediate save (debounced)
  void triggerSave() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounceDelay, () {
      if (!_isSaving) {
        _performSave();
      }
    });
  }

  /// Force immediate save (no debounce)
  Future<void> forceSave() async {
    _debounceTimer?.cancel();
    await _performSave();
  }

  Future<void> _performSave() async {
    if (_isSaving) return;

    _isSaving = true;
    onSaveStart?.call();

    try {
      await onSave();
      _lastSaveTime = DateTime.now();
      _saveCount++;
      onSaveComplete?.call();
    } catch (error) {
      onSaveError?.call(error);
    } finally {
      _isSaving = false;
    }
  }

  /// Get last save time
  DateTime? get lastSaveTime => _lastSaveTime;

  /// Get save count
  int get saveCount => _saveCount;

  /// Check if currently saving
  bool get isSaving => _isSaving;

  /// Dispose
  void dispose() {
    stop();
  }
}

/// 🔄 Crash Recovery Manager
///
/// Features:
/// ✅ Detect app crashes
/// ✅ Save recovery data
/// ✅ Restore on next launch
/// ✅ Recovery dialog
class CrashRecoveryManager {
  static const String _recoveryKey = 'crash_recovery_data';
  static const String _crashFlagKey = 'app_crashed';
  static const String _lastSaveKey = 'last_save_timestamp';

  /// Save recovery data
  static Future<void> saveRecoveryData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_recoveryKey, jsonEncode(data));
    await prefs.setInt(_lastSaveKey, DateTime.now().millisecondsSinceEpoch);
    await prefs.setBool(_crashFlagKey, true);
  }

  /// Check if there's recovery data
  static Future<bool> hasRecoveryData() async {
    final prefs = await SharedPreferences.getInstance();
    final crashed = prefs.getBool(_crashFlagKey) ?? false;
    final hasData = prefs.getString(_recoveryKey) != null;
    return crashed && hasData;
  }

  /// Get recovery data
  static Future<Map<String, dynamic>?> getRecoveryData() async {
    final prefs = await SharedPreferences.getInstance();
    final dataStr = prefs.getString(_recoveryKey);
    if (dataStr == null) return null;

    try {
      return jsonDecode(dataStr) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Get last save time
  static Future<DateTime?> getLastSaveTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_lastSaveKey);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  /// Clear recovery data
  static Future<void> clearRecoveryData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recoveryKey);
    await prefs.remove(_crashFlagKey);
    await prefs.remove(_lastSaveKey);
  }

  /// Mark app as running (clear crash flag)
  static Future<void> markAppRunning() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_crashFlagKey, false);
  }
}

/// 📋 Draft Manager - Manage Multiple Drafts
///
/// Features:
/// ✅ Save multiple drafts
/// ✅ Load draft by ID
/// ✅ List all drafts
/// ✅ Delete drafts
/// ✅ Draft metadata (name, timestamp, progress)
class DraftManager {
  static const String _draftsKey = 'form_drafts';
  static const int _maxDrafts = 10;

  /// Save a draft
  static Future<String> saveDraft(Draft draft) async {
    final prefs = await SharedPreferences.getInstance();
    final draftsJson = prefs.getString(_draftsKey);

    List<Draft> drafts = [];
    if (draftsJson != null) {
      final List<dynamic> decodedList = jsonDecode(draftsJson);
      drafts = decodedList.map((json) => Draft.fromJson(json)).toList();
    }

    // Remove old draft with same ID if exists
    drafts.removeWhere((d) => d.id == draft.id);

    // Add new draft
    drafts.insert(0, draft);

    // Keep only max drafts
    if (drafts.length > _maxDrafts) {
      drafts = drafts.sublist(0, _maxDrafts);
    }

    // Save
    await prefs.setString(
      _draftsKey,
      jsonEncode(drafts.map((d) => d.toJson()).toList()),
    );

    return draft.id;
  }

  /// Get all drafts
  static Future<List<Draft>> getAllDrafts() async {
    final prefs = await SharedPreferences.getInstance();
    final draftsJson = prefs.getString(_draftsKey);

    if (draftsJson == null) return [];

    try {
      final List<dynamic> decodedList = jsonDecode(draftsJson);
      return decodedList.map((json) => Draft.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get draft by ID
  static Future<Draft?> getDraft(String id) async {
    final drafts = await getAllDrafts();
    try {
      return drafts.firstWhere((d) => d.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Delete draft
  static Future<void> deleteDraft(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final drafts = await getAllDrafts();

    drafts.removeWhere((d) => d.id == id);

    await prefs.setString(
      _draftsKey,
      jsonEncode(drafts.map((d) => d.toJson()).toList()),
    );
  }

  /// Clear all drafts
  static Future<void> clearAllDrafts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_draftsKey);
  }
}

/// 📊 Draft Model
class Draft {
  final String id;
  final String name;
  final String? notes;
  final DateTime timestamp;
  final double progress; // 0-100
  final Map<String, dynamic> data;

  Draft({
    required this.id,
    required this.name,
    this.notes,
    required this.timestamp,
    required this.progress,
    required this.data,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'notes': notes,
        'timestamp': timestamp.millisecondsSinceEpoch,
        'progress': progress,
        'data': data,
      };

  factory Draft.fromJson(Map<String, dynamic> json) => Draft(
        id: json['id'] as String,
        name: json['name'] as String,
        notes: json['notes'] as String?,
        timestamp:
            DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
        progress: (json['progress'] as num).toDouble(),
        data: json['data'] as Map<String, dynamic>,
      );

  String get timeAgo {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inDays > 0) return 'منذ ${diff.inDays} يوم';
    if (diff.inHours > 0) return 'منذ ${diff.inHours} ساعة';
    if (diff.inMinutes > 0) return 'منذ ${diff.inMinutes} دقيقة';
    return 'الآن';
  }
}

/// 🔔 Auto-Save Indicator Widget
class AutoSaveIndicator extends StatelessWidget {
  final bool isSaving;
  final DateTime? lastSaveTime;
  final bool hasUnsavedChanges;

  const AutoSaveIndicator({
    super.key,
    required this.isSaving,
    this.lastSaveTime,
    this.hasUnsavedChanges = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isSaving) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 12.w,
            height: 12.h,
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            'جاري الحفظ...',
            style: TextStyle(fontSize: 12.sp, color: Colors.white70),
          ),
        ],
      );
    }

    if (lastSaveTime != null) {
      final diff = DateTime.now().difference(lastSaveTime!);
      String timeAgo;
      if (diff.inMinutes < 1) {
        timeAgo = 'الآن';
      } else if (diff.inMinutes < 60) {
        timeAgo = 'منذ ${diff.inMinutes}د';
      } else {
        timeAgo = 'منذ ${diff.inHours}س';
      }

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasUnsavedChanges ? Icons.save_outlined : Icons.check_circle,
            size: 16.sp,
            color: hasUnsavedChanges ? Colors.orange : Colors.green,
          ),
          SizedBox(width: 4.w),
          Text(
            timeAgo,
            style: TextStyle(fontSize: 12.sp, color: Colors.white70),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}

/// 🚨 Recovery Dialog
class RecoveryDialog extends StatelessWidget {
  final DateTime? lastSaveTime;
  final VoidCallback onRestore;
  final VoidCallback onDiscard;

  const RecoveryDialog({
    super.key,
    this.lastSaveTime,
    required this.onRestore,
    required this.onDiscard,
  });

  @override
  Widget build(BuildContext context) {
    String timeAgo = 'غير معروف';
    if (lastSaveTime != null) {
      final diff = DateTime.now().difference(lastSaveTime!);
      if (diff.inDays > 0) {
        timeAgo = 'منذ ${diff.inDays} يوم';
      } else if (diff.inHours > 0) {
        timeAgo = 'منذ ${diff.inHours} ساعة';
      } else if (diff.inMinutes > 0) {
        timeAgo = 'منذ ${diff.inMinutes} دقيقة';
      } else {
        timeAgo = 'الآن';
      }
    }

    return AlertDialog(
      icon: Icon(Icons.restore, size: 64.sp, color: Colors.blue),
      title: const Text('استرجاع البيانات'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'تم العثور على بيانات محفوظة من جلسة سابقة.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.access_time, size: 16),
                    SizedBox(width: 8.w),
                    Text(
                      'آخر حفظ: $timeAgo',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          const Text(
            'هل تريد استرجاع البيانات؟',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: onDiscard, child: const Text('تجاهل')),
        FilledButton.icon(
          onPressed: onRestore,
          icon: const Icon(Icons.restore),
          label: const Text('استرجاع'),
        ),
      ],
    );
  }
}

/// 📋 Drafts List Dialog
class DraftsListDialog extends StatefulWidget {
  final Function(Draft draft) onRestore;

  const DraftsListDialog({super.key, required this.onRestore});

  @override
  State<DraftsListDialog> createState() => _DraftsListDialogState();
}

class _DraftsListDialogState extends State<DraftsListDialog> {
  List<Draft> _drafts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDrafts();
  }

  Future<void> _loadDrafts() async {
    setState(() => _isLoading = true);
    final drafts = await DraftManager.getAllDrafts();
    setState(() {
      _drafts = drafts;
      _isLoading = false;
    });
  }

  Future<void> _deleteDraft(String id) async {
    await DraftManager.deleteDraft(id);
    await _loadDrafts();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: double.infinity,
        height: 500.h,
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.drafts),
                SizedBox(width: 8.w),
                const Expanded(
                  child: Text(
                    'المسودات المحفوظة',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // Drafts list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _drafts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.inbox,
                                  size: 64.sp, color: Colors.grey),
                              SizedBox(height: 16.h),
                              const Text(
                                'لا توجد مسودات محفوظة',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _drafts.length,
                          itemBuilder: (context, index) {
                            final draft = _drafts[index];
                            return _DraftTile(
                              draft: draft,
                              onRestore: () {
                                Navigator.pop(context);
                                widget.onRestore(draft);
                              },
                              onDelete: () => _deleteDraft(draft.id),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DraftTile extends StatelessWidget {
  final Draft draft;
  final VoidCallback onRestore;
  final VoidCallback onDelete;

  const _DraftTile({
    required this.draft,
    required this.onRestore,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.withOpacity(0.2),
          child: Text(
            '${draft.progress.toInt()}%',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
        title: Text(
          draft.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(draft.timeAgo),
            if (draft.notes != null)
              Text(
                draft.notes!,
                style: const TextStyle(fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            SizedBox(height: 4.h),
            LinearProgressIndicator(
              value: draft.progress / 100,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation(Colors.blue),
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'restore',
              child: Row(
                children: [
                  Icon(Icons.restore, size: 20),
                  SizedBox(width: 8),
                  Text('استرجاع'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('حذف', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'restore') {
              onRestore();
            } else if (value == 'delete') {
              onDelete();
            }
          },
        ),
      ),
    );
  }
}
