import 'package:flutter/material.dart';
import 'package:my_teams_apk/class/ConnectionInformation.dart';
import 'package:provider/provider.dart';

class ThreadWidget extends StatelessWidget {

  final TextEditingController _newMessageController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Selector<ConnectionInformation, Thread>(
      selector: (_, inf) => inf.thread!,
      shouldRebuild: (prev, next) {
        return true;
      },
      builder: (_, thread, __) {
        var messages = thread.messages;
        messages.sort((a, b) {
          var at = DateTime.parse(a.time);
          var bt = DateTime.parse(b.time);
          return at.compareTo(bt);
        });
        return Stack(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 60),
              child: ListView(
                reverse: true,
                children: [
                  Column(
                    children: [
                      Text(''),
                      Text(
                        'Thread name: ' + thread.title,
                        style: TextStyle(
                          fontSize: 16,
                        )
                      ),
                      Text(
                          'Thread content: ' + thread.content,
                          style: TextStyle(
                            fontSize: 16,
                          )
                      ),
                      for (var mes in messages) ThreadAnswer(mes),
                    ]
                  ),
                ]
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        color: Colors.grey,
                    ),
                    child: Row(
                        children: [
                          Flexible(
                            child: TextFormField(
                              controller: _newMessageController,
                              decoration: InputDecoration(
                                icon: Icon(Icons.message_outlined),
                              ),
                            ),
                          ),
                          IconButton(
                              icon: Icon(Icons.send),
                              onPressed: () => _addComment(context),
                          )
                        ]
                    )
                  ),
                ),
              ]
            ),
          ]
        );
      }
    );
  }

  Future<void> _addComment(BuildContext context) async {
    if (_newMessageController.text.isNotEmpty) {
      await Provider.of<ConnectionInformation>(context, listen: false).addMessage(_newMessageController.text);
      _newMessageController.clear();
    }
  }
}

class ThreadAnswer extends StatelessWidget {
  late final Message message;

  ThreadAnswer(this.message);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(message.user.name),
      subtitle: Text(message.message),
      trailing: Text(message.time),
    );
  }

}