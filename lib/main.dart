import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:ffi';
import 'batch/info.dart';
import 'home.dart';
import 'models/user_model.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final userNameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              controller: userNameController,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: "Username (Should be unique)",
                hintStyle: TextStyle(color: Colors.black),
              ),
            ),
            TextFormField(
              controller: passwordController,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: "Password",
                hintStyle: TextStyle(color: Colors.black),
              ),
            ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 30.0),
          child: ElevatedButton(
            child: const Text("Submit"),
            onPressed: () async {

                final user = {
                  "username": userNameController.text,
                  "password": passwordController.text,
                  "user_id": "898989"
                };




                Map<String,dynamic> token = await login(user);


                if (token['token'] != '') {
                  print(token);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          MainPage(title: "Farm App", user: user, token: token),

                    ),

                  );
                }

               }

                  ),

                ),

          ],
        ),
      ),
    );
  }
}

String getRandomUserName() {
  const int length = 10;
  const chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random rnd = Random();
  return String.fromCharCodes(Iterable.generate(
      length,
          (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
}


Future<Map<String,dynamic>> login(user) async{
  String url = "http://tg0217.pythonanywhere.com/users/${user["user_id"]}/login";
  final Map<String,dynamic> token = {'token': ''};

  try {
    //Verified
    final headers = {'Content-Type': 'application/json'};
    final response = await http.post(Uri.parse(url), headers: headers, body: json.encode(user));

    if (response.statusCode == 200){
      return Map<String,dynamic>.from(json.decode(response.body));

    }
    else {
      print(response.statusCode);
      return token;
    }

  }
  catch (e) {
    print(e);
    return token;
  }
}