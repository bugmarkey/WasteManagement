import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class EditContact extends StatefulWidget {
  final String binId;
  final String? areaId;

  const EditContact({super.key, required this.binId, this.areaId});

  @override
  State<EditContact> createState() => _EditContactState();
}

class _EditContactState extends State<EditContact> {
  String y = '';
  String z = '';
  String a = '';
  double val1 = 0;
  double val2 = 0;
  double val3 = 0;
  String str1 = '';
  String str2 = '';
  String str3 = '';
  double val9 = 0;
  double val10 = 0;
  double val11 = 0;
  int height1 = 0;
  int percent1 = 0;
  int height2 = 0;
  int percent2 = 0;
  int height3 = 0;
  int percent3 = 0;

  DatabaseReference? _ref;

  @override
  void initState() {
    super.initState();
    _ref = FirebaseDatabase.instance
        .ref()
        .child('areas')
        .child(widget.areaId!)
        .child('bin_data');
    getContactDetail();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromRGBO(4, 9, 35, 1),
                Color.fromRGBO(39, 105, 171, 1),
              ],
              begin: FractionalOffset.bottomCenter,
              end: FractionalOffset.topCenter,
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 73),
              child: Column(
                children: [
                  const Text(
                    'Bin Setting',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontFamily: 'Nisebuschgardens',
                    ),
                  ),
                  const SizedBox(
                    height: 0,
                  ),
                  SizedBox(
                    height: height * 0.3,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        double innerHeight = constraints.maxHeight;
                        double innerWidth = constraints.maxWidth;
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: innerHeight * 0.72,
                                width: innerWidth,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: Colors.white,
                                ),
                                child: Column(
                                  children: [
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Text(
                                      y,
                                      style: const TextStyle(
                                        color: Color.fromRGBO(39, 105, 171, 1),
                                        fontFamily: 'Nunito',
                                        fontSize: 37,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Column(
                                          children: [
                                            Text(
                                              'Model',
                                              style: TextStyle(
                                                color: Colors.grey[700],
                                                fontFamily: 'Nunito',
                                                fontSize: 25,
                                              ),
                                            ),
                                            Text(
                                              z,
                                              style: const TextStyle(
                                                color: Color.fromRGBO(
                                                    39, 105, 171, 1),
                                                fontFamily: 'Nunito',
                                                fontSize: 20,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 25,
                                            vertical: 8,
                                          ),
                                          child: Container(
                                            height: 50,
                                            width: 3,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                        Column(
                                          children: [
                                            Text(
                                              "Battery Level",
                                              style: TextStyle(
                                                color: Colors.grey[700],
                                                fontFamily: 'Nunito',
                                                fontSize: 25,
                                              ),
                                            ),
                                            Text(
                                              a,
                                              style: const TextStyle(
                                                color: Color.fromRGBO(
                                                    39, 105, 171, 1),
                                                fontFamily: 'Nunito',
                                                fontSize: 20,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Container(
                    height: height * 0.5,
                    width: width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.white,
                    ),
                    child: Wrap(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(5, 20, 5, 0),
                                    //GREEN BIN
                                    child: CircularPercentIndicator(
                                      radius: 80,
                                      lineWidth: 10,
                                      backgroundColor: Colors.grey,
                                      percent: val9,
                                      progressColor: Colors.green,
                                      circularStrokeCap:
                                          CircularStrokeCap.round,
                                      animation: true,
                                      center: Text(
                                        "$str1 \n $percent1 %",
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(20, 20, 0, 0),
                                    //RED BIN
                                    child: CircularPercentIndicator(
                                      radius: 80,
                                      lineWidth: 10,
                                      backgroundColor: Colors.grey,
                                      percent: val10,
                                      progressColor: Colors.red,
                                      circularStrokeCap:
                                          CircularStrokeCap.round,
                                      animation: true,
                                      center: Text(
                                        "$str2 \n $percent2 %",
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                //BLUE BIN
                                child: CircularPercentIndicator(
                                  radius: 80,
                                  lineWidth: 10,
                                  backgroundColor: Colors.grey,
                                  percent: val11,
                                  progressColor: Colors.blue,
                                  circularStrokeCap: CircularStrokeCap.round,
                                  animation: true,
                                  center: Text(
                                    "$str3 \n $percent3 %",
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void getContactDetail() {
    _ref!.child(widget.binId).onValue.listen((event) {
      DataSnapshot snapshot = event.snapshot;

      Map contact = snapshot.value as Map<dynamic, dynamic>;

      setState(() {
        y = contact['binname'];
        z = contact['model'];
        a = contact['batterylevel'] + "%";
        str1 = contact['var1'];
        str2 = contact['var2'];
        str3 = contact['var3'];
        val1 = double.parse(contact['bin1']);
        val2 = double.parse(contact['bin2']);
        val3 = double.parse(contact['bin3']);
        height1 = int.parse(contact['binheight']);

        double percentage1 = ((val1 - 26.0) / (height1 - 26.0)) * 10;
        double percentage2 = ((val2 - 26.0) / (height1 - 26.0)) * 10;
        double percentage3 = ((val3 - 26.0) / (height1 - 26.0)) * 10;
        percent1 = 100 - ((percentage1.round()) * 10);
        percent2 = 100 - ((percentage2.round()) * 10);
        percent3 = 100 - ((percentage3.round()) * 10);
        //BIN 1
        if (percent1 > 100) {
          percent1 = 100;
        } else if (percent1 < 0) {
          percent1 = 0;
        }
        val9 = percent1 / 100;
        //BIN 2
        if (percent2 > 100) {
          percent2 = 100;
        } else if (percent2 < 0) {
          percent2 = 0;
        }
        val10 = percent2 / 100;
        //BIN 3
        if (percent3 > 100) {
          percent3 = 100;
        } else if (percent3 < 0) {
          percent3 = 0;
        }
        val11 = percent3 / 100;
      });
    });
  }
}
