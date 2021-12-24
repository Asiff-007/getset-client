import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/check-connection.dart';
import 'package:easy_localization/easy_localization.dart';
import '../utils/constants.dart';

class ResponsePage extends StatefulWidget {
  @override
  _ResponsePageState createState() => _ResponsePageState();
}

class _ResponsePageState extends State<ResponsePage>
    with SingleTickerProviderStateMixin {
  bool shouldpop = false;
  bool connection = true;
  String name = '', contact = '';

  initPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    name = prefs.getString(Constants.Name)!;
    contact = prefs.getString(Constants.contactNumber)!;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    initPrefs();
  }

  @override
  Widget build(BuildContext context) {
    Network().checkConnection(context);

    return Scaffold(
        backgroundColor: Colors.white,
        body: Column(children: [
          Container(
              height: 530,
              width: 500,
              padding: EdgeInsets.only(top: 80),
              decoration: new BoxDecoration(
                  gradient: new LinearGradient(
                      colors: [Color(0xff330979), Color(0xff1A053D)],
                      begin: Alignment(0, 0),
                      end: Alignment(0, 1),
                      tileMode: TileMode.clamp)),
              child: Center(
                  child: Column(children: [
                Text(tr('title_response') + name,
                    style: TextStyle(
                        fontFamily: "Roboto",
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                        fontSize: 20,
                        color: Colors.yellow),
                    textAlign: TextAlign.center),
                Container(
                  margin: EdgeInsets.only(top: 50, bottom: 80),
                  width: 290,
                  height: 250,
                  child: Image.asset(
                    'assets/images/response.png',
                  ),
                ),
              ]))),
          Center(
              child: Padding(
                  padding: EdgeInsets.only(top: 50),
                  child: Text(
                      tr('signup_replay_1') + contact + tr('signup_replay_2'),
                      style: TextStyle(
                          fontFamily: "Roboto",
                          height: 1.3,
                          fontSize: 20,
                          color: Color(0xff330079)),
                      textAlign: TextAlign.center))),
        ]));
  }
}
