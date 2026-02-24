import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/file_size_validator.dart';

void main() {
  test('returns safe validation result when file is missing', () {
    final file = File(r'Z:\__missing__\ghost.pdf');

    final result = FileSizeValidator.validateFile(file);

    expect(result.isValid, isFalse);
    expect(result.fileSizeInBytes, 0);
    expect(result.errorMessage, 'ملف غير متاح');
  });
}
