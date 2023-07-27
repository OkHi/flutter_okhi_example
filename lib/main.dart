import 'package:flutter/material.dart';
import 'package:okhi_flutter/okhi_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    final config = OkHiAppConfiguration(
      branchId: "", // your branchId
      clientKey: "", // your client key
      env: OkHiEnv.prod,
      notification: OkHiAndroidNotification(
        title: "Verification in progress",
        text: "Verifying your address",
        channelId: "okhi",
        channelName: "OkHi",
        channelDescription: "Verification alerts",
      ),
    );
    OkHi.initialize(config);
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: AddressScreen(),
    );
  }
}

class AddressScreen extends StatefulWidget {
  const AddressScreen({Key? key}) : super(key: key);

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  bool _launchLocationManager = false;
  BuildContext? _context;
  final _user = OkHiUser(
    phone: "+2348000000000",
  );

  @override
  Widget build(BuildContext context) {
    _context = context;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create and Verify an address'),
      ),
      body: _renderBody(),
    );
  }

  _renderBody() {
    if (!_launchLocationManager) {
      return Center(
        child: TextButton(
          onPressed: _handleOnCreateAddressPressed,
          child: const Text('Create an address'),
        ),
      );
    }
    return OkHiLocationManager(
      user: _user,
      onCloseRequest: _handleOnCloseRequest,
      onError: _handleOnError,
      onSucess: _handleOnSuccess,
    );
  }

  _handleOnCreateAddressPressed() async {
    final result = await OkHi.canStartVerification(true);
    setState(() {
      _launchLocationManager = result;
    });
  }

  _handleOnCloseRequest() {
    // user wants to exit the OkHiLocationManager experience
    setState(() {
      _launchLocationManager = false;
    });
  }

  _handleOnError(OkHiException error) {
    // handle OkHiLocationManager errors here
    setState(() {
      _launchLocationManager = false;
    });
  }

  _handleOnSuccess(OkHiLocationManagerResponse response) async {
    // response.user - user information
    // response.location - address information
    setState(() {
      _launchLocationManager = false;
    });
    String result = await response.startVerification(
        null); // start address verification with default configuration
    _showMessage("Address verification started",
        "Successfully started verification for: $result");
  }

  _showMessage(String title, String message) {
    if (_context == null) return;
    showDialog(
      context: _context!,
      builder: (_) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
        );
      },
      barrierDismissible: true,
    );
  }
}
