/*import 'dart:convert';
import 'package:flutter/material.dart';
import '../utils/check-connection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import '../utils/sys-config.dart';
import '../utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListPrize extends StatefulWidget {
  @override
  _ListPrizeState createState() => _ListPrizeState();
}

class _ListPrizeState extends State<ListPrize> {
  bool shouldpop = false;

  @override
  Widget build(BuildContext context) {
    Network().checkConnection(context);

    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        color: Colors.deepPurpleAccent[700],
        child: Row(
          children: [
            IconButton(
                color: Colors.white, icon: Icon(Icons.menu), onPressed: () {}),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.tealAccent[700],
          child: Icon(
            Icons.qr_code_2,
            color: Colors.black,
            size: 30,
          ),
          onPressed: () {}),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: FutureBuilder<List<dynamic>>(
          future: getPrizes(),
          builder: (context, prizeSnap) {
            if (prizeSnap.hasError) {
              return Center(
                child: Text(tr('error_msg')),
              );
            } else if (prizeSnap.hasData) {
              return PrizeListItem(prizes: prizeSnap.data!);
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }
}

class PrizeListItem extends StatelessWidget {
  const PrizeListItem({required this.prizes});

  final List<dynamic> prizes;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        itemCount: prizes.length + 1,
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
                    elevation: 7,
                    child: InkWell(
                      onTap: () async {
                        Navigator.pushNamed(context, '/campaign');
                      },
                      child: Center(
                        child: ListTile(
                          title: Icon(
                            Icons.add,
                            size: 100,
                          ),
                          subtitle: Text(
                            tr('new_campaign'),
                            style: TextStyle(fontSize: 14.0),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    )));
          } else {
            var prize = prizes[index - 1];
            String prizeName = prize['name'],
                prizeStatus = prize['status'],
                prizeCount = prize['count'].toString(),
                prizeExpiry = prize['expiry'].toString(),
                prizeImage = prize['image'];
            return Container(
              width: 100,
              height: 100,
              padding: new EdgeInsets.all(5.0),
              child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 7,
                  child: Column(children: [
                    Flexible(
                      flex: 2,
                      fit: FlexFit.tight,
                      child: ListTile(
                        title: Text(totalPlayers,
                            style: TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center),
                        subtitle: Text(tr('players_total'),
                            style: TextStyle(fontSize: 14.0),
                            textAlign: TextAlign.center),
                      ),
                    ),
                    Flexible(
                      flex: 2,
                      fit: FlexFit.tight,
                      child: ListTile(
                        title: Text(claimedPrices + '/' + totalPrices,
                            style: TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center),
                        subtitle: Text(tr('players_claimed'),
                            style: TextStyle(fontSize: 14.0),
                            textAlign: TextAlign.center),
                      ),
                    ),
                    Flexible(
                      flex: 3,
                      fit: FlexFit.tight,
                      child: ListTile(
                        title: Text(campaignName,
                            style: TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center),
                        subtitle: Text(campaignStatus,
                            style: TextStyle(fontSize: 14.0),
                            textAlign: TextAlign.center),
                      ),
                    )
                  ])),
            );
          }
        });
  }
}*/
