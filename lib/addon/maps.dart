import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:smart_bin_flutter/addon/open_map_api.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_file_store/dio_cache_interceptor_file_store.dart';
import 'package:flutter_map_cache/flutter_map_cache.dart';

class MapLocator extends StatelessWidget {
  const MapLocator({super.key, required this.areaId, required this.binId});
  final String? areaId;
  final String binId;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Location',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),

      //State<MapLocator> createState() => MyMap();
      home: MyMap(
        title: 'Map Page',
        areaId: areaId,
        binId: binId,
      ),
    );
  }
}

class MyMap extends StatefulWidget {
  const MyMap(
      {super.key,
      required this.title,
      required this.areaId,
      required this.binId});
  final String title;
  final String? areaId;
  final String binId;

  @override
  State<MyMap> createState() => _MyHomePageState();
}

class CountdownAlertDialog extends StatefulWidget {
  const CountdownAlertDialog({super.key});

  @override
  State<CountdownAlertDialog> createState() => _CountdownAlertDialogState();
}

class _CountdownAlertDialogState extends State<CountdownAlertDialog> {
  int countdown = 100;

  @override
  void initState() {
    super.initState();
    startCountdown();
  }

  void startCountdown() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown == 0) {
        timer.cancel();
        Navigator.of(context).pop();
      } else {
        setState(() {
          countdown--;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Alert'),
      content: Text('Bin is full. Please empty the bin in $countdown.'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}

class _MyHomePageState extends State<MyMap> with TickerProviderStateMixin {
  final Future<CacheStore> _cacheStoreFuture = _getCacheStore();
  late MapController mapController;
  late String lat = '0';
  late String long = '0';
  // ignore: prefer_const_constructors
  late LatLng currentlocation;
  List<Marker> markers = [];
  List<Marker> markersbin = [];
  List<Marker> markersuser = [];
  List<LatLng> pointers = [];
  List<LatLng> firebaseLocationMarker = [];
  List<String> locstring = [];
  List<double> distvalue = [];
  late String lati = '0';
  late String longi = '0';
  double finalvalue = 10000;
  int listlocation = 0;
  String binColor = '';
  final mapControllers = MapController();
  Future<bool>? usercheck;
  bool? modeUser;
  bool? modeAdmin;

  late StreamSubscription<Position>
      _positionStream; //used for continuous gps update

  static Future<CacheStore> _getCacheStore() async {
    final dir = await getTemporaryDirectory();
    return FileCacheStore('${dir.path}${Platform.pathSeparator}MapTiles');
  }

  @override
  void initState() {
    super.initState();

    getCurrentLocation();
    usercheck = adminuser();
    printAllBinIds();
    fetchMarkersFromFirebase();
    userFirebaseMarker();

    //continuous update of gps
    _positionStream =
        Geolocator.getPositionStream().listen((Position position) {
      setState(() {
        currentlocation = LatLng(position.latitude, position.longitude);
      });
    });
  }

  @override
  void dispose() {
    _positionStream.cancel();
    super.dispose();
  }

  Future<void> printAllBinIds() async {
    DatabaseReference reference = FirebaseDatabase.instance
        .ref()
        .child('areas')
        .child(widget.areaId!)
        .child('bin_data');

    try {
      DatabaseEvent event = await reference.once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value != null && snapshot.value is Map<dynamic, dynamic>) {
        Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;

        debugPrint('All BinIds:');
        data.forEach((key, value) {
          debugPrint(key);
        });
      } else {
        debugPrint('Snapshot value is null or not a Map.');
      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
    }
  }

  Future<void> userFirebaseMarker() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref().child('users');
    try {
      DatabaseEvent event = await ref.once();
      DataSnapshot snapshot = event.snapshot;
      Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
      data.forEach((key, value) {
        if (value['Role'] == 'User') {
          double markerLat = double.parse(value['latitude'].toString());
          double markerLong = double.parse(value['longitude'].toString());
          debugPrint(markerLat.toString());
          debugPrint(markerLong.toString());
          debugPrint('above two are the values for the user marker');
          markersuser.add(
            Marker(
              point: LatLng(markerLat, markerLong),
              width: 90,
              height: 90,
              rotate: true,
              child: IconButton(
                splashRadius: 40,
                icon: const Icon(Icons.location_pin),
                color: const Color.fromARGB(255, 170, 24, 224),
                iconSize: 40,
                onPressed: () {
                  lati = markerLat.toString();
                  longi = markerLong.toString();
                  getCoordinates();
                },
              ),
            ),
          );
        }
      });
    } catch (e) {
      debugPrint('Error fetching data: $e');
    }
  }

  Future<void> fetchMarkersFromFirebase() async {
    debugPrint('hello World');

    DatabaseReference reference = FirebaseDatabase.instance
        .ref()
        .child('areas')
        .child(widget.areaId!)
        .child('bin_data');

    // Use try-catch to handle potential exceptions
    try {
      DatabaseEvent event = await reference.once();
      DataSnapshot snapshot = event.snapshot;

      // Check if the snapshot value is not null
      if (snapshot.value != null && snapshot.value is Map<dynamic, dynamic>) {
        Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;

        data.forEach((binId, binData) {
          if (binData['latitude'] != null && binData['longitude'] != null) {
            double markerLat = double.parse(binData['latitude'].toString());
            double markerLong = double.parse(binData['longitude'].toString());
            binColor = binData['bincolor'].toString();
            debugPrint(
                'BinId: $binId, Latitude: $markerLat, Longitude: $markerLong');
            locstring.add(binColor);
            firebaseLocationMarker.add(LatLng(markerLat, markerLong));
            markersbin.add(
              Marker(
                point: LatLng(markerLat, markerLong),
                width: 90,
                height: 90,
                rotate: true,
                child: IconButton(
                  splashRadius: 40,
                  icon: const Icon(Icons.location_pin),
                  color: binColor == 'white' ? Colors.green : Colors.red,
                  iconSize: 40,
                  onPressed: () {
                    lati = markerLat.toString();
                    longi = markerLong.toString();
                    getCoordinates();
                  },
                ),
              ),
            );
          }
        });

        setState(() {});
      } else {
        // Handle the case where snapshot value is null
        debugPrint('Snapshot value is null');
      }
    } catch (e) {
      // Handle exceptions
      debugPrint('Error fetching data1: $e');
    }
  }

  //adding marker dialog box
  Future<void> _showAddMarkerDialog(LatLng positions) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Marker'),
          content: Text(
              'Do you want to add a marker at this location? ${positions.latitude} & ${positions.longitude}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Add logic to create a marker at the pressed location
                markers.add(
                  Marker(
                    point: positions,
                    width: 90,
                    height: 90,
                    rotate: true,
                    child: IconButton(
                      icon: const Icon(Icons.location_pin),
                      color: Colors.yellow,
                      iconSize: 40,
                      onPressed: () {
                        lati = positions.latitude.toString();
                        longi = positions.longitude.toString();
                        getCoordinates();
                        // Handle marker tap event if needed
                      },
                    ),
                  ),
                );
                Navigator.of(context).pop();
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  Future<void> getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        forceAndroidLocationManager: true,
      );
      lat = position.latitude.toString();
      long = position.longitude.toString();

      debugPrint("Location: ${position.latitude}, ${position.longitude}");
      setState(() {
        currentlocation = LatLng(position.latitude, position.longitude);
        _radius();
      });
    } catch (e) {
      debugPrint("Error getting location : $e");
    }
  }

  List listOfPoints = [];
  List<LatLng> points = [];

  Future<void> _radius() async {
    debugPrint('hello');
    debugPrint(currentlocation.toString());
    debugPrint(firebaseLocationMarker.toString());
    await Future.delayed(const Duration(seconds: 2));
    for (var i = 0; i < firebaseLocationMarker.length; i++) {
      var p = 0.017453292519943295;
      var c = cos;
      var a = 0.5 -
          c((firebaseLocationMarker[i].latitude - currentlocation.latitude) *
                  p) /
              2 +
          c(currentlocation.latitude * p) *
              c(firebaseLocationMarker[i].latitude * p) *
              (1 -
                  c((firebaseLocationMarker[i].longitude -
                          currentlocation.longitude) *
                      p)) /
              2;
      var f = 1000 * (12742 * asin(sqrt(a)));
      distvalue.add(f);
      if (f < finalvalue) {
        finalvalue = f;
        listlocation = i;
      }
    }

    List<List<dynamic>> combined = List.generate(distvalue.length,
        (j) => [distvalue[j], locstring[j], firebaseLocationMarker[j]]);
    debugPrint(combined.toString());

    // Sort the combined list by the first element of each triple
    combined.sort((a, b) => a[0].compareTo(b[0]));
    debugPrint(combined.toString());

    // Split the combined list back into two lists
    distvalue = combined.map((triple) => triple[0] as double).toList();
    locstring = combined.map((triple) => triple[1] as String).toList();
    firebaseLocationMarker =
        combined.map((triple) => triple[2] as LatLng).toList();

    for (var k = 0; k < distvalue.length; k++) {
      if (locstring[k] == 'red') {
        lati = firebaseLocationMarker[k].latitude.toString();
        longi = firebaseLocationMarker[k].longitude.toString();
        debugPrint('$lati, $longi');
        getCoordinates();
        debugPrint('$lati, $longi');

        if (modeUser == true) {
          //timer
          if (distvalue[k] < 2000) {
            Timer(const Duration(seconds: 5), () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return const CountdownAlertDialog();
                },
              );
            });
          }
        }

        break;
      }
    }
  }

  Future<bool> adminuser() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    String? email = user?.email;
    if (user == null) {
      debugPrint('No user found');
    } else {
      debugPrint(email);
    }
    DatabaseReference usersRef = FirebaseDatabase.instance.ref().child('users');
    DatabaseEvent event = await usersRef.once();
    DataSnapshot snapshot = event.snapshot;
    Map<dynamic, dynamic> users = snapshot.value as Map<dynamic, dynamic>;
    for (var key in users.keys) {
      String? mail = users[key]['UserEmail'];
      String? userrole = users[key]['Role'];

      if (mail == email && userrole == "Admin") {
        debugPrint(mail);
        debugPrint(userrole);
        modeAdmin = true;
        return true;
      }
      if (mail == email && userrole == "User") {
        debugPrint(mail);
        debugPrint(userrole);
        modeUser = true;
        return false;
      }
    }
    return false;
  }

  //function to service Output API

  getCoordinates() async {
    var request = await http.get(getRouteUrl("$long,$lat",
        "$longi,$lati" /*format:"start_long,start_lat","end_long,end_lat"*/));

    setState(() {
      if (request.statusCode == 200) {
        var data = jsonDecode(request.body);
        listOfPoints = data['features'][0]['geometry']['coordinates'];
        points = listOfPoints
            .map((e) => LatLng(e[1].toDouble(), e[0].toDouble()))
            .toList();
      } else {
        debugPrint('failed : ${request.statusCode}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // show a loading screen when _cacheStore hasn't been set yet
    return FutureBuilder<CacheStore>(
      future: _cacheStoreFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final cacheStore = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.title),
            ),
            body: Stack(
              children: [
                FlutterMap(
                  mapController: mapControllers,
                  options: MapOptions(
                    initialCenter: currentlocation,
                    initialZoom: 15,
                    maxZoom: 20,
                    minZoom: 5,
                    onLongPress: (tapPosition, positions) {
                      _showAddMarkerDialog(positions);
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      tileProvider: CachedTileProvider(
                        store: cacheStore,
                        maxStale: const Duration(days: 30),
                      ),
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: currentlocation,
                          width: 90,
                          height: 90,
                          rotate: true,
                          child: IconButton(
                            icon: const Icon(Icons.location_pin),
                            color: Colors.blue,
                            iconSize: 40,
                            onPressed: () {
                              _radius();
                              // Handle marker tap event if needed
                            },
                          ),
                        ),
                      ],
                    ),
                    MarkerLayer(markers: markers),
                    MarkerLayer(markers: markersbin),
                    if (modeAdmin == true) MarkerLayer(markers: markersuser),
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: points,
                          color: Colors.blue,
                          strokeWidth: 5,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        }
        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
