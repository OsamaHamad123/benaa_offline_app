import 'package:drift/drift.dart';

/// 📄 Pagination Result
/// نتيجة الصفحات مع البيانات

class PaginationResult<T> {
  final List<T> items;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int pageSize;
  final bool hasNextPage;
  final bool hasPreviousPage;

  PaginationResult({
    required this.items,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.pageSize,
  })  : hasNextPage = currentPage < totalPages,
        hasPreviousPage = currentPage > 1;

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;
}

/// 📄 Pagination Service
/// خدمة التقسيم إلى صفحات لتحسين الأداء

class PaginationService {
  /// حساب offset من رقم الصفحة
  static int getOffset(int page, int pageSize) {
    return (page - 1) * pageSize;
  }

  /// حساب عدد الصفحات الكلي
  static int getTotalPages(int totalItems, int pageSize) {
    return (totalItems / pageSize).ceil();
  }

  /// إنشاء نتيجة pagination
  static PaginationResult<T> createResult<T>({
    required List<T> items,
    required int currentPage,
    required int totalItems,
    required int pageSize,
  }) {
    return PaginationResult<T>(
      items: items,
      currentPage: currentPage,
      totalPages: getTotalPages(totalItems, pageSize),
      totalItems: totalItems,
      pageSize: pageSize,
    );
  }

  /// تطبيق pagination على query
  static SimpleSelectStatement<Table, Row> applyPagination<Table extends HasResultSet, Row>(
    SimpleSelectStatement<Table, Row> query,
    int page,
    int pageSize,
  ) {
    final offset = getOffset(page, pageSize);
    return query
      ..limit(pageSize, offset: offset);
  }
}

/// 📄 Pagination Parameters
/// معاملات التقسيم إلى صفحات

class PaginationParams {
  final int page;
  final int pageSize;
  final String? searchQuery;
  final Map<String, dynamic>? filters;
  final String? sortBy;
  final bool sortDescending;

  const PaginationParams({
    this.page = 1,
    this.pageSize = 20,
    this.searchQuery,
    this.filters,
    this.sortBy,
    this.sortDescending = false,
  });

  PaginationParams copyWith({
    int? page,
    int? pageSize,
    String? searchQuery,
    Map<String, dynamic>? filters,
    String? sortBy,
    bool? sortDescending,
  }) {
    return PaginationParams(
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      searchQuery: searchQuery ?? this.searchQuery,
      filters: filters ?? this.filters,
      sortBy: sortBy ?? this.sortBy,
      sortDescending: sortDescending ?? this.sortDescending,
    );
  }

  int get offset => PaginationService.getOffset(page, pageSize);
}
