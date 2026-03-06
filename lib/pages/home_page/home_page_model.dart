import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import '/flutter_flow/upload_data.dart';
import 'dart:ui';
import 'home_page_widget.dart' show HomePageWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_palette/material_palette.dart';
import 'package:provider/provider.dart';

class HomePageModel extends FlutterFlowModel<HomePageWidget> {
  ///  State fields for stateful widgets in this page.

  bool isDataUploading_uploadDataVnv = false;
  FFUploadedFile uploadedLocalFile_uploadDataVnv =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');

  // Stores action output result for [Backend Call - API (Uploading Call)] action in Button widget.
  ApiCallResponse? apiResultopy;
  // State field(s) for DropDown widget.
  String? dropDownValue;
  FormFieldController<String>? dropDownValueController;

  // State field(s) for Category DropDown widget.
  String? categoryDropDownValue;
  FormFieldController<String>? categoryDropDownValueController;

  // State field(s) for Priority DropDown widget.
  String? priorityDropDownValue;
  FormFieldController<String>? priorityDropDownValueController;

  // State field(s) for Status DropDown widget.
  String? statusDropDownValue;
  FormFieldController<String>? statusDropDownValueController;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
