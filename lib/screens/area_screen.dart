import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:smart_bin_flutter/screens/add_area.dart';
import 'package:smart_bin_flutter/screens/homescreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:smart_bin_flutter/screens/login_screen.dart';

class AreaList extends StatefulWidget {
  const AreaList({super.key});

  @override
  State<AreaList> createState() => _AreaListState();
}

class _AreaListState extends State<AreaList> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  LocationPermission? _status;
  String? keystore;
  Future<bool>? usercheck;
  late Stream _areaStream;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  List<int> activeNotifications = [];
  DateTime? lastNotificationTime;

  @override
  void initState() {
    super.initState();
    usercheck = adminuser();
    _subscribeToAreaChanges();
    initializeNotifications();
    requestLocationPermission();
  }

  Future<void> initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );

    await requestNotificationPermission();
  }

  StreamSubscription<User?>? authSubscription;

  Future<void> setupUserStatusListener(String userKey) async {
    debugPrint(userKey);
    DatabaseReference usersRef = FirebaseDatabase.instance.ref().child('users');

    // Cancel the previous subscription if it exists
    authSubscription?.cancel();

    // Start a new subscription
    authSubscription = FirebaseAuth.instance.userChanges().listen((User? user) {
      if (user == null) {
        debugPrint('User is currently signed out!');
        usersRef.child(userKey).update({'status': 'offline'});
      } else {
        debugPrint('User is signed in!');
        usersRef.child(userKey).update({'status': 'online'});
        usersRef.child(userKey).onDisconnect().update({'status': 'offline'});
      }
    });
  }

  Future<bool> adminuser() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    String? email = user?.email;
    String? userKey;

    if (user == null) {
      debugPrint('No user found');
      return false;
    }
    var a = 1;
    DatabaseReference usersRef = FirebaseDatabase.instance.ref().child('users');
    DatabaseEvent event = await usersRef.once();
    DataSnapshot snapshot = event.snapshot;
    Map<dynamic, dynamic> users = snapshot.value as Map<dynamic, dynamic>;

    for (var key in users.keys) {
      String? mail = users[key]['UserEmail'];
      String? userrole = users[key]['Role'];

      if (mail == email) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          forceAndroidLocationManager: true,
        );
        String lat = position.latitude.toString();
        String long = position.longitude.toString();
        usersRef.child(key).update({'latitude': lat, 'longitude': long});

        if (userrole == "Admin") {
          userKey = key;
          debugPrint('Admin user : $userKey');
          a = 1; // store the key of the logged in user
          break;
        }
        if (userrole == "User") {
          userKey = key;
          debugPrint('User user : $userKey');
          a = 2;
          break;
        }
      }
    }

    if (userKey != null && a == 1) {
      await setupUserStatusListener(userKey);
      return true;
    }
    if (userKey != null && a == 2) {
      await setupUserStatusListener(userKey);
      return false;
    }

    return false;
  }

  Future<void> requestNotificationPermission() async {
    final PermissionStatus status = await Permission.notification.request();
    if (status.isDenied) {
      _showNotificationPermissionDialog();
    }
  }

  Future<void> requestLocationPermission() async {
    _status = await Geolocator.checkPermission();
    if (_status == LocationPermission.denied) {
      _status = await Geolocator.requestPermission();
      if (_status == LocationPermission.denied) {
        // Location permission granted, proceed with getting the location
        _showLocationDialogBox();
      } else {
        // Handle denied or restricted permission
        // You may show a dialog or provide information to the user
      }
    }
  }

  Future<void> _subscribeToAreaChanges() async {
    final FirebaseDatabase database = FirebaseDatabase.instance;
    final DatabaseReference areasRef = database.ref().child('areas');

    _areaStream = areasRef.orderByChild('name').onValue;
  }

  Future<void> keepLogin(String emailValue) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString('email', emailValue);
  }

  Future<void> _showNotification(
      String areaName, String binName, bool isFull) async {
    final currentTime = DateTime.now();
    if (lastNotificationTime != null &&
        currentTime.difference(lastNotificationTime!) <
            const Duration(minutes: 1)) {
      return;
    }

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'smart_bins',
      'bin_alert',
      importance: Importance.high,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    final notificationId = activeNotifications.length + 1;

    if (isFull == true) {
      String notificationText = '$binName in $areaName is Full';
      await flutterLocalNotificationsPlugin.show(
        notificationId,
        notificationText,
        '',
        platformChannelSpecifics,
        payload: notificationId.toString(),
      );
    }

    activeNotifications.add(notificationId);

    // Update the last notification time
    lastNotificationTime = currentTime;
  }

  void _onNotificationDismissed(int notificationId) {
    activeNotifications.remove(notificationId);
  }

  Future<void> _showLocationDialogBox() async {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('GPS location is required'),
        content: const Text(
          'Please grant permission for GPS in the app settings.',
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () async {
              Navigator.pop(context);
              final bool isOpened = await openAppSettings();
              if (!isOpened) {
                _scaffoldMessengerKey.currentState?.showSnackBar(
                  const SnackBar(
                    content: Text('Could not open app settings.'),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  //For Notification

  Future<void> _showNotificationPermissionDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Notification Permission Required'),
        content: const Text(
          'Please grant permission for notifications in the app settings.',
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () async {
              Navigator.pop(context);
              final bool isOpened = await openAppSettings();
              if (!isOpened) {
                _scaffoldMessengerKey.currentState?.showSnackBar(
                  const SnackBar(
                    content: Text('Could not open app settings.'),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 15, 45, 2),
        centerTitle: true,
        title: const Text(
          "Waste Management",
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 25,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        elevation: 0.0,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.person),
            color: const Color.fromARGB(255, 255, 255, 255),
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
            },
          )
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  Colors.green.shade300,
                  Colors.green.shade400,
                ],
                center: Alignment.center,
                radius: 1.0,
              ),
            ),
            child: StreamBuilder(
              stream: _areaStream,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  final Map<dynamic, dynamic> areas =
                      snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                  return ListView.builder(
                    itemCount: areas.length,
                    itemBuilder: (BuildContext context, int index) {
                      final List<dynamic> valuesList = areas.values.toList();
                      final Map<dynamic, dynamic> area =
                          valuesList.elementAt(index);
                      bool hasRedBin = false;
                      final List<dynamic> fullBins = [];

                      area['bin_data']?.forEach((key, value) {
                        String binValueNew = value['bin1'];
                        String binValueNew2 = value['bin2'];
                        String binValueNew3 = value['bin3'];
                        String binheightnew = value['binheight'];
                        int height1 = 0;
                        int percent1 = 0;
                        int percent2 = 0;
                        int percent3 = 0;
                        double val1 = double.parse(binValueNew);
                        double val2 = double.parse(binValueNew2);
                        double val3 = double.parse(binValueNew3);
                        height1 = int.parse(binheightnew);
                        double percentage1 =
                            ((val1 - 26) / (height1 - 26)) * 10;
                        percent1 = 100 - ((percentage1.round()) * 10);
                        double percentage2 =
                            ((val2 - 26) / (height1 - 26)) * 10;
                        percent2 = 100 - ((percentage2.round()) * 10);
                        double percentage3 =
                            ((val3 - 26) / (height1 - 26)) * 10;
                        percent3 = 100 - ((percentage3.round()) * 10);

                        if (percent1 > 100) {
                          percent1 = 100;
                        } else if (percent1 < 0) {
                          percent1 = 0;
                        }

                        if (percent1 >= 90 ||
                            percent2 >= 90 ||
                            percent3 >= 90) {
                          hasRedBin = true;
                          fullBins.add({
                            'name': area['name'],
                            'binname': value['binname']
                          });
                        }
                      });

                      for (var bin in fullBins) {
                        _showNotification(
                          bin['name'],
                          bin['binname'],
                          true,
                        );
                      }

                      return Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                        decoration: BoxDecoration(
                          color: hasRedBin ? Colors.red : Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: InkWell(
                          onTap: () {
                            String? areaId = areas.keys.elementAt(index);
                            if (areaId != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      HomePage(areaId: areaId),
                                ),
                              );
                            }
                          },
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: hasRedBin ? Colors.red : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                area['name'],
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          Positioned(
            bottom: 20.0,
            right: 20.0,
            child: FutureBuilder(
              future: usercheck,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData && snapshot.data == true) {
                  return FloatingActionButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return const AddareaForm();
                        },
                      );
                    },
                    child: const Icon(Icons.add),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ),
          Positioned(
            bottom: 80.0,
            right: 20.0,
            child: Column(
              children: [
                for (var notificationId in activeNotifications)
                  Dismissible(
                    key: Key(notificationId.toString()),
                    direction: DismissDirection.horizontal,
                    onDismissed: (_) =>
                        _onNotificationDismissed(notificationId),
                    child: const ListTile(
                      title: Text('Bin ALert'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
