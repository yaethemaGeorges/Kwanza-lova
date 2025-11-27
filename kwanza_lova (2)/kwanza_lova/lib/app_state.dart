import 'package:flutter/material.dart';
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'flutter_flow/flutter_flow_util.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {}

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  String _lastSwipeAction = '\" \"';
  String get lastSwipeAction => _lastSwipeAction;
  set lastSwipeAction(String value) {
    _lastSwipeAction = value;
  }

  String _lastSwipeProfileId = '\" \"';
  String get lastSwipeProfileId => _lastSwipeProfileId;
  set lastSwipeProfileId(String value) {
    _lastSwipeProfileId = value;
  }

  List<String> _swipedProfilesList = [];
  List<String> get swipedProfilesList => _swipedProfilesList;
  set swipedProfilesList(List<String> value) {
    _swipedProfilesList = value;
  }

  void addToSwipedProfilesList(String value) {
    swipedProfilesList.add(value);
  }

  void removeFromSwipedProfilesList(String value) {
    swipedProfilesList.remove(value);
  }

  void removeAtIndexFromSwipedProfilesList(int index) {
    swipedProfilesList.removeAt(index);
  }

  void updateSwipedProfilesListAtIndex(
    int index,
    String Function(String) updateFn,
  ) {
    swipedProfilesList[index] = updateFn(_swipedProfilesList[index]);
  }

  void insertAtIndexInSwipedProfilesList(int index, String value) {
    swipedProfilesList.insert(index, value);
  }

  List<String> _likedProfilesList = [];
  List<String> get likedProfilesList => _likedProfilesList;
  set likedProfilesList(List<String> value) {
    _likedProfilesList = value;
  }

  void addToLikedProfilesList(String value) {
    likedProfilesList.add(value);
  }

  void removeFromLikedProfilesList(String value) {
    likedProfilesList.remove(value);
  }

  void removeAtIndexFromLikedProfilesList(int index) {
    likedProfilesList.removeAt(index);
  }

  void updateLikedProfilesListAtIndex(
    int index,
    String Function(String) updateFn,
  ) {
    likedProfilesList[index] = updateFn(_likedProfilesList[index]);
  }

  void insertAtIndexInLikedProfilesList(int index, String value) {
    likedProfilesList.insert(index, value);
  }

  List<String> _passedProfilesList = [];
  List<String> get passedProfilesList => _passedProfilesList;
  set passedProfilesList(List<String> value) {
    _passedProfilesList = value;
  }

  void addToPassedProfilesList(String value) {
    passedProfilesList.add(value);
  }

  void removeFromPassedProfilesList(String value) {
    passedProfilesList.remove(value);
  }

  void removeAtIndexFromPassedProfilesList(int index) {
    passedProfilesList.removeAt(index);
  }

  void updatePassedProfilesListAtIndex(
    int index,
    String Function(String) updateFn,
  ) {
    passedProfilesList[index] = updateFn(_passedProfilesList[index]);
  }

  void insertAtIndexInPassedProfilesList(int index, String value) {
    passedProfilesList.insert(index, value);
  }

  int _initialDailySwipeCount = 0;
  int get initialDailySwipeCount => _initialDailySwipeCount;
  set initialDailySwipeCount(int value) {
    _initialDailySwipeCount = value;
  }

  int _initialDailySuperLikeCount = 0;
  int get initialDailySuperLikeCount => _initialDailySuperLikeCount;
  set initialDailySuperLikeCount(int value) {
    _initialDailySuperLikeCount = value;
  }

  String _currentChatId = '\" \"';
  String get currentChatId => _currentChatId;
  set currentChatId(String value) {
    _currentChatId = value;
  }

  int _unreadChatsCount = 0;
  int get unreadChatsCount => _unreadChatsCount;
  set unreadChatsCount(int value) {
    _unreadChatsCount = value;
  }

  String _activeChatUserId = '\" \"';
  String get activeChatUserId => _activeChatUserId;
  set activeChatUserId(String value) {
    _activeChatUserId = value;
  }

  String _currentUserId = '\" \"';
  String get currentUserId => _currentUserId;
  set currentUserId(String value) {
    _currentUserId = value;
  }

  List<UsersStruct> _usersrecord = [];
  List<UsersStruct> get usersrecord => _usersrecord;
  set usersrecord(List<UsersStruct> value) {
    _usersrecord = value;
  }

  void addToUsersrecord(UsersStruct value) {
    usersrecord.add(value);
  }

  void removeFromUsersrecord(UsersStruct value) {
    usersrecord.remove(value);
  }

  void removeAtIndexFromUsersrecord(int index) {
    usersrecord.removeAt(index);
  }

  void updateUsersrecordAtIndex(
    int index,
    UsersStruct Function(UsersStruct) updateFn,
  ) {
    usersrecord[index] = updateFn(_usersrecord[index]);
  }

  void insertAtIndexInUsersrecord(int index, UsersStruct value) {
    usersrecord.insert(index, value);
  }

  String _currency = '';
  String get currency => _currency;
  set currency(String value) {
    _currency = value;
  }

  String _paymentMethod = '';
  String get paymentMethod => _paymentMethod;
  set paymentMethod(String value) {
    _paymentMethod = value;
  }

  String _paymentData = '';
  String get paymentData => _paymentData;
  set paymentData(String value) {
    _paymentData = value;
  }

  double _amount = 0.0;
  double get amount => _amount;
  set amount(double value) {
    _amount = value;
  }

  String _transactionId = '';
  String get transactionId => _transactionId;
  set transactionId(String value) {
    _transactionId = value;
  }
}
