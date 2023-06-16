import 'package:firebase_auth/firebase_auth.dart';
import 'package:app/auth.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final User? user = Auth().currentUser;
  int _currentIndex = 0;
  final String apiUrl = 'http://10.0.2.2:8000';
  var headers = {'Content-Type': 'application/json'};
  late Timer _timer;
  String? _currentTime;
  late String lat;
  late String long;

  Future<void> signOut() async {
    await Auth().signOut();
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled');
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied!');
    }
    return await Geolocator.getCurrentPosition();
  }

  Future<void> postData() async {
    _getCurrentLocation().then((value) {
      lat = '${value.latitude}';
      long = '${value.longitude}';
    },)
    try {
      var response = await http.post(
        Uri.parse('$apiUrl/times/create/'),
        body: json.encode({
          "date": DateTime.now().millisecondsSinceEpoch,
          "location": {"lat": "$lat", "long": "$long"},
          "photo": "",
          "uid": user?.uid ?? ''
        }),
        headers: headers,
      );
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');
    } catch (error) {
      print('Error: $error');
    }
  }

  Widget _title() {
    return const Text('System');
  }

  Widget _qr_code() {
    return Column(
      children: [
        const Text('Twój kod do mierzenia czasu pracy w KIOSK'),
        const SizedBox(height: 20),
        QrImage(
          data: user?.uid ?? '',
          version: QrVersions.auto,
          size: 300.0,
        ),
      ],
    );
  }

  Widget _userInfo() {
    return Column(
      children: [
        Text('Email: ${user?.email ?? 'Unknown'}'),
      ],
    );
  }

  Widget _signOutButton() {
    return ElevatedButton(onPressed: signOut, child: const Text('Wyloguj'));
  }

  Widget _workTimeButton() {
    return ElevatedButton(
        onPressed: postData, child: const Text('Zmierz czas pracy poza KIOSK'));
  }

  @override
  Widget build(BuildContext context) {
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      setState(() {
        _currentTime = DateFormat('dd.MM.yyyy kk:mm:ss').format(DateTime.now());
      });
    });
    void dispose() {
      _timer.cancel();
      super.dispose();
    }

    List<Widget> body = [
      Container(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _qr_code(),
          ],
        ),
      ),
      Container(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Mierzenie czasu pracy w poza KIOSK'),
            Center(
              child: Text(
                _currentTime ?? '',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25.0),
              ),
            ),
            _workTimeButton(),
          ],
        ),
      ),
      Container(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _userInfo(),
            _signOutButton(),
          ],
        ),
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: _title(),
        ),
      ),
      body: body[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int newIndex) {
          setState(() {
            _currentIndex = newIndex;
          });
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.qr_code_scanner_rounded), label: 'QR Code'),
          BottomNavigationBarItem(
              icon: Icon(Icons.access_alarm), label: 'Zmierz czas'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
