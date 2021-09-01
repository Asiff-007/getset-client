import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
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
    ListPrize(campaignId: campaignId),
    ListPrize(campaignId: campaignId),
    ListPrize(campaignId: campaignId),
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
      bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white54,
          onTap: onTabTapped,
          currentIndex: _currentIndex,
          showUnselectedLabels: true,
          showSelectedLabels: true,
          backgroundColor: Colors.deepPurpleAccent[700],
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.wb_cloudy),
              label: tr('campaign'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              label: tr('prize'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.local_hospital),
              label: tr('edit'),
            ),
          ],
          iconSize: 25),
      floatingActionButton: _currentIndex == 1
          ? FloatingActionButton(
              backgroundColor: Colors.tealAccent[700],
              child: Icon(
                Icons.add,
                color: Colors.black,
                size: 30,
              ),
              onPressed: () {})
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
