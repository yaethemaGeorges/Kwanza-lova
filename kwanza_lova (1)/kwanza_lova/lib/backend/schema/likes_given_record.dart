import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class LikesGivenRecord extends FirestoreRecord {
  LikesGivenRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "giverId" field.
  String? _giverId;
  String get giverId => _giverId ?? '';
  bool hasGiverId() => _giverId != null;

  // "receiverId" field.
  String? _receiverId;
  String get receiverId => _receiverId ?? '';
  bool hasReceiverId() => _receiverId != null;

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

  // "isMatched" field.
  bool? _isMatched;
  bool get isMatched => _isMatched ?? false;
  bool hasIsMatched() => _isMatched != null;

  // "createdAt" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  void _initializeFields() {
    _giverId = snapshotData['giverId'] as String?;
    _receiverId = snapshotData['receiverId'] as String?;
    _giverName = snapshotData['giverName'] as String?;
    _giverPhotoUrl = snapshotData['giverPhotoUrl'] as String?;
    _likeType = snapshotData['likeType'] as String?;
    _timestamp = snapshotData['timestamp'] as DateTime?;
    _isMatched = snapshotData['isMatched'] as bool?;
    _createdAt = snapshotData['createdAt'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('likes_given');

  static Stream<LikesGivenRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => LikesGivenRecord.fromSnapshot(s));

  static Future<LikesGivenRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => LikesGivenRecord.fromSnapshot(s));

  static LikesGivenRecord fromSnapshot(DocumentSnapshot snapshot) =>
      LikesGivenRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static LikesGivenRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      LikesGivenRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'LikesGivenRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is LikesGivenRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createLikesGivenRecordData({
  String? giverId,
  String? receiverId,
  String? giverName,
  String? giverPhotoUrl,
  String? likeType,
  DateTime? timestamp,
  bool? isMatched,
  DateTime? createdAt,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'giverId': giverId,
      'receiverId': receiverId,
      'giverName': giverName,
      'giverPhotoUrl': giverPhotoUrl,
      'likeType': likeType,
      'timestamp': timestamp,
      'isMatched': isMatched,
      'createdAt': createdAt,
    }.withoutNulls,
  );

  return firestoreData;
}

class LikesGivenRecordDocumentEquality implements Equality<LikesGivenRecord> {
  const LikesGivenRecordDocumentEquality();

  @override
  bool equals(LikesGivenRecord? e1, LikesGivenRecord? e2) {
    return e1?.giverId == e2?.giverId &&
        e1?.receiverId == e2?.receiverId &&
        e1?.giverName == e2?.giverName &&
        e1?.giverPhotoUrl == e2?.giverPhotoUrl &&
        e1?.likeType == e2?.likeType &&
        e1?.timestamp == e2?.timestamp &&
        e1?.isMatched == e2?.isMatched &&
        e1?.createdAt == e2?.createdAt;
  }

  @override
  int hash(LikesGivenRecord? e) => const ListEquality().hash([
        e?.giverId,
        e?.receiverId,
        e?.giverName,
        e?.giverPhotoUrl,
        e?.likeType,
        e?.timestamp,
        e?.isMatched,
        e?.createdAt
      ]);

  @override
  bool isValidKey(Object? o) => o is LikesGivenRecord;
}
