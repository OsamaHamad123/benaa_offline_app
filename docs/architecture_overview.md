# Architecture Overview - Benaa Offline App

## الهدف

هذا التطبيق مبني لسيناريو ميداني يعمل Offline-first مع مزامنة لاحقة إلى Firebase، مع فصل واضح بين طبقات العرض والمنطق والبنية التحتية.

## الطبقات الرئيسية

- Presentation:
  - صفحات Flutter + Riverpod state management.
  - مسؤولة عن تجربة المستخدم فقط.
- Domain:
  - Entities + Use Cases + Contracts (Repositories).
  - لا تعتمد على Firebase أو Drift مباشرة.
- Data:
  - تنفيذ الـ repositories.
  - Local عبر Drift SQLite.
  - Remote عبر Backend abstraction (`RemoteBackend`).
- Core:
  - Sync manager, mappers, security helpers, providers, logging, notifications.

## Offline-First بشكل عملي

- أي إنشاء/تعديل يتم حفظه محليًا أولًا.
- يتم إدراج عملية في `sync_queue` بحالة pending.
- عند توفر الإنترنت: SyncManager يرسل العمليات إلى Firebase وفق أولوية وترتيب واضح.
- في الفشل: retry/backoff مع حفظ الحالة والأخطاء محليًا.

## Firebase Integration

- Firestore:
  - تخزين documents الأساسية (beneficiaries, visits, attachments metadata).
- Storage:
  - رفع ملفات المرفقات في مسار موحد.
- Security Rules:
  - مصادقة إلزامية.
  - صلاحيات Admin لإدارة taxonomies/associations.

## لماذا هذا مناسب لمشروع تخرج؟

- قابل للشرح والدفاع أكاديميًا:
  - Separation of concerns واضح.
  - مرونة تبديل backend لاحقًا (Supabase مثالًا) بدون كسر UI.
  - سيناريو Offline واقعي للميدان.
