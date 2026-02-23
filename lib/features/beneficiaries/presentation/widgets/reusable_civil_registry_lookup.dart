import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

import '../providers/civil_registry_provider.dart';
import '../providers/beneficiary_dependencies.dart';
import 'civil_registry_status_indicator.dart';
import 'autofill_button.dart';
import 'civil_registry_preview_card.dart';
import 'civil_registry_required_banner.dart';

/// 🔍 Reusable Civil Registry Lookup Widget
///
/// يمكن استخدامه في أي مكان للبحث عن بيانات السجل المدني
/// ويدعم التعبئة التلقائية للحقول
class CivilRegistryLookup extends ConsumerStatefulWidget {
  final TextEditingController nationalIdController;
  final Function(Map<String, dynamic>)? onDataFetched;
  final Function()? onAutofill;
  final bool autoFetch; // إذا true، يبحث تلقائياً عند كتابة 9 أرقام
  final Duration debounceDuration;
  final bool showPreview; // عرض معاينة البيانات
  final bool showAutofillButton; // عرض زر التعبئة التلقائية
  final Widget? customPreview; // معاينة مخصصة

  const CivilRegistryLookup({
    required this.nationalIdController, super.key,
    this.onDataFetched,
    this.onAutofill,
    this.autoFetch = true,
    this.debounceDuration = const Duration(milliseconds: 500),
    this.showPreview = true,
    this.showAutofillButton = true,
    this.customPreview,
  });

  @override
  ConsumerState<CivilRegistryLookup> createState() => _CivilRegistryLookupState();
}

class _CivilRegistryLookupState extends ConsumerState<CivilRegistryLookup> {
  Timer? _debounceTimer;
  bool _showPreviewWidget = false;
  String? _lastQueuedNationalId;

  @override
  void initState() {
    super.initState();
    if (widget.autoFetch) {
      widget.nationalIdController.addListener(_onNationalIdChanged);
    }
  }

  @override
  void dispose() {
    if (widget.autoFetch) {
      widget.nationalIdController.removeListener(_onNationalIdChanged);
    }
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onNationalIdChanged() {
    final nationalId = widget.nationalIdController.text.trim();
    final canUseCivilRegistry = ref.read(civilRegistryAvailableProvider).value ?? false;

    // Cancel previous timer
    _debounceTimer?.cancel();

    // Reset preview if ID is incomplete
    if (nationalId.length < 9) {
      _lastQueuedNationalId = null;
      setState(() => _showPreviewWidget = false);
      ref.read(civilRegistryProvider.notifier).reset();
      return;
    }

    if (!canUseCivilRegistry) {
      return;
    }

    if (nationalId.length > 9 || _lastQueuedNationalId == nationalId) {
      return;
    }

    // Debounce
    _debounceTimer = Timer(widget.debounceDuration, () {
      if (!mounted) return;
      if (nationalId.length == 9) {
        _lastQueuedNationalId = nationalId;
        _fetchData(nationalId);
      }
    });
  }

  Future<void> _fetchData(String nationalId) async {
    await ref.read(civilRegistryProvider.notifier).fetchByNationalId(nationalId);

    final state = ref.read(civilRegistryProvider);

    if (state.isSuccess && state.person != null) {
      setState(() => _showPreviewWidget = true);

      // Callback with fetched data
      if (widget.onDataFetched != null) {
        widget.onDataFetched!({
          'firstName': state.person!.firstName,
          'fatherName': state.person!.fatherName,
          'grandfatherName': state.person!.grandfatherName,
          'lastName': state.person!.lastName,
          'motherName': state.person!.motherName,
          'birthDate': state.person!.birthDate,
          'gender': state.person!.gender,
          'province': state.person!.province,
          'city': state.person!.city,
          'address': state.person!.address,
        });
      }
    } else {
      setState(() => _showPreviewWidget = false);
    }
  }

  void _handleAutofill() {
    if (widget.onAutofill != null) {
      widget.onAutofill!();
      setState(() => _showPreviewWidget = false);
    }
  }

  /// Manual search trigger
  void search() {
    final nationalId = widget.nationalIdController.text;
    if (nationalId.length == 9) {
      _fetchData(nationalId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final civilRegistryAvailable = ref.watch(civilRegistryAvailableProvider);
    final canUseCivilRegistry = civilRegistryAvailable.value ?? false;
    final civilRegistryState = ref.watch(civilRegistryProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!canUseCivilRegistry) const CivilRegistryRequiredBanner(),

        // Status Indicator
        if (canUseCivilRegistry && civilRegistryState.status != CivilRegistryStatus.initial)
          Padding(
            padding: EdgeInsets.only(top: 8.h, bottom: 8.h),
            child: CivilRegistryStatusIndicator(state: civilRegistryState),
          ),

        // Preview Card
        if (widget.showPreview && canUseCivilRegistry && _showPreviewWidget && civilRegistryState.hasData)
          Padding(
            padding: EdgeInsets.only(top: 8.h, bottom: 8.h),
            child: widget.customPreview ??
                CivilRegistryPreviewCard(
                  person: civilRegistryState.person!,
                  onDismiss: () => setState(() => _showPreviewWidget = false),
                ),
          ),

        // Autofill Button
        if (widget.showAutofillButton &&
            canUseCivilRegistry &&
            civilRegistryState.isSuccess &&
            civilRegistryState.hasData)
          Padding(
            padding: EdgeInsets.only(top: 8.h),
            child: AutofillButton(onPressed: _handleAutofill),
          ),
      ],
    );
  }
}

/// 🎯 Compact version without preview (للاستخدام في Bottom Sheets)
class CompactCivilRegistryLookup extends ConsumerStatefulWidget {
  final TextEditingController nationalIdController;
  final Function(Map<String, dynamic>) onDataFetched;

