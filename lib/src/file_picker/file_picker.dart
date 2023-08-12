import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path_helper;

import '../form_field.dart';
import '../form_scope.dart';

typedef FilePickerTextBuilder = Text Function(FastFilePickerState state);

typedef FilePickerModalPopupBuilder = Widget Function(
    BuildContext context, FastFilePickerState state);

typedef ShowFilePicker = Function(FileType entryMode);

typedef FilePickerIconButtonBuilder = Widget Function(
    FastFilePickerState state, ShowFilePicker show);

@immutable
class FastFilePicker extends FastFormField<String?> {
  FastFilePicker({
    bool? adaptive,
    bool autofocus = false,
    AutovalidateMode autovalidateMode = AutovalidateMode.onUserInteraction,
    FormFieldBuilder<String?>? builder,
    this.removeText,
    this.changeText,
    EdgeInsetsGeometry? contentPadding,
    this.heroTag,
    this.currentFile,
    this.fileType = FileType.image,
    InputDecoration? decoration,
    bool enabled = true,
    this.errorBuilder,
    this.errorFormatText,
    this.errorInvalidText,
    this.fieldHintText,
    this.fieldLabelText,
    this.savedFolderPath,
    this.helperBuilder,
    this.height = 216.0,
    String? helperText,
    this.helpText,
    required String id,
    String? initialValue,
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
    FormFieldValidator<String>? validator,
  }) : super(
          adaptive: adaptive,
          autofocus: autofocus,
          autovalidateMode: autovalidateMode,
          builder: builder ??
              (field) {
                final scope = FastFormScope.of(field.context);
                final builder =
                    scope?.builders[FastFilePicker] ?? filePickerBuilder;
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
  final FileType fileType;
  final ErrorBuilder<String>? errorBuilder;
  final String? errorFormatText;
  final String? errorInvalidText;
  final String? heroTag;
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
  FastFilePickerState createState() => FastFilePickerState();
}

class FastFilePickerState extends FastFormFieldState<String?> {
  @override
  FastFilePicker get widget => super.widget as FastFilePicker;
}

Widget filePickerIconButtonBuilder(
    FastFilePickerState state, ShowFilePicker show) {
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
        const SizedBox(height: 10),
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

Widget filePickerBuilder(FormFieldState<String?> field) {
  final state = field as FastFilePickerState;
  final context = state.context;
  final widget = state.widget;

  final decoration = widget.decoration ??
      FastFormScope.of(context)?.inputDecorator(context, widget) ??
      const InputDecoration();
  final InputDecoration effectiveDecoration =
      decoration.applyDefaults(Theme.of(context).inputDecorationTheme);

  void show(FileType type) async {
    var value = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: type,
    );
    if (value == null) {
      return;
    }
    state.didChange(value.files.single.path);
  }

  File? file;
  if (state.value != null && state.value!.isNotEmpty) {
    file = File(state.value!);
    if (!file.existsSync()) {
      if (widget.savedFolderPath != null &&
          widget.savedFolderPath!.isNotEmpty) {
        file = File(path_helper.join(widget.savedFolderPath!, state.value!));
      }
    }
  }
  final exist = file?.existsSync() ?? false;
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
            child: Stack(
              children: [
                if (state.value == null || state.value!.isEmpty)
                  InkWell(
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    onTap: widget.enabled ? () => show(FileType.image) : null,
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
                      child: const Center(
                        child: Icon(Icons.image_outlined),
                      ),
                    ),
                  ),
                if (state.value != null && state.value!.isNotEmpty)
                  exist
                      ? InkWell(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(20)),
                          onTap: widget.usePreviewDialog
                              ? () => openFileDialog(context, file!)
                              : null,
                          child: Hero(
                            tag: widget.heroTag ?? file.toString(),
                            child: ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(20)),
                              child: ExtendedImage.file(
                                file!,
                                fit: BoxFit.cover,
                                cacheWidth: widget.height.toInt(),
                                height: widget.height,
                                width: widget.height,
                              ),
                            ),
                          ),
                        )
                      : Center(
                          child: TextButton.icon(
                              onPressed: widget.enabled
                                  ? () => show(FileType.image)
                                  : null,
                              icon: const Icon(
                                Icons.warning_rounded,
                                color: Colors.red,
                              ),
                              label: Text('File Not Found\n${file!.path}')),
                        )
              ],
            ),
          ),
        ),
        filePickerIconButtonBuilder(state, show),
      ],
    ),
  );
}

openFileDialog(BuildContext context, File path) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: ExtendedImage.file(
          path,
          mode: ExtendedImageMode.gesture,
          filterQuality: FilterQuality.high,
        ),
      );
    },
  );
}
