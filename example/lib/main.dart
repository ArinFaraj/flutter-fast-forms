import 'package:flutter/material.dart';
import 'package:flutter_fast_forms/flutter_fast_forms.dart';

import 'custom_form_field.dart';

final FormModelGetter createFormModel = (BuildContext context) => [
      FormFieldModelGroup(
        title: 'Form Group 1',
        orientation: FormFieldModelGroupOrientation.horizontal,
        fields: [
          DateTimeModel(
            id: 97,
            label: 'Arrival',
            firstDate: DateTime(1997),
            lastDate: DateTime(2021),
          ),
          DateTimeModel(
            id: 99,
            label: 'Departure',
            firstDate: DateTime(1997),
            lastDate: DateTime(2021),
          ),
        ],
      ),
      FormFieldModelGroup(
        title: 'Form Group 2',
        fields: [
          TextFieldModel(
            id: 42,
            label: 'Sample Text Field',
            hint: 'MM/JJJJ',
            validator: Validators.compose([
              Validators.required(),
              Validators.minLength(6),
            ]),
            keyboardType: TextInputType.datetime,
            inputFormatters: [
              InputFormatters.maskText('##/####'),
            ],
          ),
          DropdownModel(
            id: 23,
            label: 'Sample Dropdown Field',
            items: [
              'Norway',
              'Sweden',
              'Finland',
              'Denmark',
              'Iceland',
            ],
            initialValue: 'Finland',
            validator: Validators.required(),
          ),
          RadioGroupModel(
            id: 7,
            label: 'Sample Radio Group Model',
            options: [
              RadioOption(
                title: 'Option 1',
                value: 'option-1',
              ),
              RadioOption(
                title: 'Option 2',
                value: 'option-2',
              ),
              RadioOption(
                title: 'Option 3',
                value: 'option-3',
              )
            ],
          ),
          FormFieldModel<CustomFormFieldValue>(
            id: 47,
            label: 'Sample Custom Form Field',
            builder: (context, form, model) {
              return CustomFormField(
                decoration: FormBuilder.buildInputDecoration(context, model),
              );
            },
          ),
          CheckboxModel(
            id: 999,
            title: 'I accept',
          )
        ],
      ),
    ];

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Fast Forms Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FormPage(title: 'Flutter Fast Forms Demo Page'),
    );
  }
}

class FormPage extends StatefulWidget {
  FormPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _FormPageState createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final formKey = GlobalKey<FormState>();
  List<FormFieldModelGroup> _formModel;

  @override
  void initState() {
    _formModel = createFormModel(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: FormContainer(
          formKey: formKey,
          formModel: _formModel,
        ),
      ),
    );
  }
}
