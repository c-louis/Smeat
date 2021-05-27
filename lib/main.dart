import 'package:flutter/material.dart';
import 'package:my_teams_apk/class/ConnectionInformation.dart';
import 'package:provider/provider.dart';
import 'package:vrouter/vrouter.dart';

import 'package:my_teams_apk/widgets/MyTeamsClient.dart';
import 'package:my_teams_apk/class/ConnectedRoutes.dart';

void main() {
  runApp(MyTeamsClientRoot());
}

class MyTeamsClientRoot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ConnectionInformation>(create: (_) => ConnectionInformation()),
      ],
      child: VRouter(
        theme: ThemeData.light(),
        debugShowCheckedModeBanner: false,
        mode: VRouterModes.history,
        routes: <VRouteElementBuilder>[
          VWidget(
            path: '/home',
            widget: MyTeamsClient(),
            stackedRoutes: [
              ConnectedRoutes(),
            ]
          ),
          VRouteRedirector(
            path: r':_(.*)',
            redirectTo: '/home'
          ),
        ],
      ),
    );
  }
}

