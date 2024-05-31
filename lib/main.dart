import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'src/app.dart';

void main() async {
  // Initialize sqflite for desktop platforms
  if (sqfliteFfiInit != null) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(MyApp());
}
