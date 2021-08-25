import 'dart:convert';
import 'package:flutter/material.dart';
import '../utils/check-connection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import '../utils/sys-config.dart';
import '../utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool shouldpop = false;

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
        bottomNavigationBar: BottomAppBar(
          color: Colors.deepPurpleAccent[700],
          child: Row(
            children: [
              IconButton(
                  color: Colors.white,
                  icon: Icon(Icons.menu),
                  onPressed: () {}),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.tealAccent[700],
            child: Icon(
              Icons.qr_code_2,
              color: Colors.black,
            ),
            onPressed: () {}),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        body: FutureBuilder<List<dynamic>>(
            future: getCampaigns(),
            builder: (context, campaignSnap) {
              if (campaignSnap.hasError) {
                return Center(
                  child: Text(tr('error_msg')),
                );
              } else if (campaignSnap.hasData) {
                return CampaignListItem(campaigns: campaignSnap.data!);
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            }),
      ),
    );
  }
}

class CampaignListItem extends StatelessWidget {
  const CampaignListItem({required this.campaigns});

  final List<dynamic> campaigns;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        itemCount: campaigns.length + 1,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 2.0, mainAxisSpacing: 2.0),
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return Container(
                width: 100,
                height: 100,
                padding: new EdgeInsets.all(5.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 10,
                  child: Center(
                    child: ListTile(
                      title: Icon(
                        Icons.add,
                        size: 100,
                      ),
                      subtitle: Text(
                        tr('new_campaign'),
                        style: TextStyle(fontSize: 15.0),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ));
          } else {
            String campaignName = campaigns[index - 1]['campaign_name'];
            String campaignStatus = campaigns[index - 1]['status'];
            return Container(
              width: 100,
              height: 100,
              padding: new EdgeInsets.all(5.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 10,
                child: ListTile(
                  title: Text(campaignName,
                      style: TextStyle(
                          fontSize: 20.0, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center),
                  subtitle: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(campaignStatus,
                          style: TextStyle(fontSize: 15.0),
                          textAlign: TextAlign.center)),
                ),
              ),
            );
          }
        });
  }
}
