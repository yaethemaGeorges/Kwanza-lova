import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class MatchNotificationsRecord extends FirestoreRecord {
  MatchNotificationsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "userId" field.
  String? _userId;
  String get userId => _userId ?? '';
  bool hasUserId() => _userId != null;

  // "matchId" field.
  String? _matchId;
  String get matchId => _matchId ?? '';
  bool hasMatchId() => _matchId != null;

  // "matchedWithId" field.
  String? _matchedWithId;
  String get matchedWithId => _matchedWithId ?? '';
  bool hasMatchedWithId() => _matchedWithId != null;

  // "matchedWithName" field.
  String? _matchedWithName;
  String get matchedWithName => _matchedWithName ?? '';
  bool hasMatchedWithName() => _matchedWithName != null;

  // "matchedWithPhotoUrl" field.
  String? _matchedWithPhotoUrl;
  String get matchedWithPhotoUrl => _matchedWithPhotoUrl ?? '';
  bool hasMatchedWithPhotoUrl() => _matchedWithPhotoUrl != null;

  // "notifiedAt" field.
  DateTime? _notifiedAt;
  DateTime? get notifiedAt => _notifiedAt;
  bool hasNotifiedAt() => _notifiedAt != null;

  // "isRead" field.
  bool? _isRead;
  bool get isRead => _isRead ?? false;
  bool hasIsRead() => _isRead != null;

  // "matchType" field.
  String? _matchType;
  String get matchType => _matchType ?? '';
  bool hasMatchType() => _matchType != null;

  void _initializeFields() {
    _userId = snapshotData['userId'] as String?;
    _matchId = snapshotData['matchId'] as String?;
    _matchedWithId = snapshotData['matchedWithId'] as String?;
    _matchedWithName = snapshotData['matchedWithName'] as String?;
    _matchedWithPhotoUrl = snapshotData['matchedWithPhotoUrl'] as String?;
    _notifiedAt = snapshotData['notifiedAt'] as DateTime?;
    _isRead = snapshotData['isRead'] as bool?;
    _matchType = snapshotData['matchType'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('match_notifications');

  static Stream<MatchNotificationsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => MatchNotificationsRecord.fromSnapshot(s));

  static Future<MatchNotificationsRecord> getDocumentOnce(
          DocumentReference ref) =>
      ref.get().then((s) => MatchNotificationsRecord.fromSnapshot(s));

  static MatchNotificationsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      MatchNotificationsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static MatchNotificationsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      MatchNotificationsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'MatchNotificationsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is MatchNotificationsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createMatchNotificationsRecordData({
  String? userId,
  String? matchId,
  String? matchedWithId,
  String? matchedWithName,
  String? matchedWithPhotoUrl,
  DateTime? notifiedAt,
  bool? isRead,
  String? matchType,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'userId': userId,
      'matchId': matchId,
      'matchedWithId': matchedWithId,
      'matchedWithName': matchedWithName,
      'matchedWithPhotoUrl': matchedWithPhotoUrl,
      'notifiedAt': notifiedAt,
      'isRead': isRead,
      'matchType': matchType,
    }.withoutNulls,
  );

  return firestoreData;
}

class MatchNotificationsRecordDocumentEquality
    implements Equality<MatchNotificationsRecord> {
  const MatchNotificationsRecordDocumentEquality();

  @override
  bool equals(MatchNotificationsRecord? e1, MatchNotificationsRecord? e2) {
    return e1?.userId == e2?.userId &&
        e1?.matchId == e2?.matchId &&
        e1?.matchedWithId == e2?.matchedWithId &&
        e1?.matchedWithName == e2?.matchedWithName &&
        e1?.matchedWithPhotoUrl == e2?.matchedWithPhotoUrl &&
        e1?.notifiedAt == e2?.notifiedAt &&
        e1?.isRead == e2?.isRead &&
        e1?.matchType == e2?.matchType;
  }

  @override
  int hash(MatchNotificationsRecord? e) => const ListEquality().hash([
        e?.userId,
        e?.matchId,
        e?.matchedWithId,
        e?.matchedWithName,
        e?.matchedWithPhotoUrl,
        e?.notifiedAt,
        e?.isRead,
        e?.matchType
      ]);

  @override
  bool isValidKey(Object? o) => o is MatchNotificationsRecord;
}
