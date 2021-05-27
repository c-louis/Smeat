import 'package:flutter/material.dart';
import 'package:my_teams_apk/class/ConnectionInformation.dart';
import 'package:provider/provider.dart';
import 'package:my_teams_apk/class/ConnectedRoutes.dart';

class MyTeamsClient extends StatelessWidget {
  final TextEditingController _controllerAddr = TextEditingController();
  final TextEditingController _controllerPort = TextEditingController();
  final TextEditingController _controllerName = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _controllerAddr.text = '92.222.91.125';
    _controllerPort.text = '2340';
    _controllerName.text = '';
    return MaterialApp(
      home: Scaffold(
        extendBodyBehindAppBar: true,
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text(
                'Smeat',
                style: TextStyle(
                  fontSize: 40,
                ),
              ),
              Form(
                child: Column(
                    children: <TextFormField>[
                      TextFormField(
                        controller: _controllerAddr,
                        decoration: InputDecoration(labelText: 'Server IP'),
                      ),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        controller: _controllerPort,
                        decoration: InputDecoration(labelText: 'Server Port'),
                        onTap: () {
                          if (_controllerPort.text == "Can't be empty !") {
                            _controllerPort.clear();
                          }
                        },
                      ),
                      TextFormField(
                        controller: _controllerName,
                        decoration: InputDecoration(labelText: 'Username'),
                        onTap: () {
                          if (_controllerName.text == "Can't be empty !") {
                            _controllerName.clear();
                          }
                        },
                      ),
                    ]
                ),
              ),
              ElevatedButton(
                onPressed: () => _connectToServer(context),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Connect to the Server '),
                    Icon(Icons.arrow_forward_ios_sharp),
                  ],
                )
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _connectToServer(BuildContext context) async {
    print('Called');
    String addr;
    if (_controllerAddr.text.isNotEmpty) {
      addr = _controllerAddr.text;
    } else {
      addr = '127.0.0.1';
    }
    if (_controllerName.text.isEmpty ||
        _controllerName.text == "Can't be empty !") {
      _controllerName.text = "Can't be empty !";
    }
    if (_controllerPort.text.isEmpty ||
        _controllerPort.text == "Can't be empty !") {
      _controllerPort.text = "Can't be empty !";
    }
    if (_controllerName.text.isNotEmpty && _controllerName.text.contains(' ')) {
      _controllerName.text = 'Space not allowed !';
    }
    if (_controllerPort.text == "Can't be empty !" ||
        _controllerName.text == "Can't be empty !" ||
        _controllerName.text == 'Space not allowed !') {
      return;
    }
    var tmp =
    Provider.of<ConnectionInformation>(context, listen: false);
    tmp.username = _controllerName.text;
    tmp.address = addr;
    tmp.port = _controllerPort.text;
    if (await tmp.connect()) {
      print('Successfully Connected to server and Logged in !');
      ConnectedRoutes.toTeams(context, _controllerName.text);
    } else {
      print('An Erorr occured !');
    }
  }
}