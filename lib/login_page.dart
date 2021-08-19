import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  Future onBackPress({ctx}) async {
    await showDialog<String>(
      context: ctx,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Alert'),
        content: const Text('Do you want to exit'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context, 'Cancel');
              shouldpop = false;
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              shouldpop = true;
              Navigator.pop(context, 'OK');
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void loginFunction({@required userName, passWord, ctx}) async {
    final prefs = await SharedPreferences.getInstance();
    final contents = await rootBundle.loadString(
      'assets/config/sys-config.json',
    );

// decode our json
    final config = jsonDecode(contents);
    final apiurl = config['apiUrl'];

    try {
      final response = await http.post(
        Uri.parse('$apiurl/login'),
        body: {'username': userName, 'password': passWord},
      );
      if (response.statusCode == 200) {
        final resp = json.decode(response.body);
        if (resp['status'] == 'success') {
          SnackBarTxt = 'login succesfull';
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
        SnackBarTxt = 'something went wrong';
      }
    } catch (e) {
      print(e);
      throw e;
    }
    ScaffoldMessenger.of(ctx)
        .showSnackBar(SnackBar(content: Text(SnackBarTxt)));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await onBackPress(ctx: this.context);
        return shouldpop;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.deepPurpleAccent[700],
          title: Text("Login"),
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
                        labelText: 'Username',
                        hintText: 'Enter valid username'),
                    onChanged: (value) {
                      this.userName = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter username';
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
                        labelText: 'Password',
                        hintText: 'Enter secure password'),
                    onChanged: (value) {
                      this.passWord = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter password';
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
                      'Login',
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
