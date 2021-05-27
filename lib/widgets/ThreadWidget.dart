import 'package:flutter/material.dart';
import 'package:my_teams_apk/class/ConnectionInformation.dart';
import 'package:provider/provider.dart';

class ThreadWidget extends StatefulWidget {
  @override
  ThreadWidgetState createState() => ThreadWidgetState();
}

class ThreadWidgetState extends State<ThreadWidget> {
  final TextEditingController _controllerCom = TextEditingController();

  final Widget loading = Container(
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox(
            height: 200,
            width: 200,
            child: CircularProgressIndicator(
              strokeWidth: 8,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),
            ),
          ),
          Text(
              'Loading comments...',
              style: TextStyle(
                fontSize: 20,
              )
          ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    var t = Provider.of<ConnectionInformation>(context, listen: true).thread!;
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                t.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),
              Text(t.time),
            ],
          ),
          Text(''),
          Text(
            t.content,
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          Text(''),
          Divider(),
          Text('Comments : '),
          FutureBuilder<List<Message>>(
            initialData: Provider.of<ConnectionInformation>(context, listen: false).cachedMessages,
            future: _loadMessages(context),
            builder: (context, AsyncSnapshot<List<Message>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting && (snapshot.data as List<Message>).isEmpty) return loading;
              if (snapshot.hasError) {
                print(snapshot.error);
                return Center(
                  child: Text('Error found !',
                    style: TextStyle(fontSize: 40),
                  ),
                );
              }
              return Expanded(
                child: ListView.separated(
                  itemCount: (snapshot.data as List<Message>).length,
                  itemBuilder: (context, index) {
                    Message? t = (snapshot.data as List<Message>)[index];
                    return ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(t.user.name),
                          Text(t.time),
                        ]
                      ),
                      subtitle: Text(t.message),
                    );
                  },
                  separatorBuilder: (context,index) => const Divider(),
                )
              );
            }
          ),
          TextFormField(
            controller: _controllerCom,
            decoration: InputDecoration(labelText: 'Comment'),
          ),
          ElevatedButton(
            onPressed: () => _addComment(context),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Comment '),
                Icon(Icons.comment),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<List<Message>> _loadMessages(BuildContext context) {
    print('LOADING MESSAGES');
    var cp =  Provider.of<ConnectionInformation>(context,  listen: false);
    return cp.loadMessages(null);
  }

  Future<void> _addComment(BuildContext context) async {
    if (_controllerCom.text.isNotEmpty) {
      await Provider.of<ConnectionInformation>(context, listen: false).addMessage(_controllerCom.text);
      _controllerCom.clear();
      setState(() {

      });
    }
  }
}