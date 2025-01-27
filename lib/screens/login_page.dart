import 'dart:developer';

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/sys-config.dart';
import '../utils/check-connection.dart';
import 'package:easy_localization/easy_localization.dart';
import '../utils/constants.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final formKey = GlobalKey<FormState>();
  final txtPass = TextEditingController();
  final txtUser = TextEditingController();
  late AnimationController _controller;
  late Animation<double> _animation;
  String userName = '';
  String passWord = '';
  String snackBarTxt = '';
  bool shouldpop = false;
  bool connection = true;

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    _animation = Tween<double>(begin: 0.9, end: 1.1).animate(
        CurvedAnimation(parent: _controller, curve: Interval(0.0, 0.5)));
    _controller.repeat(reverse: true);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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

  void loginFunction({@required userName, passWord, ctx}) async {
    final prefs = await SharedPreferences.getInstance();
    final apiurl = SysConfig.apiUrl;

    try {
      final response = await http.post(
        Uri.parse('$apiurl/login'),
        body: {'username': userName, 'password': passWord},
      );
      if (response.statusCode == 200) {
        final resp = json.decode(response.body);
        if (resp['status'] == 'success') {
          snackBarTxt = tr('login_success');
          prefs.setInt(Constants.shopId, resp['shop_id']);
          prefs.setInt(Constants.adminId, resp['admin_id']);
          prefs.setBool(Constants.isLogged, true);
          Navigator.pushReplacementNamed(ctx, '/home');
        } else {
          snackBarTxt = resp['error'];
        }
      } else {
        snackBarTxt = tr('wrong_msg');
      }
    } catch (e) {
      throw e;
    }
    ScaffoldMessenger.of(ctx)
        .showSnackBar(SnackBar(content: Text(snackBarTxt)));
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
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.white,
            body: Column(children: [
              Container(
                height: 580,
                width: 500,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 40.0),
                          child: Center(
                            child: ScaleTransition(
                              scale: _animation,
                              child: Container(
                                width: 240,
                                height: 240,
                                child: Image.asset(
                                  'assets/images/getsetlogo.png',
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 25),
                          child: TextFormField(
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(10),
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.deepPurpleAccent, width: 2),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.deepPurpleAccent,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.deepPurpleAccent,
                                      width: 3)),
                              labelText: tr('label_username'),
                              hintText: tr('hint_username'),
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              labelStyle: TextStyle(
                                  color: Colors.deepPurpleAccent[700]),
                            ),
                            onChanged: (value) {
                              this.userName = value;
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return tr('validation_username');
                              }
                              return null;
                            },
                            controller: txtUser,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 25.0, right: 25.0, top: 20, bottom: 0),
                          child: TextFormField(
                            obscureText: true,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(10),
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.deepPurpleAccent, width: 2),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.deepPurpleAccent,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.deepPurpleAccent,
                                      width: 3)),
                              labelText: tr('label_password'),
                              hintText: tr('hint_password'),
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              labelStyle: TextStyle(
                                  color: Colors.deepPurpleAccent[700]),
                            ),
                            onChanged: (value) {
                              this.passWord = value;
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return tr('validation_password');
                              }
                              return null;
                            },
                            controller: txtPass,
                          ),
                        ),
                        Container(
                          height: 45,
                          width: 120,
                          margin: const EdgeInsets.only(top: 50.0),
                          decoration: BoxDecoration(
                              color: Colors.yellow[600],
                              borderRadius: BorderRadius.circular(20),
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
                              if (formKey.currentState!.validate()) {
                                loginFunction(
                                    userName: this.userName,
                                    passWord: this.passWord,
                                    ctx: this.context);
                              }
                            },
                            child: Text(
                              tr('login_button'),
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                  child: Container(
                decoration: new BoxDecoration(
                    gradient: new LinearGradient(
                        colors: [Color(0xff330979), Color(0xff1A053D)],
                        begin: Alignment(0, -1),
                        end: Alignment(0, 1),
                        tileMode: TileMode.clamp)),
                child: Center(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 30,
                      ),
                      Text(tr('no_account'),
                          style: TextStyle(
                              fontFamily: "Roboto",
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                              fontSize: 20,
                              color: Colors.yellow),
                          textAlign: TextAlign.center),
                      Container(
                        height: 45,
                        width: 120,
                        margin: const EdgeInsets.only(top: 20.0),
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
                            Navigator.pushNamed(context, '/signup');
                          },
                          child: Text(
                            tr('label_get_set'),
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ))
            ])));
  }
}
