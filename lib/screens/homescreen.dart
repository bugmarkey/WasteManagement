import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:smart_bin_flutter/screens/add_bin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_bin_flutter/addon/maps.dart';
import 'package:smart_bin_flutter/screens/update.dart';

class HomePage extends StatefulWidget {
  final String areaId;

  const HomePage({super.key, required this.areaId});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double val1 = 0;
  double val2 = 0;
  double val3 = 0;
  String str1 = '';
  double val5 = 0;
  double val9 = 0;
  int height1 = 0;
  double temp1 = 0;
  Future<bool>? usercheck;
  int percent1 = 0;
  int percent2 = 0;
  int percent3 = 0;
  int percent = 0;
  String binId = "";
  int cpercent1 = 0;
  int wh1 = 0;

  Query? _ref;
  DatabaseReference reference = FirebaseDatabase.instance.ref().child('areas');

  Future<void> keeplogin(emailvalue) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString('email', emailvalue);
  }

  @override
  void initState() {
    usercheck = adminuser();
    super.initState();
    _ref = FirebaseDatabase.instance
        .ref()
        .child('areas')
        .child(widget.areaId)
        .child('bin_data')
        .orderByChild('binname');
    //recently add
  }

  Future<bool> adminuser() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    String? email = user?.email;
    if (user == null) {
      print('No user found');
    } else {
      print(email);
    }
    DatabaseReference usersRef = FirebaseDatabase.instance.ref().child('users');
    DatabaseEvent event = await usersRef.once();
    DataSnapshot snapshot = event.snapshot;
    Map<dynamic, dynamic> users = snapshot.value as Map<dynamic, dynamic>;
    for (var key in users.keys) {
      String? mail = users[key]['UserEmail'];
      String? userrole = users[key]['Role'];

      if (mail == email && userrole == "Admin") {
        print(mail);
        print(userrole);
        return true;
      }
    }
    return false;
  }

  Widget _buildContactItem({Map? contact, required String bin}) {
    //str1 = contact?['var1'];
    val1 = double.parse(contact?['bin1']);
    val2 = double.parse(contact?['bin2']);
    val3 = double.parse(contact?['bin3']);
    height1 = int.parse(contact?['binheight']);
    double percentage1 = ((val1 - 26) / (height1 - 26)) * 10;
    double percentage2 = ((val2 - 26) / (height1 - 26)) * 10;
    double percentage3 = ((val3 - 26) / (height1 - 26)) * 10;
    percent1 = 100 - ((percentage1.round()) * 10);
    print(percent1);
    percent2 = 100 - ((percentage2.round()) * 10);
    percent3 = 100 - ((percentage3.round()) * 10);

    if ((percent1 < 100) && (percent1 >= 90)) {
      percent = 100;
    } else if ((percent1 > 0 || percent2 > 0 || percent3 > 0) &&
        (percent1 < 90 || percent2 < 90 || percent3 < 90)) {
      percent = 0;
    }

    //val9 = percent1 / 100;

    checkColor(var b, var c, var d) {
      if (b >= 80 || c >= 80 || d >= 80) {
        reference
            .child(widget.areaId)
            .child("bin_data")
            .child(bin)
            .update({"bincolor": "red"});
        return const Color.fromARGB(255, 242, 75, 75);
      } else {
        reference
            .child(widget.areaId)
            .child("bin_data")
            .child(bin)
            .update({"bincolor": "white"});
        return Colors.white;
      }
    }

    return SizedBox(
      child: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          margin: const EdgeInsets.fromLTRB(15.0, 6.0, 15.0, 0.0),
          color: checkColor(percent1, percent2, percent3),
          child: ListTile(
            leading: Image.asset("assets/bin1.png"),
            onTap: () async {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => EditContact(
                            binId: bin,
                            areaId: widget.areaId,
                          )));
            },
            title: Text(
              contact?['binname'],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(contact?['location'],
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    usercheck = adminuser();
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 15, 45, 2),
          centerTitle: true,
          title: const Text("Watch Your Waste",
              style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 25,
                  color: Color.fromARGB(255, 255, 255, 255))),
          elevation: 0.0,
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.person),
              color: const Color.fromARGB(255, 255, 255, 255),
              onPressed: () async {
                setState(() {
                  keeplogin('');
                });
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
              child: FirebaseAnimatedList(
                query: _ref!,
                itemBuilder: (BuildContext context, DataSnapshot snapshot,
                    Animation<double> animation, int index) {
                  Map contact = snapshot.value as Map<dynamic, dynamic>;
                  binId = snapshot.key!;
                  return _buildContactItem(contact: contact, bin: binId);
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
                            return AddBinForm(
                              areaId: widget.areaId,
                            );
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
              bottom: 20.0,
              left: 20.0,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MapLocator(
                          areaId: widget.areaId,
                          binId: binId,
                        ),
                      ));
                },
                child: const Icon(
                  Icons.location_pin,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ));
  }
}
