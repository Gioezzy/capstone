import '../../domain/models/models.dart';

// In-memory dummy data for offline UI development. Stores asset path strings
// only; never loads images. No network access.
class MockData {
  MockData._();

  // Local placeholder asset paths (physical files may be absent; MotifCard
  // falls back via errorBuilder).
  static const String _placeholder =
      'assets/images/placeholders/motif_placeholder.png';
  static const List<String> _placeholderImages = [
    'assets/images/placeholders/motif_placeholder.png',
    'assets/images/placeholders/motif_placeholder_1.png',
    'assets/images/placeholders/motif_placeholder_2.png',
    'assets/images/placeholders/motif_placeholder_3.png',
  ];

  static final DateTime _seededAt = DateTime.utc(2023, 10, 1, 7);

  // 9 motif categories matching the API database.
  static final List<MotifCategory> categories = [
    MotifCategory(
      id: 'cat-001',
      name: 'Apel',
      description: 'Motif songket dengan bentuk yang terinspirasi dari buah apel.',
      previewImage: _placeholder,
      createdAt: _seededAt,
      updatedAt: _seededAt,
    ),
    MotifCategory(
      id: 'cat-002',
      name: 'Baragi',
      description: 'Motif Baragi khas tenunan songket tradisional.',
      previewImage: _placeholder,
      createdAt: _seededAt,
      updatedAt: _seededAt,
    ),
    MotifCategory(
      id: 'cat-003',
      name: 'Bungo Satangkai',
      description: 'Motif yang menggambarkan setangkai bunga yang anggun.',
      previewImage: _placeholder,
      createdAt: _seededAt,
      updatedAt: _seededAt,
    ),
    MotifCategory(
      id: 'cat-004',
      name: 'Itiak Pulang Patang',
      description: 'Motif yang terinspirasi dari barisan itik yang berjalan beriringan pulang di petang hari.',
      previewImage: _placeholder,
      createdAt: _seededAt,
      updatedAt: _seededAt,
    ),
    MotifCategory(
      id: 'cat-005',
      name: 'Pucuak Rabuang',
      description: 'Motif menyerupai tunas bambu (pucuk rebung), melambangkan kehidupan yang terus tumbuh.',
      previewImage: _placeholder,
      createdAt: _seededAt,
      updatedAt: _seededAt,
    ),
    MotifCategory(
      id: 'cat-006',
      name: 'Rangkiang',
      description: 'Motif yang terinspirasi dari lumbung padi tradisional Minangkabau.',
      previewImage: _placeholder,
      createdAt: _seededAt,
      updatedAt: _seededAt,
    ),
    MotifCategory(
      id: 'cat-007',
      name: 'Saik Galamai',
      description: 'Motif dengan bentuk irisan galamai (makanan tradisional), melambangkan kearifan.',
      previewImage: _placeholder,
      createdAt: _seededAt,
      updatedAt: _seededAt,
    ),
    MotifCategory(
      id: 'cat-008',
      name: 'Taratai',
      description: 'Motif bunga teratai yang melambangkan keindahan dan kesucian.',
      previewImage: _placeholder,
      createdAt: _seededAt,
      updatedAt: _seededAt,
    ),
    MotifCategory(
      id: 'cat-009',
      name: 'Tulip',
      description: 'Motif modern songket yang mengambil bentuk bunga tulip.',
      previewImage: _placeholder,
      createdAt: _seededAt,
      updatedAt: _seededAt,
    ),
  ];

  // Sample generate history entries (newest first).
  static final List<GenerateHistory> histories = [
    GenerateHistory(
      id: 'gen-042',
      categoryId: 'cat-005',
      categoryName: 'Pucuak Rabuang',
      tag: MotifTag.geometric,
      generatedImage: _placeholder,
      createdAt: DateTime.utc(2023, 10, 24, 14, 30),
    ),
    GenerateHistory(
      id: 'gen-041',
      categoryId: 'cat-004',
      categoryName: 'Itiak Pulang Patang',
      tag: MotifTag.classic,
      generatedImage: _placeholder,
      createdAt: DateTime.utc(2023, 10, 23, 9, 15),
    ),
    GenerateHistory(
      id: 'gen-040',
      categoryId: 'cat-006',
      categoryName: 'Rangkiang',
      tag: MotifTag.floral,
      generatedImage: _placeholder,
      createdAt: DateTime.utc(2023, 10, 22, 18, 5),
    ),
    GenerateHistory(
      id: 'gen-039',
      categoryId: 'cat-003',
      categoryName: 'Bungo Satangkai',
      tag: MotifTag.songket,
      generatedImage: _placeholder,
      createdAt: DateTime.utc(2023, 10, 21, 11, 40),
    ),
    GenerateHistory(
      id: 'gen-038',
      categoryId: 'cat-008',
      categoryName: 'Taratai',
      tag: MotifTag.abstract,
      generatedImage: _placeholder,
      createdAt: DateTime.utc(2023, 10, 20, 8),
    ),
  ];

