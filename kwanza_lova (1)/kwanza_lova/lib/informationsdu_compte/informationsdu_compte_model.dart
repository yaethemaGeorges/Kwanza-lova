import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'informationsdu_compte_widget.dart' show InformationsduCompteWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class InformationsduCompteModel
    extends FlutterFlowModel<InformationsduCompteWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for TextField_updatemail widget.
  FocusNode? textFieldUpdatemailFocusNode;
  TextEditingController? textFieldUpdatemailTextController;
  String? Function(BuildContext, String?)?
      textFieldUpdatemailTextControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldUpdatemailFocusNode?.dispose();
    textFieldUpdatemailTextController?.dispose();
  }
}
