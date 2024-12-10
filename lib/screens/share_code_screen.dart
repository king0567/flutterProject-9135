import 'dart:convert';

import 'package:movienightapp/utils/app_state.dart';
import 'package:movienightapp/utils/http_helper.dart';
import 'package:movienightapp/screens/movie_selection_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ShareCodeScreen extends StatefulWidget {
  const ShareCodeScreen({super.key});

  @override
  State<ShareCodeScreen> createState() => _ShareCodeScreenState();
}

class _ShareCodeScreenState extends State<ShareCodeScreen> {
  String code = "Unset";
  bool dataStored = false;

  @override
  void initState() {
    super.initState();
    _startSession();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Start Session',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blue,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.only(
                top: 80.0, bottom: 200.0, left: 8.0, right: 8.0),
            child: Column(
              children: [
                Column(
                  children: [
                    Text(
                      'Code: $code',
                      style: TextStyle(
                          fontSize: 50.0, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'Share This Code With A Friend',
                      style: TextStyle(fontSize: 20.0),
                    )
                  ],
                ),
                Spacer(),
                ElevatedButton(
                    onPressed: () {
                      if (dataStored) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MovieSelectionScreen(),
                            ));
                      }
                    },
                    child: const Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.start),
                      SizedBox(width: 8),
                      Text("Begin")
                    ]))
              ],
            ),
          ),
        ));
  }

  Future<void> _startSession() async {
    String? deviceId = Provider.of<AppState>(context, listen: false).deviceId;
    if (kDebugMode) {
      print('Device id from Share Code Screen: $deviceId');
    }
    //call api
    final response = await HttpHelper.startSession(deviceId);
    if (kDebugMode) {
      print(response['body']['data']['code']);
    }

    if (response["success"] == true) {
      setState(() {
        code = response['body']['data']['code'];
      });

      await sharedPreferencesSave(response['body']['data']['session_id']);
      setState(() {
        dataStored = true;
      });
    }
  }

  Future<void> sharedPreferencesSave(String sessionId) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString("sessionId", sessionId);
  }
}
