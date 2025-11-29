// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class StatsStruct extends FFFirebaseStruct {
  StatsStruct({
    int? totalSignups,
    int? activeUsers,
    double? totalAdRevenue,
    int? premiumConversions,
    double? retentionRate7Days,
    double? retentionRate30Days,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _totalSignups = totalSignups,
        _activeUsers = activeUsers,
        _totalAdRevenue = totalAdRevenue,
        _premiumConversions = premiumConversions,
        _retentionRate7Days = retentionRate7Days,
        _retentionRate30Days = retentionRate30Days,
        super(firestoreUtilData);

  // "totalSignups" field.
  int? _totalSignups;
  int get totalSignups => _totalSignups ?? 0;
  set totalSignups(int? val) => _totalSignups = val;

  void incrementTotalSignups(int amount) =>
      totalSignups = totalSignups + amount;

  bool hasTotalSignups() => _totalSignups != null;

  // "activeUsers" field.
  int? _activeUsers;
  int get activeUsers => _activeUsers ?? 0;
  set activeUsers(int? val) => _activeUsers = val;

  void incrementActiveUsers(int amount) => activeUsers = activeUsers + amount;

  bool hasActiveUsers() => _activeUsers != null;

  // "totalAdRevenue" field.
  double? _totalAdRevenue;
  double get totalAdRevenue => _totalAdRevenue ?? 0.0;
  set totalAdRevenue(double? val) => _totalAdRevenue = val;

  void incrementTotalAdRevenue(double amount) =>
      totalAdRevenue = totalAdRevenue + amount;

  bool hasTotalAdRevenue() => _totalAdRevenue != null;

  // "premiumConversions" field.
  int? _premiumConversions;
  int get premiumConversions => _premiumConversions ?? 0;
  set premiumConversions(int? val) => _premiumConversions = val;

  void incrementPremiumConversions(int amount) =>
      premiumConversions = premiumConversions + amount;

  bool hasPremiumConversions() => _premiumConversions != null;

  // "retentionRate7Days" field.
  double? _retentionRate7Days;
  double get retentionRate7Days => _retentionRate7Days ?? 0.0;
  set retentionRate7Days(double? val) => _retentionRate7Days = val;

  void incrementRetentionRate7Days(double amount) =>
      retentionRate7Days = retentionRate7Days + amount;

  bool hasRetentionRate7Days() => _retentionRate7Days != null;

  // "retentionRate30Days" field.
  double? _retentionRate30Days;
  double get retentionRate30Days => _retentionRate30Days ?? 0.0;
  set retentionRate30Days(double? val) => _retentionRate30Days = val;

  void incrementRetentionRate30Days(double amount) =>
      retentionRate30Days = retentionRate30Days + amount;

  bool hasRetentionRate30Days() => _retentionRate30Days != null;

  static StatsStruct fromMap(Map<String, dynamic> data) => StatsStruct(
        totalSignups: castToType<int>(data['totalSignups']),
        activeUsers: castToType<int>(data['activeUsers']),
        totalAdRevenue: castToType<double>(data['totalAdRevenue']),
        premiumConversions: castToType<int>(data['premiumConversions']),
        retentionRate7Days: castToType<double>(data['retentionRate7Days']),
        retentionRate30Days: castToType<double>(data['retentionRate30Days']),
      );

  static StatsStruct? maybeFromMap(dynamic data) =>
      data is Map ? StatsStruct.fromMap(data.cast<String, dynamic>()) : null;

  Map<String, dynamic> toMap() => {
        'totalSignups': _totalSignups,
        'activeUsers': _activeUsers,
        'totalAdRevenue': _totalAdRevenue,
        'premiumConversions': _premiumConversions,
        'retentionRate7Days': _retentionRate7Days,
        'retentionRate30Days': _retentionRate30Days,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'totalSignups': serializeParam(
          _totalSignups,
          ParamType.int,
        ),
        'activeUsers': serializeParam(
          _activeUsers,
          ParamType.int,
        ),
        'totalAdRevenue': serializeParam(
          _totalAdRevenue,
          ParamType.double,
        ),
        'premiumConversions': serializeParam(
          _premiumConversions,
          ParamType.int,
        ),
        'retentionRate7Days': serializeParam(
          _retentionRate7Days,
          ParamType.double,
        ),
        'retentionRate30Days': serializeParam(
          _retentionRate30Days,
          ParamType.double,
        ),
      }.withoutNulls;

  static StatsStruct fromSerializableMap(Map<String, dynamic> data) =>
      StatsStruct(
        totalSignups: deserializeParam(
          data['totalSignups'],
          ParamType.int,
          false,
        ),
        activeUsers: deserializeParam(
          data['activeUsers'],
          ParamType.int,
          false,
        ),
        totalAdRevenue: deserializeParam(
          data['totalAdRevenue'],
          ParamType.double,
          false,
        ),
        premiumConversions: deserializeParam(
          data['premiumConversions'],
          ParamType.int,
          false,
        ),
        retentionRate7Days: deserializeParam(
          data['retentionRate7Days'],
          ParamType.double,
          false,
        ),
        retentionRate30Days: deserializeParam(
          data['retentionRate30Days'],
          ParamType.double,
          false,
        ),
      );

  @override
  String toString() => 'StatsStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is StatsStruct &&
        totalSignups == other.totalSignups &&
        activeUsers == other.activeUsers &&
        totalAdRevenue == other.totalAdRevenue &&
        premiumConversions == other.premiumConversions &&
        retentionRate7Days == other.retentionRate7Days &&
        retentionRate30Days == other.retentionRate30Days;
  }

  @override
  int get hashCode => const ListEquality().hash([
        totalSignups,
        activeUsers,
        totalAdRevenue,
        premiumConversions,
        retentionRate7Days,
        retentionRate30Days
      ]);
}

StatsStruct createStatsStruct({
  int? totalSignups,
  int? activeUsers,
  double? totalAdRevenue,
  int? premiumConversions,
  double? retentionRate7Days,
  double? retentionRate30Days,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    StatsStruct(
      totalSignups: totalSignups,
      activeUsers: activeUsers,
      totalAdRevenue: totalAdRevenue,
      premiumConversions: premiumConversions,
      retentionRate7Days: retentionRate7Days,
      retentionRate30Days: retentionRate30Days,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

StatsStruct? updateStatsStruct(
  StatsStruct? stats, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    stats
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addStatsStructData(
  Map<String, dynamic> firestoreData,
  StatsStruct? stats,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (stats == null) {
    return;
  }
  if (stats.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && stats.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final statsData = getStatsFirestoreData(stats, forFieldValue);
  final nestedData = statsData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = stats.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getStatsFirestoreData(
  StatsStruct? stats, [
  bool forFieldValue = false,
]) {
  if (stats == null) {
    return {};
  }
  final firestoreData = mapToFirestore(stats.toMap());

  // Add any Firestore field values
  stats.firestoreUtilData.fieldValues.forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getStatsListFirestoreData(
  List<StatsStruct>? statss,
) =>
    statss?.map((e) => getStatsFirestoreData(e, true)).toList() ?? [];
