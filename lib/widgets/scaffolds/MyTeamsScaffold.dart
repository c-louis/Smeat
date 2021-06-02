import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_teams_apk/class/ConnectionInformation.dart';
import 'package:provider/provider.dart';
import 'package:random_color/random_color.dart';
import 'package:tuple/tuple.dart';
import 'package:vrouter/vrouter.dart';

import '../TeamListWidget.dart';
import '../UserListWidget.dart';

class MyTeamsScaffold extends StatelessWidget
{
  final Widget child;

  MyTeamsScaffold(this.child);

  final TextEditingController _controllerName = TextEditingController();
  final TextEditingController _controllerDesc = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var username = context.vRouter.pathParameters['username']!;

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Text('    '),
                Selector<ConnectionInformation, Tuple2<List<Team>, Team?>>(
                  selector: (_, inf) => Tuple2(inf.cachedTeams, inf.team),
                  shouldRebuild: (prev, next) {
                    return true;
                  },
                  builder: (_, data, __) {
                    return Column(
                      children: [
                        Text(''),
                        Text(''),
                        GestureDetector(
                          onTap: () => Provider.of<ConnectionInformation>(context, listen: false).setTeam = null,
                          child: CircleAvatar(
                            backgroundColor: data.item2 == null ? Colors.grey.shade600 : Colors.grey.shade800,
                            radius: 35,
                            child: const Icon(Icons.messenger, size: 30),
                          ),
                        ),
                        Text(''),
                        for (var it in data.item1) TeamAvatar(it),
                        GestureDetector(
                          onTap: () => showDialog(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: const Text('Add new Team :'),
                              content: Form(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
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
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, 'Cancel'),
                                  child: const Text('Cancel', style: TextStyle(
                                    color: Colors.red,
                                  ))
                                ),
                                TextButton(
                                    onPressed: () => _addTeam(context),
                                    child: const Text('Add the team', style: TextStyle(
                                      color: Colors.green,
                                    ))
                                ),
                              ],
                            )
                          ),
                          child: CircleAvatar(
                            backgroundColor: data.item2 == null ? Colors.grey.shade600 : Colors.grey.shade800,
                            radius: 35,
                            child: const Icon(Icons.add_circle, size: 30),
                          ),
                        ),
                      ]
                    );
                  }
                ),
                Expanded(
                  child: Selector<ConnectionInformation, Team?>(
                      selector: (_, inf) => inf.team,
                      shouldRebuild: (prev, next) => prev != next,
                      builder: (_, team, __) {
                        if (team != null) {
                          return TeamListWidget(team, Key(team.uuid));
                        } else {
                          return UserListWidget();
                        }
                      }
                  ),
                ),
              ]
            ),
          ]
        ),
      ),
      appBar: AppBar(
        title: Text('Smeat'),
        actions: [
          IconButton(
            icon: Icon(Icons.clear,
              color: Colors.red,
              size: 32,
            ),
            onPressed: () {
              VRouter.of(context).push('/');
            }
          )
        ],
      ),
      body: child,
    );
  }

  void _addTeam(BuildContext context) async {
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
    Navigator.pop(context, 'Valid');
  }
}

class TeamAvatar extends StatelessWidget {
  final Team t;
  final avatarSize;

  TeamAvatar(this.t, {this.avatarSize = 30.00});

  @override
  Widget build(BuildContext context) {

    var _randomColor = RandomColor();
    var _color = _randomColor.randomColor(
        colorHue: ColorHue.multiple(colorHues: [ColorHue.blue])
    );
    return Column(
      children: [
        GestureDetector(
          onTap: () =>
            Provider.of<ConnectionInformation>(context, listen: false).setTeam = t,
          child: CircleAvatar(
            radius: avatarSize,
            backgroundColor: _color,
            child: Text(t.name.substring(0, 2)),
          ),
        ),
        Container(
          width: 50,
          child: Divider(
            thickness: 2,
          ),
        ),
        //Text(''),
      ],
    );
  }
}