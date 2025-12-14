// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Benaa - Beneficiaries Management';

  @override
  String get beneficiariesList => 'Beneficiaries List';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get reports => 'Reports';

  @override
  String get settings => 'Settings';

  @override
  String get search => 'Search';

  @override
  String get filter => 'Filter';

  @override
  String get add => 'Add';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get ok => 'OK';

  @override
  String get close => 'Close';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get previous => 'Previous';

  @override
  String get loading => 'Loading...';

  @override
  String get noData => 'No Data';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get warning => 'Warning';

  @override
  String get info => 'Info';

  @override
  String get nationalId => 'National ID';

  @override
  String get nationalIdRequired => '🆔 National ID is required';

  @override
  String nationalIdInvalid(int length) {
    return '🆔 National ID must be $length digits\n💡 Example: 123456789';
  }

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get phoneRequired => '📱 Phone number is required';

  @override
  String get phoneInvalid =>
      '📱 Invalid number - must start with 059 or 056\n💡 Example: 0595735352 or +970595735352';

  @override
  String get email => 'Email';

  @override
  String get emailRequired => '📧 Email is required';

  @override
  String get emailInvalid => '📧 Invalid email\n💡 Example: example@email.com';

  @override
  String get birthDate => 'Birth Date';

  @override
  String get birthDateRequired => '📅 Birth date is required';

  @override
  String get birthDateInvalid => '📅 Invalid birth date\n💡 Check date format';

  @override
  String get birthDateFuture =>
      '📅 Birth date cannot be in the future\n💡 Check entered date';

  @override
  String get birthDateTooOld =>
      '📅 Unrealistic birth date\n💡 Age must be less than 120 years';

  @override
  String get name => 'Name';

  @override
  String nameRequired(String fieldName) {
    return '👤 $fieldName is required';
  }

  @override
  String nameTooShort(String fieldName, int length) {
    return '👤 $fieldName must be at least 2 characters\n💡 Current length: $length';
  }

  @override
  String nameTooLong(String fieldName, int length) {
    return '👤 $fieldName is too long\n💡 Max: 50 characters (Current: $length)';
  }

  @override
  String nameInvalidChars(String fieldName) {
    return '👤 $fieldName contains invalid characters\n💡 Use Arabic or English letters only';
  }

  @override
  String nameArabicOnly(String fieldName) {
    return '👤 Please use Arabic letters only in $fieldName\n💡 Example: محمد أحمد';
  }

  @override
  String fieldRequired(String fieldName) {
    return '⚠️ $fieldName is required';
  }

  @override
  String get addBeneficiary => 'Add Beneficiary';

  @override
  String get editBeneficiary => 'Edit Beneficiary';

  @override
  String get deleteBeneficiary => 'Delete Beneficiary';

  @override
  String get beneficiaryDetails => 'Beneficiary Details';

  @override
  String get beneficiaryAdded => 'Beneficiary added successfully';

  @override
  String get beneficiaryUpdated => 'Beneficiary updated successfully';

  @override
  String get beneficiaryDeleted => 'Beneficiary deleted successfully';

  @override
  String get confirmDelete => 'Confirm Delete';

  @override
  String get confirmDeleteMessage =>
      'Are you sure you want to delete this item?';

  @override
  String get deleteWarning => 'This action cannot be undone';

  @override
  String get networkError => 'Network connection error';

  @override
  String get serverError => 'Server error';

  @override
  String get unknownError => 'An unexpected error occurred';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get married => 'Married';

  @override
  String get single => 'Single';

  @override
  String get divorced => 'Divorced';

  @override
  String get widowed => 'Widowed';

  @override
  String get statistics => 'Statistics';

  @override
  String get totalBeneficiaries => 'Total Beneficiaries';

  @override
  String get activeBeneficiaries => 'Active Beneficiaries';

  @override
  String get pendingBeneficiaries => 'Pending Beneficiaries';

  @override
  String get todayActivities => 'Today\'s Activities';

  @override
  String get sync => 'Sync';

  @override
  String get syncInProgress => 'Syncing...';

  @override
  String get syncCompleted => 'Sync completed successfully';

  @override
  String get syncFailed => 'Sync failed';

  @override
  String lastSyncAt(String time) {
    return 'Last sync: $time';
  }

  @override
  String get draft => 'Draft';

  @override
  String get drafts => 'Drafts';

  @override
  String get saveDraft => 'Save as Draft';

  @override
  String get loadDraft => 'Load Draft';

  @override
  String get deleteDraft => 'Delete Draft';

  @override
  String get draftSaved => 'Draft saved';

  @override
  String get draftLoaded => 'Draft loaded';

  @override
  String get attachment => 'Attachment';

  @override
  String get attachments => 'Attachments';

  @override
  String get addAttachment => 'Add Attachment';

  @override
  String get deleteAttachment => 'Delete Attachment';

  @override
  String get viewAttachment => 'View Attachment';

  @override
  String get noAttachments => 'No Attachments';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String get file => 'File';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get chooseFromGallery => 'Choose from Gallery';

  @override
  String get chooseFile => 'Choose File';

  @override
  String get governorate => 'Governorate';

  @override
  String get city => 'City';

  @override
  String get address => 'Address';

  @override
  String get age => 'Age';

  @override
  String get gender => 'Gender';

  @override
  String get maritalStatus => 'Marital Status';

  @override
  String get familyMembers => 'Family Members';

  @override
  String get notes => 'Notes';

  @override
  String get description => 'Description';

  @override
  String get status => 'Status';

  @override
  String get priority => 'Priority';

  @override
  String get exportToPdf => 'Export to PDF';

  @override
  String get exportToExcel => 'Export to Excel';

  @override
  String get exportCompleted => 'Export completed successfully';

  @override
  String get exportFailed => 'Export failed';

  @override
  String get language => 'Language';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'English';

  @override
  String get changeLanguage => 'Change Language';

  @override
  String get theme => 'Theme';

  @override
  String get lightTheme => 'Light Theme';

  @override
  String get darkTheme => 'Dark Theme';

  @override
  String get systemTheme => 'System Theme';
}
