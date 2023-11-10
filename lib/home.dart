
import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'batch/create.dart';
import 'batch/delete.dart';
import 'batch/info.dart';
import 'package:http/http.dart' as http;
import 'batch/view_archived.dart';
import 'diary/main_diary.dart';
import 'batch/list_view.dart';
import 'models/user_model.dart';


class MainPage extends StatefulWidget {
  final User user;
  final Map token;

  const MainPage({super.key, required this.title, required this.user, required this.token});

  final String title;


  @override
  State<MainPage> createState() {
    return _MainPageState(user);
  }
}

Future<List> getData(url, token) async {
  String actualToken = token['token'] as String;
  final headers = {'Content-Type': 'application/json', 'Authorization': actualToken };
  final response = await http.get(Uri.parse(url), headers: headers);

  List<Map<String,dynamic>> list = List<Map<String,dynamic>>.from(json.decode(response.body));
  return list;

}

Future<int> sendData(url, body, token) async {
  String actualToken = token['token'] as String;
  final headers = {'Content-Type': 'application/json', 'Authorization': actualToken };
  final response = await http.post(Uri.parse(url), headers: headers, body: json.encode(body));

  return response.statusCode;

}

Future<int> updateData(url, body, token) async {
  String actualToken = token['token'] as String;
  final headers = {'Content-Type': 'application/json', 'Authorization': actualToken };
  final response = await http.put(Uri.parse(url), headers: headers, body: json.encode(body));

  return response.statusCode;

}

class _MainPageState extends State<MainPage> {
  _MainPageState(user);


  @override
  Widget build(BuildContext context) {

    String url = "https://tg0217.pythonanywhere.com/user/${widget.user.userId}/batches";

    return WillPopScope(
      onWillPop: () {
        SystemNavigator.pop();
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
        ),
        body: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: FutureBuilder(

              future: getData(url, widget.token),
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    return const Center(
                        child: Text("Error fetching data has occurred")
                    );
                  }
                  else if (snapshot.hasData) {
                    final docNames = snapshot.data;
                    List<Widget> sidebarList = [];

                    sidebarList.add(
                      const Divider(
                        color: Colors.black,
                      ),
                    );

                    docNames?.forEach((doc)
                    {

                      if (doc["Status"] == 1) {
                        sidebarList.add(ListTile(
                          title: Text("     ${doc.batchId}"),
                          onTap: () =>
                          {Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  InfoHomePage(batchId: doc.batchId, title: doc.batchId, user: widget.user, token: widget.token),
                            ),

                          )},
                        ),
                        );
                        sidebarList.add(
                          const Divider(
                            color: Colors.black,
                          ),
                        );
                      }
                    });
                    return Center(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Active Batches", style: TextStyle(color: Colors.green, fontSize: 32)),
                              ...sidebarList,

                            ]
                        )
                    );
                  }

                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

          ),

        ),


        drawer: makeDrawer(context, widget.title, widget.user, widget.token),
      ),
    );

  }
}




Widget makeDrawer(context, title, user, token){

  return Drawer(
      child: FutureBuilder(
        builder: (ctx, snapshot) {
          // Checking if future is resolved or not
          if (snapshot.connectionState == ConnectionState.done) {
            // If we got an error
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  '${snapshot.error} occurred',
                  style: const TextStyle(fontSize: 18),
                ),
              );

              // if we got our data
            } else if (snapshot.hasData) {
              // Extracting data from snapshot object
              final data = snapshot.data as List;
              List<Widget> activeList = [];


              data.forEach((DOC)
              {
                final d = DOC.data() as Map<String, dynamic>;
                if (d["Status"] == "Active"){
                  activeList.add( ListTile(
                    title: Text("     ${DOC.batchId}"),
                    onTap: () => {Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InfoHomePage(batchId: DOC.batchId, title: DOC.batchId, user: user, token: token),
                      ),

                    )},
                  ),
                  );

                }
              });

              return ListView(
                children: [
                  const DrawerHeader(
                    decoration: BoxDecoration(color: Colors.green,),
                    child: Text("Management App", style: TextStyle(color: Colors.white, fontSize: 32)),
                  ),
                  ListTile(
                    title: const Text("Home"),
                    onTap: () => {Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MainPage(title: title, user: user, token: token),

                      ),

                    )},
                  ),
                  ListTile(
                    title: const Text("Active Batches"),
                    onTap: (){

                    },
                  ),
                  ...activeList,

                  ListTile(
                    title: const Text("Create a new batch"),
                    onTap: () => {Navigator.push(context,
                        MaterialPageRoute(builder: (context) => CreatePage(title: 'Create a new Batch', user: user, token: token))

                    )},
                  ),

                  ListTile(
                    title: const Text("Farm Diary"),
                    onTap: () => {Navigator.push(context,
                        MaterialPageRoute(builder: (context) => MyPage(title: 'Farm Diary', user: user, token: token))

                    )},
                  ),


                  ListTile(
                    title: const Text("View Archived Batches"),
                    onTap: () => {Navigator.push(context,
                        MaterialPageRoute(builder: (context) => ArchiveViewPage(title: 'View Archived Batches', batchId: null, fields: ["Batch Name", "Total Expenses", "Total Income", "Original Quantity", "Current Quantity", "Date Archived"], path: "https:", user: user, token: token))

                    )},
                  ),
                ],
              );
            }
          }

          // Displaying LoadingSpinner to indicate waiting state
          return const Center(
            child: CircularProgressIndicator(),
          );
        },

        future: getData(user, token),
      )
  );
}


