import '../models/estate.dart';

/// Service providing local mock estates for selection in Phase 1.
class EstateService {
  static const List<Estate> _mockEstates = [
    Estate(
      id: 'est_001',
      name: 'Pinecrest Royal Estate',
      location: 'Maitama District, Phase 2',
      code: 'PRE-01',
      unitsCount: 140,
    ),
    Estate(
      id: 'est_002',
      name: 'Victoria Garden Sanctuary',
      location: 'Guzape Hills Expressway',
      code: 'VGS-04',
      unitsCount: 220,
    ),
    Estate(
      id: 'est_003',
      name: 'Horizon Hill Residences',
      location: 'Asokoro Extension, Boulevard 3',
      code: 'HHR-09',
      unitsCount: 85,
    ),
    Estate(
      id: 'est_004',
      name: 'Serene Palms Community',
      location: 'Jabi Lakeview Drive',
      code: 'SPC-12',
      unitsCount: 310,
    ),
    Estate(
      id: 'est_005',
      name: 'Oakridge Manor & Courts',
      location: 'Kado Green District',
      code: 'OMC-07',
      unitsCount: 95,
    ),
  ];

  List<Estate> getAllEstates() {
    return List.unmodifiable(_mockEstates);
  }

  List<Estate> searchEstates(String query) {
    if (query.trim().isEmpty) {
      return getAllEstates();
    }
    final normalized = query.trim().toLowerCase();
    return _mockEstates.where((estate) {
      return estate.name.toLowerCase().contains(normalized) ||
          estate.location.toLowerCase().contains(normalized) ||
          estate.code.toLowerCase().contains(normalized);
    }).toList();
  }
}
