import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vaccine_finder/Components/CustimableAppBar.dart';
import '../Components/CustimableAppBar.dart';
import '../Constants/constants.dart';
import 'package:http/http.dart' as http;
import '../Screens/Screen2.dart';

enum MyRadioButtons { dose1, dose2 }
enum MyVaccineNames { covishield, covaxine }

class Screen1 extends StatefulWidget {
  const Screen1({Key? key}) : super(key: key);

  @override
  _Screen1State createState() => _Screen1State();
}

class _Screen1State extends State<Screen1> {
  List<int> duration = [10, 15, 20, 30, 60];
  int durationValue = 15;
  StateData selectedState =
      StateData(state_id: '21', state_name: 'Maharashtra');
  List<StateData> statesList = [];
  List<DistrictData> districtList = [];
  DistrictData selectedDistrict =
      DistrictData(district_id: '363', district_name: 'Pune');

  DateTime selectedDate = DateTime.now();

  bool isDose1 = true;
  String doseText = "Dose1";
  String vaccineName = "COVISHIELD";
  bool isCoShield = true;
  MyRadioButtons? _doseNum = MyRadioButtons.dose1;
  MyVaccineNames? _vaccineNames = MyVaccineNames.covishield;
  bool status = false;
  bool isStop = true;
  bool isDistrict = true;
  int pinCode = 0;
  TextEditingController _inputController = TextEditingController();
  final validPin = RegExp(r'^[1-9]{1}[0-9]{2}\\s{0, 1}[0-9]{3}$');
  String pin = "416 415";
  bool pin_valid = false;
  String fee_type = "Free";

  void getStates() async {
    http.Response response = await http.get(
      Uri.parse('https://cdn-api.co-vin.in/api/v2/admin/location/states'),
    );
    var data = json.decode(response.body)['states'];
    List<StateData> temp = [];
    for (var i in data) {
      StateData stateData = new StateData(
          state_id: i['state_id'].toString(), state_name: i['state_name']);
      temp.add(stateData);
    }
    setState(() {
      statesList = temp;
      selectedState = temp[21];
    });
  }

  void getDistrict() async {
    http.Response response = await http.get(
      Uri.parse(
          'https://cdn-api.co-vin.in/api/v2/admin/location/districts/${selectedState.state_id}'),
    );
    var data = json.decode(response.body)['districts'];
    List<DistrictData> temp = [];
    int cnt = 0;
    for (var i in data) {
      DistrictData districtData = new DistrictData(
          district_id: i['district_id'].toString(),
          district_name: i['district_name']);
      temp.add(districtData);
    }
    setState(() {
      districtList = temp;
      selectedDistrict = temp[0];
    });
  }

  GlobalKey<FormState> formkey = GlobalKey<FormState>();

  void validate() {
    if (formkey.currentState!.validate()) {
      print("validate");
    } else {
      print("not");
    }
  }

