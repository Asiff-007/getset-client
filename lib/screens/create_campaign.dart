import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:date_field/date_field.dart';
import 'package:retail_client/screens/args/campaign_args.dart';
import '../utils/sys-config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class CreateCampaign extends StatefulWidget {
  int campaignId;
  String campaignName;
  final DateTime from, to;

  CreateCampaign(
      {required this.campaignId,
      required this.campaignName,
      required this.from,
      required this.to});

  @override
  _CreateCampaignState createState() => _CreateCampaignState();
}

class _CreateCampaignState extends State<CreateCampaign> {
  final formKey = GlobalKey<FormState>();
  final int totalPlayers = 0, claimedPrizes = 0;
  late String campaignName = widget.campaignName, snackBarTxt = '';
  late String status;
  late DateTime campaignFrom = widget.from;
  late DateTime campaignTo = widget.to;
  late IconData snackBarIcon;
  late Color snackBarIconColor;
  late int campaignId = widget.campaignId;
  late bool editStatus = campaignId > 0 ? true : false;
  bool isEnabled = true;

  buttonStatus(status) {
    setState(() {
      isEnabled = status;
    });
  }

  void createCampaignFunction(
      {@required campaignName, campaignFrom, campaignTo, ctx}) async {
    final prefs = await SharedPreferences.getInstance();
    final apiurl = SysConfig.apiUrl;
    var shopId = prefs.getInt(Constants.shopId).toString(),
        adminId = prefs.getInt(Constants.adminId).toString();

    final response = await http.post(
      Uri.parse('$apiurl/campaign'),
      body: {
        'campaign_name': campaignName,
        'from': campaignFrom,
        'to': campaignTo,
        'shop_id': shopId,
        'admin_id': adminId,
      },
    );
    if (response.statusCode == 200) {
      final resp = json.decode(response.body);
      if (resp['status'] == 'Data inserted') {
        snackBarTxt = tr('campaign_created');
        snackBarIcon = Icons.check_circle;
        snackBarIconColor = Colors.green;
        Navigator.pushReplacementNamed(ctx, '/wrapper',
            arguments: CampaignArguments(
                resp['campaign_id'].toString(),
                campaignName,
                campaignFrom.toString(),
                campaignTo.toString(),
                resp['campaign_status'],
                totalPlayers.toString(),
                claimedPrizes.toString(),
                Constants.prizeIndex));
      } else {
        snackBarTxt = tr('campaign_creation_failed');
        snackBarIcon = Icons.close;
        snackBarIconColor = Colors.red;
        buttonStatus(true);
      }
    } else {
      snackBarTxt = tr('wrong_msg');
      snackBarIcon = Icons.warning;
      snackBarIconColor = Colors.red;
      buttonStatus(true);
    }
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        content: Row(children: [
      Text(snackBarTxt),
      Icon(snackBarIcon, color: snackBarIconColor)
    ])));
  }

  void updateCampaignFunction(
      {@required campaignName, campaignFrom, campaignTo, ctx}) async {
    final apiurl = SysConfig.apiUrl;

    final response = await http.post(
      Uri.parse('$apiurl/campaign/$campaignId'),
      body: {
        'campaign_name': campaignName,
        'from': campaignFrom,
        'to': campaignTo,
      },
    );
    if (response.statusCode == 200) {
      final resp = json.decode(response.body);
      if (resp['status'] == 'Data updated') {
        snackBarTxt = tr('campaign_updated');
        snackBarIcon = Icons.check_circle;
        snackBarIconColor = Colors.green;
        Navigator.pop(ctx);
      } else {
        snackBarTxt = tr('campaign_updation_failed');
        snackBarIcon = Icons.close;
        snackBarIconColor = Colors.red;
        buttonStatus(true);
      }
    } else {
      snackBarTxt = tr('wrong_msg');
      snackBarIcon = Icons.warning;
      snackBarIconColor = Colors.red;
      buttonStatus(true);
    }
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        content: Row(children: [
      Text(snackBarTxt),
      Icon(snackBarIcon, color: snackBarIconColor)
    ])));
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent[700],
        title: Text(editStatus
            ? tr('appbar_campaign_edit')
            : tr('appbar_campaign_add')),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 60,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: TextFormField(
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(10),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.deepPurpleAccent,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.deepPurpleAccent,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.deepPurpleAccent, width: 3)),
                    labelText: tr('label_campaign_name'),
                    hintText: tr('hint_campaign_name'),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelStyle: TextStyle(color: Colors.deepPurpleAccent[700]),
                  ),
                  initialValue: editStatus ? widget.campaignName : '',
                  onChanged: (value) {
                    this.campaignName = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return tr('validation_campaign_name');
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 20.0, right: 20.0, top: 20, bottom: 0),
                child: DateTimeFormField(
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(10),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.deepPurpleAccent,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.deepPurpleAccent,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.deepPurpleAccent, width: 3)),
                    suffixIcon: Icon(Icons.event_note),
                    labelText: tr('label_campaign_startdate'),
                    hintText: tr('hint_campaign_startdate'),
                    labelStyle: TextStyle(color: Colors.deepPurpleAccent[700]),
                  ),
                  mode: DateTimeFieldPickerMode.date,
                  initialValue: editStatus ? widget.from : null,
                  validator: (value) {
                    if (value == null) {
                      return tr('validation_campaign_startdate');
                    }
                    return null;
                  },
                  onDateSelected: (DateTime value) {
                    campaignFrom = value;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 20.0, right: 20.0, top: 20, bottom: 0),
                child: DateTimeFormField(
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(10),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.deepPurpleAccent,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.deepPurpleAccent,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.deepPurpleAccent, width: 3)),
                    suffixIcon: Icon(Icons.event_note),
                    labelText: tr('label_campaign_enddate'),
                    hintText: tr('hint_campaign_enddate'),
                    labelStyle: TextStyle(color: Colors.deepPurpleAccent[700]),
                  ),
                  mode: DateTimeFieldPickerMode.date,
                  initialValue: editStatus ? widget.to : null,
                  validator: (value) {
                    if (value == null) {
                      return tr('validation_campaign_enddate-1');
                    } else if (value.isBefore(DateTime.now()) ||
                        value.isBefore(campaignFrom)) {
                      return tr('validation_campaign_enddate-2');
                    }
                    return null;
                  },
                  onDateSelected: (DateTime value) {
                    campaignTo = value;
                  },
                ),
              ),
              SizedBox(
                height: 280,
              ),
              Container(
                height: 40,
                width: 130,
                margin: const EdgeInsets.all(30.0),
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
                child: editStatus
                    ? FlatButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate() && isEnabled) {
                            buttonStatus(false);
                            updateCampaignFunction(
                                campaignName: this.campaignName,
                                campaignFrom: this.campaignFrom.toString(),
                                campaignTo: this.campaignTo.toString(),
                                ctx: this.context);
                          }
                        },
                        child: Center(
                          child: Text(
                            tr('label_edit'),
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ))
                    : FlatButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate() && isEnabled) {
                            buttonStatus(false);
                            createCampaignFunction(
                                campaignName: this.campaignName,
                                campaignFrom: this.campaignFrom.toString(),
                                campaignTo: this.campaignTo.toString(),
                                ctx: this.context);
                          }
                        },
                        child: Row(children: [
                          Icon(
                            Icons.add,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            tr('label_create'),
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ])),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
