import 'package:capstone/core/network/api_client.dart';
import 'package:capstone/core/network/api_endpoints.dart';
import 'package:capstone/domain/models/models.dart';
import 'package:capstone/domain/repositories/motif_repository.dart';

// REST implementation. Maps endpoints <-> models per the API contract.
// Errors surface as AppException from ApiClient. Wired later via AppConfig.
class ApiMotifRepository implements MotifRepository {
  final ApiClient _client;

  ApiMotifRepository(this._client);

  @override
  Future<List<MotifCategory>> getCategories() async {
    final data = await _client.get(ApiEndpoints.categories);
    final list = _unwrap(data) as List;
    return list
        .map((e) => MotifCategory.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<MotifCategory> getCategory(String id) async {
    final data = await _client.get(ApiEndpoints.categoryById(id));
    return MotifCategory.fromJson(_unwrap(data) as Map<String, dynamic>);
  }

  @override
  Future<GenerateResult> generateMotif(GenerateRequest request) async {
    final data = await _client.post(
      ApiEndpoints.generate,
      data: request.toJson(),
    );
    return GenerateResult.fromJson(_unwrap(data) as Map<String, dynamic>);
  }

  @override
  Future<List<GenerateHistory>> getHistories({
    int page = 1,
    int pageSize = 20,
    String? categoryId,
    HistorySort sort = HistorySort.newest,
  }) async {
    final data = await _client.get(
      ApiEndpoints.histories,
      queryParameters: {
        'page': page,
        'page_size': pageSize,
        'sort': _sortValue(sort),
        if (categoryId != null) 'category_id': categoryId,
      },
    );
    final list = _unwrap(data) as List;
    return list
        .map((e) => GenerateHistory.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<GeneratedMotif> getMotif(String id) async {
    final data = await _client.get(ApiEndpoints.motifById(id));
    return GeneratedMotif.fromJson(_unwrap(data) as Map<String, dynamic>);
  }

  @override
  Future<GenerateHistory> saveToHistory(String motifId) async {
    final data = await _client.post(ApiEndpoints.saveMotif(motifId));
    return GenerateHistory.fromJson(_unwrap(data) as Map<String, dynamic>);
  }

  @override
  Future<MotifImage> getDownloadInfo(String motifId) async {
    final data = await _client.get(ApiEndpoints.downloadMotif(motifId));
    final json = _unwrap(data) as Map<String, dynamic>;
    return MotifImage(
      id: motifId,
      generatedMotifId: motifId,
      url: json['url'] as String,
      fileName: json['file_name'] as String,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<void> deleteHistory(String id) =>
      _client.delete(ApiEndpoints.deleteHistory(id));

  // Responses are wrapped in {"data": ...}.
  dynamic _unwrap(dynamic data) => (data as Map<String, dynamic>)['data'];

  String _sortValue(HistorySort sort) =>
      sort == HistorySort.newest ? 'created_at_desc' : 'created_at_asc';
}
