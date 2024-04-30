// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_final_fields, unused_field

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:just_audio/just_audio.dart';
import 'package:openai/drawer.dart';
import 'package:openai/services/openAIService.dart';
import 'package:openai/splashPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' as io;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class dashboard extends StatefulWidget {
  const dashboard({super.key});

  @override
  State<dashboard> createState() => _dashboardState();
}

class _dashboardState extends State<dashboard> {
  Future<http.Response>? chatApiResponse;
  Future<http.Response>? imageGenApiResponse;
  Future<String>? speechToTextResponse;
  final audioPlayer = AudioPlayer();
  final _chatPromptController = TextEditingController();
  final _imageGenerationPromptController = TextEditingController();
  final _responseController = TextEditingController();
  final recorder = FlutterSoundRecorder();

  Future initRecorder() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw 'Microphone permission not granted!';
    }
    await recorder.openRecorder();

    recorder.setSubscriptionDuration(const Duration(milliseconds: 500));
  }

  Future record() async {
    await recorder.startRecorder(toFile: 'speech.mp4');
  }

  Future stop() async {
    String? recordedPath = await recorder.stopRecorder();
    setState(() {});
    String? transcript =
        await openAIService.speechToText(recordedPath.toString());
    speechToTextResponse = openAIService.speechToText(recordedPath.toString());
  }

  Future<void> initAudioPlayer(String audioPath) async {
    try {
      await audioPlayer.setFilePath(audioPath);
    } catch (_) {
      throw Exception(_);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initRecorder();
  }

  @override
  void dispose() {
    recorder.closeRecorder();
    audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _blankAlert() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Response Failed'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Please enter a prompt'),
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

  Future<http.Response> chatResponse() async {
    return await openAIService.chatbot_response(_chatPromptController.text);
  }

  Future<http.Response> imageGenResponse() async {
    return await openAIService
        .imageGen_response(_imageGenerationPromptController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      drawer: drawer(),
      body: Container(
        child: Center(
            child: Padding(
          padding: EdgeInsets.all(8),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Flex(
              direction: Axis.vertical,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 35),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7.5),
                      border: Border.all(
                          color: Color.fromARGB(255, 196, 194, 194),
                          width: 1.5,
                          style: BorderStyle.solid)),
                  padding: EdgeInsets.all(10),
                  child: Flex(
                    direction: Axis.vertical,
                    children: [
                      Flex(
                        direction: Axis.horizontal,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(10),
                            child: Icon(
                              Icons.textsms_sharp,
                              color: Color.fromARGB(255, 2, 164, 118),
                              size: 60,
                            ),
                          ),
                          Text(
                            "Speech To Text",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Color.fromARGB(255, 2, 164, 118),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 35),
                        child: ElevatedButton(
                          style: ButtonStyle(
                            iconColor: MaterialStateColor.resolveWith(
                                (states) => Colors.white),
                            backgroundColor: MaterialStateColor.resolveWith(
                              (states) => Color.fromARGB(255, 2, 164, 118),
                            ),
                            elevation: MaterialStateProperty.all(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              recorder.isRecording ? Icons.stop : Icons.mic,
                              size: 80,
                            ),
                          ),
                          onPressed: () async => {
                            if (recorder.isRecording)
                              {await stop()}
                            else
                              {await record()},
                            setState(() {})
                          },
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 30),
                        child: StreamBuilder<RecordingDisposition>(
                          stream: recorder.onProgress,
                          builder: (context, snapshot) {
                            final duration = snapshot.hasData
                                ? snapshot.data!.duration
                                : Duration.zero;
                            return Text(
                                '${duration.inDays}${duration.inHours}:${duration.inMinutes}'
                                '${duration.inSeconds}',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w400,
                                  color: Color.fromARGB(255, 2, 164, 118),
                                ));
                          },
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 25, bottom: 25),
                        child: FutureBuilder<String>(
                          future: speechToTextResponse,
                          builder: (BuildContext context,
                              AsyncSnapshot<String> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.none) {
                              return Text("");
                            } else if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return SpinKitCircle(
                                color: Color.fromARGB(255, 2, 164, 118),
                                size: 75,
                              );
                            } else if (snapshot.connectionState ==
                                ConnectionState.done) {
                              if (snapshot.data == null) {
                                return Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(7),
                                        border: Border.all(
                                            color: Colors.red, width: 1.5)),
                                    child: Flex(
                                      direction: Axis.vertical,
                                      children: [
                                        Icon(
                                          Icons.error,
                                          color: Colors.red,
                                          size: 50,
                                        ),
                                        Text(
                                          "Server Error Please Retry",
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 20,
                                              letterSpacing: 2),
                                        ),
                                      ],
                                    ));
                              }

                              return Container(
                                margin: EdgeInsets.only(top: 10, bottom: 10),
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(7),
                                      border: Border.all(
                                          width: 2.25,
                                          color: Color.fromARGB(
                                              255, 2, 164, 118))),
                                  child: Flex(
                                    direction: Axis.vertical,
                                    children: [
                                      Container(
                                          margin: EdgeInsets.only(
                                              top: 5, bottom: 5),
                                          child: AnimatedTextKit(
                                            repeatForever: false,
                                            isRepeatingAnimation: false,
                                            animatedTexts: [
                                              TyperAnimatedText(
                                                snapshot.data.toString(),
                                                textStyle: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 17.5,
                                                    letterSpacing: 0.75,
                                                    wordSpacing: 1.75),
                                                speed:
                                                    Duration(milliseconds: 50),
                                              )
                                            ],
                                          ))
                                    ],
                                  ),
                                ),
                              );
                            } else if (snapshot.hasError) {
                              return Container(
                                color: Colors.red,
                                child: Text(
                                  "Server Error Please Retry",
                                  style:
                                      TextStyle(fontSize: 20, letterSpacing: 1),
                                ),
                              );
                            }
                            return Text("");
                          },
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 35),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7.5),
                      border: Border.all(
                          color: Color.fromARGB(255, 196, 194, 194),
                          width: 1.5,
                          style: BorderStyle.solid)),
                  padding: EdgeInsets.all(10),
                  child: Flex(
                    direction: Axis.vertical,
                    children: [
                      Flex(
                        direction: Axis.horizontal,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(10),
                            child: Icon(
                              Icons.message_rounded,
                              color: Color.fromARGB(255, 250, 76, 17),
                              size: 60,
                            ),
                          ),
                          Text(
                            "ChatBot",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      TextField(
                          controller: _chatPromptController,
                          minLines: 1,
                          maxLines: 10,
                          style: TextStyle(fontSize: 20),
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 3.350,
                                    color: Color.fromARGB(255, 245, 100, 52))),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 1.675,
                                    color: Color.fromARGB(255, 250, 76, 17))),
                            disabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 1.675,
                                    color: Color.fromARGB(255, 250, 76, 17))),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color.fromARGB(255, 250, 76, 17)),
                                borderRadius: BorderRadius.circular(10)),
                            hintText: "Enter a prompt",
                            hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 18,
                                fontWeight: FontWeight.w400),
                          )),
                      Container(
                        margin: EdgeInsets.only(top: 35),
                        child: ElevatedButton(
                            style: ButtonStyle(
                              iconColor: MaterialStateColor.resolveWith(
                                  (states) => Colors.white),
                              backgroundColor: MaterialStateColor.resolveWith(
                                (states) => Color.fromARGB(255, 250, 76, 17),
                              ),
                              elevation: MaterialStateProperty.all(15),
                            ),
                            onPressed: () => {
                                  if (_chatPromptController.text == '')
                                    {_blankAlert()}
                                  else
                                    {
                                      setState(() {
                                        chatApiResponse = chatResponse();
                                      }),
                                    }
                                },
                            child: Padding(
                              padding: EdgeInsets.all(7),
                              child: Text(
                                "Chat",
                                style: TextStyle(
                                    fontSize: 26.5,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w400),
                              ),
                            )),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 25, bottom: 25),
                        child: FutureBuilder<http.Response>(
                          future: chatApiResponse,
                          builder: (BuildContext context,
                              AsyncSnapshot<http.Response> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.none) {
                              return Text("");
                            } else if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Container(
                                margin: EdgeInsets.only(top: 20),
                                child: SpinKitDualRing(
                                  color: Color.fromARGB(255, 250, 76, 17),
                                  size: 75,
                                ),
                              );
                            } else if (snapshot.connectionState ==
                                ConnectionState.done) {
                              if (snapshot.data == null) {
                                return Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(7),
                                        border: Border.all(
                                            color: Colors.red, width: 1.5)),
                                    child: Flex(
                                      direction: Axis.vertical,
                                      children: [
                                        Icon(
                                          Icons.error,
                                          color: Colors.red,
                                          size: 50,
                                        ),
                                        Text(
                                          "Server Error Please Retry",
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 20,
                                              letterSpacing: 2),
                                        ),
                                      ],
                                    ));
                              }
                              Map<String, dynamic> data =
                                  jsonDecode(snapshot.data!.body);
                              return Container(
                                margin: EdgeInsets.only(top: 10, bottom: 10),
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(7),
                                      border: Border.all(
                                        width: 1.75,
                                        color: Color.fromARGB(255, 250, 76, 17),
                                      )),
                                  child: SingleChildScrollView(
                                      child: AnimatedTextKit(
                                    repeatForever: false,
                                    isRepeatingAnimation: false,
                                    animatedTexts: [
                                      TypewriterAnimatedText(
                                          data["choices"][0]["message"]
                                              ["content"],
                                          speed: Duration(milliseconds: 40),
                                          textStyle: TextStyle(
                                              color: Colors.black,
                                              fontSize: 17.5,
                                              letterSpacing: 0.75,
                                              wordSpacing: 1.75)),
                                    ],
                                  )),
                                ),
                              );
                            } else if (snapshot.hasError) {
                              return Container(
                                color: Colors.red,
                                child: Text(
                                  "Server Error Please Retry",
                                  style:
                                      TextStyle(fontSize: 20, letterSpacing: 1),
                                ),
                              );
                            }
                            return Text("");
                          },
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 35, bottom: 12.5),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7.5),
                      border: Border.all(
                          color: Color.fromARGB(255, 196, 194, 194),
                          width: 1.5,
                          style: BorderStyle.solid)),
                  padding: EdgeInsets.all(10),
                  child: Flex(
                    direction: Axis.vertical,
                    children: [
                      Flex(
                        direction: Axis.horizontal,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(10),
                            child: Icon(
                              Icons.image_outlined,
                              color: Color.fromARGB(255, 43, 6, 130),
                              size: 60,
                            ),
                          ),
                          Text(
                            "Image Generation",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: Color.fromARGB(255, 43, 6, 130)),
                          ),
                        ],
                      ),
                      TextField(
                          controller: _imageGenerationPromptController,
                          minLines: 1,
                          maxLines: 10,
                          style: TextStyle(fontSize: 20),
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 3.350,
                                    color: Color.fromARGB(255, 43, 6, 130))),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 1.675,
                                    color: Color.fromARGB(255, 43, 6, 130))),
                            disabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 1.675,
                                    color: Color.fromARGB(255, 43, 6, 130))),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color.fromARGB(255, 43, 6, 130)),
                                borderRadius: BorderRadius.circular(10)),
                            hintText: "Imagine a photo",
                            hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 18,
                                fontWeight: FontWeight.w400),
                          )),
                      Container(
                        margin: EdgeInsets.only(top: 35),
                        child: ElevatedButton(
                            style: ButtonStyle(
                              iconColor: MaterialStateColor.resolveWith(
                                  (states) => Colors.white),
                              backgroundColor: MaterialStateColor.resolveWith(
                                (states) => Color.fromARGB(255, 43, 6, 130),
                              ),
                              elevation: MaterialStateProperty.all(15),
                            ),
                            onPressed: () => {
                                  if (_imageGenerationPromptController.text ==
                                      '')
                                    {_blankAlert()}
                                  else
                                    {
                                      setState(() {
                                        imageGenApiResponse =
                                            imageGenResponse();
                                      })
                                    }
                                },
                            child: Padding(
                              padding: EdgeInsets.all(7.5),
                              child: Text(
                                "Generate",
                                style: TextStyle(
                                    fontSize: 24.5,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w400),
                              ),
                            )),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 25, bottom: 25),
                        child: FutureBuilder<http.Response>(
                          future: imageGenApiResponse,
                          builder: (BuildContext context,
                              AsyncSnapshot<http.Response> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.none) {
                              return Text("");
                            } else if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return SpinKitWaveSpinner(
                                color: Color.fromARGB(255, 89, 19, 151),
                                size: 75,
                              );
                            } else if (snapshot.connectionState ==
                                ConnectionState.done) {
                              if (snapshot.data == null) {
                                return Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(7),
                                        border: Border.all(
                                            color: Colors.red, width: 1.5)),
                                    child: Flex(
                                      direction: Axis.vertical,
                                      children: [
                                        Icon(
                                          Icons.error,
                                          color: Colors.red,
                                          size: 50,
                                        ),
                                        Text(
                                          "Server Error Please Retry",
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 20,
                                              letterSpacing: 2),
                                        ),
                                      ],
                                    ));
                              }
                              Map<String, dynamic> data =
                                  jsonDecode(snapshot.data!.body);
                              return Container(
                                margin: EdgeInsets.only(top: 10, bottom: 10),
                                child: Container(
                                  padding: EdgeInsets.all(0.2),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width /
                                        1.25,
                                    child: Image.network(data["data"][0]["url"],
                                        fit: BoxFit.cover),
                                  ),
                                ),
                              );
                            } else if (snapshot.hasError) {
                              return Container(
                                color: Colors.red,
                                child: Text(
                                  "Server Error Please Retry",
                                  style:
                                      TextStyle(fontSize: 20, letterSpacing: 1),
                                ),
                              );
                            }
                            return Text("");
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        )),
      ),
    );
  }
}
