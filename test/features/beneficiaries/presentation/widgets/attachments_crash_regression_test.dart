import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:benaa_offline_app/features/attachments/domain/models/pending_attachment.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/widgets/form/attachments/organized_attachments_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('attachments tab card does not crash with missing file path', (tester) async {
    final missingFile = File(r'Z:\__missing__\old_attachment.pdf');

    await tester.pumpWidget(
      ProviderScope(
        child: ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (_, __) => MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: OrganizedAttachmentsCard(
                  attachments: [
                    PendingAttachment(
                      file: missingFile,
                      documentType: 'document_type::1',
                      personType: 'file_owner',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('ملف غير متاح'), findsWidgets);
  });
}
