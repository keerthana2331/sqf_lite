// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:sq_lite/contactlist.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contact Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: GoogleFonts.montserratTextTheme(),
      ),
      home: ContactListPage(),
    );
  }
}
