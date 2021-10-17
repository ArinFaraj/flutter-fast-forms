import 'package:flutter/material.dart';

import '../form_field.dart';
import '../form_scope.dart';

typedef ObjectListHeaderBuilder = Widget Function(
    BuildContext context, Function(dynamic value) add);
typedef ObjectListItemBuilder = Widget Function(
    BuildContext context, dynamic object, VoidCallback remove);

@immutable
class FastObjectList<T> extends FastFormField<List<T>> {
  FastObjectList({
    bool autofocus = false,
    AutovalidateMode autovalidateMode = AutovalidateMode.onUserInteraction,
    FormFieldBuilder<List<T>>? builder,
    EdgeInsetsGeometry? contentPadding,
    InputDecoration? decoration,
    bool enabled = true,
    String? helperText,
    this.hint,
    required String id,
    List<T>? initialValue,
    this.items = const [],
    Key? key,
    String? label,
    ValueChanged<List<T>>? onChanged,
    VoidCallback? onReset,
    this.onSaved,
    this.selectedItemBuilder,
    required this.headerBuilder,
    required this.itemBuilder,
    FormFieldValidator? validator,
  })  : t = T,
        super(
          autofocus: autofocus,
          autovalidateMode: autovalidateMode,
          builder: builder ??
              (field) {
                final scope = FastFormScope.of(field.context);
                final builder =
                    scope?.builders[FastObjectList] ?? objectListBuilder;
                return builder(field);
              },
          decoration: decoration,
          enabled: enabled,
          helperText: helperText,
          id: id,
          initialValue: initialValue ?? [],
          key: key,
          label: label,
          onChanged: onChanged,
          onReset: onReset,
          onSaved: onSaved,
          validator: validator,
        );
  final Type t;
  final Widget? hint;
  final List<String> items;
  final FormFieldSetter<List<T>>? onSaved;
  final DropdownButtonBuilder? selectedItemBuilder;
  final ObjectListHeaderBuilder headerBuilder;
  final ObjectListItemBuilder itemBuilder;
  @override
  FastObjectListState<T> createState() => FastObjectListState<T>();
}

class FastObjectListState<T> extends FastFormFieldState<List<T>> {
  @override
  FastObjectList<T> get widget => super.widget as FastObjectList<T>;
}

final FormFieldBuilder<List<dynamic>> objectListBuilder =
    (FormFieldState<List<dynamic>> field) {
  final state = field as FastObjectListState;
  final widget = state.widget;

  final decorator = FastFormScope.of(state.context)?.inputDecorator;
  final _decoration = widget.decoration ??
      decorator?.call(state.context, state.widget) ??
      const InputDecoration();

  return Builder(builder: (context) {
    return InputDecorator(
      decoration: _decoration.copyWith(
        contentPadding: widget.contentPadding,
        errorText: state.errorText,
      ),
      child: SizedBox(
        height: 200,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            widget.headerBuilder(context, (value) {
              print('adding $value');
              state.value!.insert(0, value);
              field.didChange(state.value!);
              print('currently ${state.value}');
            }),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: state.value?.length ?? 0,
                itemBuilder: (context, index) {
                  return widget.itemBuilder(context, state.value![index], () {
                    print('removing $index');
                    state.value!.remove(state.value![index]);
                    field.didChange(state.value!);
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  });
};
