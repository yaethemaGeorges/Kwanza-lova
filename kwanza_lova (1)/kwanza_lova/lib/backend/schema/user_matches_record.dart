import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class UserMatchesRecord extends FirestoreRecord {
  UserMatchesRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "matchId" field.
  String? _matchId;
  String get matchId => _matchId ?? '';
  bool hasMatchId() => _matchId != null;

  // "userId" field.
  String? _userId;
  String get userId => _userId ?? '';
  bool hasUserId() => _userId != null;

  // "userName" field.
  String? _userName;
  String get userName => _userName ?? '';
  bool hasUserName() => _userName != null;

  // "userPhotoUrl" field.
  String? _userPhotoUrl;
  String get userPhotoUrl => _userPhotoUrl ?? '';
  bool hasUserPhotoUrl() => _userPhotoUrl != null;

  // "matchedAt" field.
  DateTime? _matchedAt;
  DateTime? get matchedAt => _matchedAt;
  bool hasMatchedAt() => _matchedAt != null;

  // "isActive" field.
  bool? _isActive;
  bool get isActive => _isActive ?? false;
  bool hasIsActive() => _isActive != null;

  // "unreadCount" field.
  int? _unreadCount;
  int get unreadCount => _unreadCount ?? 0;
  bool hasUnreadCount() => _unreadCount != null;

  // "matchType" field.
  String? _matchType;
  String get matchType => _matchType ?? '';
  bool hasMatchType() => _matchType != null;

  DocumentReference get parentReference => reference.parent.parent!;

  void _initializeFields() {
    _matchId = snapshotData['matchId'] as String?;
    _userId = snapshotData['userId'] as String?;
    _userName = snapshotData['userName'] as String?;
    _userPhotoUrl = snapshotData['userPhotoUrl'] as String?;
    _matchedAt = snapshotData['matchedAt'] as DateTime?;
    _isActive = snapshotData['isActive'] as bool?;
    _unreadCount = castToType<int>(snapshotData['unreadCount']);
    _matchType = snapshotData['matchType'] as String?;
  }

  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('user_matches')
          : FirebaseFirestore.instance.collectionGroup('user_matches');

  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      parent.collection('user_matches').doc(id);

  static Stream<UserMatchesRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => UserMatchesRecord.fromSnapshot(s));

  static Future<UserMatchesRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => UserMatchesRecord.fromSnapshot(s));

  static UserMatchesRecord fromSnapshot(DocumentSnapshot snapshot) =>
      UserMatchesRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static UserMatchesRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      UserMatchesRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'UserMatchesRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is UserMatchesRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createUserMatchesRecordData({
  String? matchId,
  String? userId,
  String? userName,
  String? userPhotoUrl,
  DateTime? matchedAt,
  bool? isActive,
  int? unreadCount,
  String? matchType,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'matchId': matchId,
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'matchedAt': matchedAt,
      'isActive': isActive,
      'unreadCount': unreadCount,
      'matchType': matchType,
    }.withoutNulls,
  );

  return firestoreData;
}

class UserMatchesRecordDocumentEquality implements Equality<UserMatchesRecord> {
  const UserMatchesRecordDocumentEquality();

  @override
  bool equals(UserMatchesRecord? e1, UserMatchesRecord? e2) {
    return e1?.matchId == e2?.matchId &&
        e1?.userId == e2?.userId &&
        e1?.userName == e2?.userName &&
        e1?.userPhotoUrl == e2?.userPhotoUrl &&
        e1?.matchedAt == e2?.matchedAt &&
        e1?.isActive == e2?.isActive &&
        e1?.unreadCount == e2?.unreadCount &&
        e1?.matchType == e2?.matchType;
  }

  @override
  int hash(UserMatchesRecord? e) => const ListEquality().hash([
        e?.matchId,
        e?.userId,
        e?.userName,
        e?.userPhotoUrl,
        e?.matchedAt,
        e?.isActive,
        e?.unreadCount,
        e?.matchType
      ]);

  @override
  bool isValidKey(Object? o) => o is UserMatchesRecord;
}
