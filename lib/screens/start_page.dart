import 'package:flutter/material.dart';
import '../utils/check-connection.dart';
import 'package:easy_localization/easy_localization.dart';

class StartPage extends StatefulWidget {
  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage>
    with SingleTickerProviderStateMixin {
  bool shouldpop = false;

  Future onBackPress({ctx}) async {
    await showDialog<String>(
      context: ctx,
      builder: (BuildContext context) => AlertDialog(
        title: Text(tr('alert')),
        content: Text(tr('alert_exit')),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context, tr('alert_cancel'));
              shouldpop = false;
            },
            child: Text(tr('alert_cancel')),
          ),
          TextButton(
            onPressed: () {
              shouldpop = true;
              Navigator.pop(context, tr('alert_ok'));
            },
            child: Text(tr('alert_ok')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Network().checkConnection(context);

    return WillPopScope(
        onWillPop: () async {
          await onBackPress(ctx: this.context);
          return shouldpop;
        },
        child: Scaffold(
            backgroundColor: Colors.white,
            body: Column(children: [
              Container(
                  height: 580,
                  width: 500,
                  decoration: new BoxDecoration(
                      gradient: new LinearGradient(
                          colors: [Color(0xff330979), Color(0xff1A053D)],
                          begin: Alignment(0, 0),
                          end: Alignment(0, 1),
                          tileMode: TileMode.clamp)),
                  child: Center(
                      child: Column(children: [
                    Container(
                      margin: EdgeInsets.only(top: 100, bottom: 80),
                      width: 290,
                      height: 290,
                      child: Image.asset(
                        'assets/images/start_page.png',
                      ),
                    ),
                    Text(tr('welcome_note'),
                        style: TextStyle(
                            fontFamily: "Roboto",
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                            fontSize: 20,
                            color: Colors.yellow),
                        textAlign: TextAlign.center)
                  ]))),
              Container(
                height: 45,
                width: 120,
                margin: const EdgeInsets.only(top: 70.0),
                decoration: BoxDecoration(
                    color: Colors.yellow[600],
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey[700]!.withOpacity(0.2),
                        spreadRadius: 4,
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      )
                    ]),
                child: FlatButton(
                  onPressed: () async {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: Text(
                    tr('label_get_set'),
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ])));
  }
}
