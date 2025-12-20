import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../../../attachments/domain/models/pending_attachment.dart'; // 🆕 Import PendingAttachment

// Toggle form-level debug printing during manual debugging. Keep false
// in CI/tests to avoid console I/O jitter.
bool _enableFormDebugPrints = false;

/// 🎯 Form Controllers & State Variables with ChangeNotifier
///
/// Centralizes all TextEditingControllers and state variables
/// for the beneficiary form with smart state management.
/// Uses ChangeNotifier for automatic UI updates without setState.
class BeneficiaryFormControllers extends ChangeNotifier {
  // Auto-save callback
  final void Function()? onAutoSave;
  Timer? _autoSaveDebounce;

  BeneficiaryFormControllers({this.onAutoSave});

  // Text Controllers (don't need notifications)
  final firstNameController = TextEditingController();
  final fatherNameController = TextEditingController();
  final grandfatherNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final motherNameController = TextEditingController();
  final nationalIdController = TextEditingController();
  final birthDateController = TextEditingController();
  final phoneController = TextEditingController();
  final altPhoneController = TextEditingController();
  final addressController = TextEditingController();
  final neighborhoodController = TextEditingController();
  final numberOfDependentsController = TextEditingController();
  final numberOfMalesController = TextEditingController();
  final numberOfFemalesController = TextEditingController();
  final notesController = TextEditingController();
  final chronicDiseasesController = TextEditingController();
  final addressBeforeDisplacementController = TextEditingController();
  final createdByUserController = TextEditingController(); // 🆕 اسم المستخدم المدخل

  // 🔥 CRITICAL FIX: Prevent rebuild on every keystroke
  // Only notify on dropdown/switch changes, NOT on text input
  bool _shouldNotifyListeners = true;

  /// Temporarily disable notifications (for bulk updates)
  void pauseNotifications() => _shouldNotifyListeners = false;
  void resumeNotifications() {
    _shouldNotifyListeners = true;
    notifyListeners();
  }

  // Dropdown values with smart setters
  String? _selectedGender;
  String? get selectedGender => _selectedGender;
  set selectedGender(String? value) {
    if (_selectedGender != value) {
      _selectedGender = value;
      _notifyAndScheduleAutoSave();
    }
  }

  String? _selectedMaritalStatus;
  String? get selectedMaritalStatus => _selectedMaritalStatus;
  set selectedMaritalStatus(String? value) {
    if (_selectedMaritalStatus != value) {
      _selectedMaritalStatus = value;
      _notifyAndScheduleAutoSave();
    }
  }

  String? _selectedEducationLevel;
  String? get selectedEducationLevel => _selectedEducationLevel;
  set selectedEducationLevel(String? value) {
    if (_selectedEducationLevel != value) {
      _selectedEducationLevel = value;
      _notifyAndScheduleAutoSave();
    }
  }

  String? _selectedEmploymentStatus;
  String? get selectedEmploymentStatus => _selectedEmploymentStatus;
  set selectedEmploymentStatus(String? value) {
    if (_selectedEmploymentStatus != value) {
      _selectedEmploymentStatus = value;
      _notifyAndScheduleAutoSave();
    }
  }

  String? _selectedCategory;
  String? get selectedCategory => _selectedCategory;
  set selectedCategory(String? value) {
    if (_selectedCategory != value) {
      _selectedCategory = value;
      _notifyAndScheduleAutoSave();
    }
  }

  String? _selectedRelationship;
  String? get selectedRelationship => _selectedRelationship;
  set selectedRelationship(String? value) {
    if (_selectedRelationship != value) {
      _selectedRelationship = value;
      _notifyAndScheduleAutoSave();
    }
  }

  String? _selectedSection;
  String? get selectedSection => _selectedSection;
  set selectedSection(String? value) {
    if (_selectedSection != value) {
      _selectedSection = value;
      _notifyAndScheduleAutoSave();
    }
  }

  String? _selectedCity;
  String? get selectedCity => _selectedCity;
  set selectedCity(String? value) {
    if (_selectedCity != value) {
      _selectedCity = value;
      _notifyAndScheduleAutoSave();
    }
  }

  String? _selectedProvince;
  String? get selectedProvince => _selectedProvince;
  set selectedProvince(String? value) {
    if (_selectedProvince != value) {
      _selectedProvince = value;
      _notifyAndScheduleAutoSave();
    }
  }

