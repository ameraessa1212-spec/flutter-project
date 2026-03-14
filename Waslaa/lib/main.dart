import 'package:flutter/material.dart';
import 'package:Waslla/const/app_dimensions.dart';
import 'package:Waslla/splach_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    AppDimensions.initialize(context);
    return MaterialApp(
      title: 'Waslaa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Cairo'),
      home: SplachScreen(),
    );
  }
}
