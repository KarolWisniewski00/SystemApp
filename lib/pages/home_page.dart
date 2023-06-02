import 'package:firebase_auth/firebase_auth.dart';
import 'package:app/auth.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final User? user = Auth().currentUser;
  int _currentIndex = 0;

  Future<void> signOut() async {
    await Auth().signOut();
  }

  Widget _title() {
    return const Text('System');
  }

  Widget _qr_code() {
    return Column(
      children: [
        const Text('Twój kod do mierzenia czasu pracy'),
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
        onPressed: () {}, child: const Text('Wyślij czas pracy - ręcznie'));
  }

  @override
  Widget build(BuildContext context) {
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
      )),
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
