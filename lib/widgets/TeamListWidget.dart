import 'package:flutter/material.dart';
import 'package:my_teams_apk/class/ConnectedRoutes.dart';
import 'package:my_teams_apk/class/ConnectionInformation.dart';
import 'package:provider/provider.dart';
import 'package:vrouter/vrouter.dart';

class TeamListWidget extends StatefulWidget {
  late final Team t;

  TeamListWidget(this.t, Key key) : super(key: key);

  @override
  _TeamListWidgetState createState() => _TeamListWidgetState(t);
}

class _TeamListWidgetState extends State<TeamListWidget> {
  late final Team t;

  final TextEditingController _controllerName = TextEditingController();
  final TextEditingController _controllerDesc = TextEditingController();

  _TeamListWidgetState(this.t);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(t.name,
          style: TextStyle(
            fontSize: 32,
          )),
      for (var c in channels()) c,
      GestureDetector(
          onTap: () => showDialog(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                    title: const Text('Add new Channel :'),
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
                            decoration:
                                InputDecoration(labelText: 'Description'),
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
                          child: const Text('Cancel',
                              style: TextStyle(
                                color: Colors.red,
                              ))),
                      TextButton(
                          onPressed: () => _addChannel(context),
                          child: const Text('Add the team',
                              style: TextStyle(
                                color: Colors.green,
                              ))),
                    ],
                  )),
          child: Row(children: [
            Padding(
              padding: EdgeInsets.all(12),
              child: Icon(Icons.add_circle_outline),
            ),
            Text(' Add a new channel'),
          ])),
    ]);
  }

  List<Widget> channels() {
    var widgets = List<Widget>.empty(growable: true);

    for (var channel in t.channels) {
      widgets.add(ChannelWidget(channel));
    }

    return widgets;
  }

  void _addChannel(BuildContext context) async {
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
    await Provider.of<ConnectionInformation>(context, listen: false)
        .addChannel(_controllerName.text, _controllerDesc.text);
    Navigator.pop(context, 'Valid');
  }
}

class ChannelWidget extends StatefulWidget {
  late final Channel c;

  ChannelWidget(this.c);

  @override
  _ChannelWidgetState createState() => _ChannelWidgetState(c);
}

class _ChannelWidgetState extends State<ChannelWidget>
    with TickerProviderStateMixin {
  late final Channel c;

  late AnimationController _threadsListControlAnimationController;
  late Animation<double> _threadsListAnimation;

  final TextEditingController _controllerName = TextEditingController();
  final TextEditingController _controllerDesc = TextEditingController();

  _ChannelWidgetState(this.c);

  @override
  void initState() {
    super.initState();

    _threadsListControlAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _threadsListAnimation = CurvedAnimation(
      parent: _threadsListControlAnimationController,
      curve: Curves.easeInCubic,
    );
  }

  @override
  void dispose() {
    _threadsListControlAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(children: [
        IconButton(
          icon: Icon(Icons.arrow_circle_down),
          onPressed: onChannelButtonPressed,
        ),
        Text(' ' + c.name),
      ]),
      SizeTransition(
        sizeFactor: _threadsListAnimation,
        child: ClipRect(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            for (var thread in c.threads) ThreadButton(c, thread),
            Padding(
              padding: EdgeInsets.fromLTRB(25, 3, 0, 10),
              child: GestureDetector(
                onTap: () => showDialog(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                          title: const Text('Add new Thread :'),
                          content: Form(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextFormField(
                                  controller: _controllerName,
                                  decoration:
                                      InputDecoration(labelText: 'Name'),
                                  onTap: () {
                                    if (_controllerName.text ==
                                        "Can't be empty !") {
                                      _controllerName.clear();
                                    }
                                  },
                                ),
                                TextFormField(
                                  controller: _controllerDesc,
                                  decoration:
                                      InputDecoration(labelText: 'Description'),
                                  onTap: () {
                                    if (_controllerDesc.text ==
                                        "Can't be empty !") {
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
                                onPressed: () =>
                                    Navigator.pop(context, 'Cancel'),
                                child: const Text('Cancel',
                                    style: TextStyle(
                                      color: Colors.red,
                                    ))),
                            TextButton(
                                onPressed: () => _addThread(context),
                                child: const Text('Add the thread',
                                    style: TextStyle(
                                      color: Colors.green,
                                    ))),
                          ],
                        )),
                child: Text('+ - Create new thread',
                    style: TextStyle(
                      fontSize: 16,
                    )),
              ),
            ),
          ]),
        ),
      ),
    ]);
  }

  void onChannelButtonPressed() {
    if (_threadsListControlAnimationController.value == 1) {
      _threadsListControlAnimationController.reverse();
    } else {
      _threadsListControlAnimationController.forward();
    }
  }

  void _addThread(BuildContext context) async {
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
    Provider.of<ConnectionInformation>(context, listen: false).setChannel = c;
    await Provider.of<ConnectionInformation>(context, listen: false)
        .addThread(_controllerName.text, _controllerDesc.text);
    Navigator.pop(context, 'Valid');
  }
}

class ThreadButton extends StatelessWidget {
  late final Channel channel;
  late final Thread thread;

  ThreadButton(this.channel, this.thread);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(25, 3, 0, 15),
      child: GestureDetector(
        onTap: () {
          Provider.of<ConnectionInformation>(context, listen: false).setChannel = channel;
          Provider.of<ConnectionInformation>(context, listen: false).setThread = thread;
          ConnectedRoutes.toThread(context, VRouter.of(context).pathParameters['username']!);
        },
        child: Text('# - ' + thread.title,
          style: TextStyle(
            fontSize: 16,
          )
        ),
      ),
    );
  }
}
