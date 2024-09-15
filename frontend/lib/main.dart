import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/screens/loading_screen.dart';

void main() async {
  await dotenv.load(fileName: "assets/env/.env");
  String apiServerUrl = dotenv.get("API_SERVER_URL");
  print(apiServerUrl);
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: LoadingScreen(),
    );
  }
}
