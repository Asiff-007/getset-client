import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import '../utils/check-connection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import '../utils/sys-config.dart';
import '../utils/constants.dart';

class CampaignDetails extends StatefulWidget {
  final int campaignId, totalPlayers, claimedPrizes;
  final String campaignName, campaignStatus;
  final DateTime campaignFrom;

  CampaignDetails(
      {required this.campaignId,
      required this.campaignName,
      required this.campaignStatus,
      required this.campaignFrom,
      required this.totalPlayers,
      required this.claimedPrizes});

  @override
  _CampaignDetailsState createState() => _CampaignDetailsState();
}

class _CampaignDetailsState extends State<CampaignDetails> {
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  late int campaignId = widget.campaignId;
  late String campaignName = widget.campaignName,
      campaignStatus = widget.campaignStatus,
      campaignFrom = formatter.format(widget.campaignFrom),
      totalPlayers = widget.totalPlayers.toString(),
      claimedPrizes = widget.claimedPrizes.toString();
  late bool switchStatus = campaignStatus == Constants.Active;

  Future<List<dynamic>> getPrizes() async {
    final apiurl = SysConfig.apiUrl;
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

  Future<List<dynamic>> getWinners() async {
    final apiurl = SysConfig.apiUrl;

    final response = await http.get(
      Uri.parse('$apiurl/userPrice/?campaign_id=$campaignId'),
    );
    final resp = json.decode(response.body);
    return resp;
  }

  updateCampaign({@required campaignId, value}) async {
    final apiurl = SysConfig.apiUrl;
    final String status = value == true ? Constants.Active : Constants.InActive;

    await http.post(
      Uri.parse('$apiurl/campaign/$campaignId'),
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
          title: Text(campaignName),
          actions: [
            Switch(
              value: switchStatus,
              activeColor: Colors.yellow,
              activeTrackColor: Colors.tealAccent[300],
              onChanged: (value) async {
                await updateCampaign(campaignId: campaignId, value: value);
                setState(() {
                  switchStatus = value;
                });
              },
            ),
          ], //IconButt
        ),
        body: ListView(
          children: [
            Padding(
                padding: new EdgeInsets.only(
                    left: 18.0, right: 18, top: 15, bottom: 4),
                child: Card(
                    color: Colors.yellow[600],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    elevation: 3,
                    child: SizedBox(
                        height: 140,
                        child: Column(
                          children: [
                            SizedBox(height: 5),
                            Padding(
                              padding: new EdgeInsets.only(left: 40),
                              child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    tr('prize_claimed'),
                                    style: (TextStyle(
                                        fontSize: 20, color: Colors.indigo[900])),
                                    textAlign: TextAlign.start,
                                  )),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            FutureBuilder<List<dynamic>>(
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
                                          child: Padding(
                                        padding: EdgeInsets.only(
                                            top: 15, bottom: 15),
                                        child: Text(tr('prize_empty-2'),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(fontSize: 18,color: Colors.indigo[900])),
                                      ));
                                    } else {
                                      return Container(
                                          height: 80,
                                          width: double.maxFinite,
                                          child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              shrinkWrap: true,
                                              itemCount: prizes.length,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                var prize = prizes[index];
                                                String prizeName =
                                                        prize['name'],
                                                    prizeGiven = prize['given']
                                                        .toString(),
                                                    prizeCount = prize['count']
                                                        .toString();
                                                return Container(
                                                  width: 170,
                                                  height: 50,
                                                  child: ListTile(
                                                    title: Text(
                                                        prizeGiven +
                                                            '/' +
                                                            prizeCount,
                                                        style: TextStyle(
                                                            fontSize: 25.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Colors.indigo[900]),
                                                        textAlign:
                                                            TextAlign.center),
                                                    subtitle: Text(prizeName,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        softWrap: false,
                                                        style: TextStyle(
                                                            fontSize: 15.0,
                                                            color:
                                                                Colors.indigo[900]),
                                                        textAlign:
                                                            TextAlign.center),
                                                  ),
                                                );
                                              }));
                                    }
                                  } else {
                                    return Center(
                                      child: CircularProgressIndicator(
                                          color: Colors.deepPurpleAccent[700]),
                                    );
                                  }
                                })
                          ],
                        )))),
            Padding(
                padding: new EdgeInsets.only(
                    left: 35.0, right: 18, top: 15, bottom: 4),
                child: Row(children: [
                  Text(
                    claimedPrizes + '/' + totalPlayers,
                    style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo[900]),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text('players',
                      style: TextStyle(fontSize: 18.0, color: Colors.indigo[900]))
                ])),
            Padding(
                padding: new EdgeInsets.only(
                  left: 35.0,
                  right: 18,
                ),
                child: Container(
                    child: FutureBuilder<List<dynamic>>(
                        future: getWinners(),
                        builder: (context, winnerSnap) {
                          if (winnerSnap.hasError) {
                            return Center(
                              child: Text(tr('error_msg')),
                            );
                          } else if (winnerSnap.hasData) {
                            var winners = winnerSnap.data!;
                            return ListView.builder(
                                physics: ClampingScrollPhysics(),
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                itemCount: winners.length,
                                itemBuilder: (BuildContext context, int index) {
                                  var winner = winners[index];
                                  String winnerId =
                                          winner['ticketId'].toString(),
                                      prizeName = winner['prizeName'];
                                  return Column(
                                    children: <Widget>[
                                      ListTile(
                                        title: Text(
                                          winnerId,
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black54),
                                        ),
                                        trailing: Container(
                                            width: 130,
                                            child: Text(
                                              prizeName,
                                              overflow: TextOverflow.ellipsis,
                                              softWrap: false,
                                              textAlign: TextAlign.end,
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.indigo[900]),
                                            )),
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 0, horizontal: 1),
                                        dense: true,
                                      ),
                                      Divider(
                                        height: 0,
                                        thickness: 1,
                                        color: Colors.black,
                                      ),
                                    ],
                                  );
                                });
                          } else {
                            return Center(
                              child: CircularProgressIndicator(
                                  color: Colors.deepPurpleAccent[700]),
                            );
                          }
                        })))
          ],
        ));
  }
}
