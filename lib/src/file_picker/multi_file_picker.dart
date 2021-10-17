import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../flutter_fast_forms.dart';
import '../form_field.dart';
import '../form_scope.dart';
import 'package:path/path.dart' as path_helper;

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
    EdgeInsetsGeometry? contentPadding,
    this.currentFile,
    this.savedFolderPath,
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
    List<String>? initialValue = const [],
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
  }) : super(
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
  final String? savedFolderPath;
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

Widget multifilePickerIconButtonBuilder(
    FastMultiFilePickerState state, ShowMultiFilePicker show) {
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
        const SizedBox(
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
}

Widget multifilePickerBuilder(FormFieldState<List<String>> field) {
  final state = field as FastMultiFilePickerState;
  final context = state.context;
  final widget = state.widget;

  final decoration = widget.decoration ??
      FastFormScope.of(context)?.inputDecorator(context, widget) ??
      const InputDecoration();
  final InputDecoration effectiveDecoration =
      decoration.applyDefaults(Theme.of(context).inputDecorationTheme);

  void show(FileTypeCross type) async {
    try {
      var value = await FilePickerCross.importMultipleFromStorage(type: type);

      var files = state.value!;
      files.addAll(value.map((e) => e.path!));
      state.didChange(files);
    } catch (e) {
      String _exceptionData = (type as dynamic).reason();
      log('----------------------');
      log('REASON: $_exceptionData');
      if (_exceptionData == 'read_external_storage_denied') {
        throw Exception('Permission was denied');
      } else if (_exceptionData == 'selection_canceled') {
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

                File file = File(state.value![index]);
                if (!file.existsSync()) {
                  if (widget.savedFolderPath != null &&
                      widget.savedFolderPath!.isNotEmpty) {
                    file = File(path_helper.join(
                        widget.savedFolderPath!, state.value![index]));
                  }
                }

                final exist = file.existsSync();
                return StatefulBuilder(builder: (context, setState) {
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 100),
                        opacity: wid,
                        child: ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(20)),
                          child: exist
                              ? InkWell(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(20)),
                                  onTap: widget.usePreviewDialog
                                      ? () => openFileDialog(context, file)
                                      : null,
                                  child: ExtendedImage.file(
                                    file,
                                    fit: BoxFit.cover,
                                    cacheWidth: widget.height.toInt(),
                                    height: widget.height,
                                    width: widget.height,
                                  ),
                                )
                              : Center(
                                  child: TextButton.icon(
                                      onPressed: widget.enabled
                                          ? () => show(FileTypeCross.image)
                                          : null,
                                      icon: const Icon(
                                        Icons.warning_rounded,
                                        color: Colors.red,
                                      ),
                                      label:
                                          Text('File Not Found\n${file.path}')),
                                ),
                        ),
                      ),
                      Positioned(
                        top: -5,
                        right: -10,
                        child: MaterialButton(
                          shape: const CircleBorder(),
                          color: Colors.red,
                          onPressed: () async {
                            setState(() {
                              wid = 0;
                            });
                            await Future.delayed(
                                const Duration(milliseconds: 99));
                            var files = state.value!;
                            files.removeAt(index);

                            state.didChange(files);
                          },
                          child: const Icon(Icons.remove_outlined),
                        ),
                      ),
                    ],
                  );
                });
              },
            ),
          InkWell(
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            onTap: widget.enabled ? () => show(FileTypeCross.image) : null,
            child: Container(
              height: widget.height,
              width: widget.height,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.secondary,
                ),
                //color:Colors.transparent,
                borderRadius: const BorderRadius.all(
                  Radius.circular(20),
                ),
              ),
              child: const Center(child: Icon(Icons.add)),
            ),
          ),
        ],
      ),
    ),
  );
}
