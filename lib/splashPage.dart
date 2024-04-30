// ignore_for_file: prefer_const_constructors

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:openai/dashboard.dart';
import 'package:openai/loginPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class splashPage extends StatefulWidget {
  const splashPage({super.key});

  @override
  State<splashPage> createState() => _splashPageState();
}

class _splashPageState extends State<splashPage> {
  Future<void> checkIsLogged() async {
    Future.delayed(Duration(milliseconds: 2000), () async {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      if (preferences.getString('access_token') == '' ||
          preferences.getString('access_token') == null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => loginPage()),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => dashboard()),
        );
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkIsLogged();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          child: SpinKitDoubleBounce(
            color: Color.fromARGB(255, 50, 2, 131),
            size: 210,
          ),
        ),
      ),
    );
  }
}
