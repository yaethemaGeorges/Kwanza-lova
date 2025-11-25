import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class LikesReceivedRecord extends FirestoreRecord {
  LikesReceivedRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "receiverId" field.
  String? _receiverId;
  String get receiverId => _receiverId ?? '';
  bool hasReceiverId() => _receiverId != null;

  // "giverId" field.
  String? _giverId;
  String get giverId => _giverId ?? '';
  bool hasGiverId() => _giverId != null;

  // "giverName" field.
  String? _giverName;
  String get giverName => _giverName ?? '';
  bool hasGiverName() => _giverName != null;

  // "giverPhotoUrl" field.
  String? _giverPhotoUrl;
  String get giverPhotoUrl => _giverPhotoUrl ?? '';
  bool hasGiverPhotoUrl() => _giverPhotoUrl != null;

  // "likeType" field.
  String? _likeType;
  String get likeType => _likeType ?? '';
  bool hasLikeType() => _likeType != null;

  // "timestamp" field.
  DateTime? _timestamp;
  DateTime? get timestamp => _timestamp;
  bool hasTimestamp() => _timestamp != null;

  // "isNotified" field.
  bool? _isNotified;
  bool get isNotified => _isNotified ?? false;
  bool hasIsNotified() => _isNotified != null;

  // "isMatched" field.
  bool? _isMatched;
  bool get isMatched => _isMatched ?? false;
  bool hasIsMatched() => _isMatched != null;

  // "isRead" field.
  bool? _isRead;
  bool get isRead => _isRead ?? false;
  bool hasIsRead() => _isRead != null;

  // "createdAt" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  void _initializeFields() {
    _receiverId = snapshotData['receiverId'] as String?;
    _giverId = snapshotData['giverId'] as String?;
    _giverName = snapshotData['giverName'] as String?;
    _giverPhotoUrl = snapshotData['giverPhotoUrl'] as String?;
    _likeType = snapshotData['likeType'] as String?;
    _timestamp = snapshotData['timestamp'] as DateTime?;
    _isNotified = snapshotData['isNotified'] as bool?;
    _isMatched = snapshotData['isMatched'] as bool?;
    _isRead = snapshotData['isRead'] as bool?;
    _createdAt = snapshotData['createdAt'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('likes_received');

  static Stream<LikesReceivedRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => LikesReceivedRecord.fromSnapshot(s));

  static Future<LikesReceivedRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => LikesReceivedRecord.fromSnapshot(s));

  static LikesReceivedRecord fromSnapshot(DocumentSnapshot snapshot) =>
      LikesReceivedRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static LikesReceivedRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      LikesReceivedRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'LikesReceivedRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is LikesReceivedRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createLikesReceivedRecordData({
  String? receiverId,
  String? giverId,
  String? giverName,
  String? giverPhotoUrl,
  String? likeType,
  DateTime? timestamp,
  bool? isNotified,
  bool? isMatched,
  bool? isRead,
  DateTime? createdAt,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'receiverId': receiverId,
      'giverId': giverId,
      'giverName': giverName,
      'giverPhotoUrl': giverPhotoUrl,
      'likeType': likeType,
      'timestamp': timestamp,
      'isNotified': isNotified,
      'isMatched': isMatched,
      'isRead': isRead,
      'createdAt': createdAt,
    }.withoutNulls,
  );

  return firestoreData;
}

class LikesReceivedRecordDocumentEquality
    implements Equality<LikesReceivedRecord> {
  const LikesReceivedRecordDocumentEquality();

  @override
  bool equals(LikesReceivedRecord? e1, LikesReceivedRecord? e2) {
    return e1?.receiverId == e2?.receiverId &&
        e1?.giverId == e2?.giverId &&
        e1?.giverName == e2?.giverName &&
        e1?.giverPhotoUrl == e2?.giverPhotoUrl &&
        e1?.likeType == e2?.likeType &&
        e1?.timestamp == e2?.timestamp &&
        e1?.isNotified == e2?.isNotified &&
        e1?.isMatched == e2?.isMatched &&
        e1?.isRead == e2?.isRead &&
        e1?.createdAt == e2?.createdAt;
  }

  @override
  int hash(LikesReceivedRecord? e) => const ListEquality().hash([
        e?.receiverId,
        e?.giverId,
        e?.giverName,
        e?.giverPhotoUrl,
        e?.likeType,
        e?.timestamp,
        e?.isNotified,
        e?.isMatched,
        e?.isRead,
        e?.createdAt
      ]);

  @override
  bool isValidKey(Object? o) => o is LikesReceivedRecord;
}
