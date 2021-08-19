import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/sys-config.dart';
import 'package:easy_localization/easy_localization.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final txtPass = TextEditingController();
  final txtUser = TextEditingController();
  String userName = '';
  String passWord = '';
  String warn = '';
  String SnackBarTxt = '';
  bool shouldpop = false;
  bool connection = true;

  Future onBackPress({ctx}) async {
    await showDialog<String>(
      context: ctx,
      builder: (BuildContext context) => AlertDialog(
        title: Text(tr('alert')),
        content: Text(tr('alert_exit')),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context, 'Cancel');
              shouldpop = false;
            },
            child: Text(tr('alert_cancel')),
          ),
          TextButton(
            onPressed: () {
              shouldpop = true;
              Navigator.pop(context, 'OK');
            },
            child: Text(tr('alert_ok')),
          ),
        ],
      ),
    );
  }

  void loginFunction({@required userName, passWord, ctx}) async {
    final prefs = await SharedPreferences.getInstance();
    final apiurl = sysConfig.apiUrl;

    try {
      final response = await http.post(
        Uri.parse('$apiurl/login'),
        body: {'username': userName, 'password': passWord},
      );
      if (response.statusCode == 200) {
        final resp = json.decode(response.body);
        if (resp['status'] == 'success') {
          SnackBarTxt = tr('login_success');
          setState(() {
            warn = '';
          });
          prefs.setBool('isLogged', false);
        } else {
          SnackBarTxt = resp['error'];
          setState(() {
            warn = resp['error'];
          });
        }
      } else {
        SnackBarTxt = tr('login_wrong');
      }
    } catch (e) {
      print(e);
      throw e;
    }
    ScaffoldMessenger.of(ctx)
        .showSnackBar(SnackBar(content: Text(SnackBarTxt)));
  }

  void checkConnection(BuildContext ctx) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        connection = true;
      }
    } on SocketException catch (_) {
      connection = false;
      showNoInternetMessage(ctx);
    }
  }

  showNoInternetMessage(BuildContext context) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(tr('no_internet'))));
  }

  @override
  Widget build(BuildContext context) {
    checkConnection(context);

    return WillPopScope(
      onWillPop: () async {
        await onBackPress(ctx: this.context);
        return shouldpop;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.deepPurpleAccent[700],
          title: Text(tr('login_title')),
        ),
        body: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              children: <Widget>[
                Text(
                  '$warn',
                  style: TextStyle(color: Colors.red),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 60.0),
                  child: Center(
                    child: Container(
                      width: 200,
                      height: 200,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25),
                  child: TextFormField(
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(10),
                        border: OutlineInputBorder(),
                        labelText: tr('label_username'),
                        hintText: tr('hint_username')),
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
                      left: 25.0, right: 25.0, top: 15, bottom: 0),
                  child: TextFormField(
                    obscureText: true,
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(10),
                        border: OutlineInputBorder(),
                        labelText: tr('label_password'),
                        hintText: tr('hint_password')),
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
                  height: 40,
                  width: 150,
                  margin: const EdgeInsets.all(30.0),
                  decoration: BoxDecoration(
                      color: Colors.deepPurpleAccent[700],
                      borderRadius: BorderRadius.circular(20)),
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
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
