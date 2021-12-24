import 'dart:developer';

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/sys-config.dart';
import '../utils/check-connection.dart';
import 'package:easy_localization/easy_localization.dart';
import '../utils/constants.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage>
    with SingleTickerProviderStateMixin {
  final formKey = GlobalKey<FormState>();
  final txtPass = TextEditingController();
  final txtUser = TextEditingController();
  String userName = '';
  String contactNumber = '';
  String snackBarTxt = '';
  bool shouldpop = false;
  bool connection = true;

  void signupFunction({@required name, contactNumber, ctx}) async {
    final prefs = await SharedPreferences.getInstance();
    final apiurl = SysConfig.apiUrl;

    try {
      final response = await http.post(
        Uri.parse('$apiurl/enquiry'),
        body: {'name': name, 'contact_number': contactNumber},
      );
      if (response.statusCode == 200) {
        final resp = json.decode(response.body);
        if (resp['status'] == 'Data inserted') {
          snackBarTxt = tr('signup_success');
          prefs.setString(Constants.Name, name);
          prefs.setString(Constants.contactNumber, contactNumber);
          Navigator.pushReplacementNamed(ctx, '/response');
        } else {
          snackBarTxt = resp['error'];
        }
      } else {
        snackBarTxt = tr('wrong_msg');
      }
    } catch (e) {
      throw e;
    }
    Loader.hide();
    ScaffoldMessenger.of(ctx)
        .showSnackBar(SnackBar(content: Text(snackBarTxt)));
  }

  @override
  Widget build(BuildContext context) {
    Network().checkConnection(context);

    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        body: Stack(children: [
          Column(children: [
            Container(
              padding: EdgeInsets.only(top: 50),
              height: 380,
              width: 500,
              decoration: new BoxDecoration(
                  gradient: new LinearGradient(
                      colors: [Color(0xff330979), Color(0xff1A053D)],
                      begin: Alignment(0, -1),
                      end: Alignment(0, 1),
                      tileMode: TileMode.clamp)),
              child: Text(tr('title_signup'),
                  style: TextStyle(
                      fontFamily: "Roboto",
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                      fontSize: 20,
                      color: Colors.yellow),
                  textAlign: TextAlign.center),
            ),
            Expanded(
              child: Container(
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 100,
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
                              labelText: tr('label_name'),
                              hintText: tr('hint_name'),
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
                                return tr('validation_name');
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
                              labelText: tr('label_contact_number'),
                              hintText: tr('hint_contact_number'),
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              labelStyle: TextStyle(
                                  color: Colors.deepPurpleAccent[700]),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            onChanged: (value) {
                              this.contactNumber = value;
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return tr('validation_contact_number');
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
                                Loader.show(context,
                                    isAppbarOverlay: false,
                                    progressIndicator:
                                        CircularProgressIndicator(
                                      color: Colors.deepPurpleAccent[700],
                                    ));
                                signupFunction(
                                    name: this.userName,
                                    contactNumber: this.contactNumber,
                                    ctx: this.context);
                              }
                            },
                            child: Text(
                              tr('label_get_set'),
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ]),
          Container(
            margin: EdgeInsets.only(top: 140, left: 25),
            width: 290,
            height: 290,
            child: Image.asset(
              'assets/images/signup_page.png',
            ),
          ),
        ]));
  }
}