  void valid_pin(value) async {
    String date = selectedDate.toString().substring(0, 10);
    String finalDate = '';
    String dd = date.substring(8, 10);
    String mm = date.substring(5, 7);
    String yy = date.substring(0, 4);
    finalDate += (dd + "-" + mm + '-' + yy);
    // print("Date is " + finalDate);

    http.Response response = await http.get(
      Uri.parse(
          'https://cdn-api.co-vin.in/api/v2/appointment/sessions/public/findByPin?pincode=$value&date=$finalDate'),
    );

    var data = json.decode(response.body);

    if (data['error'] == null) {
      setState(() {
        pin_valid = true;
      });
    } else {
      setState(() {
        pin_valid = false;
      });
    }

    // print(data);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getStates();
    getDistrict();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15.0),
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
                        padding: const EdgeInsets.all(15.0),
                        child: Text(
                          'Below Select Duration input field is to fetch the vaccination slot details after every selected seconds',
                          style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Text(
                      'Select Duration(in seconds): ',
                      style: TextStyle(
                          color: Colors.black45, fontWeight: FontWeight.w900),
                    ),
                  ),
                  CustomDropDown(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isDistrict = true;
                                });
                              },
                              child: Text(
                                'By District',
                                style: TextStyle(
                                    color: (isDistrict
                                        ? Colors.white
                                        : Colors.black45)),
                              ),
                              style: ElevatedButton.styleFrom(
                                primary: (isDistrict
                                    ? Colors.indigo[400]
                                    : Colors.white),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isDistrict = false;
                                });
                              },
                              child: Text(
                                'By Pin',
                                style: TextStyle(
                                    color: (isDistrict == false
                                        ? Colors.white
                                        : Colors.black45)),
                              ),
                              style: ElevatedButton.styleFrom(
                                primary: (isDistrict == false
                                    ? Colors.indigo[400]
                                    : Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  (isDistrict)
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Text(
                                'Select State : ',
                                style: TextStyle(
                                    color: Colors.black45,
                                    fontWeight: FontWeight.w900),
                              ),
                            ),
                            CustomStateDropDown(),
                            Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Text(
                                'Select District : ',
                                style: TextStyle(
                                    color: Colors.black45,
                                    fontWeight: FontWeight.w900),
                              ),
                            ),
                            CustomDistrictDropDown(),
                          ],
                        )
                      : Column(
                          children: [
                            Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                        topLeft:
                                            Radius.circular(kDropDownRadius),
                                        bottomRight:
                                            Radius.circular(kDropDownRadius),
                                        bottomLeft:
                                            Radius.circular(kDropDownRadius)),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: (pin_valid
                                            ? Colors.grey
                                            : Colors.red),
                                        offset: Offset(0.0, 2.0), //(x,y)
                                        blurRadius: 6.0,
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 10.0),
                                    child: Form(
                                      key: formkey,
                                      child: Column(
                                        children: [
                                          TextFormField(
                                            autovalidateMode:
                                                AutovalidateMode.always,
                                            style: TextStyle(
                                              color: Colors.black45,
                                            ),
                                            controller: _inputController,
                                            decoration: InputDecoration(
                                              hintText: "Enter Pin Code",
                                              border: InputBorder.none,
                                            ),
                                            keyboardType: TextInputType.number,
                                            validator: (value) {
                                              valid_pin(value);
                                              if (pin_valid == true) {
                                                pin = value!;
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )),
                          ],
                        ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Text(
                      'Select Date : ',
                      style: kTextStyle,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
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
                      child: Center(
                        child: SizedBox(
                            height: 200.0,
                            width: 300,
                            child: CupertinoDatePicker(
                              minimumYear: 2021,
                              maximumYear: 2023,
                              initialDateTime: DateTime.now(),
                              mode: CupertinoDatePickerMode.date,
                              onDateTimeChanged: (dateTime) {
                                setState(() {
                                  selectedDate = dateTime;
                                });
                              },
                            )),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Text(
                      'Select Vaccine : ',
                      style: kTextStyle,
                    ),
                  ),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                isCoShield = true;
                                vaccineName = "COVISHIELD";
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(kDropDownRadius),
                                    bottomRight:
                                        Radius.circular(kDropDownRadius),
                                    bottomLeft:
                                        Radius.circular(kDropDownRadius)),
                                color: (vaccineName == "COVISHIELD")
                                    ? Colors.indigo[400]
                                    : Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey,
                                    offset: Offset(0.0, 2.0), //(x,y)
                                    blurRadius: 6.0,
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Text(
                                  "Covishield",
                                  style: (vaccineName == "COVISHIELD")
                                      ? TextStyle(color: Colors.white)
                                      : kTextStyle,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                isCoShield = false;
                                vaccineName = "COVAXIN";
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(kDropDownRadius),
                                    bottomRight:
                                        Radius.circular(kDropDownRadius),
                                    bottomLeft:
                                        Radius.circular(kDropDownRadius)),
                                color: (vaccineName == "COVAXIN")
                                    ? Colors.indigo[400]
                                    : Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey,
                                    offset: Offset(0.0, 2.0), //(x,y)
                                    blurRadius: 6.0,
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Text(
                                  "Covaxin",
                                  style: (vaccineName == "COVAXIN")
                                      ? TextStyle(color: Colors.white)
                                      : kTextStyle,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                isCoShield = false;
                                vaccineName = "SPUTNIK V";
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(kDropDownRadius),
                                    bottomRight:
                                        Radius.circular(kDropDownRadius),
                                    bottomLeft:
                                        Radius.circular(kDropDownRadius)),
                                color: (vaccineName == "SPUTNIK V")
                                    ? Colors.indigo[400]
                                    : Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey,
                                    offset: Offset(0.0, 2.0), //(x,y)
                                    blurRadius: 6.0,
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Text(
                                  "Sputnik V",
                                  style: (vaccineName == "SPUTNIK V")
                                      ? TextStyle(color: Colors.white)
                                      : kTextStyle,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Padding(
                  //   padding: const EdgeInsets.all(16.0),
                  //   child: Container(
                  //     decoration: BoxDecoration(
                  //       borderRadius: BorderRadius.only(
                  //           topLeft: Radius.circular(kDropDownRadius),
                  //           bottomRight: Radius.circular(kDropDownRadius),
                  //           bottomLeft: Radius.circular(kDropDownRadius)),
                  //       color: Colors.white,
                  //       boxShadow: [
                  //         BoxShadow(
                  //           color: Colors.grey,
                  //           offset: Offset(0.0, 2.0), //(x,y)
                  //           blurRadius: 6.0,
                  //         ),
                  //       ],
                  //     ),
                  //     child: Row(
                  //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //       children: [
                  //         Expanded(
                  //           child: ListTile(
                  //             title: Text(
                  //               'Covishield',
                  //               style: kTextStyle,
                  //             ),
                  //             leading: Transform.scale(
                  //               scale: 1.2,
                  //               child: Radio<MyVaccineNames>(
                  //                 activeColor: Colors.indigo[400],
                  //                 value: MyVaccineNames.covishield,
                  //                 groupValue: _vaccineNames,
                  //                 onChanged: (MyVaccineNames? value) {
                  //                   setState(
                  //                     () {
                  //                       isCoShield = true;
                  //                       _vaccineNames = value;
                  //                       vaccineName = "COVISHIELD";
                  //                     },
                  //                   );
                  //                 },
                  //               ),
                  //             ),
                  //           ),
                  //         ),
                  //         Expanded(
                  //           child: ListTile(
                  //             title: Text(
                  //               'Covaxin',
                  //               style: kTextStyle,
                  //             ),
                  //             leading: Transform.scale(
                  //               scale: 1.2,
                  //               child: Radio<MyVaccineNames>(
                  //                 activeColor: Colors.indigo[400],
                  //                 value: MyVaccineNames.covaxine,
                  //                 groupValue: _vaccineNames,
                  //                 onChanged: (MyVaccineNames? value) {
                  //                   setState(
                  //                     () {
                  //                       isCoShield = false;
                  //                       _vaccineNames = value;
                  //                       vaccineName = "COVAXIN";
                  //                     },
                  //                   );
                  //                 },
                  //               ),
                  //             ),
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),

                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Text(
                      'Select Fee Type : ',
                      style: kTextStyle,
                    ),
                  ),

                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 16.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              fee_type = "Free";
                            });
                          },
                          child: SizedBox(
                            width: 100.0,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(kDropDownRadius),
                                    bottomRight:
                                        Radius.circular(kDropDownRadius),
                                    bottomLeft:
                                        Radius.circular(kDropDownRadius)),
                                color: (fee_type == "Free")
                                    ? Colors.indigo[400]
                                    : Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey,
                                    offset: Offset(0.0, 2.0), //(x,y)
                                    blurRadius: 6.0,
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Text(
                                  "Free",
                                  style: (fee_type == "Free")
                                      ? TextStyle(color: Colors.white)
                                      : kTextStyle,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              fee_type = "Paid";
                            });
                          },
                          child: SizedBox(
                            width: 100.0,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(kDropDownRadius),
                                    bottomRight:
                                        Radius.circular(kDropDownRadius),
                                    bottomLeft:
                                        Radius.circular(kDropDownRadius)),
                                color: (fee_type == "Paid")
                                    ? Colors.indigo[400]
                                    : Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey,
                                    offset: Offset(0.0, 2.0), //(x,y)
                                    blurRadius: 6.0,
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Text(
                                  "Paid",
                                  style: (fee_type == "Paid")
                                      ? TextStyle(color: Colors.white)
                                      : kTextStyle,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16.0),
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: ListTile(
                              title: Text(
                                'Dose1',
                                style: kTextStyle,
                              ),
                              leading: Transform.scale(
                                scale: 1.2,
                                child: Radio<MyRadioButtons>(
                                  activeColor: Colors.indigo[400],
                                  value: MyRadioButtons.dose1,
                                  groupValue: _doseNum,
                                  onChanged: (MyRadioButtons? value) {
                                    setState(
                                      () {
                                        isDose1 = true;
                                        _doseNum = value;
                                        doseText = "Dose1";
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListTile(
                              title: Text(
                                'Dose2',
                                style: kTextStyle,
                              ),
                              leading: Transform.scale(
                                scale: 1.2,
                                child: Radio<MyRadioButtons>(
                                  activeColor: Colors.indigo[400],
                                  value: MyRadioButtons.dose2,
                                  groupValue: _doseNum,
                                  onChanged: (MyRadioButtons? value) {
                                    setState(
                                      () {
                                        isDose1 = false;
                                        _doseNum = value;
                                        doseText = "Dose2";
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: () {
                            if (isDistrict || pin_valid == true) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Screen2(
                                    durationValue: durationValue,
                                    isDose1: isDose1,
                                    selectedDate: selectedDate,
                                    selectedDistrict: selectedDistrict,
                                    vaccineName: vaccineName,
                                    doseText: doseText,
                                    pin: pin,
                                    isDistrict: isDistrict,
                                    fee_type: fee_type,
                                  ),
                                ),
                              );
                            } else {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  elevation: 30.0,
                                  title: Center(
                                    child: Text(
                                      "Wrong Pin!!!",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                  content: Text(
                                    'Please Enter valid pin code to proceed further',
                                    style: kTextStyle,
                                  ),
                                  actions: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: ElevatedButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              style: ElevatedButton.styleFrom(
                                                primary: Colors.indigo[400],
                                                shape: StadiumBorder(),
                                              ),
                                              child: Text('Try Again'),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );

                              print("Wrong pin");
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text('Start'),
                          ),
                          style: ElevatedButton.styleFrom(
                              primary: Colors.indigo[400],
                              shape: StadiumBorder()),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Padding CustomDistrictDropDown() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6.0),
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
        child: DropdownButtonHideUnderline(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton(
              hint: Text('Select The District'),
              isExpanded: true,
              value: selectedDistrict,
              onChanged: (DistrictData? newValue) {
                setState(() {
                  selectedDistrict = newValue!;
                });
              },
              items: districtList
                  .map(
                    (e) => DropdownMenuItem(
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: new Text(
                          e.district_name,
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      value: e,
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }

  Padding CustomStateDropDown() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6.0),
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
        child: DropdownButtonHideUnderline(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton(
              hint: Text('Select The State'),
              isExpanded: true,
              value: selectedState,
              onChanged: (StateData? newValue) {
                setState(() {
                  selectedState = newValue!;
                  getDistrict();
                });
              },
              items: statesList
                  .map(
                    (e) => DropdownMenuItem(
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: new Text(
                          e.state_name,
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      value: e,
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }

  Padding CustomDropDown() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6.0),
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
        child: DropdownButtonHideUnderline(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton(
              hint: Text('Select The Duration'),
              isExpanded: true,
              value: durationValue,
              onChanged: (int? newValue) {
                setState(() {
                  durationValue = newValue!;
                });
              },
              items: duration
                  .map(
                    (e) => DropdownMenuItem(
                      child: Container(
                        height: 50.0,
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: new Text(
                            '$e',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                      value: e,
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class StateData {
  final String state_id;
  final String state_name;
  StateData({required this.state_id, required this.state_name});
}

class DistrictData {
  final String district_id;
  final String district_name;
  DistrictData({required this.district_id, required this.district_name});
}
