import 'package:flutter/material.dart';
import 'package:my_teams_apk/class/ConnectedRoutes.dart';
import 'package:my_teams_apk/class/ConnectionInformation.dart';
import 'package:provider/provider.dart';
import 'package:vrouter/vrouter.dart';

class ChannelsListWidget extends StatelessWidget {
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
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          ),
          Text(
              "Loading Channels...",
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
      initialData: Provider.of<ConnectionInformation>(context, listen: false).cachedChannels,
      future: _loadChannels(context),
      builder: (BuildContext context, AsyncSnapshot<List<Channel>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && (snapshot.data as List<Channel>).isEmpty) return loading;
        if (snapshot.hasError) {
          print(snapshot.error);
          return Center(
            child: Text("Error found !",
              style: TextStyle(fontSize: 40),
            ),
          );
        }
        return ListView.separated(
          itemCount: (snapshot.data as List<Channel>).length,
          itemBuilder: (context, index) {
            Channel? t = (snapshot.data as List<Channel>)[index];
            return ListTile(
              title: Text(t.name),
              subtitle: Text(t.description),
              onTap: () {
                Provider.of<ConnectionInformation>(context, listen: false).setChannel = t;
                ConnectedRoutes.toThreads(context, context.vRouter.pathParameters['username']!, context.vRouter.pathParameters['team']!, t.uuid);
              },
            );
          },
          separatorBuilder: (context, index) => const Divider(),
        );
      },
    );
  }

  Future<List<Channel>> _loadChannels(BuildContext context) async {
    ConnectionInformation cp =  Provider.of<ConnectionInformation>(context,  listen: false);
    return await cp.loadChannels(null);
  }
}