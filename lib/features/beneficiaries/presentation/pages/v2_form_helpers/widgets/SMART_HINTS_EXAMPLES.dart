import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'smart_field_hints.dart';

/// 📚 Smart Field Hints Examples

// ═══════════════════════════════════════════════════════════════════════
// Example 1: National ID with Smart Hint
// ═══════════════════════════════════════════════════════════════════════

class NationalIdExample extends StatefulWidget {
  const NationalIdExample({super.key});

  @override
  State<NationalIdExample> createState() => _NationalIdExampleState();
}

class _NationalIdExampleState extends State<NationalIdExample> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مثال: الرقم الوطني')),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            SmartHintField(
              hint: SmartHint.nationalId(),
              child: TextFormField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: 'الرقم الوطني',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.badge),
                ),
                keyboardType: TextInputType.number,
                maxLength: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Example 2: Complete Form with Multiple Hints
// ═══════════════════════════════════════════════════════════════════════

class CompleteFormWithHints extends StatefulWidget {
  const CompleteFormWithHints({super.key});

  @override
  State<CompleteFormWithHints> createState() => _CompleteFormWithHintsState();
}

class _CompleteFormWithHintsState extends State<CompleteFormWithHints> {
  final _nationalIdController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _incomeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('نموذج مع تلميحات ذكية')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            // National ID with hint
            SmartHintField(
              hint: SmartHint.nationalId(),
              child: TextFormField(
                controller: _nationalIdController,
                decoration: const InputDecoration(
                  labelText: 'الرقم الوطني',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.badge),
                ),
                keyboardType: TextInputType.number,
                maxLength: 18,
              ),
            ),

            SizedBox(height: 20.h),

            // Phone with hint
            SmartHintField(
              hint: SmartHint.phoneNumber(),
              child: TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'رقم الهاتف',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                maxLength: 11,
              ),
            ),

            SizedBox(height: 20.h),

            // Email with hint
            SmartHintField(
              hint: SmartHint.email(),
              child: TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ),

            SizedBox(height: 20.h),

            // Income with hint
            SmartHintField(
              hint: SmartHint.income(),
              child: TextFormField(
                controller: _incomeController,
                decoration: const InputDecoration(
                  labelText: 'الدخل الشهري',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                  suffix: Text('IQD'),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nationalIdController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _incomeController.dispose();
    super.dispose();
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Example 3: Hint Badges (Compact Version)
// ═══════════════════════════════════════════════════════════════════════

class HintBadgesExample extends StatelessWidget {
  const HintBadgesExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مثال: شارات التلميحات')),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'اضغط على الشارة لعرض التلميح',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey),
            ),

            SizedBox(height: 16.h),

            // National ID field with badge
            TextFormField(
              decoration: InputDecoration(
                labelText: 'الرقم الوطني',
                border: const OutlineInputBorder(),
                suffixIcon: Padding(
                  padding: EdgeInsets.all(8.w),
                  child: HintBadge(hint: SmartHint.nationalId()),
                ),
              ),
              keyboardType: TextInputType.number,
            ),

            SizedBox(height: 16.h),

            // Phone field with badge
            TextFormField(
              decoration: InputDecoration(
                labelText: 'رقم الهاتف',
                border: const OutlineInputBorder(),
                suffixIcon: Padding(
                  padding: EdgeInsets.all(8.w),
                  child: HintBadge(hint: SmartHint.phoneNumber()),
                ),
              ),
              keyboardType: TextInputType.phone,
            ),

            SizedBox(height: 16.h),

            // UNHCR field with badge
            TextFormField(
              decoration: InputDecoration(
                labelText: 'رقم المفوضية',
                border: const OutlineInputBorder(),
                suffixIcon: Padding(
                  padding: EdgeInsets.all(8.w),
                  child: HintBadge(hint: SmartHint.unhcrNumber()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Example 4: Custom Hint
// ═══════════════════════════════════════════════════════════════════════

class CustomHintExample extends StatelessWidget {
  const CustomHintExample({super.key});

  @override
  Widget build(BuildContext context) {
    final customHint = SmartHint(
      title: 'حقل مخصص',
      description: 'هذا مثال على تلميح مخصص',
      example: 'مثال: ABC-123',
      icon: Icons.star,
      color: Colors.deepPurple,
      bulletPoints: ['✅ نقطة 1', '✅ نقطة 2', '✅ نقطة 3'],
      customWidget: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.purple.shade50,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text('💡 معلومة إضافية هنا', style: TextStyle(fontSize: 12.sp)),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('مثال: تلميح مخصص')),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: SmartHintField(
          hint: customHint,
          child: TextFormField(
            decoration: const InputDecoration(
              labelText: 'حقل مخصص',
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Example 5: All Pre-configured Hints Showcase
// ═══════════════════════════════════════════════════════════════════════

class AllHintsShowcase extends StatelessWidget {
  const AllHintsShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('جميع التلميحات المتاحة')),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          _buildHintCard(SmartHint.nationalId()),
          _buildHintCard(SmartHint.phoneNumber()),
          _buildHintCard(SmartHint.email()),
          _buildHintCard(SmartHint.dateOfBirth()),
          _buildHintCard(SmartHint.address()),
          _buildHintCard(SmartHint.occupation()),
          _buildHintCard(SmartHint.income()),
          _buildHintCard(SmartHint.familyMembers()),
          _buildHintCard(SmartHint.unhcrNumber()),
          _buildHintCard(SmartHint.rationCard()),
        ],
      ),
    );
  }

  Widget _buildHintCard(SmartHint hint) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      child: ListTile(
        leading: Icon(hint.icon, color: hint.color, size: 32.sp),
        title: Text(
          hint.title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp),
        ),
        subtitle: Text(hint.description, style: TextStyle(fontSize: 13.sp)),
        trailing: HintBadge(hint: hint),
      ),
    );
  }
}
