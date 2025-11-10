import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/providers.dart';
import '../../core/utils/responsive_utils.dart';
import 'cubit/beneficiary_form_cubit.dart';
import 'cubit/beneficiary_form_state.dart';

class AddBeneficiaryPageV2 extends ConsumerWidget {
  final String? beneficiaryId;

  const AddBeneficiaryPageV2({super.key, this.beneficiaryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final database = ref.watch(databaseProvider);

    return BlocProvider(
      create: (context) => BeneficiaryFormCubit(
        database: database,
        beneficiaryId: beneficiaryId,
      ),
      child: const _AddBeneficiaryView(),
    );
  }
}

class _AddBeneficiaryView extends StatefulWidget {
  const _AddBeneficiaryView();

  @override
  State<_AddBeneficiaryView> createState() => _AddBeneficiaryViewState();
}

class _AddBeneficiaryViewState extends State<_AddBeneficiaryView> {
  // Controllers - لكن بدون setState!
  final _fullNameController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _fileNoController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _addressController = TextEditingController();
  final _districtController = TextEditingController();
  final _motherNameController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _associationNameController = TextEditingController();
  final _familySizeController = TextEditingController();
  final _notesController = TextEditingController();

  // Local state for dropdowns - NO CUBIT!
  String _governorate = 'بغداد';
  String _gender = 'male';
  String _category = 'orphan';
  String _healthStatus = 'good';
  bool _hasDisability = false;

  bool _isInitialized = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _nationalIdController.dispose();
    _fileNoController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    _districtController.dispose();
    _motherNameController.dispose();
    _fatherNameController.dispose();
    _associationNameController.dispose();
    _familySizeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rv = ResponsiveUtils.getValues(context);

