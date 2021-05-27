import 'package:flutter/material.dart';
import 'package:vrouter/vrouter.dart';

class MyTeamsScaffold extends StatelessWidget
{
  final Widget child;

  const MyTeamsScaffold(this.child);

  @override
  Widget build(BuildContext context) {
    var username = context.vRouter.pathParameters['username']!;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            VRouter.of(context).systemPop();
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: Text('Connected as : ' + username),
      ),
      body: child,
    );
  }
}