// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:openai/dashboard.dart';

class errorPage extends StatefulWidget {
  errorPage();

  @override
  State<errorPage> createState() => _errorPageState();
}

class _errorPageState extends State<errorPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: SingleChildScrollView(
          child: Flex(
            direction: Axis.vertical,
            children: [
              Icon(
                Icons.error,
                color: Colors.red,
                size: 100,
              ),
              Text(
                "Server Error",
                style: TextStyle(
                    color: Colors.red,
                    fontSize: 30,
                    decoration: TextDecoration.none),
              ),
              Container(
                margin: EdgeInsets.only(top: 50),
                child: ElevatedButton(
                    onPressed: () => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => dashboard()),
                          )
                        },
                    child: Text(
                      "Try Again",
                      style: TextStyle(fontSize: 20),
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }
}
