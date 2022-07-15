import 'package:flutter/material.dart';
import 'package:scanr/components/Home.dart';

void main() {
  runApp(const Scanr());
}

class Scanr extends StatelessWidget {
  const Scanr({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scanr',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.deepPurple,
      ),
      routes: {
        "/": (_) => const Home(),
      },
    );
  }
}
