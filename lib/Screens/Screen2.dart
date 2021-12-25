import 'package:flutter/material.dart';
import '../Components/CustimableAppBar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import '../Screens/Screen1.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import '../Constants/constants.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class Screen2 extends StatefulWidget {
  @override
  final int durationValue;
  final DateTime selectedDate;
  final bool isDose1;
  final DistrictData selectedDistrict;
  final String vaccineName;
  final String doseText;
  final String pin;
  final bool isDistrict;
  final String fee_type;

  Screen2({
    required this.durationValue,
    required this.selectedDate,
    required this.isDose1,
    required this.selectedDistrict,
    required this.vaccineName,
    required this.doseText,
    required this.pin,
    required this.isDistrict,
    required this.fee_type,
  });
  State<StatefulWidget> createState() {
    return _Screen2State(
        this.durationValue,
        this.selectedDate,
        this.isDose1,
        this.selectedDistrict,
        this.vaccineName,
        this.doseText,
        this.pin,
        this.isDistrict,
        this.fee_type);
  }
}

class _Screen2State extends State<Screen2> {
  bool isStop = false;
  int durationValue;
  DateTime selectedDate;
  bool isDose1;
  DistrictData selectedDistrict;
  String vaccineName;
  String doseText;
  String pin;
  bool isDistrict;
  String fee_type;

  _Screen2State(
      this.durationValue,
      this.selectedDate,
      this.isDose1,
      this.selectedDistrict,
      this.vaccineName,
      this.doseText,
      this.pin,
      this.isDistrict,
      this.fee_type);

  bool status = true;

  List<VaccineData> apiData = [];

  void getResponse() async {
    List<VaccineData> list = [];
    String date = selectedDate.toString().substring(0, 10);
    String finalDate = '';
    String dd = date.substring(8, 10);
    String mm = date.substring(5, 7);
    String yy = date.substring(0, 4);
    finalDate += (dd + "-" + mm + '-' + yy);
    // print("Date is " + finalDate);
    http.Response response;
    EasyLoading.show(
      status: 'Fetching',
    );
    if (isDistrict)
      response = await http.get(Uri.parse(
          "https://cdn-api.co-vin.in/api/v2/appointment/sessions/public/findByDistrict?district_id=${selectedDistrict.district_id}&date=$finalDate"));
    else
      response = await http.get(Uri.parse(
          "https://cdn-api.co-vin.in/api/v2/appointment/sessions/public/findByPin?pincode=$pin&date=$finalDate"));
    var data = response.body;

    var jsonData = json.decode(data)['sessions'];
    // print(jsonData);
    for (var v in jsonData) {
      if (isDose1) {
        if (v['available_capacity'] > 0 &&
            v['available_capacity_dose1'] > 0 &&
            v['vaccine'] == vaccineName &&
            v['fee_type'] == fee_type) {
          VaccineData vc = VaccineData(
              centerName: v['name'],
              availableSlots: v['available_capacity'],
              availableDose1Slots: v['available_capacity_dose1'],
              availableDose2Slots: v['available_capacity_dose2'],
              address: v['address']);
          list.add(vc);
          // print(vc);
        }
      } else {
        if (v['available_capacity'] > 0 &&
            v['available_capacity_dose2'] > 0 &&
            v['vaccine'] == vaccineName &&
            v['fee_type'] == fee_type) {
          VaccineData vc = VaccineData(
              centerName: v['name'],
              availableSlots: v['available_capacity'],
              availableDose1Slots: v['available_capacity_dose1'],
              availableDose2Slots: v['available_capacity_dose2'],
              address: v['address']);
          list.add(vc);
        }
      }
      EasyLoading.dismiss();
      _timer?.cancel();
    }

    setState(() {
      apiData = list;
    });
    // print(list);
    if (list.length > 0 && status) {
      playSound();
    }
  }

  void playSound() {
    final player = AudioCache();
    if (!isStop)
      player.play('alarm.wav');
    else
      player.clearAll();
  }

  startTimer() async {
    Timer.periodic(
      new Duration(seconds: durationValue),
      (timer) {
        if (isStop) {
          timer.cancel();
        }
        if (isStop == false) {
          getResponse();
        }
      },
    );
  }

