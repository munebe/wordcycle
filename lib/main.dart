import 'package:flutter/material.dart';
import 'package:wordcycle/pages/home_page.dart'; // Ana sayfanızı buraya ekleyin

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      home: HomePage(), // Ana sayfa olarak HomePage'i ayarlıyoruz
      debugShowCheckedModeBanner: false,
    );
  }
}
