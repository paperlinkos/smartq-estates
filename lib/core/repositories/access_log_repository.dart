import '../models/access_record.dart';
import '../models/pass_verification_result.dart';

/// Architecture contract for estate gate access logging.
///
/// Records entries authorized by security officers. Designed to be backed by
/// [LocalAccessLogRepository] (in-memory prototype) or a network-backed provider
/// (e.g. Supabase) without requiring changes to calling screens or widgets.
abstract class AccessLogRepository {
  /// Records a confirmed entry into the estate from an authorized [result].
  ///
  /// Throws [ArgumentError] if [result.isAllowed] is false, because only valid
  /// passes may produce an access record.
  AccessRecord recordEntry({
    required PassVerificationResult result,
    required String gateId,
    String? recordedBy,
    DateTime? timestamp,
  });

  /// Returns all records where [enteredAt] matches today's calendar date.
  List<AccessRecord> getTodayEntries();

  /// Returns the most recent entries, sorted newest first, up to [limit].
  List<AccessRecord> getRecentEntries({int limit = 20});

  /// Clears stored records. Primarily used to reset state between test cases.
  void clear();
}

/// In-memory implementation of [AccessLogRepository] for the local prototype.
///
/// Uses a singleton pattern so that records created on [AccessResultScreen]
/// are immediately observable on [SecurityHomeScreen].
class LocalAccessLogRepository implements AccessLogRepository {
  LocalAccessLogRepository._();

  /// The singleton instance shared across the application session.
  static final LocalAccessLogRepository instance = LocalAccessLogRepository._();

  /// Creates an isolated repository instance for unit tests.
  // ignore: prefer_constructors_over_static_methods
  static LocalAccessLogRepository testInstance() => LocalAccessLogRepository._();

  final List<AccessRecord> _records = [];

  @override
  AccessRecord recordEntry({
    required PassVerificationResult result,
    required String gateId,
    String? recordedBy,
    DateTime? timestamp,
  }) {
    if (!result.isAllowed) {
      throw ArgumentError('Cannot record entry for non-valid verification result.');
    }

    final passId = result.passId ??
        result.visitorPass?.passId ??
        result.eventPass?.passId ??
        'UNKNOWN';

    final subjectName = result.visitorPass?.invitation.visitorName ??
        result.eventPass?.event.name ??
        passId;

    final record = AccessRecord.create(
      passId: passId,
      passType: result.passType,
      subjectName: subjectName,
      gateId: gateId,
      recordedBy: recordedBy,
      enteredAt: timestamp,
    );

    _records.add(record);
    return record;
  }

  @override
  List<AccessRecord> getTodayEntries() {
    final now = DateTime.now();
    return _records.where((r) {
      return r.enteredAt.year == now.year &&
          r.enteredAt.month == now.month &&
          r.enteredAt.day == now.day;
    }).toList();
  }

  @override
  List<AccessRecord> getRecentEntries({int limit = 20}) {
    return _records.reversed.take(limit).toList();
  }

  @override
  void clear() {
    _records.clear();
  }
}