    return BlocConsumer<BeneficiaryFormCubit, BeneficiaryFormState>(
      listener: (context, state) {
        if (state.isSaved) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                context.read<BeneficiaryFormCubit>().beneficiaryId != null
                    ? 'تم تحديث البيانات بنجاح'
                    : 'تم إضافة المستفيد بنجاح',
              ),
              backgroundColor: Colors.green,
            ),
          );
          context.pop();
        }

        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }

        // تحميل البيانات في Controllers عند التحميل
        if (!state.isLoading && !_isInitialized) {
          _isInitialized = true;
          _fullNameController.text = state.fullName;
          _nationalIdController.text = state.nationalId;
          _fileNoController.text = state.fileNo;
          _phoneNumberController.text = state.phoneNumber;
          _addressController.text = state.address;
          _districtController.text = state.district;
          _motherNameController.text = state.motherName;
          _fatherNameController.text = state.fatherName;
          _associationNameController.text = state.associationName;
          _familySizeController.text = state.familySize.toString();
          _notesController.text = state.notes;

          setState(() {
            _governorate = state.governorate;
            _gender = state.gender;
            _category = state.category;
            _healthStatus = state.healthStatus;
            _hasDisability = state.hasDisability;
          });
        }
      },
      buildWhen: (previous, current) {
        // فقط rebuild عند تغيير isLoading أو isSaved أو errorMessage
        return previous.isLoading != current.isLoading ||
            previous.isSaved != current.isSaved ||
            previous.errorMessage != current.errorMessage;
      },
      builder: (context, state) {
        final cubit = context.read<BeneficiaryFormCubit>();
        final isEdit = cubit.beneficiaryId != null;

        return Scaffold(
          appBar: AppBar(
            title: Text(isEdit ? 'تعديل مستفيد' : 'إضافة مستفيد جديد'),
            actions: [
              if (isEdit)
                IconButton(
                  icon: const Icon(Icons.visibility),
                  tooltip: 'عرض التفاصيل',
                  onPressed: () =>
                      context.push('/beneficiaries/${cubit.beneficiaryId}'),
                ),
              IconButton(
                icon: const Icon(Icons.info_outline),
                tooltip: 'مساعدة',
                onPressed: () => _showHelpDialog(context),
              ),
            ],
          ),
          body: state.isLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        isEdit ? 'جاري تحميل البيانات...' : 'جاري الحفظ...',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: rv.padding,
                  physics: const BouncingScrollPhysics(),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildBasicInfoSection(context, state, cubit, rv),
                      SizedBox(height: rv.spacing15),
                      _buildContactSection(context, state, cubit, rv),
                      SizedBox(height: rv.spacing15),
                      _buildFamilySection(context, state, cubit, rv),
                      SizedBox(height: rv.spacing15),
                      _buildHealthSection(context, state, cubit, rv),
                      SizedBox(height: rv.spacing15),
                      _buildNotesSection(context, state, cubit, rv),
                      SizedBox(height: rv.spacing * 2),
                      _buildSaveButton(context, state, cubit, isEdit),
                      SizedBox(
                        height: MediaQuery.of(context).padding.bottom + 16,
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildBasicInfoSection(
    BuildContext context,
    BeneficiaryFormState state,
    BeneficiaryFormCubit cubit,
    ResponsiveValues rv,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'المعلومات الأساسية'),
        SizedBox(height: rv.spacing),
        TextFormField(
          controller: _fullNameController,
          decoration: const InputDecoration(
            labelText: 'الاسم الكامل *',
            prefixIcon: Icon(Icons.person),
            helperText: 'الاسم الثلاثي أو الرباعي',
          ),
          onChanged: cubit.updateFullName,
          textInputAction: TextInputAction.next,
        ),
        SizedBox(height: rv.spacing),
        TextFormField(
          controller: _associationNameController,
          decoration: const InputDecoration(
            labelText: 'اسم الجمعية',
            prefixIcon: Icon(Icons.business),
            hintText: 'مثال: جمعية البناء الخيرية',
          ),
          onChanged: cubit.updateAssociationName,
          textInputAction: TextInputAction.next,
        ),
        SizedBox(height: rv.spacing),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _nationalIdController,
                decoration: const InputDecoration(
                  labelText: 'الرقم الوطني *',
                  prefixIcon: Icon(Icons.badge),
                ),
                keyboardType: TextInputType.number,
                onChanged: cubit.updateNationalId,
                textInputAction: TextInputAction.next,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _fileNoController,
                decoration: const InputDecoration(
                  labelText: 'رقم الملف *',
                  prefixIcon: Icon(Icons.folder),
                ),
                onChanged: cubit.updateFileNo,
                textInputAction: TextInputAction.next,
              ),
            ),
          ],
        ),
        SizedBox(height: rv.spacing),
        DropdownButtonFormField<String>(
          value: _governorate,
          decoration: const InputDecoration(
            labelText: 'المحافظة *',
            prefixIcon: Icon(Icons.location_on),
          ),
          items: const [
            DropdownMenuItem(value: 'بغداد', child: Text('بغداد')),
            DropdownMenuItem(value: 'البصرة', child: Text('البصرة')),
            DropdownMenuItem(value: 'نينوى', child: Text('نينوى')),
            DropdownMenuItem(value: 'الأنبار', child: Text('الأنبار')),
            DropdownMenuItem(value: 'ديالى', child: Text('ديالى')),
            DropdownMenuItem(value: 'كربلاء', child: Text('كربلاء')),
            DropdownMenuItem(value: 'النجف', child: Text('النجف')),
          ],
          onChanged: (v) {
            setState(() => _governorate = v!);
            cubit.updateGovernorate(v!);
          },
        ),
        SizedBox(height: rv.spacing),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _gender,
                decoration: const InputDecoration(
                  labelText: 'الجنس *',
                  prefixIcon: Icon(Icons.wc),
                ),
                items: const [
                  DropdownMenuItem(value: 'male', child: Text('ذكر')),
                  DropdownMenuItem(value: 'female', child: Text('أنثى')),
                ],
                onChanged: (v) {
                  setState(() => _gender = v!);
                  cubit.updateGender(v!);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(
                  labelText: 'الفئة *',
                  prefixIcon: Icon(Icons.category),
                ),
                items: const [
                  DropdownMenuItem(value: 'orphan', child: Text('يتيم')),
                  DropdownMenuItem(value: 'widow', child: Text('أرملة')),
                  DropdownMenuItem(value: 'poor', child: Text('فقير')),
                  DropdownMenuItem(value: 'disabled', child: Text('معاق')),
                ],
                onChanged: (v) {
                  setState(() => _category = v!);
                  cubit.updateCategory(v!);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContactSection(
    BuildContext context,
    BeneficiaryFormState state,
    BeneficiaryFormCubit cubit,
    ResponsiveValues rv,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'معلومات الاتصال'),
        SizedBox(height: rv.spacing),
        TextFormField(
          controller: _phoneNumberController,
          decoration: const InputDecoration(
            labelText: 'رقم الهاتف',
            prefixIcon: Icon(Icons.phone),
          ),
          keyboardType: TextInputType.phone,
          onChanged: cubit.updatePhoneNumber,
          textInputAction: TextInputAction.next,
        ),
        SizedBox(height: rv.spacing),
        TextFormField(
          controller: _districtController,
          decoration: const InputDecoration(
            labelText: 'القضاء',
            prefixIcon: Icon(Icons.location_city),
          ),
          onChanged: cubit.updateDistrict,
          textInputAction: TextInputAction.next,
        ),
        SizedBox(height: rv.spacing),
        TextFormField(
          controller: _addressController,
          decoration: const InputDecoration(
            labelText: 'العنوان',
            prefixIcon: Icon(Icons.home),
          ),
          onChanged: cubit.updateAddress,
          textInputAction: TextInputAction.next,
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildFamilySection(
    BuildContext context,
    BeneficiaryFormState state,
    BeneficiaryFormCubit cubit,
    ResponsiveValues rv,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'معلومات العائلة'),
        SizedBox(height: rv.spacing),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _fatherNameController,
                decoration: const InputDecoration(
                  labelText: 'اسم الأب',
                  prefixIcon: Icon(Icons.person),
                ),
                onChanged: cubit.updateFatherName,
                textInputAction: TextInputAction.next,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _motherNameController,
                decoration: const InputDecoration(
                  labelText: 'اسم الأم',
                  prefixIcon: Icon(Icons.person),
                ),
                onChanged: cubit.updateMotherName,
                textInputAction: TextInputAction.next,
              ),
            ),
          ],
        ),
        SizedBox(height: rv.spacing),
        TextFormField(
          controller: _familySizeController,
          decoration: const InputDecoration(
            labelText: 'عدد أفراد الأسرة',
            prefixIcon: Icon(Icons.family_restroom),
          ),
          keyboardType: TextInputType.number,
          onChanged: (v) => cubit.updateFamilySize(int.tryParse(v) ?? 1),
          textInputAction: TextInputAction.next,
        ),
      ],
    );
  }

  Widget _buildHealthSection(
    BuildContext context,
    BeneficiaryFormState state,
    BeneficiaryFormCubit cubit,
    ResponsiveValues rv,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'الحالة الصحية'),
        SizedBox(height: rv.spacing),
        DropdownButtonFormField<String>(
          value: _healthStatus,
          decoration: const InputDecoration(
            labelText: 'الحالة الصحية',
            prefixIcon: Icon(Icons.health_and_safety),
          ),
          items: const [
            DropdownMenuItem(value: 'good', child: Text('جيدة')),
            DropdownMenuItem(value: 'fair', child: Text('متوسطة')),
            DropdownMenuItem(value: 'poor', child: Text('ضعيفة')),
          ],
          onChanged: (v) {
            setState(() => _healthStatus = v!);
            cubit.updateHealthStatus(v!);
          },
        ),
        SizedBox(height: rv.spacing),
        CheckboxListTile(
          value: _hasDisability,
          onChanged: (v) {
            setState(() => _hasDisability = v ?? false);
            cubit.updateHasDisability(v ?? false);
          },
          title: const Text('لديه إعاقة'),
          controlAffinity: ListTileControlAffinity.leading,
        ),
      ],
    );
  }

  Widget _buildNotesSection(
    BuildContext context,
    BeneficiaryFormState state,
    BeneficiaryFormCubit cubit,
    ResponsiveValues rv,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'ملاحظات'),
        SizedBox(height: rv.spacing),
        TextFormField(
          controller: _notesController,
          decoration: const InputDecoration(
            labelText: 'ملاحظات إضافية',
            prefixIcon: Icon(Icons.notes),
            alignLabelWithHint: true,
          ),
          maxLines: 4,
          onChanged: cubit.updateNotes,
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }

  Widget _buildSaveButton(
    BuildContext context,
    BeneficiaryFormState state,
    BeneficiaryFormCubit cubit,
    bool isEdit,
  ) {
    return SizedBox(
      height: 56,
      child: ElevatedButton.icon(
        onPressed: state.isLoading
            ? null
            : () {
                final error = cubit.validateForm();
                if (error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(error), backgroundColor: Colors.red),
                  );
                  return;
                }
                cubit.saveBeneficiary();
              },
        icon: state.isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.save),
        label: Text(isEdit ? 'تحديث البيانات' : 'حفظ البيانات'),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('نصائح الإدخال'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '📝 الحقول المطلوبة:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• الاسم الكامل\n• الرقم الوطني\n• رقم الملف\n• المحافظة'),
              SizedBox(height: 16),
              Text('💡 نصائح:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text(
                '• تأكد من صحة البيانات قبل الحفظ\n• يمكنك التعديل لاحقاً\n• البيانات تُحفظ محلياً أولاً',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('فهمت'),
          ),
        ],
      ),
    );
  }
}
