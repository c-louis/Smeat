import 'package:flutter/material.dart';
import 'package:vrouter/vrouter.dart';
import 'package:my_teams_apk/widgets/scaffolds/MyTeamsScaffold.dart';
import 'package:my_teams_apk/widgets/TeamsWidget.dart';
import 'package:my_teams_apk/widgets/ChannelsWidget.dart';
import 'package:my_teams_apk/widgets/ThreadsWidget.dart';
import 'package:my_teams_apk/widgets/ThreadWidget.dart';

class ConnectedRoutes extends VRouteElementBuilder {
  static final String teams = 'teams';

  static void toTeams(BuildContext context, String username) => context.vRouter.push('/$username/$teams');

  static final String channels = 'channels';

  static void toChannels(BuildContext context, String username, String team) =>
    context.vRouter.push('/$username/$teams/$team/$channels');

  static final String threads = 'threads';

  static void toThreads(BuildContext context, String username, String team, String channel) =>
    context.vRouter.push('/$username/$teams/$team/$channels/$channel/$threads');

  static void toThread(BuildContext context, String username, String team, String channel, String thread) {
    print( '/$username/$teams/$team/$channels/$channel/$threads/$thread');
    context.vRouter.push(
        '/$username/$teams/$team/$channels/$channel/$threads/$thread');
  }

  @override
  List<VRouteElement> buildRoutes() {
    return [VNester(
        path: '/:username',
        widgetBuilder: (child) => MyTeamsScaffold(child),
        nestedRoutes: [
          VWidget(
            path: teams,
            widget: TeamsWidget(),
            stackedRoutes: [
              VWidget(
                path: ':team/' + channels,
                widget: ChannelsWidget(),
                stackedRoutes: [
                  VWidget(
                    path: ':channel/' + threads,
                    widget: ThreadsWidget(),
                    stackedRoutes: [
                      VWidget(
                        path: ':thread',
                        widget: ThreadWidget(),
                      ),
                    ]
                  ),
                ]
              ),
            ]
          ),
        ]
    )];
  }
}