  String? _selectedDisplacementStatus;
  String? get selectedDisplacementStatus => _selectedDisplacementStatus;
  set selectedDisplacementStatus(String? value) {
    if (_selectedDisplacementStatus != value) {
      _selectedDisplacementStatus = value;
      _notifyAndScheduleAutoSave();
    }
  }

  String? _selectedHealthStatus;
  String? get selectedHealthStatus => _selectedHealthStatus;
  set selectedHealthStatus(String? value) {
    if (_selectedHealthStatus != value) {
      _selectedHealthStatus = value;
      _notifyAndScheduleAutoSave();
    }
  }

  String? _selectedHousingStatus;
  String? get selectedHousingStatus => _selectedHousingStatus;
  set selectedHousingStatus(String? value) {
    if (_selectedHousingStatus != value) {
      _selectedHousingStatus = value;
      _notifyAndScheduleAutoSave();
    }
  }

  String? _selectedHousingType;
  String? get selectedHousingType => _selectedHousingType;
  set selectedHousingType(String? value) {
    if (_selectedHousingType != value) {
      _selectedHousingType = value;
      _notifyAndScheduleAutoSave();
    }
  }

  // Boolean switches with smart setter
  bool _hasDisability = false;
  bool get hasDisability => _hasDisability;
  set hasDisability(bool value) {
    if (_hasDisability != value) {
      _hasDisability = value;
      _notifyAndScheduleAutoSave();
    }
  }

  // Pending attachment files (for form submission)
  final List<File> _pendingAttachmentFiles = [];
  List<File> get pendingAttachmentFiles => _pendingAttachmentFiles;

  // 🆕 Enhanced Pending Attachments with Metadata
  final List<PendingAttachment> _pendingAttachments = [];
  List<PendingAttachment> get pendingAttachments => _pendingAttachments;

  // 👨‍👩‍👧‍👦 Family members data (living and deceased)
  final List<Map<String, dynamic>> _livingMembers = [];
  List<Map<String, dynamic>> get livingMembers => _livingMembers;

  // Notifiers to allow fine-grained UI updates without parent setState
  final ValueNotifier<List<Map<String, dynamic>>> livingMembersNotifier = ValueNotifier(const []);

  final List<Map<String, dynamic>> _deceasedMembers = [];
  List<Map<String, dynamic>> get deceasedMembers => _deceasedMembers;

  final ValueNotifier<List<Map<String, dynamic>>> deceasedMembersNotifier = ValueNotifier(const []);

  /// Setter for pending files (used by PendingAttachmentsSection callback)
  set pendingAttachmentFiles(List<File> files) {
    _pendingAttachmentFiles.clear();
    _pendingAttachmentFiles.addAll(files);
    if (kDebugMode && _enableFormDebugPrints) {
      debugPrint(
        '📋 [FormControllers] Updated pending files via setter. Count: ${_pendingAttachmentFiles.length}',
      );
    }
    _notifyAndScheduleAutoSave();
  }

  /// Update pending files (batch operation)
  void updatePendingFiles(List<File> newFiles) {
    _pendingAttachmentFiles.clear();
    _pendingAttachmentFiles.addAll(newFiles);
    if (kDebugMode && _enableFormDebugPrints) {
      debugPrint(
        '📋 [FormControllers] Updated pending files. Count: ${_pendingAttachmentFiles.length}',
      );
    }
    _notifyAndScheduleAutoSave();
  }

  /// Add single pending file
  void addPendingFile(File file) {
    _pendingAttachmentFiles.add(file);
    _notifyAndScheduleAutoSave();
  }

  /// Remove pending file by index
  void removePendingFile(int index) {
    // 🆕 Enhanced Pending Attachments Methods
    /// Update pending attachments (with metadata)
    void updatePendingAttachments(List<PendingAttachment> newAttachments) {
      _pendingAttachments.clear();
      _pendingAttachments.addAll(newAttachments);
      // Also update legacy list for backward compatibility
      _pendingAttachmentFiles.clear();
      _pendingAttachmentFiles.addAll(newAttachments.map((a) => a.file));
      if (kDebugMode && _enableFormDebugPrints) {
        debugPrint(
          '📋 [FormControllers] Updated pending attachments. Count: ${_pendingAttachments.length}',
        );
      }
      _notifyAndScheduleAutoSave();
    }

    /// Add single pending attachment
    void addPendingAttachment(PendingAttachment attachment) {
      _pendingAttachments.add(attachment);
      _pendingAttachmentFiles.add(attachment.file);
      _notifyAndScheduleAutoSave();
    }

    /// Remove pending attachment by index
    void removePendingAttachment(int index) {
      if (index >= 0 && index < _pendingAttachments.length) {
        _pendingAttachments.removeAt(index);
        if (index < _pendingAttachmentFiles.length) {
          _pendingAttachmentFiles.removeAt(index);
        }
        _notifyAndScheduleAutoSave();
      }
    }

    if (index >= 0 && index < _pendingAttachmentFiles.length) {
      _pendingAttachmentFiles.removeAt(index);
      _notifyAndScheduleAutoSave();
    }
  }

