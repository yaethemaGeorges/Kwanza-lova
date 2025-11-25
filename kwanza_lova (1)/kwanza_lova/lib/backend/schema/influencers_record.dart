import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class InfluencersRecord extends FirestoreRecord {
  InfluencersRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "influencerId" field.
  String? _influencerId;
  String get influencerId => _influencerId ?? '';
  bool hasInfluencerId() => _influencerId != null;

  // "name" field.
  String? _name;
  String get name => _name ?? '';
  bool hasName() => _name != null;

  // "email" field.
  String? _email;
  String get email => _email ?? '';
  bool hasEmail() => _email != null;

  // "phoneNumber" field.
  String? _phoneNumber;
  String get phoneNumber => _phoneNumber ?? '';
  bool hasPhoneNumber() => _phoneNumber != null;

  // "promoCode" field.
  String? _promoCode;
  String get promoCode => _promoCode ?? '';
  bool hasPromoCode() => _promoCode != null;

  // "codeCreatedAt" field.
  DateTime? _codeCreatedAt;
  DateTime? get codeCreatedAt => _codeCreatedAt;
  bool hasCodeCreatedAt() => _codeCreatedAt != null;

  // "codeExpiresAt" field.
  DateTime? _codeExpiresAt;
  DateTime? get codeExpiresAt => _codeExpiresAt;
  bool hasCodeExpiresAt() => _codeExpiresAt != null;

  // "isActive" field.
  bool? _isActive;
  bool get isActive => _isActive ?? false;
  bool hasIsActive() => _isActive != null;

  // "tier" field.
  String? _tier;
  String get tier => _tier ?? '';
  bool hasTier() => _tier != null;

  // "stats" field.
  StatsStruct? _stats;
  StatsStruct get stats => _stats ?? StatsStruct();
  bool hasStats() => _stats != null;

  // "createdAt" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  // "lastUpdatedAt" field.
  DateTime? _lastUpdatedAt;
  DateTime? get lastUpdatedAt => _lastUpdatedAt;
  bool hasLastUpdatedAt() => _lastUpdatedAt != null;

  void _initializeFields() {
    _influencerId = snapshotData['influencerId'] as String?;
    _name = snapshotData['name'] as String?;
    _email = snapshotData['email'] as String?;
    _phoneNumber = snapshotData['phoneNumber'] as String?;
    _promoCode = snapshotData['promoCode'] as String?;
    _codeCreatedAt = snapshotData['codeCreatedAt'] as DateTime?;
    _codeExpiresAt = snapshotData['codeExpiresAt'] as DateTime?;
    _isActive = snapshotData['isActive'] as bool?;
    _tier = snapshotData['tier'] as String?;
    _stats = snapshotData['stats'] is StatsStruct
        ? snapshotData['stats']
        : StatsStruct.maybeFromMap(snapshotData['stats']);
    _createdAt = snapshotData['createdAt'] as DateTime?;
    _lastUpdatedAt = snapshotData['lastUpdatedAt'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('influencers');

  static Stream<InfluencersRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => InfluencersRecord.fromSnapshot(s));

  static Future<InfluencersRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => InfluencersRecord.fromSnapshot(s));

  static InfluencersRecord fromSnapshot(DocumentSnapshot snapshot) =>
      InfluencersRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static InfluencersRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      InfluencersRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'InfluencersRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is InfluencersRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createInfluencersRecordData({
  String? influencerId,
  String? name,
  String? email,
  String? phoneNumber,
  String? promoCode,
  DateTime? codeCreatedAt,
  DateTime? codeExpiresAt,
  bool? isActive,
  String? tier,
  StatsStruct? stats,
  DateTime? createdAt,
  DateTime? lastUpdatedAt,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'influencerId': influencerId,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'promoCode': promoCode,
      'codeCreatedAt': codeCreatedAt,
      'codeExpiresAt': codeExpiresAt,
      'isActive': isActive,
      'tier': tier,
      'stats': StatsStruct().toMap(),
      'createdAt': createdAt,
      'lastUpdatedAt': lastUpdatedAt,
    }.withoutNulls,
  );

  // Handle nested data for "stats" field.
  addStatsStructData(firestoreData, stats, 'stats');

  return firestoreData;
}

class InfluencersRecordDocumentEquality implements Equality<InfluencersRecord> {
  const InfluencersRecordDocumentEquality();

  @override
  bool equals(InfluencersRecord? e1, InfluencersRecord? e2) {
    return e1?.influencerId == e2?.influencerId &&
        e1?.name == e2?.name &&
        e1?.email == e2?.email &&
        e1?.phoneNumber == e2?.phoneNumber &&
        e1?.promoCode == e2?.promoCode &&
        e1?.codeCreatedAt == e2?.codeCreatedAt &&
        e1?.codeExpiresAt == e2?.codeExpiresAt &&
        e1?.isActive == e2?.isActive &&
        e1?.tier == e2?.tier &&
        e1?.stats == e2?.stats &&
        e1?.createdAt == e2?.createdAt &&
        e1?.lastUpdatedAt == e2?.lastUpdatedAt;
  }

  @override
  int hash(InfluencersRecord? e) => const ListEquality().hash([
        e?.influencerId,
        e?.name,
        e?.email,
        e?.phoneNumber,
        e?.promoCode,
        e?.codeCreatedAt,
        e?.codeExpiresAt,
        e?.isActive,
        e?.tier,
        e?.stats,
        e?.createdAt,
        e?.lastUpdatedAt
      ]);

  @override
  bool isValidKey(Object? o) => o is InfluencersRecord;
}
