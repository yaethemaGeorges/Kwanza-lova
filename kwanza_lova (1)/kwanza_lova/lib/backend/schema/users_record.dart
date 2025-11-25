import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class UsersRecord extends FirestoreRecord {
  UsersRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "email" field.
  String? _email;
  String get email => _email ?? '';
  bool hasEmail() => _email != null;

  // "photo_url" field.
  String? _photoUrl;
  String get photoUrl => _photoUrl ?? '';
  bool hasPhotoUrl() => _photoUrl != null;

  // "uid" field.
  String? _uid;
  String get uid => _uid ?? '';
  bool hasUid() => _uid != null;

  // "created_time" field.
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  // "phone_number" field.
  String? _phoneNumber;
  String get phoneNumber => _phoneNumber ?? '';
  bool hasPhoneNumber() => _phoneNumber != null;

  // "gender" field.
  String? _gender;
  String get gender => _gender ?? '';
  bool hasGender() => _gender != null;

  // "Bio" field.
  String? _bio;
  String get bio => _bio ?? '';
  bool hasBio() => _bio != null;

  // "Firstname" field.
  String? _firstname;
  String get firstname => _firstname ?? '';
  bool hasFirstname() => _firstname != null;

  // "lastname" field.
  String? _lastname;
  String get lastname => _lastname ?? '';
  bool hasLastname() => _lastname != null;

  // "relationshiptype" field.
  String? _relationshiptype;
  String get relationshiptype => _relationshiptype ?? '';
  bool hasRelationshiptype() => _relationshiptype != null;

  // "interested_in" field.
  String? _interestedIn;
  String get interestedIn => _interestedIn ?? '';
  bool hasInterestedIn() => _interestedIn != null;

  // "age" field.
  int? _age;
  int get age => _age ?? 0;
  bool hasAge() => _age != null;

  // "location" field.
  String? _location;
  String get location => _location ?? '';
  bool hasLocation() => _location != null;

  // "isSubscribed" field.
  bool? _isSubscribed;
  bool get isSubscribed => _isSubscribed ?? false;
  bool hasIsSubscribed() => _isSubscribed != null;

  // "subscriptionPlan" field.
  String? _subscriptionPlan;
  String get subscriptionPlan => _subscriptionPlan ?? '';
  bool hasSubscriptionPlan() => _subscriptionPlan != null;

  // "isActive" field.
  bool? _isActive;
  bool get isActive => _isActive ?? false;
  bool hasIsActive() => _isActive != null;

  // "display_name" field.
  String? _displayName;
  String get displayName => _displayName ?? '';
  bool hasDisplayName() => _displayName != null;

  // "subscriptionType" field.
  String? _subscriptionType;
  String get subscriptionType => _subscriptionType ?? '';
  bool hasSubscriptionType() => _subscriptionType != null;

  // "subscriptionPrice" field.
  double? _subscriptionPrice;
  double get subscriptionPrice => _subscriptionPrice ?? 0.0;
  bool hasSubscriptionPrice() => _subscriptionPrice != null;

  // "subscriptionCurrency" field.
  String? _subscriptionCurrency;
  String get subscriptionCurrency => _subscriptionCurrency ?? '';
  bool hasSubscriptionCurrency() => _subscriptionCurrency != null;

  // "subscriptionExpiry" field.
  DateTime? _subscriptionExpiry;
  DateTime? get subscriptionExpiry => _subscriptionExpiry;
  bool hasSubscriptionExpiry() => _subscriptionExpiry != null;

  // "subscriptionActivatedAt" field.
  DateTime? _subscriptionActivatedAt;
  DateTime? get subscriptionActivatedAt => _subscriptionActivatedAt;
  bool hasSubscriptionActivatedAt() => _subscriptionActivatedAt != null;

  // "autoRenew" field.
  bool? _autoRenew;
  bool get autoRenew => _autoRenew ?? false;
  bool hasAutoRenew() => _autoRenew != null;

  // "subscriptionCancelledAt" field.
  DateTime? _subscriptionCancelledAt;
  DateTime? get subscriptionCancelledAt => _subscriptionCancelledAt;
  bool hasSubscriptionCancelledAt() => _subscriptionCancelledAt != null;

  // "lastTransactionId" field.
  String? _lastTransactionId;
  String get lastTransactionId => _lastTransactionId ?? '';
  bool hasLastTransactionId() => _lastTransactionId != null;

  // "referralCode" field.
  String? _referralCode;
  String get referralCode => _referralCode ?? '';
  bool hasReferralCode() => _referralCode != null;

  // "referralInfluencerId" field.
  String? _referralInfluencerId;
  String get referralInfluencerId => _referralInfluencerId ?? '';
  bool hasReferralInfluencerId() => _referralInfluencerId != null;

  // "isVerified" field.
  bool? _isVerified;
  bool get isVerified => _isVerified ?? false;
  bool hasIsVerified() => _isVerified != null;

  // "accountStatus" field.
  String? _accountStatus;
  String get accountStatus => _accountStatus ?? '';
  bool hasAccountStatus() => _accountStatus != null;

  void _initializeFields() {
    _email = snapshotData['email'] as String?;
    _photoUrl = snapshotData['photo_url'] as String?;
    _uid = snapshotData['uid'] as String?;
    _createdTime = snapshotData['created_time'] as DateTime?;
    _phoneNumber = snapshotData['phone_number'] as String?;
    _gender = snapshotData['gender'] as String?;
    _bio = snapshotData['Bio'] as String?;
    _firstname = snapshotData['Firstname'] as String?;
    _lastname = snapshotData['lastname'] as String?;
    _relationshiptype = snapshotData['relationshiptype'] as String?;
    _interestedIn = snapshotData['interested_in'] as String?;
    _age = castToType<int>(snapshotData['age']);
    _location = snapshotData['location'] as String?;
    _isSubscribed = snapshotData['isSubscribed'] as bool?;
    _subscriptionPlan = snapshotData['subscriptionPlan'] as String?;
    _isActive = snapshotData['isActive'] as bool?;
    _displayName = snapshotData['display_name'] as String?;
    _subscriptionType = snapshotData['subscriptionType'] as String?;
    _subscriptionPrice = castToType<double>(snapshotData['subscriptionPrice']);
    _subscriptionCurrency = snapshotData['subscriptionCurrency'] as String?;
    _subscriptionExpiry = snapshotData['subscriptionExpiry'] as DateTime?;
    _subscriptionActivatedAt =
        snapshotData['subscriptionActivatedAt'] as DateTime?;
    _autoRenew = snapshotData['autoRenew'] as bool?;
    _subscriptionCancelledAt =
        snapshotData['subscriptionCancelledAt'] as DateTime?;
    _lastTransactionId = snapshotData['lastTransactionId'] as String?;
    _referralCode = snapshotData['referralCode'] as String?;
    _referralInfluencerId = snapshotData['referralInfluencerId'] as String?;
    _isVerified = snapshotData['isVerified'] as bool?;
    _accountStatus = snapshotData['accountStatus'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('users');

  static Stream<UsersRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => UsersRecord.fromSnapshot(s));

  static Future<UsersRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => UsersRecord.fromSnapshot(s));

  static UsersRecord fromSnapshot(DocumentSnapshot snapshot) => UsersRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static UsersRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      UsersRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'UsersRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is UsersRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createUsersRecordData({
  String? email,
  String? photoUrl,
  String? uid,
  DateTime? createdTime,
  String? phoneNumber,
  String? gender,
  String? bio,
  String? firstname,
  String? lastname,
  String? relationshiptype,
  String? interestedIn,
  int? age,
  String? location,
  bool? isSubscribed,
  String? subscriptionPlan,
  bool? isActive,
  String? displayName,
  String? subscriptionType,
  double? subscriptionPrice,
  String? subscriptionCurrency,
  DateTime? subscriptionExpiry,
  DateTime? subscriptionActivatedAt,
  bool? autoRenew,
  DateTime? subscriptionCancelledAt,
  String? lastTransactionId,
  String? referralCode,
  String? referralInfluencerId,
  bool? isVerified,
  String? accountStatus,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'email': email,
      'photo_url': photoUrl,
      'uid': uid,
      'created_time': createdTime,
      'phone_number': phoneNumber,
      'gender': gender,
      'Bio': bio,
      'Firstname': firstname,
      'lastname': lastname,
      'relationshiptype': relationshiptype,
      'interested_in': interestedIn,
      'age': age,
      'location': location,
      'isSubscribed': isSubscribed,
      'subscriptionPlan': subscriptionPlan,
      'isActive': isActive,
      'display_name': displayName,
      'subscriptionType': subscriptionType,
      'subscriptionPrice': subscriptionPrice,
      'subscriptionCurrency': subscriptionCurrency,
      'subscriptionExpiry': subscriptionExpiry,
      'subscriptionActivatedAt': subscriptionActivatedAt,
      'autoRenew': autoRenew,
      'subscriptionCancelledAt': subscriptionCancelledAt,
      'lastTransactionId': lastTransactionId,
      'referralCode': referralCode,
      'referralInfluencerId': referralInfluencerId,
      'isVerified': isVerified,
      'accountStatus': accountStatus,
    }.withoutNulls,
  );

  return firestoreData;
}

