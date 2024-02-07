import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class AddBinForm extends StatefulWidget {
  final String areaId;
  const AddBinForm({super.key, required this.areaId});
  @override
  State<AddBinForm> createState() => _AddBinFormState();
}

class _AddBinFormState extends State<AddBinForm> {
  final _formKey = GlobalKey<FormState>();

  late String? _location;
  late String? _binname;
  late String? _model;
  late String? _binheight;
  late String? _emptyspace;
  late String? latii;
  late String? longii;
  late String? location;

  late DatabaseReference _binDataRef;

  @override
  void initState() {
    super.initState();
    _binDataRef = FirebaseDatabase.instance
        .ref()
        .child('areas')
        .child(widget.areaId)
        .child('bin_data');
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        forceAndroidLocationManager: true,
      );
      latii = position.latitude.toString();
      longii = position.longitude.toString();
      print("Location: ${position.latitude}, ${position.longitude}");
      setState(() {
        //_currentPosition = position;
        location = '(${position.latitude}, ${position.longitude})';
      });
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState?.save();
      final newBin = {
        'latitude': latii,
        'longitude': longii,
        'location': _location,
        'binname': _binname,
        'model': _model,
        'binheight': _binheight,
        'emptyspace': _emptyspace,
        'batterylevel': "0",
        'bincolor': "white",
        'var1': "Food Waste",
        'bin1': "70",
      };
      _binDataRef.push().set(newBin);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Bin'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              /*TextFormField(
                decoration: const InputDecoration(labelText: 'Latitude'),
                initialValue: latii,
                validator: (value) {
                  if(value == null){
                    value = latii;
                  }
                  //return null;
                },
                onSaved:(value) => _latitude=value,
                ),
              
              Text('$longii',
              textAlign: TextAlign.left,
              
              ),*/

              TextFormField(
                decoration: const InputDecoration(labelText: 'Location'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a location';
                  }
                  return null;
                },
                onSaved: (value) => _location = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Bin Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a bin name';
                  }
                  return null;
                },
                onSaved: (value) => _binname = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Emty Space'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a Empty Space';
                  }
                  return null;
                },
                onSaved: (value) => _emptyspace = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Model'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a model';
                  }
                  return null;
                },
                onSaved: (value) => _model = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Bin Height'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter bin height';
                  }
                  return null;
                },
                onSaved: (value) => _binheight = value,
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
