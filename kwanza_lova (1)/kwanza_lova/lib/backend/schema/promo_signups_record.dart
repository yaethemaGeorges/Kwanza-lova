import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class PromoSignupsRecord extends FirestoreRecord {
  PromoSignupsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "signupId" field.
  String? _signupId;
  String get signupId => _signupId ?? '';
  bool hasSignupId() => _signupId != null;

  // "userId" field.
  String? _userId;
  String get userId => _userId ?? '';
  bool hasUserId() => _userId != null;

  // "promoCode" field.
  String? _promoCode;
  String get promoCode => _promoCode ?? '';
  bool hasPromoCode() => _promoCode != null;

  // "influencerId" field.
  String? _influencerId;
  String get influencerId => _influencerId ?? '';
  bool hasInfluencerId() => _influencerId != null;

  // "signupDate" field.
  DateTime? _signupDate;
  DateTime? get signupDate => _signupDate;
  bool hasSignupDate() => _signupDate != null;

  // "isActive" field.
  bool? _isActive;
  bool get isActive => _isActive ?? false;
  bool hasIsActive() => _isActive != null;

  // "userStatus" field.
  String? _userStatus;
  String get userStatus => _userStatus ?? '';
  bool hasUserStatus() => _userStatus != null;

  // "lastActiveDate" field.
  String? _lastActiveDate;
  String get lastActiveDate => _lastActiveDate ?? '';
  bool hasLastActiveDate() => _lastActiveDate != null;

  // "adRevenueGenerated" field.
  double? _adRevenueGenerated;
  double get adRevenueGenerated => _adRevenueGenerated ?? 0.0;
  bool hasAdRevenueGenerated() => _adRevenueGenerated != null;

  // "isPremium" field.
  bool? _isPremium;
  bool get isPremium => _isPremium ?? false;
  bool hasIsPremium() => _isPremium != null;

  // "premiumStartDate" field.
  DateTime? _premiumStartDate;
  DateTime? get premiumStartDate => _premiumStartDate;
  bool hasPremiumStartDate() => _premiumStartDate != null;

  // "location" field.
  String? _location;
  String get location => _location ?? '';
  bool hasLocation() => _location != null;

  // "verifiedAt" field.
  DateTime? _verifiedAt;
  DateTime? get verifiedAt => _verifiedAt;
  bool hasVerifiedAt() => _verifiedAt != null;

  void _initializeFields() {
    _signupId = snapshotData['signupId'] as String?;
    _userId = snapshotData['userId'] as String?;
    _promoCode = snapshotData['promoCode'] as String?;
    _influencerId = snapshotData['influencerId'] as String?;
    _signupDate = snapshotData['signupDate'] as DateTime?;
    _isActive = snapshotData['isActive'] as bool?;
    _userStatus = snapshotData['userStatus'] as String?;
    _lastActiveDate = snapshotData['lastActiveDate'] as String?;
    _adRevenueGenerated =
        castToType<double>(snapshotData['adRevenueGenerated']);
    _isPremium = snapshotData['isPremium'] as bool?;
    _premiumStartDate = snapshotData['premiumStartDate'] as DateTime?;
    _location = snapshotData['location'] as String?;
    _verifiedAt = snapshotData['verifiedAt'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('promo_signups');

  static Stream<PromoSignupsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => PromoSignupsRecord.fromSnapshot(s));

  static Future<PromoSignupsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => PromoSignupsRecord.fromSnapshot(s));

  static PromoSignupsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      PromoSignupsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static PromoSignupsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      PromoSignupsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'PromoSignupsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is PromoSignupsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createPromoSignupsRecordData({
  String? signupId,
  String? userId,
  String? promoCode,
  String? influencerId,
  DateTime? signupDate,
  bool? isActive,
  String? userStatus,
  String? lastActiveDate,
  double? adRevenueGenerated,
  bool? isPremium,
  DateTime? premiumStartDate,
  String? location,
  DateTime? verifiedAt,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'signupId': signupId,
      'userId': userId,
      'promoCode': promoCode,
      'influencerId': influencerId,
      'signupDate': signupDate,
      'isActive': isActive,
      'userStatus': userStatus,
      'lastActiveDate': lastActiveDate,
      'adRevenueGenerated': adRevenueGenerated,
      'isPremium': isPremium,
      'premiumStartDate': premiumStartDate,
      'location': location,
      'verifiedAt': verifiedAt,
    }.withoutNulls,
  );

  return firestoreData;
}

class PromoSignupsRecordDocumentEquality
    implements Equality<PromoSignupsRecord> {
  const PromoSignupsRecordDocumentEquality();

  @override
  bool equals(PromoSignupsRecord? e1, PromoSignupsRecord? e2) {
    return e1?.signupId == e2?.signupId &&
        e1?.userId == e2?.userId &&
        e1?.promoCode == e2?.promoCode &&
        e1?.influencerId == e2?.influencerId &&
        e1?.signupDate == e2?.signupDate &&
        e1?.isActive == e2?.isActive &&
        e1?.userStatus == e2?.userStatus &&
        e1?.lastActiveDate == e2?.lastActiveDate &&
        e1?.adRevenueGenerated == e2?.adRevenueGenerated &&
        e1?.isPremium == e2?.isPremium &&
        e1?.premiumStartDate == e2?.premiumStartDate &&
        e1?.location == e2?.location &&
        e1?.verifiedAt == e2?.verifiedAt;
  }

  @override
  int hash(PromoSignupsRecord? e) => const ListEquality().hash([
        e?.signupId,
        e?.userId,
        e?.promoCode,
        e?.influencerId,
        e?.signupDate,
        e?.isActive,
        e?.userStatus,
        e?.lastActiveDate,
        e?.adRevenueGenerated,
        e?.isPremium,
        e?.premiumStartDate,
        e?.location,
        e?.verifiedAt
      ]);

  @override
  bool isValidKey(Object? o) => o is PromoSignupsRecord;
}
