import 'package:flutter/material.dart';
import 'package:my_teams_apk/class/ConnectionInformation.dart';

import 'package:my_teams_apk/widgets/ThreadsListWidget.dart';
import 'package:provider/provider.dart';

class ThreadsWidget extends StatefulWidget {

  @override
  ThreadsWidgetState createState() => ThreadsWidgetState();
}

class ThreadsWidgetState extends State<ThreadsWidget>
{
  final TextEditingController _controllerName = TextEditingController();
  final TextEditingController _controllerDesc = TextEditingController();

  int oldselected = -1;
  int selected = 0;
  Widget? body;

  @override
  Widget build(BuildContext context) {
    if (oldselected != selected) {
      switch (selected) {
        case 0:
          {
            body = ThreadsListWidget();
          }
          break;
        case 1:
          {
            body = Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                child: Column(
                  children: [
                    TextFormField(
                      controller: _controllerName,
                      decoration: InputDecoration(labelText: 'Title'),
                      onTap: () {
                        if (_controllerName.text == "Can't be empty !")
                          _controllerName.clear();
                      },
                    ),
                    TextFormField(
                      controller: _controllerDesc,
                      decoration: InputDecoration(labelText: 'Content'),
                      onTap: () {
                        if (_controllerDesc.text == "Can't be empty !")
                          _controllerDesc.clear();
                      },
                    ),
                    Text(""),
                    ElevatedButton(
                      onPressed: _addThread,
                      child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("Add a team "),
                            Icon(Icons.add),
                          ]
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          break;
        case 2:
          {

          }
          break;
      }
    }

    return Scaffold(
      body: body,
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "List threads"),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: "Add a thread"),
          BottomNavigationBarItem(icon: Icon(Icons.supervised_user_circle), label: "Talk with people"),
        ],
        onTap: (clicked) => _updatePage(clicked),
        currentIndex: selected,
      ),
    );
  }

  void _updatePage(int clicked) {
    if (clicked != selected) {
      setState(() {
        oldselected = selected;
        selected = clicked;
      });
    }
  }

  void _addThread() async {
    if (_controllerName.text.isEmpty ||
        _controllerName.text == "Can't be empty !") {
      _controllerName.text = "Can't be empty !";
    }
    if (_controllerDesc.text.isEmpty ||
        _controllerDesc.text == "Can't be empty !") {
      _controllerDesc.text = "Can't be empty !";
    }
    if (_controllerName.text == "Can't be empty !" ||
        _controllerDesc.text == "Can't be empty !")
      return;
    Provider.of<ConnectionInformation>(context, listen: false).addThread(_controllerName.text, _controllerDesc.text);
  }
}