  // Generated motifs linked to histories above, with display metadata.
  static final List<GeneratedMotif> motifs = [
    GeneratedMotif(
      id: 'mtf-101',
      historyId: 'gen-042',
      categoryId: 'cat-005',
      imageUrl: _placeholder,
      title: 'Songket Pucuak Rabuang',
      baseModel: 'Tradisional Nusantara v2',
      complexity: 0.85,
      primaryColor: 'Monochrome',
      iterations: 50,
      createdAt: DateTime.utc(2023, 10, 24, 14, 30),
    ),
    GeneratedMotif(
      id: 'mtf-100',
      historyId: 'gen-041',
      categoryId: 'cat-004',
      imageUrl: _placeholder,
      title: 'Songket Itiak Pulang Patang',
      baseModel: 'Tradisional Nusantara v2',
      complexity: 0.78,
      primaryColor: 'Monochrome',
      iterations: 40,
      createdAt: DateTime.utc(2023, 10, 23, 9, 15),
    ),
    GeneratedMotif(
      id: 'mtf-099',
      historyId: 'gen-040',
      categoryId: 'cat-006',
      imageUrl: _placeholder,
      title: 'Songket Rangkiang',
      baseModel: 'Tradisional Nusantara v2',
      complexity: 0.82,
      primaryColor: 'Monochrome',
      iterations: 45,
      createdAt: DateTime.utc(2023, 10, 22, 18, 5),
    ),
    GeneratedMotif(
      id: 'mtf-098',
      historyId: 'gen-039',
      categoryId: 'cat-003',
      imageUrl: _placeholder,
      title: 'Songket Bungo Satangkai',
      baseModel: 'Tradisional Nusantara v2',
      complexity: 0.70,
      primaryColor: 'Monochrome',
      iterations: 35,
      createdAt: DateTime.utc(2023, 10, 21, 11, 40),
    ),
    GeneratedMotif(
      id: 'mtf-097',
      historyId: 'gen-038',
      categoryId: 'cat-008',
      imageUrl: _placeholder,
      title: 'Songket Taratai',
      baseModel: 'Tradisional Nusantara v2',
      complexity: 0.90,
      primaryColor: 'Monochrome',
      iterations: 60,
      createdAt: DateTime.utc(2023, 10, 20, 8),
    ),
  ];


  static int _historyCounter = 100;

  // Returns a category by id, or null when not found.
  static MotifCategory? categoryById(String id) {
    for (final category in categories) {
      if (category.id == id) return category;
    }
    return null;
  }

  // Returns a generated motif by id, or null when not found.
  static GeneratedMotif? motifById(String id) {
    for (final motif in motifs) {
      if (motif.id == id) return motif;
    }
    return null;
  }

  // Deterministic: same (categoryId, seed) always yields the same motif,
  // including a deterministic imageUrl (Property 6: seed reproduction).
  static GeneratedMotif motifFor(String categoryId, int seed) {
    final template = motifs[_indexFor(categoryId, seed, motifs.length)];
    final image =
        _placeholderImages[_indexFor(categoryId, seed, _placeholderImages.length)];
    final category = categoryById(categoryId);
    return template.copyWith(
      id: 'mtf-$categoryId-$seed',
      categoryId: categoryId,
      imageUrl: image,
      title: category != null ? 'Songket ${category.name}' : template.title,
    );
  }

  // Returns a fresh history id. Not deterministic across calls, never throws.
  static String nextHistoryId() => 'gen-${_historyCounter++}';

  // Stable hash of (categoryId, seed) mapped into [0, modulo).
  static int _indexFor(String categoryId, int seed, int modulo) {
    if (modulo <= 0) return 0;
    var hash = seed & 0x7fffffff;
    for (final unit in categoryId.codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }
    return hash % modulo;
  }
}
