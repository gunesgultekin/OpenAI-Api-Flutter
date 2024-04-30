// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:openai/dashboard.dart';
import 'package:openai/services/authService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class loginPage extends StatefulWidget {
  const loginPage({super.key});

  @override
  State<loginPage> createState() => _loginPageState();
}

class _loginPageState extends State<loginPage> {
  Future<http.Response>? _loginResponse;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _loginAlert() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button or not?
      builder: (BuildContext context) {
        return AlertDialog(
          title: Flex(
            direction: Axis.horizontal,
            children: [
              Container(
                margin: EdgeInsets.only(right: 10),
                child: Icon(
                  Icons.error_rounded,
                  color: Colors.red,
                ),
              ),
              const Text('Login Failed'),
            ],
          ),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Invalid username or password'),
              ],
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _blankAlert() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Login Failed'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Please enter all necessary fields'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<http.Response> checkLogin() async {
    if (_usernameController.text == '' || _passwordController.text == '') {
      _blankAlert();
      return http.Response("Success", HttpStatus.unauthorized);
    }
    try {
      await authService.login(
          _usernameController.text, _passwordController.text);
      SharedPreferences preferences = await SharedPreferences.getInstance();
      // If authService.login check fails, an exception will be thrown
      // No authorization tokens will be generated
      // If any errors re-check whether token exist or not
      if (preferences.getString('access_token') == '' ||
          preferences.getString('access_token') == null) {
        _loginAlert();
        return http.Response("Success", HttpStatus.unauthorized);
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => dashboard()),
        );
        return http.Response("Success", HttpStatus.accepted);
      }
    } on Exception catch (_) {
      _loginAlert();
      return http.Response("failes", HttpStatus.unauthorized);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Flex(
            mainAxisAlignment: MainAxisAlignment.center,
            direction: Axis.vertical,
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 10),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width / 1.1,
                  child: TextField(
                      style: TextStyle(fontSize: 20),
                      maxLines: 1,
                      minLines: 1,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: Colors.black26)),
                        contentPadding: EdgeInsets.symmetric(vertical: 15),
                        hintText: "",
                        helperText: "Enter your username",
                      ),
                      autofocus: true,
                      controller: _usernameController),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 10),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width / 1.1,
                  child: TextField(
                      obscureText: true,
                      style: TextStyle(fontSize: 20),
                      maxLines: 1,
                      minLines: 1,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: Colors.black26)),
                        contentPadding: EdgeInsets.symmetric(vertical: 15),
                        hintText: "",
                        helperText: "Enter your password",
                      ),
                      autofocus: true,
                      controller: _passwordController),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 15),
                child: ElevatedButton(
                    style: ButtonStyle(
                      iconColor: MaterialStateColor.resolveWith(
                          (states) => Colors.white),
                      backgroundColor: MaterialStateColor.resolveWith(
                          (states) => Colors.blueAccent),
                      elevation: MaterialStateProperty.all(15),
                    ),
                    onPressed: () => {
                          setState(() {
                            _loginResponse = checkLogin();
                          })
                        },
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        "Login",
                        style: TextStyle(
                            fontSize: 22.5,
                            color: Colors.white,
                            fontWeight: FontWeight.w400),
                      ),
                    )),
              ),
              Container(
                margin: EdgeInsets.only(top: 25, bottom: 25),
                child: FutureBuilder<http.Response>(
                    future: _loginResponse,
                    builder: (BuildContext context,
                        AsyncSnapshot<http.Response> snapshot) {
                      if (snapshot.connectionState == ConnectionState.none) {
                        return Text("");
                      } else if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Container(
                          margin: EdgeInsets.all(50),
                          child: SpinKitDoubleBounce(
                            color: Color.fromARGB(255, 3, 18, 104),
                            size: 165,
                          ),
                        );
                      } else if (snapshot.connectionState ==
                          ConnectionState.done) {
                        return Text("");
                      } else if (snapshot.data == null) {
                        return Text("Server Error");
                      }
                      return Text("");
                    }),
              )
            ],
          ),
        ),
      ),
    );
  }
}
