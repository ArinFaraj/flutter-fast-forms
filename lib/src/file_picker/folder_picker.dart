import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../form_field.dart';
import '../form_scope.dart';
import 'package:path/path.dart' as path_helper;

typedef FolderPickerTextBuilder = Text Function(FastFolderPickerState state);

typedef FolderPickerModalPopupBuilder = Widget Function(
    BuildContext context, FastFolderPickerState state);

typedef ShowFolderPicker = Function();

typedef FolderPickerIconButtonBuilder = Widget Function(
    FastFolderPickerState state, ShowFolderPicker show);

@immutable
class FastFolderPicker extends FastFormField<String?> {
  FastFolderPicker({
    bool? adaptive,
    bool autofocus = false,
    AutovalidateMode autovalidateMode = AutovalidateMode.onUserInteraction,
    FormFieldBuilder<String?>? builder,
    this.removeText,
    this.changeText,
    this.trailingPath,
    this.currentFolder,
    InputDecoration? decoration,
    bool enabled = true,
    this.errorBuilder,
    this.errorFormatText,
    this.errorInvalidText,
    this.fieldHintText,
    this.fieldLabelText,
    this.helperBuilder,
    this.height = 216.0,
    String? helperText,
    this.helpText,
    required String id,
    Key? key,
    String? label,
    this.locale,
    this.modalCancelButtonText = 'Cancel',
    this.modalDoneButtonText = 'Done',
    ValueChanged<String?>? onChanged,
    VoidCallback? onReset,
    FormFieldSetter<String>? onSaved,
    this.routeSettings,
    this.showModalPopup = false,
    this.useBigPreview = true,
    this.usePreviewDialog = true,
    String? initialValue,
    EdgeInsetsGeometry? contentPadding,
    FormFieldValidator<String>? validator,
  }) : super(
          adaptive: adaptive,
          autofocus: autofocus,
          autovalidateMode: autovalidateMode,
          builder: builder ??
              (field) {
                final scope = FastFormScope.of(field.context);
                final builder =
                    scope?.builders[FastFolderPicker] ?? folderPickerBuilder;
                return builder(field);
              },
          contentPadding: contentPadding,
          decoration: decoration,
          enabled: enabled,
          helperText: helperText,
          id: id,
          initialValue: initialValue,
          key: key,
          label: label,
          onChanged: onChanged,
          onReset: onReset,
          onSaved: onSaved,
          validator: validator,
        );

  final String? removeText;
  final String? changeText;
  final String? trailingPath;
  final String? currentFolder;
  final ErrorBuilder<String>? errorBuilder;
  final String? errorFormatText;
  final String? errorInvalidText;
  final String? fieldHintText;
  final String? fieldLabelText;
  final double height;
  final HelperBuilder<String>? helperBuilder;
  final String? helpText;
  final Locale? locale;
  final String modalCancelButtonText;
  final String modalDoneButtonText;
  final RouteSettings? routeSettings;
  final bool showModalPopup;

  final bool useBigPreview;
  final bool usePreviewDialog;

  @override
  FastFolderPickerState createState() => FastFolderPickerState();
}

class FastFolderPickerState extends FastFormFieldState<String?> {
  @override
  FastFolderPicker get widget => super.widget as FastFolderPicker;
}

Widget folderPickerIconButtonBuilder(
    FastFolderPickerState state, ShowFolderPicker show) {
  final widget = state.widget;

  return OutlinedButton(
    child: const Padding(
      padding: EdgeInsets.all(8.0),
      child: Icon(Icons.folder_rounded),
    ),
    onPressed: widget.enabled ? () => show() : null,
  );
}

Widget folderPickerBuilder(FormFieldState<String?> field) {
  final state = field as FastFolderPickerState;
  final context = state.context;
  final widget = state.widget;

  final decoration = widget.decoration ??
      FastFormScope.of(context)?.inputDecorator(context, widget) ??
      const InputDecoration();
  final InputDecoration effectiveDecoration =
      decoration.applyDefaults(Theme.of(context).inputDecorationTheme);

  void show() async {
    try {
      String? pathForExports = await FilePicker.platform.getDirectoryPath();
      if (pathForExports == null) throw Exception('selection_canceled');
// you parse the file's directory and use it for later automated exports.
      // pathForExports =
      //     pathForExports.substring(0, pathForExports.lastIndexOf(r'/'));
      log(pathForExports);

      state.didChange(
        path_helper.join(
          pathForExports,
          widget.trailingPath,
        ),
      );
    } catch (e) {
      String _exceptionData = (e as dynamic).toString();
      log('----------------------');
      log('REASON: $_exceptionData');
      if (_exceptionData.contains('read_external_storage_denied')) {
        throw Exception('Permission was denied');
      } else if (_exceptionData.contains('selection_canceled')) {
        log('User canceled operation');
      }
      log('----------------------');
    }
  }

  return InputDecorator(
    decoration: effectiveDecoration.copyWith(
      contentPadding: widget.contentPadding,
      errorText: state.errorText,
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: InkWell(
              onTap: widget.enabled ? () => show() : null,
              child: Text(
                state.value ?? '',
              ),
            ),
          ),
        ),
        folderPickerIconButtonBuilder(state, show),
      ],
    ),
  );
}