class UsersRecordDocumentEquality implements Equality<UsersRecord> {
  const UsersRecordDocumentEquality();

  @override
  bool equals(UsersRecord? e1, UsersRecord? e2) {
    return e1?.email == e2?.email &&
        e1?.photoUrl == e2?.photoUrl &&
        e1?.uid == e2?.uid &&
        e1?.createdTime == e2?.createdTime &&
        e1?.phoneNumber == e2?.phoneNumber &&
        e1?.gender == e2?.gender &&
        e1?.bio == e2?.bio &&
        e1?.firstname == e2?.firstname &&
        e1?.lastname == e2?.lastname &&
        e1?.relationshiptype == e2?.relationshiptype &&
        e1?.interestedIn == e2?.interestedIn &&
        e1?.age == e2?.age &&
        e1?.location == e2?.location &&
        e1?.isSubscribed == e2?.isSubscribed &&
        e1?.subscriptionPlan == e2?.subscriptionPlan &&
        e1?.isActive == e2?.isActive &&
        e1?.displayName == e2?.displayName &&
        e1?.subscriptionType == e2?.subscriptionType &&
        e1?.subscriptionPrice == e2?.subscriptionPrice &&
        e1?.subscriptionCurrency == e2?.subscriptionCurrency &&
        e1?.subscriptionExpiry == e2?.subscriptionExpiry &&
        e1?.subscriptionActivatedAt == e2?.subscriptionActivatedAt &&
        e1?.autoRenew == e2?.autoRenew &&
        e1?.subscriptionCancelledAt == e2?.subscriptionCancelledAt &&
        e1?.lastTransactionId == e2?.lastTransactionId &&
        e1?.referralCode == e2?.referralCode &&
        e1?.referralInfluencerId == e2?.referralInfluencerId &&
        e1?.isVerified == e2?.isVerified &&
        e1?.accountStatus == e2?.accountStatus;
  }

  @override
  int hash(UsersRecord? e) => const ListEquality().hash([
        e?.email,
        e?.photoUrl,
        e?.uid,
        e?.createdTime,
        e?.phoneNumber,
        e?.gender,
        e?.bio,
        e?.firstname,
        e?.lastname,
        e?.relationshiptype,
        e?.interestedIn,
        e?.age,
        e?.location,
        e?.isSubscribed,
        e?.subscriptionPlan,
        e?.isActive,
        e?.displayName,
        e?.subscriptionType,
        e?.subscriptionPrice,
        e?.subscriptionCurrency,
        e?.subscriptionExpiry,
        e?.subscriptionActivatedAt,
        e?.autoRenew,
        e?.subscriptionCancelledAt,
        e?.lastTransactionId,
        e?.referralCode,
        e?.referralInfluencerId,
        e?.isVerified,
        e?.accountStatus
      ]);

  @override
  bool isValidKey(Object? o) => o is UsersRecord;
}
