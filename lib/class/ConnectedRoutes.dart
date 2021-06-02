import 'package:flutter/material.dart';
import 'package:my_teams_apk/widgets/WelcomeWidget.dart';
import 'package:vrouter/vrouter.dart';
import 'package:my_teams_apk/widgets/scaffolds/MyTeamsScaffold.dart';
import 'package:my_teams_apk/widgets/TeamsWidget.dart';
import 'package:my_teams_apk/widgets/ChannelsWidget.dart';
import 'package:my_teams_apk/widgets/ThreadsWidget.dart';
import 'package:my_teams_apk/widgets/ThreadWidget.dart';

class ConnectedRoutes extends VRouteElementBuilder {
  static final String welcome = 'welcome';

  static void toWelcome(BuildContext context, String username) => context.vRouter.push('/$username/$welcome');

  static final String thread = 'thread';

  static void toThread(BuildContext context, String username) => context.vRouter.push('/$username/$thread');

  static final String user = 'user';

  static void toUser(BuildContext context, String username) =>
    context.vRouter.push('/$username/$user');

  @override
  List<VRouteElement> buildRoutes() {
    return [VNester(
        path: '/:username',
        widgetBuilder: (child) => MyTeamsScaffold(child),
        nestedRoutes: [
          VWidget(
            path: welcome,
            widget: WelcomeWidget(),
          ),
          VWidget(
            path: thread,
            widget: ThreadWidget(),
          ),
          VWidget(
            path: user,
            widget: ChannelsWidget(),
          ),
        ]
    )];
  }
}
