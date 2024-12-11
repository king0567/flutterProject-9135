import 'package:flutter/services.dart';
import 'package:movienightapp/utils/app_state.dart';
import 'package:movienightapp/utils/http_helper.dart';
import 'package:movienightapp/screens/welcome_screen.dart';
import 'package:movienightapp/screens/movie_selection_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EnterCodeScreen extends StatefulWidget {
  const EnterCodeScreen({super.key});

  @override
  State<EnterCodeScreen> createState() => _EnterCodeScreenState();
}

class _EnterCodeScreenState extends State<EnterCodeScreen> {
  final GlobalKey<FormState> _formStateKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Join Session',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blue,
        ),
        body: Center(
          child: Form(
            key: _formStateKey,
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 80.0, bottom: 200.0, left: 8.0, right: 8.0),
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                        labelText: 'Enter The Code From Your Friend',
                        labelStyle: Theme.of(context).textTheme.bodyLarge,
                        icon: const Icon(Icons.code),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 20.0, horizontal: 0.0)),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    style: Theme.of(context)
                        .textTheme
                        .headlineLarge!
                        .copyWith(letterSpacing: 20.0),
                    textAlign: TextAlign.center,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4)
                    ],
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your code!';
                      }
                      if (value.length != 4) {
                        return 'The code must be 4 digits';
                      }
                      return null;
                    },
                    onSaved: (String? value) {
                      _joinSession(value);
                    },
                  ),
                  const Spacer(),
                  ElevatedButton(
                      onPressed: () {
                        if (_formStateKey.currentState!.validate()) {
                          _formStateKey.currentState!.save();
                        }
                      },
                      child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.start),
                            SizedBox(width: 8),
                            Text("Begin")
                          ]))
                ],
              ),
            ),
          ),
        ));
  }

  Future<void> _joinSession(String? code) async {
    String? deviceId = Provider.of<AppState>(context, listen: false).deviceId;
    if (kDebugMode) {
      print('Device id from Enter Code Screen: $deviceId');
    }
    //call api
    final response = await HttpHelper.joinSession(deviceId, code);
    if (response["success"] == true) {
      await sharedPreferencesSave(response['body']['data']['session_id']);
      if (mounted) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const MovieSelectionScreen()));
      }
    } else {
      if (mounted) {
        showAlert(context, "Error",
            response["message"] ?? "Invalid code. Please try again.");
      }
    }
  }

  Future<void> sharedPreferencesSave(String sessionId) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setString("sessionId", sessionId);
  }
}

void showAlert(BuildContext context, String title, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const WelcomeScreen()));
            },
            child: const Text("OK"),
          ),
        ],
      );
    },
  );
}
