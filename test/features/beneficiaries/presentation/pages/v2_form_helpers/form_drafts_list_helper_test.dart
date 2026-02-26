import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/form_drafts_list_helper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FormDraftsListHelper', () {
    test('drops drafts with missing draftId', () {
      final result = FormDraftsListHelper.normalizeDrafts([
        {
          'name': 'no-id',
          'savedAt': '2026-02-26T10:00:00.000Z',
        },
      ]);

      expect(result, isEmpty);
    });

    test('parses valid draft and keeps fallback name/date behavior', () {
      final result = FormDraftsListHelper.normalizeDrafts([
        {
          'draftId': 'd1',
          'name': 'draft-1',
          'savedAt': '2026-02-26T10:00:00.000Z',
        },
      ]);

      expect(result.length, 1);
      expect(result.first.draftId, 'd1');
      expect(result.first.draftName, 'draft-1');
      expect(result.first.savedAt, isNotNull);
    });

    test('uses safe fallback when name and savedAt are invalid', () {
      final result = FormDraftsListHelper.normalizeDrafts([
        {
          'draftId': 'd2',
          'name': '   ',
          'savedAt': 'not-a-date',
        },
      ]);

      expect(result.length, 1);
      expect(result.first.draftName, 'مسودة');
      expect(result.first.savedAt, isNull);
    });
  });
}
