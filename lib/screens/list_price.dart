import 'dart:convert';
import 'package:flutter/material.dart';
import '../utils/check-connection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import '../utils/sys-config.dart';
import '../utils/constants.dart';

class ListPrize extends StatefulWidget {
  final int campaignId;

  ListPrize({required this.campaignId});

  @override
  _ListPrizeState createState() => _ListPrizeState();
}

class _ListPrizeState extends State<ListPrize> {
  late bool switchStatus;

  Future<List<dynamic>> getPrizes() async {
    final apiurl = SysConfig.apiUrl;
    late int campaignId = widget.campaignId;
    try {
      final response = await http.get(
        Uri.parse('$apiurl/price/?campaign_id=$campaignId'),
      );
      final resp = json.decode(response.body);
      return resp;
    } catch (e) {
      throw e;
    }
  }

  updatePrize({@required prizeId, value}) async {
    final apiurl = SysConfig.apiUrl;
    final String status = value == true ? Constants.Active : Constants.InActive;

    await http.post(
      Uri.parse('$apiurl/price/$prizeId'),
      body: {
        'status': status,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Network().checkConnection(context);

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepPurpleAccent[700],
          title: Text(tr('prize_list')), //IconButt
        ),
        body: FutureBuilder<List<dynamic>>(
            future: getPrizes(),
            builder: (context, prizeSnap) {
              if (prizeSnap.hasError) {
                return Center(
                  child: Text(tr('error_msg')),
                );
              } else if (prizeSnap.hasData) {
                var prizes = prizeSnap.data!;
                if (prizes.length == 0) {
                  return Center(
                    child: Text(tr('prize_empty-1'),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 30)),
                  );
                } else {
                  return ListView.builder(
                      itemCount: prizes.length,
                      itemBuilder: (BuildContext context, int index) {
                        var prize = prizes[index];
                        String prizeName = prize['name'],
                            prizeStatus = prize['status'],
                            prizeCount = prize['count'].toString(),
                            prizeImage = prize['image'];
                        var prizeId = prize['id'];
                        switchStatus =
                            prizeStatus == Constants.Active ? true : false;
                        return Container(
                          width: 100,
                          height: 250,
                          padding: new EdgeInsets.only(
                              left: 25.0, right: 25, top: 4, bottom: 4),
                          child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              elevation: 3,
                              child: Padding(
                                  padding: EdgeInsets.only(bottom: 15),
                                  child: Column(children: [
                                    SizedBox(
                                      height: 0,
                                    ),
                                    Flexible(
                                      flex: 4,
                                      fit: FlexFit.loose,
                                      child: CircleAvatar(
                                          radius: 80,
                                          backgroundColor: Colors.transparent,
                                          child: Image.network(
                                            prizeImage,
                                            fit: BoxFit.cover,
                                          )),
                                    ),
                                    Flexible(
                                        flex: 1,
                                        fit: FlexFit.loose,
                                        child: Row(children: [
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Expanded(
                                              child: ListTile(
                                            title: Text(
                                              prizeName,
                                              style: TextStyle(
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            subtitle: Text(
                                              prizeCount +
                                                  ' ' +
                                                  tr('prize_quantity'),
                                              style: TextStyle(
                                                fontSize: 13,
                                              ),
                                            ),
                                          )),
                                          Switch(
                                            value: switchStatus,
                                            activeColor:
                                                Colors.deepPurpleAccent[700],
                                            activeTrackColor:
                                                Colors.deepPurpleAccent[300],
                                            onChanged: (value) async {
                                              await updatePrize(
                                                  prizeId: prizeId,
                                                  value: value);
                                              setState(() {
                                                switchStatus = value;
                                              });
                                            },
                                          ),
                                          SizedBox(
                                            width: 10,
                                          )
                                        ])),
                                  ]))),
                        );
                      });
                }
              } else {
                return Center(
                  child: CircularProgressIndicator(
                    color: Colors.deepPurpleAccent[700],
                  ),
                );
              }
            }));
  }
}
