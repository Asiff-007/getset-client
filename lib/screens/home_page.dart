import 'dart:convert';
import 'package:flutter/material.dart';
import '../utils/check-connection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import '../utils/sys-config.dart';
import '../utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'args/campaign_args.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool shouldpop = false;
  //Function for refresh This page on return to this page
  Future onReturn(dynamic value) async {
    setState(() {});
  }

  void popUpItem(BuildContext context, item) async {
    if (item == 0) {
      final prefs = await SharedPreferences.getInstance();
      prefs.setBool(Constants.isLogged, false);
      Navigator.pushReplacementNamed(context, '/login');
    }
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

  Future<List<dynamic>> getCampaigns() async {
    final prefs = await SharedPreferences.getInstance();
    final apiurl = SysConfig.apiUrl;
    var shopId = prefs.getInt(Constants.shopId);
    try {
      final response = await http.get(
        Uri.parse('$apiurl/campaign/?shop_id=$shopId'),
      );
      final resp = json.decode(response.body);
      return resp;
    } catch (e) {
      throw e;
    }
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
        extendBody: true,
        bottomNavigationBar: BottomAppBar(
            shape: CircularNotchedRectangle(),
            notchMargin: 5,
            elevation: 7,
            color: Colors.deepPurpleAccent[700],
            child: Container(
              height: 55,
              child: Row(
                children: [
                  PopupMenuButton<int>(
                    icon: Icon(
                      Icons.menu,
                      color: Colors.white,
                    ),
                    itemBuilder: (context) => [
                      PopupMenuItem<int>(
                          value: 0,
                          child: Row(
                            children: [
                              Icon(
                                Icons.logout,
                                color: Colors.deepPurpleAccent[700],
                              ),
                              const SizedBox(
                                width: 7,
                              ),
                              Text(tr('logout_button'))
                            ],
                          )),
                    ],
                    onSelected: (item) => popUpItem(context, item),
                  ),
                ],
              ),
            )),
        floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.yellow[600],
            elevation: 10,
            child: Icon(
              Icons.qr_code_2,
              color: Colors.black,
              size: 30,
            ),
            onPressed: () async {
              Navigator.pushNamed(context, '/scan');
            }),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        body: Container(
            decoration: new BoxDecoration(
                image: DecorationImage(
                    image: ExactAssetImage('assets/images/getset_loogo.png'),
                    colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.dstIn),
                    alignment: Alignment(0,.5)),
                gradient: new LinearGradient(
                    colors: [Color(0xff621eee), Color(0xffead64b)],
                    begin: Alignment(0, -1),
                    end: Alignment(0, 1),
                    tileMode: TileMode.clamp)),
            child: FutureBuilder<List<dynamic>>(
                future: getCampaigns(),
                builder: (context, campaignSnap) {
                  if (campaignSnap.hasError) {
                    return Center(
                      child: Text(tr('error_msg')),
                    );
                  } else if (campaignSnap.hasData) {
                    var campaigns = campaignSnap.data!;
                    return Padding(
                        padding: EdgeInsets.only(top: 10, left: 10, right: 10),
                        child: GridView.builder(
                            itemCount: campaigns.length + 1,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 2.0,
                                    mainAxisSpacing: 2.0),
                            itemBuilder: (BuildContext context, int index) {
                              if (index == 0) {
                                return Container(
                                    width: 100,
                                    height: 100,
                                    padding: new EdgeInsets.all(5.0),
                                    child: Card(
                                        color: Colors.yellow,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                            side: BorderSide(width: 0)),
                                        elevation: 7,
                                        child: InkWell(
                                          onTap: () async {
                                            Navigator.pushNamed(
                                                    context, '/campaign')
                                                .then(onReturn);
                                          },
                                          child: Center(
                                            child: ListTile(
                                              title: Icon(
                                                Icons.add,
                                                size: 100,
                                              ),
                                              subtitle: Text(
                                                tr('new_campaign'),
                                                style:
                                                    TextStyle(fontSize: 14.0),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                        )));
                              } else {
                                var campaign = campaigns[index - 1];
                                String campaignName = campaign['campaign_name'],
                                    campaignStatus = campaign['status'],
                                    totalPrices =
                                        campaign['total_prices'].toString(),
                                    claimedPrices =
                                        campaign['claimed_prices'].toString(),
                                    totalPlayers =
                                        campaign['total_players'].toString(),
                                    campaignId = campaign['id'].toString(),
                                    from = campaign['from'].toString(),
                                    to = campaign['to'].toString();
                                Color? cardColor =
                                        campaignStatus == Constants.Active
                                            ? Colors.tealAccent
                                            : Colors.indigo[900],
                                    textColor1 =
                                        campaignStatus == Constants.Active
                                            ? Colors.indigo[900]
                                            : Colors.yellow,
                                    textColor2 =
                                        campaignStatus == Constants.Active
                                            ? Colors.indigo[900]
                                            : Colors.white;
                                return Container(
                                  width: 100,
                                  height: 100,
                                  padding: new EdgeInsets.all(5.0),
                                  child: Card(
                                      color: cardColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                      ),
                                      elevation: 7,
                                      child: InkWell(
                                          onTap: () async {
                                            Navigator.pushNamed(
                                                    context, '/wrapper',
                                                    arguments:
                                                        CampaignArguments(
                                                            campaignId,
                                                            campaignName,
                                                            from,
                                                            to,
                                                            campaignStatus,
                                                            totalPlayers,
                                                            claimedPrices,
                                                            Constants
                                                                .campaignIndex))
                                                .then(onReturn);
                                          },
                                          child: Column(children: [
                                            Flexible(
                                              flex: 2,
                                              fit: FlexFit.tight,
                                              child: ListTile(
                                                title: Text(totalPlayers,
                                                    style: TextStyle(
                                                        fontSize: 18.0,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: textColor2),
                                                    textAlign:
                                                        TextAlign.center),
                                                subtitle: Text(
                                                    tr('players_total'),
                                                    style: TextStyle(
                                                        fontSize: 14.0,
                                                        color: textColor2),
                                                    textAlign:
                                                        TextAlign.center),
                                              ),
                                            ),
                                            Flexible(
                                              flex: 2,
                                              fit: FlexFit.tight,
                                              child: ListTile(
                                                title: Text(
                                                    claimedPrices +
                                                        '/' +
                                                        totalPrices,
                                                    style: TextStyle(
                                                        fontSize: 18.0,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: textColor1),
                                                    textAlign:
                                                        TextAlign.center),
                                                subtitle: Text(
                                                    tr('players_claimed'),
                                                    style: TextStyle(
                                                        fontSize: 14.0,
                                                        color: textColor1),
                                                    textAlign:
                                                        TextAlign.center),
                                              ),
                                            ),
                                            Flexible(
                                              flex: 3,
                                              fit: FlexFit.tight,
                                              child: ListTile(
                                                title: Text(campaignName,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    softWrap: false,
                                                    style: TextStyle(
                                                        fontSize: 18.0,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: textColor2),
                                                    textAlign:
                                                        TextAlign.center),
                                                subtitle: Text(
                                                    campaignStatus
                                                        .toUpperCase(),
                                                    style: TextStyle(
                                                        fontSize: 14.0,
                                                        color: textColor1),
                                                    textAlign:
                                                        TextAlign.center),
                                              ),
                                            )
                                          ]))),
                                );
                              }
                            }));
                  } else {
                    return Center(
                      child: CircularProgressIndicator(
                          color: Colors.deepPurpleAccent[700]),
                    );
                  }
                })),
      ),
    );
  }
}
