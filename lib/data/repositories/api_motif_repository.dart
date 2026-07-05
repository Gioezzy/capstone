import 'dart:io';

import 'package:capstone/core/network/api_client.dart';
import 'package:capstone/core/network/api_endpoints.dart';
import 'package:capstone/domain/models/models.dart';
import 'package:capstone/domain/repositories/motif_repository.dart';
import 'package:dio/dio.dart' as dio_client;
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

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
    
    
    final json = _unwrap(data) as Map<String, dynamic>;
    

    // New backend contract: {"motif": {...}, "used_seed": ..., "history_id": ...}.
    if (json['motif'] is Map<String, dynamic>) {
      return GenerateResult.fromJson(json);
    }

    
    // Backward-compatible fallback for the earlier backend response that
    // returned motif fields directly inside "data".
    final historyId = json['history_id'] as String;
    return GenerateResult.fromJson({
      'motif': {
        'id': json['id'],
        'history_id': historyId,
        'category_id': json['category_id'],
        'image_url': json['image_url'],
        'created_at': json['created_at'],
        'title': json['title'],
      },
      'used_seed': request.noiseSeed ?? 0,
      'history_id': historyId,
    });
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
    final url = json['url'] as String;
    final fileName = json['file_name'] as String;

    try {
      // Minta izin penyimpanan terlebih dahulu (dibungkus try-catch agar tidak crash jika belum full rebuild)
      try {
        await Permission.storage.request();
      } catch (pe) {
        debugPrint('WARNING: Gagal meminta izin storage: $pe');
      }

      final dio = dio_client.Dio();
      
      Directory? dir;
      if (Platform.isAndroid) {
        // Coba simpan ke folder Download publik Android
        dir = Directory('/storage/emulated/0/Download');
        if (!await dir.exists()) {
          dir = await getExternalStorageDirectory();
        }
      } else {
        dir = await getDownloadsDirectory();
      }

      // Jika direktori ditemukan, lakukan pengunduhan biner file secara nyata
      if (dir != null) {
        final savePath = '${dir.path}/$fileName';
        await dio.download(url, savePath);
        debugPrint('INFO: File berhasil diunduh ke $savePath');
      } else {
        throw Exception('Direktori penyimpanan tidak tersedia');
      }
    } catch (e) {
      debugPrint('ERROR: Gagal mengunduh file: $e');
      throw Exception('Gagal menyimpan file ke perangkat lokal: $e');
    }

    return MotifImage(
      id: motifId,
      generatedMotifId: motifId,
      url: url,
      fileName: fileName,
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
