import 'package:flutter/material.dart';

import '../form_field.dart';
import '../form_scope.dart';
import 'star.dart';

typedef RatingStarFixBuilder = Widget Function(FastRatingStarState state);

typedef RatingStarLabelBuilder = String Function(FastRatingStarState state);

@immutable
class FastRatingStar extends FastFormField<double> {
  FastRatingStar({
    bool? adaptive,
    bool autofocus = false,
    AutovalidateMode autovalidateMode = AutovalidateMode.onUserInteraction,
    FormFieldBuilder<double>? builder,
    EdgeInsetsGeometry? contentPadding,
    InputDecoration? decoration,
    bool enabled = true,
    this.starCount,
    this.errorBuilder,
    FocusNode? focusNode,
    String? helperText,
    this.helperBuilder,
    required String id,
    double? initialValue,
    Key? key,
    String? label,
    this.max = 10,
    this.labelBuilder,
    this.prefixBuilder,
    ValueChanged<double>? onChanged,
    VoidCallback? onReset,
    FormFieldSetter<double>? onSaved,
    this.suffixBuilder,
    FormFieldValidator<double>? validator,
  }) : super(
          adaptive: adaptive,
          autofocus: autofocus,
          autovalidateMode: autovalidateMode,
          builder: builder ??
              (field) {
                final scope = FastFormScope.of(field.context);
                final builder =
                    scope?.builders[FastRatingStar] ?? ratingStarBuilder;
                return builder(field);
              },
          contentPadding: contentPadding,
          decoration: decoration,
          enabled: enabled,
          helperText: helperText,
          id: id,
          initialValue: initialValue ?? 0,
          key: key,
          label: label,
          onChanged: onChanged,
          onReset: onReset,
          onSaved: onSaved,
          validator: validator,
        );

  final int? starCount;
  final ErrorBuilder<double>? errorBuilder;
  final HelperBuilder<double>? helperBuilder;
  final RatingStarLabelBuilder? labelBuilder;
  final double max;
  final RatingStarFixBuilder? prefixBuilder;
  final RatingStarFixBuilder? suffixBuilder;

  @override
  FastRatingStarState createState() => FastRatingStarState();
}

class FastRatingStarState extends FastFormFieldState<double> {
  @override
  FastRatingStar get widget => super.widget as FastRatingStar;
}

String ratingStarLabelBuilder(FastRatingStarState state) {
  return state.value!.toStringAsFixed(0);
}

Widget ratingStarSuffixBuilder(FastRatingStarState state) {
  return SizedBox(
    width: 32.0,
    child: Text(
      state.value!.toStringAsFixed(0),
      style: const TextStyle(
        fontSize: 16.0,
      ),
    ),
  );
}

Widget ratingStarBuilder(FormFieldState<double> field) {
  final state = field as FastRatingStarState;
  final context = state.context;
  final widget = state.widget;
  final theme = Theme.of(context);
  final decorator = FastFormScope.of(context)?.inputDecorator;
  final _decoration = widget.decoration ??
      decorator?.call(context, widget) ??
      const InputDecoration();
  final effectiveDecoration =
      _decoration.applyDefaults(theme.inputDecorationTheme);
  return InputDecorator(
    decoration: effectiveDecoration.copyWith(
        contentPadding: widget.contentPadding,
        errorText: state.errorText,
        labelText: widget.labelBuilder?.call(state)),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        if (widget.prefixBuilder != null) widget.prefixBuilder!(state),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SimpleStarRating(
              key: ValueKey(state.value),
              allowHalfRating: true,
              starCount: widget.starCount ?? 5,
              size: 25,
              spacing: 8,
              rating: state.value!,
              onRated: widget.enabled ? state.didChange : null,
            ),
          ),
        ),
        if (widget.suffixBuilder != null) widget.suffixBuilder!(state),
      ],
    ),
  );
}
