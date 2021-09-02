import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:retail_client/screens/args/add_price_args.dart';
import '../utils/check-connection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import '../utils/sys-config.dart';

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

  @override
  Widget build(BuildContext context) {
    Network().checkConnection(context);

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepPurpleAccent[700],
          automaticallyImplyLeading: false,
          title: Text(tr('prize_list')),
          leading: IconButton(
            icon: Icon(Icons.menu),
            tooltip: 'Menu Icon',
            onPressed: () {},
          ), //IconButt
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
                                Navigator.pushNamed(context, '/add_price',
                                    arguments: AddPrizeArguments(
                                        widget.campaignId.toString()));
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
                        switchStatus =
                            prize['status'] == 'Active' ? true : false;
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
                                            onChanged: (value) {
                                              log(value.toString());
                                              log(switchStatus.toString());
                                              switchStatus = value;
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
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            }));
  }
}
