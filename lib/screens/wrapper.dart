import 'package:flutter/material.dart';
import 'package:retail_client/screens/args/add_price_args.dart';
import './list_price.dart';

class Wrapper extends StatefulWidget {
  final String campaignId;
  final int index;
  Wrapper({required this.campaignId, required this.index});

  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  late int _currentIndex = widget.index;
  late int campaignId = int.parse(widget.campaignId);
  late List<Widget> _children = [
    Center(
        child: Text(
      'Campaign Details',
      textAlign: TextAlign.center,
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35),
    )),
    ListPrize(campaignId: campaignId),
    Center(
        child: Text('Edit Campaign',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35))),
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_currentIndex],
      bottomNavigationBar: BottomAppBar(
          color: Colors.deepPurpleAccent[700],
          shape: CircularNotchedRectangle(),
          notchMargin: 5,
          elevation: 7,
          child: Container(
            height: 55,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.campaign,
                      color:
                          _currentIndex == 0 ? Colors.white : Colors.white54),
                  onPressed: () {
                    onTabTapped(0);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.card_giftcard,
                      color:
                          _currentIndex == 1 ? Colors.white : Colors.white54),
                  onPressed: () {
                    onTabTapped(1);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.edit,
                      color:
                          _currentIndex == 2 ? Colors.white : Colors.white54),
                  onPressed: () {
                    onTabTapped(2);
                  },
                ),
              ],
            ),
          )),
      floatingActionButton: _currentIndex == 1
          ? FloatingActionButton(
              backgroundColor: Colors.tealAccent[700],
              child: Icon(
                Icons.add,
                color: Colors.black,
                size: 30,
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/add_price',
                    arguments: AddPrizeArguments(campaignId.toString()));
              })
          : FloatingActionButton(
              backgroundColor: Colors.tealAccent[700],
              child: Icon(
                Icons.qr_code_2,
                color: Colors.black,
                size: 30,
              ),
              onPressed: () {}),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}
