// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:openai/splashPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class drawer extends StatefulWidget {
  const drawer({super.key});

  @override
  State<drawer> createState() => _drawerState();
}

class _drawerState extends State<drawer> {
  Future<void> logout() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.remove('access_token');
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: Container(
        margin: EdgeInsets.only(left: 7.5),
        height: MediaQuery.of(context).size.height / 1.5,
        child: Drawer(
          backgroundColor: Colors.white,
          child: Center(
            child: SingleChildScrollView(
              child: Flex(
                direction: Axis.vertical,
                children: [
                  ElevatedButton(
                      style: ButtonStyle(
                        iconColor: MaterialStateColor.resolveWith(
                            (states) => Colors.white),
                        backgroundColor: MaterialStateColor.resolveWith(
                            (states) => Colors.blueAccent),
                        elevation: MaterialStateProperty.all(15),
                      ),
                      onPressed: () => {
                            logout(),
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => splashPage()),
                            )
                          },
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Flex(
                          mainAxisSize: MainAxisSize.min,
                          direction: Axis.horizontal,
                          children: [
                            Icon(
                              Icons.logout,
                              size: 30,
                            ),
                            Text(
                              "Logout",
                              style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w400),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
