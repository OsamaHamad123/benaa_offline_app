# Taxonomy Contract Review (Backend ↔ App)

مرجع العقد الرسمي:

- https://palestine.benaadev.org/api-documentation.html

## القاعدة المعتمدة داخل التطبيق

- أولوية حل المجموعة من metadata القادمة من backend:
  1. slug
  2. endpoint
  3. name
  4. arabicName
  5. englishName
- في حال عدم التطابق المباشر، يتم تطبيق normalize/alias mapping.
- أي slug جديد غير معروف لا يُكسر التطبيق، ويُصنف ضمن dynamic taxonomy policy.

## عقد slug -> appGroup

- الملف التنفيذي المعتمد: docs/taxonomy_slug_app_group_contract.json
- هذا الملف هو المرجع المشترك لفريقي التطبيق والـ backend عند إضافة مجموعات جديدة.

## جدول المراجعة الدورية

- [ ] أسبوعيًا: مقارنة مجموعات API الفعلية مع canonicalGroups.
- [ ] قبل كل Release: التحقق من عدم وجود slugs جديدة غير مصنفة.
- [ ] عند ظهور slug جديد: تصنيفه إلى:
  - mapped-to-existing-field
  - new-field-required
  - ignored-not-used
- [ ] تحديث اختبارات taxonomy_group_test عند إضافة alias رسمي جديد.