  /// Update living family members
  void updateLivingMembers(List<Map<String, dynamic>> members) {
    _livingMembers.clear();
    _livingMembers.addAll(members);
    livingMembersNotifier.value = List.unmodifiable(_livingMembers);
    _notifyAndScheduleAutoSave();
  }

  /// Update deceased family members
  void updateDeceasedMembers(List<Map<String, dynamic>> members) {
    _deceasedMembers.clear();
    _deceasedMembers.addAll(members);
    deceasedMembersNotifier.value = List.unmodifiable(_deceasedMembers);
    _notifyAndScheduleAutoSave();
  }

  /// Add a living family member
  void addLivingMember(Map<String, dynamic> member) {
    _livingMembers.add(member);
    livingMembersNotifier.value = List.unmodifiable(_livingMembers);
    _notifyAndScheduleAutoSave();
  }

  /// Add a deceased family member
  void addDeceasedMember(Map<String, dynamic> member) {
    _deceasedMembers.add(member);
    deceasedMembersNotifier.value = List.unmodifiable(_deceasedMembers);
    _notifyAndScheduleAutoSave();
  }

  /// Remove living family member by index
  void removeLivingMember(int index) {
    if (index >= 0 && index < _livingMembers.length) {
      _livingMembers.removeAt(index);
      livingMembersNotifier.value = List.unmodifiable(_livingMembers);
      _notifyAndScheduleAutoSave();
    }
  }

  /// Remove deceased family member by index
  void removeDeceasedMember(int index) {
    if (index >= 0 && index < _deceasedMembers.length) {
      _deceasedMembers.removeAt(index);
      deceasedMembersNotifier.value = List.unmodifiable(_deceasedMembers);
      _notifyAndScheduleAutoSave();
    }
  }

  void updateDeceasedMember(int index, Map<String, dynamic> member) {
    if (index >= 0 && index < _deceasedMembers.length) {
      _deceasedMembers[index] = member;
      deceasedMembersNotifier.value = List.unmodifiable(_deceasedMembers);
      _notifyAndScheduleAutoSave();
    }
  }

  void updateLivingMember(int index, Map<String, dynamic> member) {
    if (index >= 0 && index < _livingMembers.length) {
      _livingMembers[index] = member;
      livingMembersNotifier.value = List.unmodifiable(_livingMembers);
      _notifyAndScheduleAutoSave();
    }
  }

  /// Smart notification with auto-save scheduling
  /// ✅ Only notifies on dropdown changes, NOT on text input (prevents 60 rebuilds/sec)
  void _notifyAndScheduleAutoSave() {
    // Schedule auto-save (timer-based, no immediate notification)
    _scheduleAutoSave();

    // Only notify on dropdown/switch changes
    if (_shouldNotifyListeners) {
      notifyListeners();
    }
  }

  /// Schedule auto-save (debounced - only after 30s of inactivity)
  void _scheduleAutoSave() {
    if (onAutoSave == null) return;

    // Cancel previous timer
    _autoSaveDebounce?.cancel();

    // Start new timer - save after 30 seconds of last change
    _autoSaveDebounce = Timer(const Duration(seconds: 30), () {
      if (_hasValidData()) {
        onAutoSave!();
      }
    });
  }

  /// Check if data is valid for auto-save
  bool _hasValidData() {
    return firstNameController.text.trim().isNotEmpty && nationalIdController.text.trim().length == 9;
  }

