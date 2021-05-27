import 'package:flutter/material.dart';
import 'package:my_teams_apk/class/ConnectionInformation.dart';

import 'package:my_teams_apk/widgets/TeamsListWidget.dart';
import 'package:provider/provider.dart';

class TeamsWidget extends StatefulWidget {

  @override
  TeamsWidgetState createState() => TeamsWidgetState();
}

class TeamsWidgetState extends State<TeamsWidget>
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
            body = TeamsListWidget();
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
                      decoration: InputDecoration(labelText: 'Name'),
                      onTap: () {
                        if (_controllerName.text == "Can't be empty !") {
                          _controllerName.clear();
                        }
                      },
                    ),
                    TextFormField(
                      controller: _controllerDesc,
                      decoration: InputDecoration(labelText: 'Description'),
                      onTap: () {
                        if (_controllerDesc.text == "Can't be empty !") {
                          _controllerDesc.clear();
                        }
                      },
                    ),
                    Text(''),
                    ElevatedButton(
                      onPressed: _addTeam,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Add a team '),
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
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'List teams'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Add a team'),
          BottomNavigationBarItem(icon: Icon(Icons.supervised_user_circle), label: 'Talk with people'),
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

  void _addTeam() async {
    if (_controllerName.text.isEmpty ||
        _controllerName.text == "Can't be empty !") {
      _controllerName.text = "Can't be empty !";
    }
    if (_controllerDesc.text.isEmpty ||
        _controllerDesc.text == "Can't be empty !") {
      _controllerDesc.text = "Can't be empty !";
    }
    if (_controllerName.text == "Can't be empty !" ||
        _controllerDesc.text == "Can't be empty !") {
      return;
    }
    await Provider.of<ConnectionInformation>(context, listen: false).addTeam(_controllerName.text, _controllerDesc.text);
  }
}