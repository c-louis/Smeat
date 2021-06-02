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
    var t = Provider.of<ConnectionInformation>(context).thread;

    if (t == null) {
      return Text('Todo');
    } else {
      return Column(
        children: [
          Text(t.title),
          Text(t.content),
        ]
      );
    }
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