  Timer? _timer;
  late double _progress;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getResponse();
    EasyLoading.addStatusCallback((status) {
      print('EasyLoading Status $status');
      if (status == EasyLoadingStatus.dismiss) {
        _timer?.cancel();
      }
    });
    EasyLoading.show(
      status: 'Fetching',
    );
    setState(() {
      isStop = false;
    });
    startTimer();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: CustomAppBar(),
        body: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  launch('https://selfregistration.cowin.gov.in/');
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Login To Cowin'),
                ),
                style: ElevatedButton.styleFrom(
                    primary: Colors.green[400], shape: StadiumBorder()),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(kDropDownRadius),
                      bottomRight: Radius.circular(kDropDownRadius),
                      bottomLeft: Radius.circular(kDropDownRadius)),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      offset: Offset(0.0, 2.0), //(x,y)
                      blurRadius: 6.0,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: 10.0),
                        child: Text(
                          'Alert sound : ',
                          style: kTextStyle,
                        ),
                      ),
                      SizedBox(
                          child: Switch(
                        activeColor: Colors.indigo[400],
                        value: status,
                        onChanged: (value) {
                          setState(() {
                            status = value;
                          });
                        },
                      )),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isStop = true;
                    });
                    startTimer();
                    Navigator.pop(context,
                        MaterialPageRoute(builder: (context) => Screen1()));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Stop'),
                  ),
                  style: ElevatedButton.styleFrom(
                      primary: Colors.indigo[400], shape: StadiumBorder()),
                ),
              ),
            ),
            apiData.length > 0
                ? Container(
                    child: ListView.builder(
                        physics: ClampingScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: apiData.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(kDropDownRadius),
                                    bottomRight:
                                        Radius.circular(kDropDownRadius),
                                    bottomLeft:
                                        Radius.circular(kDropDownRadius)),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey,
                                    offset: Offset(0.0, 2.0), //(x,y)
                                    blurRadius: 6.0,
                                  ),
                                ],
                              ),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.only(
                                          top: 12.0,
                                          left: 16.0,
                                          bottom: 8.0,
                                          right: 8.0),
                                      child: Text(
                                        apiData[index].centerName,
                                        softWrap: false,
                                        overflow: TextOverflow.fade,
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(
                                          top: 8.0, left: 16.0, bottom: 8.0),
                                      child: Text(
                                        apiData[index].address.toLowerCase(),
                                        softWrap: false,
                                        overflow: TextOverflow.fade,
                                        style: TextStyle(
                                            fontSize: 15.0, color: Colors.grey),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(
                                          top: 8.0, left: 16.0, bottom: 8.0),
                                      child: Row(
                                        children: [
                                          Text(
                                            '$vaccineName',
                                            style: TextStyle(
                                                color: Colors.indigo[400],
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(
                                          top: 8.0, left: 16.0, bottom: 8.0),
                                      child: Row(
                                        children: [
                                          Text(
                                            '$doseText: ',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {},
                                            style: ElevatedButton.styleFrom(
                                                primary: Colors.green),
                                            child: Text(
                                              isDose1
                                                  ? apiData[index]
                                                      .availableDose1Slots
                                                      .toString()
                                                  : apiData[index]
                                                      .availableDose2Slots
                                                      .toString(),
                                              style: TextStyle(fontSize: 15.0),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 20.0),
                                            child: Text(
                                              'Fee Type : ',
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 15.0,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {},
                                            style: ElevatedButton.styleFrom(
                                                primary: (fee_type == 'Free')
                                                    ? Colors.green
                                                    : Colors.red),
                                            child: Text(
                                              fee_type,
                                              style: TextStyle(fontSize: 15.0),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Container(
                                    //   padding: EdgeInsets.only(
                                    //       top: 8.0, left: 16.0, bottom: 8.0),
                                    //   child: Row(
                                    //     children: [
                                    //       Padding(
                                    //         padding:
                                    //             const EdgeInsets.only(left: 20.0),
                                    //         child: Text(
                                    //           'Fee Type : ',
                                    //           style: TextStyle(
                                    //               color: Colors.black,
                                    //               fontSize: 15.0,
                                    //               fontWeight: FontWeight.bold),
                                    //         ),
                                    //       ),
                                    //       ElevatedButton(
                                    //         onPressed: () {},
                                    //         style: ElevatedButton.styleFrom(
                                    //             primary: (fee_type == 'Free')
                                    //                 ? Colors.green
                                    //                 : Colors.red),
                                    //         child: Text(
                                    //           fee_type,
                                    //           style: TextStyle(fontSize: 15.0),
                                    //         ),
                                    //       ),
                                    //     ],
                                    //   ),
                                    // )
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                  )
                : Container(
                    margin: EdgeInsets.only(top: 30.0),
                    child: Center(
                      child: Text(
                        'No Slots available',
                        style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black45),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class VaccineData {
  final String centerName;
  final int availableSlots;
  final int availableDose1Slots;
  final int availableDose2Slots;
  final String address;
  VaccineData(
      {required this.centerName,
      required this.availableSlots,
      required this.availableDose1Slots,
      required this.availableDose2Slots,
      required this.address});
}
