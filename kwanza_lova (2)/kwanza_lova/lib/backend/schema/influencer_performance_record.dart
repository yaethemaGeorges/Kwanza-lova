import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class InfluencerPerformanceRecord extends FirestoreRecord {
  InfluencerPerformanceRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "performanceId" field.
  String? _performanceId;
  String get performanceId => _performanceId ?? '';
  bool hasPerformanceId() => _performanceId != null;

  // "influencerId" field.
  String? _influencerId;
  String get influencerId => _influencerId ?? '';
  bool hasInfluencerId() => _influencerId != null;

  // "date" field.
  DateTime? _date;
  DateTime? get date => _date;
  bool hasDate() => _date != null;

  // "dailySignups" field.
  int? _dailySignups;
  int get dailySignups => _dailySignups ?? 0;
  bool hasDailySignups() => _dailySignups != null;

  // "dailyActiveUsers" field.
  int? _dailyActiveUsers;
  int get dailyActiveUsers => _dailyActiveUsers ?? 0;
  bool hasDailyActiveUsers() => _dailyActiveUsers != null;

  // "dailyAdRevenue" field.
  double? _dailyAdRevenue;
  double get dailyAdRevenue => _dailyAdRevenue ?? 0.0;
  bool hasDailyAdRevenue() => _dailyAdRevenue != null;

  // "dailyPremiumConversions" field.
  int? _dailyPremiumConversions;
  int get dailyPremiumConversions => _dailyPremiumConversions ?? 0;
  bool hasDailyPremiumConversions() => _dailyPremiumConversions != null;

  void _initializeFields() {
    _performanceId = snapshotData['performanceId'] as String?;
    _influencerId = snapshotData['influencerId'] as String?;
    _date = snapshotData['date'] as DateTime?;
    _dailySignups = castToType<int>(snapshotData['dailySignups']);
    _dailyActiveUsers = castToType<int>(snapshotData['dailyActiveUsers']);
    _dailyAdRevenue = castToType<double>(snapshotData['dailyAdRevenue']);
    _dailyPremiumConversions =
        castToType<int>(snapshotData['dailyPremiumConversions']);
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('influencer_performance');

  static Stream<InfluencerPerformanceRecord> getDocument(
          DocumentReference ref) =>
      ref.snapshots().map((s) => InfluencerPerformanceRecord.fromSnapshot(s));

  static Future<InfluencerPerformanceRecord> getDocumentOnce(
          DocumentReference ref) =>
      ref.get().then((s) => InfluencerPerformanceRecord.fromSnapshot(s));

  static InfluencerPerformanceRecord fromSnapshot(DocumentSnapshot snapshot) =>
      InfluencerPerformanceRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static InfluencerPerformanceRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      InfluencerPerformanceRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'InfluencerPerformanceRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is InfluencerPerformanceRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createInfluencerPerformanceRecordData({
  String? performanceId,
  String? influencerId,
  DateTime? date,
  int? dailySignups,
  int? dailyActiveUsers,
  double? dailyAdRevenue,
  int? dailyPremiumConversions,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'performanceId': performanceId,
      'influencerId': influencerId,
      'date': date,
      'dailySignups': dailySignups,
      'dailyActiveUsers': dailyActiveUsers,
      'dailyAdRevenue': dailyAdRevenue,
      'dailyPremiumConversions': dailyPremiumConversions,
    }.withoutNulls,
  );

  return firestoreData;
}

class InfluencerPerformanceRecordDocumentEquality
    implements Equality<InfluencerPerformanceRecord> {
  const InfluencerPerformanceRecordDocumentEquality();

  @override
  bool equals(
      InfluencerPerformanceRecord? e1, InfluencerPerformanceRecord? e2) {
    return e1?.performanceId == e2?.performanceId &&
        e1?.influencerId == e2?.influencerId &&
        e1?.date == e2?.date &&
        e1?.dailySignups == e2?.dailySignups &&
        e1?.dailyActiveUsers == e2?.dailyActiveUsers &&
        e1?.dailyAdRevenue == e2?.dailyAdRevenue &&
        e1?.dailyPremiumConversions == e2?.dailyPremiumConversions;
  }

  @override
  int hash(InfluencerPerformanceRecord? e) => const ListEquality().hash([
        e?.performanceId,
        e?.influencerId,
        e?.date,
        e?.dailySignups,
        e?.dailyActiveUsers,
        e?.dailyAdRevenue,
        e?.dailyPremiumConversions
      ]);

  @override
  bool isValidKey(Object? o) => o is InfluencerPerformanceRecord;
}
