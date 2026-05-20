# Firebase Security Rules - Benaa Offline App

## لماذا نحتاج القواعد؟

- تمنع الوصول غير المصرح به لبيانات المستفيدين والمرفقات.
- تضمن أن التطبيق لا يعتمد فقط على حماية الواجهة (Flutter) بل يطبق حماية على مستوى الخادم.
- تقلل مخاطر التلاعب المباشر عبر Firebase SDK أو REST API.

## كيف تعمل الأدوار؟

- جميع العمليات تتطلب مستخدمًا مسجلاً الدخول (`request.auth != null`).
- يتم اعتبار المستخدم Admin إذا كان لديه claim:
  - `admin == true` أو `role == "admin"`.
- Admin يمكنه إدارة:
  - `taxonomies`
  - `associations`
  - `representatives`
- المستخدم العادي يمكنه إنشاء/تحديث:
  - `beneficiaries`
  - `beneficiaries/{id}/visits`
  - `beneficiaries/{id}/attachments`
- الحذف مقيد عمومًا، مع تفضيل soft delete عبر حقول مثل:
  - `deleted_at`
  - `is_deleted`

## قيود وتبسيطات مناسبة لنسخة مشروع التخرج

- القواعد تعتمد على custom claims للأدوار؛ إدارة claims نفسها تتم من لوحة/سيرفر منفصل.
- لا يوجد تحقق ملكية دقيق لكل مستفيد (ownership scoping) في هذه النسخة.
- شرط `updated_at` يفرض أن التحديث أحدث من القيمة السابقة، لكنه لا يمنع كل أشكال التعارض (conflict resolution الكامل يحتاج منطق إضافي).
- Storage rules تتحقق من:
  - مسار الرفع `beneficiaries/{beneficiaryId}/attachments/{fileName}`
  - نوع الملف (`image/*` أو `application/pdf`)
  - الحد الأقصى للحجم (10MB)
- هذه القواعد مناسبة للديمو الأكاديمي، لكن الإنتاج يحتاج طبقة إضافية مثل App Check، مراقبة تدقيق (audit logs)، وسياسات أكثر دقة لكل دور/منطقة/جمعية.

## الملفات

- `firestore.rules`
- `storage.rules`
