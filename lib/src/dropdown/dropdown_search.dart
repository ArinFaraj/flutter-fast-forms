// import 'package:dropdown_search/dropdown_search.dart';
// import 'package:flutter/material.dart';

// import '../form_field.dart';
// import '../form_scope.dart';

// typedef DropdownSearchMenuItemsBuilder<T> = List<DropdownMenuItem<T>> Function(
//     List<T> items, FastDropdownSearchState state);

// @immutable
// class FastDropdownSearch<T> extends FastFormField<T> {
//   FastDropdownSearch({
//     bool autofocus = false,
//     AutovalidateMode autovalidateMode = AutovalidateMode.onUserInteraction,
//     FormFieldBuilder<T>? builder,
//     EdgeInsetsGeometry? contentPadding,
//     InputDecoration? decoration,
//     this.dropdownSearchColor,
//     bool enabled = true,
//     this.focusNode,
//     String? helperText,
//     this.hint,
//     required String id,
//     T? initialValue,
//     this.items = const [],
//     this.itemsBuilder,
//     Key? key,
//     String? label,
//     ValueChanged<T>? onChanged,
//     VoidCallback? onReset,
//     this.onSaved,
//     this.selectedItemBuilder,
//     FormFieldValidator? validator,
//   }) : super(
//           autofocus: autofocus,
//           autovalidateMode: autovalidateMode,
//           builder: builder ??
//               (field) {
//                 final scope = FastFormScope.of(field.context);
//                 Widget Function(FormFieldState<T>) builder =
//                     scope?.builders[FastDropdownSearch] ??
//                         dropdownSearchBuilder;
//                 return builder(field);
//               },
//           decoration: decoration,
//           enabled: enabled,
//           helperText: helperText,
//           id: id,
//           initialValue: initialValue,
//           key: key,
//           label: label,
//           onChanged: onChanged,
//           onReset: onReset,
//           onSaved: onSaved,
//           validator: validator,
//         );

//   final Color? dropdownSearchColor;
//   final FocusNode? focusNode;
//   final Widget? hint;
//   final List<T> items;
//   final DropdownSearchMenuItemsBuilder? itemsBuilder;
//   final FormFieldSetter? onSaved;
//   final DropdownButtonBuilder? selectedItemBuilder;

//   @override
//   FastDropdownSearchState<T> createState() => FastDropdownSearchState<T>();

//   final FormFieldBuilder<T> dropdownSearchBuilder = (FormFieldState<T> field) {
//     final state = field as FastDropdownSearchState<T>;
//     final widget = state.widget;

//     final decorator = FastFormScope.of(state.context)?.inputDecorator;
//     final _decoration = widget.decoration ??
//         decorator?.call(state.context, state.widget) ??
//         const InputDecoration();
//     final _itemsBuilder = widget.itemsBuilder ?? dropdownSearchMenuItemsBuilder;
//     final _onChanged = (value) {
//       if (value != field.value) field.didChange(value);
//     };

//     return DropdownSearch<T>();

//     return DropdownButtonFormField<T>(
//       autofocus: widget.autofocus,
//       autovalidateMode: widget.autovalidateMode,
//       decoration: _decoration,
//       dropdownColor: widget.dropdownSearchColor,
//       focusNode: widget.focusNode,
//       hint: widget.hint,
//       items: _itemsBuilder<T>(widget.items, state),
//       onChanged: widget.enabled ? _onChanged : null,
//       onSaved: widget.onSaved,
//       selectedItemBuilder: widget.selectedItemBuilder,
//       validator: widget.validator,
//       value: state.value,
//     );
//   };

//   DropdownSearchMenuItemsBuilder<T> dropdownSearchMenuItemsBuilder(List<T> items, FastDropdownSearchState state) {
//     return items.map((item) {
//       return DropdownMenuItem<T>(
//         value: item,
//         child: Text(item.toString()),
//       );
//     }).toList();
//   }
// }

// class FastDropdownSearchState<T> extends FastFormFieldState<T> {
//   @override
//   FastDropdownSearch<T> get widget => super.widget as FastDropdownSearch<T>;
// }