  const CompactCivilRegistryLookup({
    required this.nationalIdController, required this.onDataFetched, super.key,
  });

  @override
  ConsumerState<CompactCivilRegistryLookup> createState() => _CompactCivilRegistryLookupState();
}

class _CompactCivilRegistryLookupState extends ConsumerState<CompactCivilRegistryLookup> {
  Timer? _debounceTimer;
  String? _lastQueuedNationalId;

  @override
  void initState() {
    super.initState();
    widget.nationalIdController.addListener(_onNationalIdChanged);
  }

  @override
  void dispose() {
    widget.nationalIdController.removeListener(_onNationalIdChanged);
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onNationalIdChanged() {
    final nationalId = widget.nationalIdController.text.trim();
    final canUseCivilRegistry = ref.read(civilRegistryAvailableProvider).value ?? false;
    _debounceTimer?.cancel();

    if (nationalId.length < 9) {
      _lastQueuedNationalId = null;
      ref.read(civilRegistryProvider.notifier).reset();
      return;
    }

    if (!canUseCivilRegistry) {
      return;
    }

    if (nationalId.length > 9 || _lastQueuedNationalId == nationalId) {
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      if (nationalId.length == 9) {
        _lastQueuedNationalId = nationalId;
        _fetchAndFill(nationalId);
      }
    });
  }

  Future<void> _fetchAndFill(String nationalId) async {
    await ref.read(civilRegistryProvider.notifier).fetchByNationalId(nationalId);

    final state = ref.read(civilRegistryProvider);

    if (state.isSuccess && state.person != null) {
      widget.onDataFetched({
        'firstName': state.person!.firstName,
        'fatherName': state.person!.fatherName,
        'grandfatherName': state.person!.grandfatherName,
        'lastName': state.person!.lastName,
        'motherName': state.person!.motherName,
        'birthDate': state.person!.birthDate,
        'gender': state.person!.gender == 'ذكر' ? 1 : 2,
        'province': state.person!.province,
        'city': state.person!.city,
        'address': state.person!.address,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final civilRegistryAvailable = ref.watch(civilRegistryAvailableProvider);
    final canUseCivilRegistry = civilRegistryAvailable.value ?? false;
    final state = ref.watch(civilRegistryProvider);

    if (!canUseCivilRegistry) {
      return const CivilRegistryRequiredBanner();
    }

    // عرض مؤشر بسيط فقط
    if (state.status == CivilRegistryStatus.loading) {
      return Padding(
        padding: EdgeInsets.only(top: 8.h),
        child: Row(
          children: [
            SizedBox(
              width: 14.w,
              height: 14.w,
              child: const CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 8.w),
            Text(
              'جاري البحث في السجل المدني...',
              style: TextStyle(fontSize: 12.sp, color: Colors.blue),
            ),
          ],
        ),
      );
    }

    if (state.isSuccess) {
      return Padding(
        padding: EdgeInsets.only(top: 8.h),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle, size: 16.sp, color: Colors.green),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  'تم جلب البيانات من السجل المدني',
                  style: TextStyle(fontSize: 12.sp, color: Colors.green[700]),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (state.isNotFound) {
      return Padding(
        padding: EdgeInsets.only(top: 8.h),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.orange.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 16.sp, color: Colors.orange),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  'لم يتم العثور على بيانات في السجل المدني',
                  style: TextStyle(fontSize: 12.sp, color: Colors.orange[700]),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
