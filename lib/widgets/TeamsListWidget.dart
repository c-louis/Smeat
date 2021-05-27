import 'package:flutter/material.dart';
import 'package:my_teams_apk/class/ConnectedRoutes.dart';
import 'package:my_teams_apk/class/ConnectionInformation.dart';
import 'package:provider/provider.dart';
import 'package:vrouter/vrouter.dart';

class TeamsListWidget extends StatelessWidget {
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
            ),
          ),
          Text(
              "Loading teams...",
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
      initialData: Provider.of<ConnectionInformation>(context, listen: false).cachedTeams,
      future: _loadTeams(context),
      builder: (BuildContext context, AsyncSnapshot<List<Team>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && (snapshot.data as List<Team>).isEmpty) return loading;
        if (snapshot.hasError) {
          print(snapshot.error);
          return Center(
            child: Text("Error found !",
              style: TextStyle(fontSize: 40),
            ),
          );
        }
        return ListView.separated(
          itemCount: (snapshot.data as List<Team>).length,
          itemBuilder: (context, index) {
            Team? t = (snapshot.data as List<Team>)[index];
            return ListTile(
              title: Text(t.name),
              subtitle: Text(t.desc),
              onTap: () {
                Provider.of<ConnectionInformation>(context, listen: false).setTeam = t;
                ConnectedRoutes.toChannels(context, context.vRouter.pathParameters['username'] ?? "", t.uuid);
              },
            );
          },
          separatorBuilder: (context,index) => const Divider(),
        );
      },
    );
  }

  Future<List<Team>> _loadTeams(BuildContext context) async {
    ConnectionInformation cp =  Provider.of<ConnectionInformation>(context,  listen: false);
    return await cp.loadTeams();
  }
}