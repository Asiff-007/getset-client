import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:retail_client/utils/constants.dart';
import 'package:retail_client/utils/sys-config.dart';
import 'package:http/http.dart' as http;

class VerifyPrize extends StatefulWidget {
  final String campaignId, ticketId;

  VerifyPrize({required this.campaignId, required this.ticketId});
  @override
  _VerifyPrize createState() => _VerifyPrize();
}

class _VerifyPrize extends State<VerifyPrize> {
  late String ticketId = widget.ticketId;
  late int campaignId = int.parse(widget.campaignId);
  String snackBarTxt = '';
  late IconData snackBarIcon;
  late Color snackBarIconColor;

  verifyPrize() async {
    final apiurl = SysConfig.apiUrl;
    try {
      final response = await http.get(
        Uri.parse('$apiurl/userPrice/$ticketId'),
      );
      final resp = json.decode(response.body);
      if (resp['status'] == 'failed') {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(resp['error'])));
        Navigator.pop(context);
      } else {
        return resp;
      }
    } catch (e) {
      throw e;
    }
  }

  void updateUserPrize() async {
    final apiurl = SysConfig.apiUrl;

    final response = await http.post(
      Uri.parse('$apiurl/userPrice/$ticketId/?campaign_id=$campaignId'),
      body: {
        'claim_status': Constants.Claimed,
        'claimed_on': DateTime.now().toString(),
      },
    );
    if (response.statusCode == 200) {
      final resp = json.decode(response.body);
      if (resp['status'] == 'Data updated') {
        snackBarTxt = tr('prize_verified');
        snackBarIcon = Icons.check_circle;
        snackBarIconColor = Colors.green;
        Navigator.pop(context);
      } else {
        snackBarTxt = tr('prize_verification_faild');
        snackBarIcon = Icons.close;
        snackBarIconColor = Colors.red;
      }
    } else {
      snackBarTxt = tr('wrong_msg');
      snackBarIcon = Icons.warning;
      snackBarIconColor = Colors.red;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: [
      Text(snackBarTxt),
      Icon(snackBarIcon, color: snackBarIconColor)
    ])));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.deepPurpleAccent[700],
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          decoration: new BoxDecoration(
              gradient: new LinearGradient(
                  colors: [Color(0xff621eee), Color(0xffead64b)],
                  begin: Alignment(0, -1),
                  end: Alignment(0, 1),
                  tileMode: TileMode.clamp)),
          child: FutureBuilder<dynamic>(
              future: verifyPrize(),
              builder: (context, prizeSnap) {
                if (prizeSnap.hasError) {
                  return Center(
                    child: Text(tr('error_msg')),
                  );
                } else if (prizeSnap.hasData) {
                  var prize = prizeSnap.data!;
                  String prizeImage = prize['image'],
                      prizeName = prize['name'],
                      ticketId = prize['ticket_id'].toString();
                  DateTime prizeWonON = DateTime.parse(prize['price_won_on']);
                  return SingleChildScrollView(
                      child: Container(
                          child: Center(
                              child: Column(
                    children: [
                      SizedBox(
                        height: 30,
                      ),
                      Text(
                        tr('title_verification'),
                        style: TextStyle(fontSize: 28, color: Colors.white),
                      ),
                      SizedBox(
                        height: 17,
                      ),
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        elevation: 3,
                        child: CircleAvatar(
                            radius: 100,
                            backgroundColor: Colors.transparent,
                            child: Image.network(
                              prizeImage,
                              fit: BoxFit.cover,
                            )),
                      ),
                      SizedBox(
                        height: 17,
                      ),
                      Text(
                        prizeName,
                        style: TextStyle(fontSize: 28, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Text(tr('ticket_id') + '   :  ' + ticketId,
                          style: TextStyle(fontSize: 18, color: Colors.white)),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                          DateFormat('dd-MM-yyyy - kk:mm:a')
                              .format(prizeWonON)
                              .toString(),
                          style: TextStyle(fontSize: 18, color: Colors.white)),
                      SizedBox(
                        height: 35,
                      ),
                      Container(
                        height: 50,
                        width: 150,
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
                        child: FlatButton(
                            onPressed: () async {
                              updateUserPrize();
                            },
                            child: Row(children: [
                              Icon(
                                Icons.add,
                                size: 18,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                tr('prize_confirm'),
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ])),
                      ),
                    ],
                  ))));
                } else {
                  return Center(
                    child: CircularProgressIndicator(
                        color: Colors.deepPurpleAccent[700]),
                  );
                }
              }),
        ));
  }
}