  /// Convert controllers to Map for draft saving
  Map<String, dynamic> toMap() {
    return {
      'firstName': firstNameController.text,
      'fatherName': fatherNameController.text,
      'grandfatherName': grandfatherNameController.text,
      'lastName': lastNameController.text,
      'motherName': motherNameController.text,
      'nationalId': nationalIdController.text,
      'birthDate': birthDateController.text,
      'phone': phoneController.text,
      'altPhone': altPhoneController.text,
      'address': addressController.text,
      'neighborhood': neighborhoodController.text,
      'numberOfDependents': numberOfDependentsController.text,
      'numberOfMales': numberOfMalesController.text,
      'numberOfFemales': numberOfFemalesController.text,
      'notes': notesController.text,
      'chronicDiseases': chronicDiseasesController.text,
      'addressBeforeDisplacement': addressBeforeDisplacementController.text,
      'selectedGender': _selectedGender,
      'selectedMaritalStatus': _selectedMaritalStatus,
      'selectedEducationLevel': _selectedEducationLevel,
      'selectedEmploymentStatus': _selectedEmploymentStatus,
      'selectedCategory': _selectedCategory,
      'selectedCity': _selectedCity,
      'selectedProvince': _selectedProvince,
      'selectedDisplacementStatus': _selectedDisplacementStatus,
      'selectedHealthStatus': _selectedHealthStatus,
      'selectedHousingStatus': _selectedHousingStatus,
      'selectedHousingType': _selectedHousingType,
      'selectedRelationship': _selectedRelationship,
      'hasDisability': _hasDisability,
    };
  }

  /// Load data from Map (draft or saved data)
  void fromMap(Map<String, dynamic> map) {
    firstNameController.text = map['firstName'] ?? '';
    fatherNameController.text = map['fatherName'] ?? '';
    grandfatherNameController.text = map['grandfatherName'] ?? '';
    lastNameController.text = map['lastName'] ?? '';
    motherNameController.text = map['motherName'] ?? '';
    nationalIdController.text = map['nationalId'] ?? '';
    birthDateController.text = map['birthDate'] ?? '';
    phoneController.text = map['phone'] ?? '';
    altPhoneController.text = map['altPhone'] ?? '';
    addressController.text = map['address'] ?? '';
    neighborhoodController.text = map['neighborhood'] ?? '';
    numberOfDependentsController.text = map['numberOfDependents'] ?? '';
    numberOfMalesController.text = map['numberOfMales'] ?? '';
    numberOfFemalesController.text = map['numberOfFemales'] ?? '';
    notesController.text = map['notes'] ?? '';
    chronicDiseasesController.text = map['chronicDiseases'] ?? '';
    addressBeforeDisplacementController.text = map['addressBeforeDisplacement'] ?? '';

    _selectedGender = map['selectedGender'];
    _selectedMaritalStatus = map['selectedMaritalStatus'];
    _selectedEducationLevel = map['selectedEducationLevel'];
    _selectedEmploymentStatus = map['selectedEmploymentStatus'];
    _selectedCategory = map['selectedCategory'];
    _selectedCity = map['selectedCity'];
    _selectedProvince = map['selectedProvince'];
    _selectedDisplacementStatus = map['selectedDisplacementStatus'];
    _selectedHealthStatus = map['selectedHealthStatus'];
    _selectedHousingStatus = map['selectedHousingStatus'];
    _selectedHousingType = map['selectedHousingType'];
    _selectedRelationship = map['selectedRelationship'];
    _hasDisability = map['hasDisability'] ?? false;

    // update notifiers too
    livingMembersNotifier.value = List.unmodifiable(_livingMembers);
    deceasedMembersNotifier.value = List.unmodifiable(_deceasedMembers);
    notifyListeners();
  }

  /// Dispose all controllers
  @override
  void dispose() {
    // ✅ Cancel auto-save timer and nullify to prevent memory leak
    _autoSaveDebounce?.cancel();
    _autoSaveDebounce = null;

    // Dispose text controllers
    firstNameController.dispose();
    fatherNameController.dispose();
    grandfatherNameController.dispose();
    lastNameController.dispose();
    motherNameController.dispose();
    nationalIdController.dispose();
    birthDateController.dispose();
    phoneController.dispose();
    altPhoneController.dispose();
    addressController.dispose();
    neighborhoodController.dispose();
    numberOfDependentsController.dispose();
    numberOfMalesController.dispose();
    numberOfFemalesController.dispose();
    notesController.dispose();
    chronicDiseasesController.dispose();
    addressBeforeDisplacementController.dispose();
    createdByUserController.dispose(); // 🆕 Dispose createdByUser controller

    livingMembersNotifier.dispose();
    deceasedMembersNotifier.dispose();

    super.dispose(); // ✅ Call super
  }
}
