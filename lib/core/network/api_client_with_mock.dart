import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';
import 'mock_api_server.dart';
import '../providers/providers.dart';

/// 🎭 API Client with Mock Support
///
/// يدعم التبديل بين API حقيقي و Mock Server محلي
/// مفيد للتطوير والتجربة قبل توفر API حقيقي
class ApiClientWithMock {
  final ApiClient? _realClient;
  final MockApiServer? _mockServer;
  final bool _useMock;

  ApiClientWithMock({
    ApiClient? realClient,
    MockApiServer? mockServer,
    required bool useMock,
  })  : _realClient = realClient,
        _mockServer = mockServer,
        _useMock = useMock;

  /// التحقق من أنه في وضع Mock
  bool get isMockMode => _useMock;

  // ============================================================================
  // BENEFICIARIES
  // ============================================================================

  Future<Map<String, dynamic>> syncBeneficiaries(
    List<Map<String, dynamic>> beneficiaries,
  ) async {
    if (_useMock) {
      if (_mockServer == null) {
        throw Exception('Mock server not initialized');
      }
      return await _mockServer.syncBeneficiaries(beneficiaries);
    } else {
      if (_realClient == null) {
        throw Exception('Real API client not initialized');
      }
      return await _realClient.syncBeneficiaries(beneficiaries);
    }
  }

  Future<Map<String, dynamic>> fetchBeneficiaries({
    DateTime? since,
    int? limit,
    int? offset,
  }) async {
    if (_useMock) {
      if (_mockServer == null) {
        throw Exception('Mock server not initialized');
      }
      return await _mockServer.fetchBeneficiaries(
        since: since,
        limit: limit,
        offset: offset,
      );
    } else {
      if (_realClient == null) {
        throw Exception('Real API client not initialized');
      }
      // Call real API when available
      throw UnimplementedError('Real API not implemented yet');
    }
  }

  Future<Map<String, dynamic>> deleteBeneficiary(String serverId) async {
    if (_useMock) {
      if (_mockServer == null) {
        throw Exception('Mock server not initialized');
      }
      return await _mockServer.deleteBeneficiary(serverId);
    } else {
      if (_realClient == null) {
        throw Exception('Real API client not initialized');
      }
      // Call real API when available
      throw UnimplementedError('Real API not implemented yet');
    }
  }

  // ============================================================================
  // CONFLICTS
  // ============================================================================

  Future<Map<String, dynamic>> resolveConflict({
    required String localId,
    required String serverId,
    required String resolution,
    Map<String, dynamic>? mergedData,
  }) async {
    if (_useMock) {
      if (_mockServer == null) {
        throw Exception('Mock server not initialized');
      }
      return await _mockServer.resolveConflict(
        localId: localId,
        serverId: serverId,
        resolution: resolution,
        mergedData: mergedData,
      );
    } else {
      // Call real API when available
      throw UnimplementedError('Real API not implemented yet');
    }
  }

  // ============================================================================
  // SERVER STATUS
  // ============================================================================

  Future<Map<String, dynamic>> getServerStatus() async {
    if (_useMock) {
      if (_mockServer == null) {
        throw Exception('Mock server not initialized');
      }
      return await _mockServer.getServerStatus();
    } else {
      if (_realClient == null) {
        throw Exception('Real API client not initialized');
      }
      // Call real API when available
      throw UnimplementedError('Real API not implemented yet');
    }
  }

  // ============================================================================
  // MOCK SERVER CONTROLS
  // ============================================================================

  /// متاح فقط في وضع Mock
  Future<void> clearMockServerData() async {
    if (!_useMock || _mockServer == null) {
      throw Exception('Not in mock mode');
    }
    await _mockServer.clearServerData();
  }

  /// متاح فقط في وضع Mock
  Future<void> seedMockTestData() async {
    if (!_useMock || _mockServer == null) {
      throw Exception('Not in mock mode');
    }
    await _mockServer.seedTestData();
  }

  /// تعديل إعدادات Mock Server
  void configureMockServer({
    bool? simulateNetworkDelay,
    int? minDelayMs,
    int? maxDelayMs,
    double? errorRate,
    bool? simulateConflicts,
  }) {
    if (!_useMock || _mockServer == null) {
      throw Exception('Not in mock mode');
    }

    if (simulateNetworkDelay != null) {
      _mockServer.simulateNetworkDelay = simulateNetworkDelay;
    }
    if (minDelayMs != null) {
      _mockServer.minDelayMs = minDelayMs;
    }
    if (maxDelayMs != null) {
      _mockServer.maxDelayMs = maxDelayMs;
    }
    if (errorRate != null) {
      _mockServer.errorRate = errorRate;
    }
    if (simulateConflicts != null) {
      _mockServer.simulateConflicts = simulateConflicts;
    }
  }
}

// ============================================================================
// PROVIDERS
// ============================================================================

/// Provider للـ Mock Server
final mockApiServerProvider = FutureProvider<MockApiServer>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return MockApiServer(prefs);
});

/// Provider للـ API Client مع دعم Mock
final apiClientWithMockProvider = FutureProvider<ApiClientWithMock>((
  ref,
) async {
  // اقرأ من الإعدادات: هل نستخدم Mock؟
  final prefs = await SharedPreferences.getInstance();
  final useMock =
      prefs.getBool('use_mock_api') ?? true; // افتراضياً نستخدم Mock

  if (useMock) {
    final mockServer = await ref.watch(mockApiServerProvider.future);
    return ApiClientWithMock(mockServer: mockServer, useMock: true);
  } else {
    final config = await ref.watch(appConfigProvider.future);
    final realClient = ApiClient(config);
    return ApiClientWithMock(realClient: realClient, useMock: false);
  }
});

/// Provider للتحكم في وضع Mock
final mockModeProvider = StateProvider<bool>((ref) => true);
