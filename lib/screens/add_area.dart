import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class AddareaForm extends StatefulWidget {
  const AddareaForm({super.key});
  @override
  State<AddareaForm> createState() => _AddareaFormState();
}

class _AddareaFormState extends State<AddareaForm> {
  final _formKey = GlobalKey<FormState>();

  late String? _areaname;

  late DatabaseReference _binDataRef;

  @override
  void initState() {
    super.initState();
    _binDataRef = FirebaseDatabase.instance.ref().child('areas');
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState?.save();
      final newBin = {
        'name': _areaname,
      };
      _binDataRef.push().set(newBin);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Area'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Area Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a Area name';
                  }
                  return null;
                },
                onSaved: (value) => _areaname = value,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
        TextButton(
          onPressed: _submitForm,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
