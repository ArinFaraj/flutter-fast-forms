import 'dart:async';
import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../flutter_fast_forms.dart';
import '../form_field.dart';
import '../form_scope.dart';

typedef MultiFilePickerTextBuilder = Text Function(
    FastMultiFilePickerState state);

typedef MultiFilePickerModalPopupBuilder = Widget Function(
    BuildContext context, FastMultiFilePickerState state);

typedef ShowMultiFilePicker = Function(FileTypeCross entryMode);

typedef MultiFilePickerIconButtonBuilder = Widget Function(
    FastMultiFilePickerState state, ShowMultiFilePicker show);

@immutable
class FastMultiFilePicker extends FastFormField<List<String>> {
  FastMultiFilePicker({
    bool? adaptive,
    bool autofocus = false,
    AutovalidateMode autovalidateMode = AutovalidateMode.onUserInteraction,
    FormFieldBuilder<List<String>>? builder,
    this.removeText,
    this.changeText,
    this.contentPadding,
    this.currentFile,
    this.fileType = FileTypeCross.image,
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
    List<String>? initialValue,
    Key? key,
    String? label,
    this.locale,
    this.modalCancelButtonText = 'Cancel',
    this.modalDoneButtonText = 'Done',
    ValueChanged<List<String>>? onChanged,
    VoidCallback? onReset,
    FormFieldSetter<List<String>>? onSaved,
    this.routeSettings,
    this.showModalPopup = false,
    this.useBigPreview = true,
    this.usePreviewDialog = true,
    FormFieldValidator<List<String>>? validator,
  })  : initialValue = initialValue ?? [],
        super(
          adaptive: adaptive,
          autofocus: autofocus,
          autovalidateMode: autovalidateMode,
          builder: builder ??
              (field) {
                final scope = FastFormScope.of(field.context);
                final builder = scope?.builders[FastMultiFilePicker] ??
                    multifilePickerBuilder;
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
  final EdgeInsetsGeometry? contentPadding;
  final String? currentFile;
  final FileTypeCross fileType;
  final ErrorBuilder<String>? errorBuilder;
  final String? errorFormatText;
  final String? errorInvalidText;
  final String? fieldHintText;
  final String? fieldLabelText;
  final double height;
  final HelperBuilder<String>? helperBuilder;
  final String? helpText;
  final List<String> initialValue;
  final Locale? locale;
  final String modalCancelButtonText;
  final String modalDoneButtonText;
  final RouteSettings? routeSettings;
  final bool showModalPopup;

  final bool useBigPreview;
  final bool usePreviewDialog;

  @override
  FastMultiFilePickerState createState() => FastMultiFilePickerState();
}

class FastMultiFilePickerState extends FastFormFieldState<List<String>> {
  @override
  FastMultiFilePicker get widget => super.widget as FastMultiFilePicker;
}

final MultiFilePickerIconButtonBuilder multifilePickerIconButtonBuilder =
    (FastMultiFilePickerState state, ShowMultiFilePicker show) {
  final widget = state.widget;

  return SizedBox(
    width: 200,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(widget.changeText ?? 'Change Image'),
          ),
          onPressed: widget.enabled ? () => show(widget.fileType) : null,
        ),
        SizedBox(
          height: 10,
        ),
        OutlinedButton(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(widget.removeText ?? 'Remove Image'),
          ),
          onPressed: widget.enabled ? () => state.didChange(null) : null,
        ),
      ],
    ),
  );
};

final FormFieldBuilder<List<String>> multifilePickerBuilder =
    (FormFieldState<List<String>> field) {
  final state = field as FastMultiFilePickerState;
  final context = state.context;
  final widget = state.widget;

  final decoration = widget.decoration ??
      FastFormScope.of(context)?.inputDecorator(context, widget) ??
      const InputDecoration();
  final InputDecoration effectiveDecoration =
      decoration.applyDefaults(Theme.of(context).inputDecorationTheme);

  final ShowMultiFilePicker show = (FileTypeCross type) {
    FilePickerCross.importMultipleFromStorage(type: type).then((value) {
      var files = state.value!;
      files.addAll(value.map((e) => e.path!));
      state.didChange(files);
    }).onError((dynamic error, _) {
      String _exceptionData = error.reason();
      print('----------------------');
      print('REASON: $_exceptionData');
      if (_exceptionData == 'read_external_storage_denied') {
        print('Permission was denied');
      } else if (_exceptionData == 'selection_canceled') {
        print('User canceled operation');
      }
      print('----------------------');
    });
  };
  return InputDecorator(
    decoration: effectiveDecoration.copyWith(
      contentPadding: widget.contentPadding,
      errorText: state.errorText,
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Wrap(
        spacing: 5,
        runSpacing: 5,
        children: [
          if (state.value!.isNotEmpty)
            ...List.generate(
              state.value!.length,
              (index) {
                var wid = 1.0;

                return StatefulBuilder(builder: (context, setState) {
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      AnimatedOpacity(
                        duration: Duration(milliseconds: 100),
                        opacity: wid,
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          child: InkWell(
                            onTap: widget.usePreviewDialog
                                ? () =>
                                    openFileDialog(context, state.value![index])
                                : null,
                            child: ExtendedImage.file(
                              File(state.value![index]),
                              fit: BoxFit.cover,
                              height: widget.height,
                              width: widget.height,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: -5,
                        right: -10,
                        child: MaterialButton(
                          shape: CircleBorder(),
                          color: Colors.red,
                          onPressed: () async {
                            setState(() {
                              wid = 0;
                            });
                            await Future.delayed(Duration(milliseconds: 99));
                            var files = state.value!;
                            files.removeAt(index);

                            state.didChange(files);
                          },
                          child: Icon(Icons.remove_outlined),
                        ),
                      ),
                    ],
                  );
                });
              },
            ),
          InkWell(
            onTap: widget.enabled ? () => show(FileTypeCross.image) : null,
            child: Container(
              height: widget.height,
              width: widget.height,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).accentColor,
                ),
                //color:Colors.transparent,
                borderRadius: BorderRadius.all(
                  Radius.circular(20),
                ),
              ),
              child: Center(child: const Icon(Icons.add)),
            ),
          ),
        ],
      ),
    ),
  );
};
