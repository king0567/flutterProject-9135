import 'dart:io';

import 'package:android_id/android_id.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:movienightapp/screens/share_code_screen.dart';
import 'package:movienightapp/screens/enter_code_screen.dart';
import 'package:movienightapp/utils/app_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({
    super.key,
  });

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    _initializeDeviceId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movie Night'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ShareCodeScreen(),
                    ));
              },
              child: const Text('Start Session'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EnterCodeScreen(),
                    ));
              },
              child: const Text('Join Session'),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _initializeDeviceId() async {
    String deviceId = await _fetchDeviceId();
    if (mounted) {
      Provider.of<AppState>(context, listen: false).setDeviceId(deviceId);
    }
  }

  Future<String> _fetchDeviceId() async {
    String deviceId = "";

    try {
      if (Platform.isAndroid) {
        const androidPlugin = AndroidId();
        deviceId = await androidPlugin.getId() ?? 'Unknown id';
      } else if (Platform.isIOS) {
        var deviceInfoPlugin = DeviceInfoPlugin();
        var iOSInfo = await deviceInfoPlugin.iosInfo;
        deviceId = iOSInfo.identifierForVendor ?? 'Unknown id';
      } else {
        deviceId = 'Unsupported platform';
      }
    } catch (e) {
      deviceId = 'Error: $e';
    }

    if (kDebugMode) {
      print('Device id: $deviceId');
    }
    return deviceId;
  }
}
