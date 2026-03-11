import 'package:flutter/material.dart';
import 'package:shadaa/const/app_dimensions.dart';
import 'package:shadaa/splach_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    AppDimensions.initialize(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Cairo'),
      home: SplachScreen(),
    );
  }
}
