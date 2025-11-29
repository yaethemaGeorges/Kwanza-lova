import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class MatchesRecord extends FirestoreRecord {
  MatchesRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "matchId" field.
  String? _matchId;
  String get matchId => _matchId ?? '';
  bool hasMatchId() => _matchId != null;

  // "user1Id" field.
  String? _user1Id;
  String get user1Id => _user1Id ?? '';
  bool hasUser1Id() => _user1Id != null;

  // "user2Id" field.
  String? _user2Id;
  String get user2Id => _user2Id ?? '';
  bool hasUser2Id() => _user2Id != null;

  // "user1Name" field.
  String? _user1Name;
  String get user1Name => _user1Name ?? '';
  bool hasUser1Name() => _user1Name != null;

  // "user2Name" field.
  String? _user2Name;
  String get user2Name => _user2Name ?? '';
  bool hasUser2Name() => _user2Name != null;

  // "user1PhotoUrl" field.
  String? _user1PhotoUrl;
  String get user1PhotoUrl => _user1PhotoUrl ?? '';
  bool hasUser1PhotoUrl() => _user1PhotoUrl != null;

  // "user2PhotoUrl" field.
  String? _user2PhotoUrl;
  String get user2PhotoUrl => _user2PhotoUrl ?? '';
  bool hasUser2PhotoUrl() => _user2PhotoUrl != null;

  // "matchedAt" field.
  DateTime? _matchedAt;
  DateTime? get matchedAt => _matchedAt;
  bool hasMatchedAt() => _matchedAt != null;

  // "isActive" field.
  bool? _isActive;
  bool get isActive => _isActive ?? false;
  bool hasIsActive() => _isActive != null;

  // "lastMessage" field.
  String? _lastMessage;
  String get lastMessage => _lastMessage ?? '';
  bool hasLastMessage() => _lastMessage != null;

  // "lastMessageAt" field.
  DateTime? _lastMessageAt;
  DateTime? get lastMessageAt => _lastMessageAt;
  bool hasLastMessageAt() => _lastMessageAt != null;

  // "createdBy" field.
  String? _createdBy;
  String get createdBy => _createdBy ?? '';
  bool hasCreatedBy() => _createdBy != null;

  // "matchType" field.
  String? _matchType;
  String get matchType => _matchType ?? '';
  bool hasMatchType() => _matchType != null;

  void _initializeFields() {
    _matchId = snapshotData['matchId'] as String?;
    _user1Id = snapshotData['user1Id'] as String?;
    _user2Id = snapshotData['user2Id'] as String?;
    _user1Name = snapshotData['user1Name'] as String?;
    _user2Name = snapshotData['user2Name'] as String?;
    _user1PhotoUrl = snapshotData['user1PhotoUrl'] as String?;
    _user2PhotoUrl = snapshotData['user2PhotoUrl'] as String?;
    _matchedAt = snapshotData['matchedAt'] as DateTime?;
    _isActive = snapshotData['isActive'] as bool?;
    _lastMessage = snapshotData['lastMessage'] as String?;
    _lastMessageAt = snapshotData['lastMessageAt'] as DateTime?;
    _createdBy = snapshotData['createdBy'] as String?;
    _matchType = snapshotData['matchType'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('matches');

  static Stream<MatchesRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => MatchesRecord.fromSnapshot(s));

  static Future<MatchesRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => MatchesRecord.fromSnapshot(s));

  static MatchesRecord fromSnapshot(DocumentSnapshot snapshot) =>
      MatchesRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static MatchesRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      MatchesRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'MatchesRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is MatchesRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createMatchesRecordData({
  String? matchId,
  String? user1Id,
  String? user2Id,
  String? user1Name,
  String? user2Name,
  String? user1PhotoUrl,
  String? user2PhotoUrl,
  DateTime? matchedAt,
  bool? isActive,
  String? lastMessage,
  DateTime? lastMessageAt,
  String? createdBy,
  String? matchType,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'matchId': matchId,
      'user1Id': user1Id,
      'user2Id': user2Id,
      'user1Name': user1Name,
      'user2Name': user2Name,
      'user1PhotoUrl': user1PhotoUrl,
      'user2PhotoUrl': user2PhotoUrl,
      'matchedAt': matchedAt,
      'isActive': isActive,
      'lastMessage': lastMessage,
      'lastMessageAt': lastMessageAt,
      'createdBy': createdBy,
      'matchType': matchType,
    }.withoutNulls,
  );

  return firestoreData;
}

class MatchesRecordDocumentEquality implements Equality<MatchesRecord> {
  const MatchesRecordDocumentEquality();

  @override
  bool equals(MatchesRecord? e1, MatchesRecord? e2) {
    return e1?.matchId == e2?.matchId &&
        e1?.user1Id == e2?.user1Id &&
        e1?.user2Id == e2?.user2Id &&
        e1?.user1Name == e2?.user1Name &&
        e1?.user2Name == e2?.user2Name &&
        e1?.user1PhotoUrl == e2?.user1PhotoUrl &&
        e1?.user2PhotoUrl == e2?.user2PhotoUrl &&
        e1?.matchedAt == e2?.matchedAt &&
        e1?.isActive == e2?.isActive &&
        e1?.lastMessage == e2?.lastMessage &&
        e1?.lastMessageAt == e2?.lastMessageAt &&
        e1?.createdBy == e2?.createdBy &&
        e1?.matchType == e2?.matchType;
  }

  @override
  int hash(MatchesRecord? e) => const ListEquality().hash([
        e?.matchId,
        e?.user1Id,
        e?.user2Id,
        e?.user1Name,
        e?.user2Name,
        e?.user1PhotoUrl,
        e?.user2PhotoUrl,
        e?.matchedAt,
        e?.isActive,
        e?.lastMessage,
        e?.lastMessageAt,
        e?.createdBy,
        e?.matchType
      ]);

  @override
  bool isValidKey(Object? o) => o is MatchesRecord;
}
