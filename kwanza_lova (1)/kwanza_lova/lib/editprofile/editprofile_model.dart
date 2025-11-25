import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/firebase_storage/storage.dart';
import '/flutter_flow/flutter_flow_choice_chips.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_radio_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import '/flutter_flow/upload_data.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import 'editprofile_widget.dart' show EditprofileWidget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class EditprofileModel extends FlutterFlowModel<EditprofileWidget> {
  ///  Local state fields for this page.

  String? oldPhoroUrl;

  ///  State fields for stateful widgets in this page.

  bool isDataUploading_uploadDataF6e = false;
  FFUploadedFile uploadedLocalFile_uploadDataF6e =
      FFUploadedFile(bytes: Uint8List.fromList([]));
  String uploadedFileUrl_uploadDataF6e = '';

  // State field(s) for yourfirstName widget.
  FocusNode? yourfirstNameFocusNode;
  TextEditingController? yourfirstNameTextController;
  String? Function(BuildContext, String?)? yourfirstNameTextControllerValidator;
  // State field(s) for yourlastName widget.
  FocusNode? yourlastNameFocusNode;
  TextEditingController? yourlastNameTextController;
  String? Function(BuildContext, String?)? yourlastNameTextControllerValidator;
  // State field(s) for your_age widget.
  FocusNode? yourAgeFocusNode;
  TextEditingController? yourAgeTextController;
  String? Function(BuildContext, String?)? yourAgeTextControllerValidator;
  // State field(s) for Phone_number widget.
  FocusNode? phoneNumberFocusNode;
  TextEditingController? phoneNumberTextController;
  String? Function(BuildContext, String?)? phoneNumberTextControllerValidator;
  // State field(s) for city widget.
  FocusNode? cityFocusNode;
  TextEditingController? cityTextController;
  String? Function(BuildContext, String?)? cityTextControllerValidator;
  // State field(s) for ChoiceChips widget.
  FormFieldController<List<String>>? choiceChipsValueController;
  String? get choiceChipsValue =>
      choiceChipsValueController?.value?.firstOrNull;
  set choiceChipsValue(String? val) =>
      choiceChipsValueController?.value = val != null ? [val] : [];
  // State field(s) for relationshiptype widget.
  FormFieldController<String>? relationshiptypeValueController;
  // State field(s) for myBio widget.
  FocusNode? myBioFocusNode;
  TextEditingController? myBioTextController;
  String? Function(BuildContext, String?)? myBioTextControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    yourfirstNameFocusNode?.dispose();
    yourfirstNameTextController?.dispose();

    yourlastNameFocusNode?.dispose();
    yourlastNameTextController?.dispose();

    yourAgeFocusNode?.dispose();
    yourAgeTextController?.dispose();

    phoneNumberFocusNode?.dispose();
    phoneNumberTextController?.dispose();

    cityFocusNode?.dispose();
    cityTextController?.dispose();

    myBioFocusNode?.dispose();
    myBioTextController?.dispose();
  }

  /// Additional helper methods.
  String? get relationshiptypeValue => relationshiptypeValueController?.value;
}
