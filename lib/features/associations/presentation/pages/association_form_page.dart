import 'package:benaa_offline_app/core/error_handling/result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/association.dart';
import '../../domain/repositories/association_repository.dart';
import '../providers/associations_provider.dart';
import '../widgets/representative_dropdown.dart';

/// 📝 Association Form Page
///
/// صفحة إضافة أو تعديل جمعية
class AssociationFormPage extends ConsumerStatefulWidget {
  final String? associationId; // null = إضافة, populated = تعديل

  const AssociationFormPage({super.key, this.associationId});

  @override
  ConsumerState<AssociationFormPage> createState() => _AssociationFormPageState();
}

class _AssociationFormPageState extends ConsumerState<AssociationFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late final TextEditingController _nameController;
  late final TextEditingController _shortNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _bankNameController;
  late final TextEditingController _accountNumberController;
  late final TextEditingController _swiftCodeController;
  late final TextEditingController _bankPhoneController;

  String? _selectedCurrency = 'IQD';
  String? _selectedRepresentativeId;
  bool _isActive = true;
  bool _isLoading = false;
  Association? _existingAssociation;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _shortNameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _bankNameController = TextEditingController();
    _accountNumberController = TextEditingController();
    _swiftCodeController = TextEditingController();
    _bankPhoneController = TextEditingController();

    // تحميل البيانات في حال التعديل
    if (widget.associationId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadAssociation());
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _shortNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _swiftCodeController.dispose();
    _bankPhoneController.dispose();
    super.dispose();
  }

  Future<void> _loadAssociation() async {
    setState(() => _isLoading = true);

    final useCase = ref.read(getAssociationByIdUseCaseProvider);
    final result = await useCase.execute(widget.associationId!);

    if (result case Success(value: final association)) {
      if (mounted) {
        setState(() {
          _existingAssociation = association;
          _nameController.text = association.name;
          _shortNameController.text = association.shortName ?? '';
          _phoneController.text = association.phone;
          _emailController.text = association.email ?? '';
          _bankNameController.text = association.bankName;
          _accountNumberController.text = association.accountNumber;
          _swiftCodeController.text = association.swiftCode ?? '';
          _bankPhoneController.text = association.bankPhone ?? '';
          _selectedCurrency = association.accountCurrency ?? 'IQD';
          _selectedRepresentativeId = association.representativeId;
          _isActive = association.isActive;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    if (_existingAssociation == null) {
      // Create new
      final params = AssociationParams(
        name: _nameController.text.trim(),
        shortName: _shortNameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        bankName: _bankNameController.text.trim(),
        accountNumber: _accountNumberController.text.trim(),
        swiftCode: _swiftCodeController.text.trim(),
        bankPhone: _bankPhoneController.text.trim(),
        accountCurrency: _selectedCurrency,
        representativeId: _selectedRepresentativeId,
        isActive: _isActive,
      );

      final success = await ref.read(associationsProvider.notifier).createAssociation(params);

      if (success && mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تمت إضافة الجمعية بنجاح ✅')),
        );
      }
    } else {
      // Update existing
      final updated = _existingAssociation!.copyWith(
        name: _nameController.text.trim(),
        shortName: _shortNameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        bankName: _bankNameController.text.trim(),
        accountNumber: _accountNumberController.text.trim(),
        swiftCode: _swiftCodeController.text.trim(),
        bankPhone: _bankPhoneController.text.trim(),
        accountCurrency: _selectedCurrency,
        representativeId: _selectedRepresentativeId,
        isActive: _isActive,
      );

      final success = await ref.read(associationsProvider.notifier).updateAssociation(updated);

      if (success && mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحديث الجمعية بنجاح ✅')),
        );
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.associationId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'تعديل جمعية' : 'إضافة جمعية جديدة'),
        centerTitle: true,
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // ═══════════════════════════════════════════
                  // 📝 معلومات أساسية
                  // ═══════════════════════════════════════════
                  _buildSectionHeader('📝 معلومات أساسية'),
                  const SizedBox(height: 12),

                  _buildTextField(
                    controller: _nameController,
                    label: 'اسم الجمعية *',
                    hint: 'جمعية بناء الخيرية',
                    validator: (v) => v?.trim().isEmpty == true ? 'اسم الجمعية مطلوب' : null,
                  ),

                  _buildTextField(
                    controller: _shortNameController,
                    label: 'الاسم المختصر',
                    hint: 'بناء',
                  ),

                  const SizedBox(height: 24),

                  // ═══════════════════════════════════════════
                  // 📞 معلومات الاتصال
                  // ═══════════════════════════════════════════
                  _buildSectionHeader('📞 معلومات الاتصال'),
                  const SizedBox(height: 12),

                  _buildTextField(
                    controller: _phoneController,
                    label: 'رقم الهاتف *',
                    hint: '07701234567',
                    keyboardType: TextInputType.phone,
                    validator: (v) => v?.trim().isEmpty == true ? 'رقم الهاتف مطلوب' : null,
                  ),

                  _buildTextField(
                    controller: _emailController,
                    label: 'البريد الإلكتروني',
                    hint: 'info@benaa.org',
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 24),

                  // ═══════════════════════════════════════════
                  // 🏦 المعلومات المصرفية
                  // ═══════════════════════════════════════════
                  _buildSectionHeader('🏦 المعلومات المصرفية'),
                  const SizedBox(height: 12),

                  _buildTextField(
                    controller: _bankNameController,
                    label: 'اسم البنك *',
                    hint: 'البنك التجاري العراقي',
                    validator: (v) => v?.trim().isEmpty == true ? 'اسم البنك مطلوب' : null,
                  ),

                  _buildTextField(
                    controller: _accountNumberController,
                    label: 'رقم الحساب *',
                    hint: '123456789',
                    keyboardType: TextInputType.number,
                    validator: (v) => v?.trim().isEmpty == true ? 'رقم الحساب مطلوب' : null,
                  ),

                  _buildTextField(
                    controller: _swiftCodeController,
                    label: 'رمز السويفت',
                    hint: 'BKIQIQBA',
                  ),

                  _buildTextField(
                    controller: _bankPhoneController,
                    label: 'رقم هاتف البنك',
                    hint: '07901234567',
                    keyboardType: TextInputType.phone,
                  ),

                  // عملة الحساب
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedCurrency,
                    decoration: InputDecoration(
                      labelText: 'عملة الحساب',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.attach_money),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'IQD', child: Text('دينار عراقي (IQD)')),
                      DropdownMenuItem(value: 'USD', child: Text('دولار أمريكي (USD)')),
                      DropdownMenuItem(value: 'EUR', child: Text('يورو (EUR)')),
                    ],
                    onChanged: (v) => setState(() => _selectedCurrency = v),
                  ),

                  const SizedBox(height: 24),

                  // ═══════════════════════════════════════════
                  // 👤 مندوب الجمعية
                  // ═══════════════════════════════════════════
                  _buildSectionHeader('👤 مندوب الجمعية'),
                  const SizedBox(height: 12),

                  RepresentativeDropdown(
                    selectedId: _selectedRepresentativeId,
                    onChanged: (id) => setState(() => _selectedRepresentativeId = id),
                  ),

                  const SizedBox(height: 32),

                  // ═══════════════════════════════════════════
                  // Save Button
                  // ═══════════════════════════════════════════
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('إلغاء', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            isEdit ? 'تحديث' : 'حفظ',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2196F3),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textDirection: TextDirection.rtl,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        validator: validator,
      ),
    );
  }
}
