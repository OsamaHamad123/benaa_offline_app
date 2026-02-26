import 'package:flutter_test/flutter_test.dart';
import 'package:benaa_offline_app/features/taxonomies/data/models/taxonomy_dto.dart';
import 'package:benaa_offline_app/features/taxonomies/domain/entities/taxonomy_group.dart';

void main() {
  group('TaxonomyDTO', () {
    test('fromJson should parse complete JSON correctly', () {
      final json = {
        'id': '123',
        'group': 'governorate',
        'code': 'BGD',
        'label': 'بغداد',
        'label_en': 'Baghdad',
        'parent_id': null,
        'sort_order': 1,
        'is_active': true,
        'description': 'العاصمة',
        'color': '#FF0000',
        'icon': 'location_city',
        'metadata': {'population': 8000000},
        'created_at': '2024-01-01T00:00:00Z',
        'updated_at': '2024-01-02T00:00:00Z',
        'deleted_at': null,
      };

      final dto = TaxonomyDTO.fromJson(json);

      expect(dto.id, '123');
      expect(dto.groupValue, 'governorate');
      expect(dto.code, 'BGD');
      expect(dto.label, 'بغداد');
      expect(dto.labelEn, 'Baghdad');
      expect(dto.sortOrder, 1);
      expect(dto.isActive, true);
      expect(dto.color, '#FF0000');
    });

    test('fromJson should handle minimal JSON', () {
      final json = {
        'id': '1',
        'group': 'category',
        'code': 'orphan',
        'label': 'يتيم',
      };

      final dto = TaxonomyDTO.fromJson(json);

      expect(dto.id, '1');
      expect(dto.groupValue, 'category');
      expect(dto.code, 'orphan');
      expect(dto.label, 'يتيم');
      expect(dto.isActive, true); // default
      expect(dto.sortOrder, 0); // default
    });

    test('fromJson should handle integer id', () {
      final json = {
        'id': 123, // int instead of string
        'group': 'category',
        'code': 'test',
        'label': 'Test',
      };

      final dto = TaxonomyDTO.fromJson(json);
      expect(dto.id, '123');
    });

    test('fromJson should handle is_active as 1/0', () {
      final json1 = {
        'id': '1',
        'group': 'category',
        'code': 'test',
        'label': 'Test',
        'is_active': 1,
      };

      final json0 = {
        'id': '2',
        'group': 'category',
        'code': 'test2',
        'label': 'Test2',
        'is_active': 0,
      };

      expect(TaxonomyDTO.fromJson(json1).isActive, true);
      expect(TaxonomyDTO.fromJson(json0).isActive, false);
    });

    test('fromJson should handle is_active as "true"/"false" strings', () {
      final jsonTrue = {
        'id': '1',
        'group': 'category',
        'code': 'test',
        'label': 'Test',
        'is_active': 'true',
      };

      final jsonFalse = {
        'id': '2',
        'group': 'category',
        'code': 'test2',
        'label': 'Test2',
        'is_active': 'false',
      };

      expect(TaxonomyDTO.fromJson(jsonTrue).isActive, true);
      expect(TaxonomyDTO.fromJson(jsonFalse).isActive, false);
    });

    test('toJson should produce valid JSON', () {
      const dto = TaxonomyDTO(
        id: '123',
        groupValue: 'governorate',
        code: 'BGD',
        label: 'بغداد',
        labelEn: 'Baghdad',
        sortOrder: 1,
      );

      final json = dto.toJson();

      expect(json['id'], '123');
      expect(json['group'], 'governorate');
      expect(json['code'], 'BGD');
      expect(json['label'], 'بغداد');
      expect(json['label_en'], 'Baghdad');
      expect(json['sort_order'], 1);
      expect(json['is_active'], true);
    });

    test('toEntity should convert to Taxonomy entity', () {
      final dto = TaxonomyDTO(
        id: '123',
        groupValue: 'governorate',
        code: 'BGD',
        label: 'بغداد',
        labelEn: 'Baghdad',
        sortOrder: 1,
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024, 1, 2),
      );

      final entity = dto.toEntity();

      expect(entity.id, '123');
      expect(entity.group, TaxonomyGroup.governorate);
      expect(entity.code, 'BGD');
      expect(entity.label, 'بغداد');
      expect(entity.labelEn, 'Baghdad');
      expect(entity.isActive, true);
    });

    test('fromEntity should convert from Taxonomy entity', () {
      final now = DateTime.now();
      final entity = TaxonomyDTO(
        id: '123',
        groupValue: 'category',
        code: 'orphan',
        label: 'يتيم',
        createdAt: now,
        updatedAt: now,
      ).toEntity();

      final dto = TaxonomyDTO.fromEntity(entity);

      expect(dto.id, '123');
      expect(dto.groupValue, 'category');
      expect(dto.code, 'orphan');
      expect(dto.label, 'يتيم');
    });

    test('toDbCompanion should generate collision-safe local id', () {
      const dto = TaxonomyDTO(
        id: '1',
        groupValue: 'governorate',
        code: 'GZA',
        label: 'غزة',
      );

      final companion = dto.toDbCompanion();
      expect(companion.id.value, 'governorate::1');
    });

    test('extractRemoteId should return suffix from local id', () {
      expect(TaxonomyDTO.extractRemoteId('governorate::1'), '1');
      expect(TaxonomyDTO.extractRemoteId('plain-id'), 'plain-id');
      expect(TaxonomyDTO.extractRemoteId(''), '');
    });
  });

  group('TaxonomySyncRequestDTO', () {
    test('toJson should include lastSync when provided', () {
      final request = TaxonomySyncRequestDTO(
        lastSync: DateTime(2024, 1, 1, 12),
      );

      final json = request.toJson();

      expect(json['last_sync'], isNotNull);
    });

    test('toJson should not include lastSync when null', () {
      const request = TaxonomySyncRequestDTO();

      final json = request.toJson();

      expect(json.containsKey('last_sync'), false);
    });

    test('toJson should include group when provided', () {
      const request = TaxonomySyncRequestDTO(
        group: 'governorate',
      );

      final json = request.toJson();

      expect(json['group'], 'governorate');
    });

    test('toJson should include includeDeleted', () {
      const request = TaxonomySyncRequestDTO(
        includeDeleted: false,
      );

      final json = request.toJson();

      expect(json['include_deleted'], false);
    });
  });

  group('TaxonomySyncResponseDTO', () {
    test('fromJson should parse sync response', () {
      final json = {
        'success': true,
        'message': 'تمت المزامنة بنجاح',
        'added': 1,
        'updated': 0,
        'deleted': 1,
        'sync_time': '2024-01-01T12:00:00Z',
        'taxonomies': [
          {'id': '1', 'group': 'category', 'code': 'new', 'label': 'جديد'},
        ],
      };

      final response = TaxonomySyncResponseDTO.fromJson(json);

      expect(response.success, true);
      expect(response.message, 'تمت المزامنة بنجاح');
      expect(response.added, 1);
      expect(response.updated, 0);
      expect(response.deleted, 1);
      expect(response.taxonomies?.length, 1);
    });

    test('fromJson should handle response without taxonomies', () {
      final json = {
        'success': true,
        'added': 2,
        'updated': 0,
        'deleted': 0,
      };

      final response = TaxonomySyncResponseDTO.fromJson(json);

      expect(response.success, true);
      expect(response.added, 2);
      expect(response.taxonomies, isNull);
    });

    test('toSyncResult should convert to TaxonomySyncResult', () {
      final dto = TaxonomySyncResponseDTO(
        success: true,
        message: 'Done',
        added: 1,
        updated: 2,
        deleted: 3,
        syncTime: DateTime.now(),
      );

      final result = dto.toSyncResult();

      expect(result.success, true);
      expect(result.addedCount, 1);
      expect(result.updatedCount, 2);
      expect(result.deletedCount, 3);
    });

    test('toJson should produce valid JSON', () {
      final dto = TaxonomySyncResponseDTO(
        success: true,
        added: 5,
        updated: 3,
        deleted: 1,
        message: 'Synced',
        syncTime: DateTime(2024),
      );

      final json = dto.toJson();

      expect(json['success'], true);
      expect(json['added'], 5);
      expect(json['updated'], 3);
      expect(json['deleted'], 1);
      expect(json['message'], 'Synced');
    });
  });

  group('TaxonomyResponseDTO', () {
    test('fromJson should parse nested data.item payload', () {
      final json = {
        'success': true,
        'message': 'Item retrieved successfully',
        'data': {
          'category': {
            'slug': 'provinces',
          },
          'item': {
            'id': 1,
            'name': 'غزة',
            'code': '1',
          },
        },
      };

      final response = TaxonomyResponseDTO.fromJson(json);

      expect(response.success, true);
      expect(response.data.id, '1');
      expect(response.data.label, 'غزة');
      expect(response.data.groupValue, 'governorate');
    });
  });

  group('TaxonomiesResponseDTO.fromSyncAllJson', () {
    test('parses nested categories map format', () {
      final json = {
        'success': true,
        'data': {
          'categories': {
            'social-status': {
              'label_ar': 'الحالة الاجتماعية',
              'items': [
                {'id': 1, 'name': 'متزوج'},
                {'id': 2, 'name': 'أعزب'},
              ],
            },
          },
        },
      };

      final dto = TaxonomiesResponseDTO.fromSyncAllJson(json);

      expect(dto.success, true);
      expect(dto.data, hasLength(2));
      expect(dto.data.first.groupValue, 'marital_status');
    });

    test('parses flat list fallback format', () {
      final json = {
        'success': true,
        'data': [
          {
            'id': 10,
            'group': 'gender',
            'code': 'male',
            'label': 'ذكر',
            'is_active': 1,
          },
          {
            'id': 11,
            'group': 'gender',
            'code': 'female',
            'label': 'أنثى',
            'is_active': 1,
          },
        ],
      };

      final dto = TaxonomiesResponseDTO.fromSyncAllJson(json);

      expect(dto.success, true);
      expect(dto.data, hasLength(2));
      expect(dto.data.first.groupValue, 'gender');
    });

    test('maps backend API documented slugs to app groups', () {
      final json = {
        'success': true,
        'data': {
          'categories': {
            'relations': {
              'items': [
                {'id': 1, 'name': 'أخ'},
              ],
            },
            'provinces': {
              'items': [
                {'id': 2, 'name': 'غزة'},
              ],
            },
            'cities': {
              'items': [
                {'id': 12, 'name': 'غزة المدينة'},
              ],
            },
            'accommodation-types': {
              'items': [
                {'id': 3, 'name': 'شقة'},
              ],
            },
            'guarantee-types': {
              'items': [
                {'id': 4, 'name': 'كفالة فردية'},
              ],
            },
            'document-types': {
              'items': [
                {'id': 5, 'name': 'هوية شخصية'},
              ],
            },
            'bank-names': {
              'items': [
                {'id': 6, 'name': 'بنك فلسطين'},
              ],
            },
            'currencies': {
              'items': [
                {'id': 7, 'name': 'شيكل'},
              ],
            },
            'death-reasons': {
              'items': [
                {'id': 8, 'name': 'مرض'},
              ],
            },
          },
        },
      };

      final dto = TaxonomiesResponseDTO.fromSyncAllJson(json);

      expect(dto.data.where((item) => item.groupValue == 'relationship').length, 1);
      expect(dto.data.where((item) => item.groupValue == 'governorate').length, 1);
      expect(dto.data.where((item) => item.groupValue == 'city').length, 1);
      expect(dto.data.where((item) => item.groupValue == 'housing_type').length, 1);
      expect(dto.data.where((item) => item.groupValue == 'guarantee_type').length, 1);
      expect(dto.data.where((item) => item.groupValue == 'document_type').length, 1);
      expect(dto.data.where((item) => item.groupValue == 'bank_name').length, 1);
      expect(dto.data.where((item) => item.groupValue == 'currency').length, 1);
      expect(dto.data.where((item) => item.groupValue == 'death_reason').length, 1);
    });

    test('parses scalar map items under category data', () {
      final json = {
        'success': true,
        'data': {
          'categories': {
            'marital-statuses': {
              'label_ar': 'الحالة الاجتماعية',
              'count': 2,
              'items': {
                '1': 'أعزب',
                '2': 'متزوج',
              },
            },
          },
        },
      };

      final dto = TaxonomiesResponseDTO.fromSyncAllJson(json);

      expect(dto.success, true);
      expect(dto.data, hasLength(2));
      expect(dto.data.every((item) => item.groupValue == 'marital_status'), true);
      expect(dto.data.map((item) => item.label).toSet(), containsAll({'أعزب', 'متزوج'}));
    });

    test('keeps outer category group even when item category field points to request-statuses', () {
      final json = {
        'success': true,
        'data': {
          'categories': {
            'categories': {
              'label_ar': 'فئات المستفيد',
              'items': [
                {
                  'id': 1,
                  'name': 'يتيم',
                  'category': 'request-statuses',
                },
              ],
            },
          },
        },
      };

      final dto = TaxonomiesResponseDTO.fromSyncAllJson(json);

      expect(dto.data, hasLength(1));
      expect(dto.data.first.groupValue, 'category');
    });

    test('keeps outer request-statuses group even when item category field points to categories', () {
      final json = {
        'success': true,
        'data': {
          'categories': {
            'request-statuses': {
              'label_ar': 'حالة الطلب',
              'items': [
                {
                  'id': 9,
                  'name': 'قيد الدراسة',
                  'category': 'categories',
                },
              ],
            },
          },
        },
      };

      final dto = TaxonomiesResponseDTO.fromSyncAllJson(json);

      expect(dto.data, hasLength(1));
      expect(dto.data.first.groupValue, 'beneficiary_status');
    });
  });
}
