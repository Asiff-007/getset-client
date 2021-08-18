import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final txtPass = TextEditingController();
  final txtUser = TextEditingController();
  String u_name = '';
  String p_word = '';
  String warn = '';
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
              print(shouldpop);
              Navigator.pop(context, 'OK');
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void loginFunction({@required u_name, p_word, ctx}) async {
    final prefs = await SharedPreferences.getInstance();

    try {
      final response = await http.post(
        Uri.parse('http://192.168.0.111:3002/admin'),
        body: {'username': u_name, 'password': p_word},
      );
      final resp = json.decode(response.body);
      if (resp['status'] == 'success') {
        ScaffoldMessenger.of(ctx)
            .showSnackBar(const SnackBar(content: Text('login succesfull')));
        setState(() {
          warn = '';
        });
      } else {
        ScaffoldMessenger.of(ctx)
            .showSnackBar(SnackBar(content: Text(resp['error'])));
        setState(() {
          warn = resp['error'];
        });
      }
    } catch (e) {
      print(e);
      throw e;
    }
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
            key: _formKey,
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
                        hintText: 'Enter valid username as abc@gmail.com'),
                    onChanged: (value) {
                      this.u_name = value;
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
                      this.p_word = value;
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
                      if (_formKey.currentState!.validate()) {
                        loginFunction(
                            u_name: this.u_name,
                            p_word: this.p_word,
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
