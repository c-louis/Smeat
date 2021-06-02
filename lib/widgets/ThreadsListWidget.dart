import 'package:flutter/material.dart';
import 'package:my_teams_apk/class/ConnectedRoutes.dart';
import 'package:my_teams_apk/class/ConnectionInformation.dart';
import 'package:provider/provider.dart';
import 'package:vrouter/vrouter.dart';

class ThreadsListWidget extends StatelessWidget {
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
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
            ),
          ),
          Text(
              'Loading threads...',
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
    return FutureBuilder(
      initialData: Provider.of<ConnectionInformation>(context, listen: false).cachedThreads,
      future: _loadThreads(context),
      builder: (BuildContext context, AsyncSnapshot<List<Thread>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && (snapshot.data as List<Thread>).isEmpty) return loading;
        if (snapshot.hasError) {
          print(snapshot.error);
          return Center(
            child: Text('Error found !\n' + snapshot.error.toString(),
              style: TextStyle(fontSize: 40),
            ),
          );
        }
        return ListView.separated(
          itemCount: (snapshot.data as List<Thread>).length,
          itemBuilder: (context, index) {
            var t = (snapshot.data as List<Thread>)[index];
            return ListTile(
              title: Text(t.title),
              subtitle: Text(t.content, softWrap: false, overflow: TextOverflow.ellipsis),
              onTap: () {
                Provider.of<ConnectionInformation>(context, listen: false).setThread = t;
                ConnectedRoutes.toThread(context,
                  context.vRouter.pathParameters['username']!,
                );
              },
            );
          },
          separatorBuilder: (context, index) => const Divider(),
        );
      },
    );
  }

  Future<List<Thread>> _loadThreads(BuildContext context) async {
    var cp =  Provider.of<ConnectionInformation>(context,  listen: false);
    return await cp.loadThreads();
  }
}