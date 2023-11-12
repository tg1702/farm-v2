
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../home.dart';
import '../models/user_model.dart';
import 'info.dart';
import '../main.dart';
import 'create.dart';


class EditPage extends StatefulWidget {
  final batchName;
  final batchId;
  final Map<String,dynamic> user;
  final show;
  final Map<String,dynamic> token;
  const EditPage({super.key, required this.title, required this.batchName, required this.show, required this.user,
  required this.token, required this.batchId
  });

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  var nameController = TextEditingController();

  var descriptionController = TextEditingController();
  var costController = TextEditingController();


  var incomeController = TextEditingController();
  late TextEditingController expQuantityController;
  late TextEditingController deathCountController;
  late TextEditingController dateController;
  late TextEditingController deathDateController;


  var expenseCategories = ["Feed", "Medicine", "Bedding", "Chick purchase", "Transport", "Processing", "Other"];
  List getExpenseCategories(){
    return expenseCategories;
  }
  String? dropdownvalue = "Feed";

  @override
  void initState(){
    super.initState();

    expQuantityController = TextEditingController(text: '1');

    deathCountController = TextEditingController(text: '1');
    deathDateController = TextEditingController(text: generateDate());
    dateController = TextEditingController(text: generateDate());
  }

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
    body: SingleChildScrollView(
    child: Center(
      child: Column(
      // Column is also a layout widget. It takes a list of children and
      // arranges them vertically. By default, it sizes itself to fit its
      // children horizontally, and tries to be as tall as its parent.
      //
      // Invoke "debug painting" (press "p" in the console, choose the
      // "Toggle Debug Paint" action from the Flutter Inspector in Android
      // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
      // to see the wireframe for each widget.
      //
      // Column has various properties to control how it sizes itself and
      // how it positions its children. Here we use mainAxisAlignment to
      // center the children vertically; the main axis here is the vertical
      // axis because Columns are vertical (the cross axis would be
      // horizontal).
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (widget.show == 1)
        ListView(
          padding: const EdgeInsets.all(20.0),
          shrinkWrap: true,
          children: [


            const Text("Expense Category", style: TextStyle(color: Colors.blueGrey)),
            DropdownButton(

              value: dropdownvalue,


              icon: const Icon(Icons.keyboard_arrow_down),


              items: expenseCategories.map((String item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item),
                );
              }).toList(),

              onChanged: (String? newValue) {
                setState(() {
                  dropdownvalue = newValue!;
                });
              },
            ),


            DateTimePicker(
              type: DateTimePickerType.date,
              controller: dateController,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              icon: Icon(Icons.event),
              dateLabelText: 'Date',
              validator: (value) {
                return null;
              },
              onChanged: (value){
                dateController.text = value;
              }


            ),

            TextField(
              controller: costController,
              decoration: const InputDecoration(labelText: "Cost per Unit"),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp("[0-9,.]")),
              ], // Only numbers can be entered
            ),
            TextField(
              controller: expQuantityController,
              decoration: const InputDecoration(labelText: "Quantity Used"),
              keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp("[0-9,.]")),
                ],

            ),
            TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Description',
                )
            ),

            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton(
                  child: const Text("Submit"),
                  onPressed: () async{
                    String url =  "https://tg0217.pythonanywhere.com/user/${widget.user["user_id"]}/batches/${widget.batchName}/expenses";
                    final newEntry = <String, dynamic>  {
                      "Name": dropdownvalue,
                      "Date": fixDate(dateController.text),
                      "Cost": double.parse(costController.text),
                      "Quantity": int.parse(expQuantityController.text),
                      "Description": descriptionController.text,
                      "Total_Cost": double.parse(costController.text)*int.parse(expQuantityController.text),
                    };

                    updateData(url, newEntry, widget.token);



                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InfoHomePage(batchId: widget.batchId, batchName: widget.batchName, title: 'Info for ${widget.batchName}', user: widget.user, token: widget.token),
                      ),

                    );
                  }
              ),
            ),


      ],
    ),
        if (widget.show == 2)
        ListView(
          shrinkWrap: true,
          children: [
            TextField(
                controller: incomeController,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Add Income',

                )
            ),

            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton(
                child: const Text("Submit"),
                onPressed: () async{
                  updateData("https://tg0217.pythonanywhere.com/user/${widget.user["user_id"]}/batches/${widget.batchName}", {"Total_Income": double.parse(incomeController.text)}, widget.token);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => InfoHomePage(title: 'Info for ${widget.batchName}', batchName: widget.batchName, batchId: widget.batchName, user: widget.user, token: widget.token),

                    ),
                  );
                }
              ),
            ),
          ],
        ),

        if (widget.show == 3)
        ListView(
          shrinkWrap: true,
          children: [

            TextField(

              controller: deathCountController,
              decoration: const InputDecoration(labelText: "Add Number of deaths"),
              keyboardType: const TextInputType.numberWithOptions(signed: true),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
            ),

            DateTimePicker(
              type: DateTimePickerType.date,
              controller: deathDateController,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              icon: const Icon(Icons.event),
              dateLabelText: 'Date',
              validator: (value) {
                return null;
              },
              onChanged: (value){
                deathDateController.text = value;
              }

            ),


            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton(
                  child: const Text("Submit"),
                  onPressed: () async{
                    String url = "https://tg0217.pythonanywhere.com/user/${widget.user["user_id"]}/batches/${widget.batchName}";

                    // TODO: Add a week field to database
                         final newEntry = <String, dynamic> {
                           "Date": fixDate(deathDateController.text),
                           "Quantity": int.parse(deathCountController.text),
                         };
                         sendData(url, newEntry, widget.token);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => InfoHomePage(title: 'Info for ${widget.batchName}', batchName: widget.batchName, batchId: widget.batchId, user: widget.user, token: widget.token),
                            ),

                        );
                        },
                    ),



              ),
          ],
        ),

      ],
      ),
    ),
      ),

      // This trailing comma makes auto-formatting nicer for build methods.
      drawer: makeDrawer(context, 'Farm App', widget.user, widget.token),
    );

  }
}



String generateTime(){
  var time = DateTime.now();

  String hour = time.hour < 10 ? "0${time.hour}":"${time.hour}";
  String minute = time.minute < 10 ? "0${time.minute}":"${time.minute}";
  String second = time.second < 10 ? "0${time.second}":"${time.second}";

  var currentTime = "-$hour-$minute-$second";
  return currentTime;
}


int calculateWeek(originalDate, currentDate){


  if (originalDate == null) return 1;

  int year = int.parse("${originalDate[6]}${originalDate[7]}${originalDate[8]}${originalDate[9]}");
  int month = int.parse("${originalDate[3]}${originalDate[4]}");
  int day =   int.parse("${originalDate[0]}${originalDate[1]}");

  int year2 = int.parse("${currentDate[6]}${currentDate[7]}${currentDate[8]}${currentDate[9]}");
  int month2 = int.parse("${currentDate[3]}${currentDate[4]}");
  int day2 =   int.parse("${currentDate[0]}${currentDate[1]}");

  var originalDateTime = DateTime( year, month, day);
  var currentDateTime = DateTime( year2, month2, day2);

  int currentWeek = 0;

  while (!originalDateTime.isAfter(currentDateTime)) {
    ++currentWeek;
    originalDateTime = DateTime(originalDateTime.year, originalDateTime.month, originalDateTime.day + 7);
  }
  return currentWeek;
}