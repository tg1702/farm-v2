
import 'package:flutter/material.dart';
import '../home.dart';
import '../models/user_model.dart';
import 'edit.dart';
import '../main.dart';
import 'info.dart';
import 'list_view.dart';

class ArchiveViewPage extends StatefulWidget {


  const ArchiveViewPage({super.key, required this.title,
    required this.token, required this.user, required this.fields, required this.batchId, required this.path});

  final Map<String,dynamic> user;
  final path;
  final batchId;
  final fields;
  final Map<String,dynamic> token;
  final String title;

  @override
  State<StatefulWidget> createState() {
    return _ArchiveViewPageState(path, fields, batchId);
  }

}

class _ArchiveViewPageState extends State<ArchiveViewPage> {
  _ArchiveViewPageState(path, fields, batchId);

  bool show = false;


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

        title: Text(widget.title),
      ),
      body: Center(

        child: FutureBuilder(
            builder: (context, snapshot) {
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

                  final docs = snapshot.data as List;
                  var data = [];
                  List subIds = [];

                  docs.forEach((d) {
                    Map<String,dynamic> rec = d.data() as Map<String, dynamic>;
                    data.add(rec);
                    subIds.add(rec["batch_id"]);
                  });

                  bool showIncome = (widget.fields.contains("Income")) ? true:false;

                  List <DataRow> rows = [];

                  for (int i = data.length-1; i >= 0; i--) {
                    print(widget.batchId);
                    rows.add(DataRow(cells: [
                      DataCell(Text('${data[i][widget.fields[0]]}')),
                      DataCell(Text('${data[i][widget.fields[1]]}')),
                      if (widget.fields.length > 2)
                        DataCell(ElevatedButton(child: const Text("Full record", style: TextStyle(fontSize: 10)), onPressed: () {Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                InfoHomePage(title: '(Archived) ${subIds[i]}' , batchId: subIds[i], user: widget.user, token: widget.token),
                          ),

                        );} ))
                    ],

                    ));
                  }
                  return Center(
                    child: Column(
                        children: [
                          Flexible(
                            child: DataTable(
                              rows: [...rows],
                              columns: [DataColumn(label: Text(widget.fields[0])),
                                DataColumn(label: Text(widget.fields[1])),

                                if (widget.fields.length > 2)
                                  const DataColumn(label: Text('More')),


                              ],
                            ),

                          ),


                        ]
                    ),
                  );
                }
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
            future: getData(widget.path, widget.token)
        ),
      ),
      drawer: makeDrawer(context, "Farm App", widget.user, widget.token),
    );
  }
}

