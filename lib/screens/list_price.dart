import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:retail_client/utils/campaign_arguments.dart';
import '../utils/check-connection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import '../utils/sys-config.dart';
import '../utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListPrize extends StatefulWidget {
  final int campaignId;

  ListPrize({required this.campaignId});

  @override
  _ListPrizeState createState() => _ListPrizeState();
}

class _ListPrizeState extends State<ListPrize> {
  Future<List<dynamic>> getPrizes() async {
    final prefs = await SharedPreferences.getInstance();
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

  @override
  Widget build(BuildContext context) {
    Network().checkConnection(context);

    return FutureBuilder<List<dynamic>>(
        future: getPrizes(),
        builder: (context, prizeSnap) {
          if (prizeSnap.hasError) {
            return Center(
              child: Text(tr('error_msg')),
            );
          } else if (prizeSnap.hasData) {
            return PrizeListItem(
              prizes: prizeSnap.data!,
              campaignId: widget.campaignId,
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }
}

class PrizeListItem extends StatelessWidget {
  PrizeListItem({required this.prizes, required this.campaignId});

  final List<dynamic> prizes;
  int campaignId, index = 1;

  @override
  Widget build(BuildContext context) {
    if (prizes.length == 0) {
      return Center(
        child: Container(
            width: 200,
            height: 200,
            padding: new EdgeInsets.all(5.0),
            child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 7,
                child: InkWell(
                  onTap: () async {
                    Navigator.pushReplacementNamed(context, '/add_price',
                        arguments:
                            CampaignArguments(campaignId.toString(), index));
                  },
                  child: Center(
                    child: ListTile(
                      title: Icon(
                        Icons.add,
                        size: 100,
                      ),
                      subtitle: Text(
                        tr('label_add_prize'),
                        style: TextStyle(fontSize: 14.0),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ))),
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
            return Container(
              width: 100,
              height: 300,
              padding: new EdgeInsets.all(5.0),
              child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 7,
                  child: Column(children: [
                    Flexible(
                      flex: 4,
                      fit: FlexFit.tight,
                      child: CircleAvatar(
                          radius: 150,
                          backgroundColor: Colors.transparent,
                          child: Image.network(
                            prizeImage,
                            fit: BoxFit.cover,
                          )),
                    ),
                    Flexible(
                      flex: 1,
                      fit: FlexFit.loose,
                      child: Text(prizeName,
                          style: TextStyle(
                              fontSize: 18.0, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center),
                    ),
                    Flexible(
                      flex: 1,
                      fit: FlexFit.loose,
                      child: Text(prizeCount,
                          style: TextStyle(
                              fontSize: 18.0, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center),
                    )
                  ])),
            );
          });
    }
  }
}
