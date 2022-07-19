import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'screens/home_page.dart';
import 'package:device_preview/device_preview.dart';

void main() => runApp(DevicePreview(
    enabled: true,
    tools: const [...DevicePreview.defaultTools],
    builder: (context) => const MyApp()));

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Shoppy',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: const HomePage(),
    );
  }
}
