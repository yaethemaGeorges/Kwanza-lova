// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class UsersStruct extends FFFirebaseStruct {
  UsersStruct({
    String? displayName,
    String? photoUrl,
    int? age,
    String? gender,
    String? location,
    String? bio,
    String? email,
    DateTime? createdTime,
    String? firstName,
    String? lastName,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _displayName = displayName,
        _photoUrl = photoUrl,
        _age = age,
        _gender = gender,
        _location = location,
        _bio = bio,
        _email = email,
        _createdTime = createdTime,
        _firstName = firstName,
        _lastName = lastName,
        super(firestoreUtilData);

  // "display_Name" field.
  String? _displayName;
  String get displayName => _displayName ?? '\" \"';
  set displayName(String? val) => _displayName = val;

  bool hasDisplayName() => _displayName != null;

  // "photoUrl" field.
  String? _photoUrl;
  String get photoUrl => _photoUrl ?? '\" \"';
  set photoUrl(String? val) => _photoUrl = val;

  bool hasPhotoUrl() => _photoUrl != null;

  // "age" field.
  int? _age;
  int get age => _age ?? 0;
  set age(int? val) => _age = val;

  void incrementAge(int amount) => age = age + amount;

  bool hasAge() => _age != null;

  // "gender" field.
  String? _gender;
  String get gender => _gender ?? '\" \"';
  set gender(String? val) => _gender = val;

  bool hasGender() => _gender != null;

  // "location" field.
  String? _location;
  String get location => _location ?? '\" \"';
  set location(String? val) => _location = val;

  bool hasLocation() => _location != null;

  // "bio" field.
  String? _bio;
  String get bio => _bio ?? '\" \"';
  set bio(String? val) => _bio = val;

  bool hasBio() => _bio != null;

  // "email" field.
  String? _email;
  String get email => _email ?? '\" \"';
  set email(String? val) => _email = val;

  bool hasEmail() => _email != null;

  // "created_time" field.
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  set createdTime(DateTime? val) => _createdTime = val;

  bool hasCreatedTime() => _createdTime != null;

  // "FirstName" field.
  String? _firstName;
  String get firstName => _firstName ?? '\" \"';
  set firstName(String? val) => _firstName = val;

  bool hasFirstName() => _firstName != null;

  // "LastName" field.
  String? _lastName;
  String get lastName => _lastName ?? '\" \"';
  set lastName(String? val) => _lastName = val;

  bool hasLastName() => _lastName != null;

  static UsersStruct fromMap(Map<String, dynamic> data) => UsersStruct(
        displayName: data['display_Name'] as String?,
        photoUrl: data['photoUrl'] as String?,
        age: castToType<int>(data['age']),
        gender: data['gender'] as String?,
        location: data['location'] as String?,
        bio: data['bio'] as String?,
        email: data['email'] as String?,
        createdTime: data['created_time'] as DateTime?,
        firstName: data['FirstName'] as String?,
        lastName: data['LastName'] as String?,
      );

  static UsersStruct? maybeFromMap(dynamic data) =>
      data is Map ? UsersStruct.fromMap(data.cast<String, dynamic>()) : null;

  Map<String, dynamic> toMap() => {
        'display_Name': _displayName,
        'photoUrl': _photoUrl,
        'age': _age,
        'gender': _gender,
        'location': _location,
        'bio': _bio,
        'email': _email,
        'created_time': _createdTime,
        'FirstName': _firstName,
        'LastName': _lastName,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'display_Name': serializeParam(
          _displayName,
          ParamType.String,
        ),
        'photoUrl': serializeParam(
          _photoUrl,
          ParamType.String,
        ),
        'age': serializeParam(
          _age,
          ParamType.int,
        ),
        'gender': serializeParam(
          _gender,
          ParamType.String,
        ),
        'location': serializeParam(
          _location,
          ParamType.String,
        ),
        'bio': serializeParam(
          _bio,
          ParamType.String,
        ),
        'email': serializeParam(
          _email,
          ParamType.String,
        ),
        'created_time': serializeParam(
          _createdTime,
          ParamType.DateTime,
        ),
        'FirstName': serializeParam(
          _firstName,
          ParamType.String,
        ),
        'LastName': serializeParam(
          _lastName,
          ParamType.String,
        ),
      }.withoutNulls;

  static UsersStruct fromSerializableMap(Map<String, dynamic> data) =>
      UsersStruct(
        displayName: deserializeParam(
          data['display_Name'],
          ParamType.String,
          false,
        ),
        photoUrl: deserializeParam(
          data['photoUrl'],
          ParamType.String,
          false,
        ),
        age: deserializeParam(
          data['age'],
          ParamType.int,
          false,
        ),
        gender: deserializeParam(
          data['gender'],
          ParamType.String,
          false,
        ),
        location: deserializeParam(
          data['location'],
          ParamType.String,
          false,
        ),
        bio: deserializeParam(
          data['bio'],
          ParamType.String,
          false,
        ),
        email: deserializeParam(
          data['email'],
          ParamType.String,
          false,
        ),
        createdTime: deserializeParam(
          data['created_time'],
          ParamType.DateTime,
          false,
        ),
        firstName: deserializeParam(
          data['FirstName'],
          ParamType.String,
          false,
        ),
        lastName: deserializeParam(
          data['LastName'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'UsersStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is UsersStruct &&
        displayName == other.displayName &&
        photoUrl == other.photoUrl &&
        age == other.age &&
        gender == other.gender &&
        location == other.location &&
        bio == other.bio &&
        email == other.email &&
        createdTime == other.createdTime &&
        firstName == other.firstName &&
        lastName == other.lastName;
  }

  @override
  int get hashCode => const ListEquality().hash([
        displayName,
        photoUrl,
        age,
        gender,
        location,
        bio,
        email,
        createdTime,
        firstName,
        lastName
      ]);
}

UsersStruct createUsersStruct({
  String? displayName,
  String? photoUrl,
  int? age,
  String? gender,
  String? location,
  String? bio,
  String? email,
  DateTime? createdTime,
  String? firstName,
  String? lastName,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    UsersStruct(
      displayName: displayName,
      photoUrl: photoUrl,
      age: age,
      gender: gender,
      location: location,
      bio: bio,
      email: email,
      createdTime: createdTime,
      firstName: firstName,
      lastName: lastName,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

UsersStruct? updateUsersStruct(
  UsersStruct? users, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    users
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addUsersStructData(
  Map<String, dynamic> firestoreData,
  UsersStruct? users,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (users == null) {
    return;
  }
  if (users.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && users.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final usersData = getUsersFirestoreData(users, forFieldValue);
  final nestedData = usersData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = users.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getUsersFirestoreData(
  UsersStruct? users, [
  bool forFieldValue = false,
]) {
  if (users == null) {
    return {};
  }
  final firestoreData = mapToFirestore(users.toMap());

  // Add any Firestore field values
  users.firestoreUtilData.fieldValues.forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getUsersListFirestoreData(
  List<UsersStruct>? userss,
) =>
    userss?.map((e) => getUsersFirestoreData(e, true)).toList() ?? [];
