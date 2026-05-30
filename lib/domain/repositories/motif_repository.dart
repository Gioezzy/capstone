import 'package:capstone/domain/models/models.dart';

enum HistorySort { newest, oldest }

// Single contract shared by mock and api implementations.
abstract interface class MotifRepository {
  Future<List<MotifCategory>> getCategories();
  Future<MotifCategory> getCategory(String id);
  Future<GenerateResult> generateMotif(GenerateRequest request);
  Future<List<GenerateHistory>> getHistories({
    int page = 1,
    int pageSize = 20,
    String? categoryId,
    HistorySort sort = HistorySort.newest,
  });
  Future<GeneratedMotif> getMotif(String id);
  Future<GenerateHistory> saveToHistory(String motifId);
  Future<MotifImage> getDownloadInfo(String motifId);
  Future<void> deleteHistory(String id);
}
