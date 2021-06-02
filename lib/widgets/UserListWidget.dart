import 'package:flutter/material.dart';
import 'package:my_teams_apk/class/ConnectionInformation.dart';
import 'package:provider/provider.dart';

class UserListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Selector<ConnectionInformation, List<User>>(
      selector: (_, inf) => inf.cachedUsers,
      shouldRebuild: (prev, next) => prev.length != next.length,
      builder: (_, users, __) {

        users.sort((a, b) {
          if (a.status == false && b.status == false) {
            return a.name.toLowerCase().compareTo(b.name.toLowerCase());
          }
          return a.status ? -1 : 1;
        });

        return Column(
          children: [
            Text(''),
            Text('Users',
              style: TextStyle(
                fontSize: 24,
              )
            ),
            for (var user in users) UserDisplay(user),
          ]
        );
      }
    );
  }

}

class UserDisplay extends StatelessWidget {
  late final User user;

  UserDisplay(this.user);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(10, 0, 20, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(user.name),
              Icon(Icons.device_thermostat, color: user.status ? Colors.green : Colors.red),
            ],
          ),
        ),
        Divider(),
      ]
    );
  }

}