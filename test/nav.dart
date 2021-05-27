import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vrouter/vrouter.dart';

main() {
  group('VNester', () {
    testWidgets('VNester VStacked pop', (WidgetTester tester) async {
      await tester.pumpWidget(
        VRouter(
          routes: [
            VWidget(
              path: '/',
              widget: Builder(
                builder: (BuildContext context) {
                  return Scaffold(
                    body: Text('VWidgetHome'),
                    floatingActionButton: FloatingActionButton(
                      onPressed: () => VRouter.of(context).push('/user/team'),
                    ),
                  );
                },
              ),
              stackedRoutes: [
                VNester(
                  path: '/user',
                  widgetBuilder: (child) => Builder(
                    builder: (BuildContext context) {
                      return Scaffold(
                        appBar: AppBar(
                          title: Text('Scaffold VNester'),
                          leading: IconButton(
                            onPressed: () {
                              VRouter.of(context).systemPop();
                            },
                            icon: Icon(Icons.arrow_forward_rounded),
                          ),
                        ),
                        body: child,
                      );
                    },
                  ),
                  nestedRoutes: [
                    VWidget(
                      path: 'team',
                      widget: Builder(
                        builder: (BuildContext context) {
                          return OutlinedButton(
                            onPressed: () => VRouter.of(context).push('/user/team/channel'),
                            child: Text('VWidgetTeam'),
                          );
                        },
                      ),
                      stackedRoutes: [
                        VPopHandler(
                          onPop: (vRedirector) async => vRedirector.push('/user/team/channel'),
                          stackedRoutes: [
                            VWidget(
                              path: 'channel',
                              widget: Builder(
                                builder: (BuildContext context) {
                                  return OutlinedButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: Text('VWidgetChannel'),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      );

      await tester.pumpAndSettle();

      // At first we are on "/" so only VWidget1 should be shown

      final vWidget1Finder = find.text('VWidgetHome');
      final vWidget2Finder = find.text('VWidgetTeam');
      final vWidget3Finder = find.text('VWidgetChannel');
      final vNesterFinder = find.text('Scaffold VNester');

      expect(vWidget1Finder, findsOneWidget);
      expect(vNesterFinder, findsNothing);
      expect(vWidget2Finder, findsNothing);
      expect(vWidget3Finder, findsNothing);

      // Navigate to '/user/team'
      // Tap the add button.
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(vWidget1Finder, findsNothing);
      expect(vNesterFinder, findsOneWidget);
      expect(vWidget2Finder, findsOneWidget);
      expect(vWidget3Finder, findsNothing);

      // Push to '/user/team/channel'
      // Tap the add button.
      await tester.tap(find.byType(OutlinedButton));
      await tester.pumpAndSettle();

      expect(vWidget1Finder, findsNothing);
      expect(vNesterFinder, findsOneWidget);
      expect(vWidget2Finder, findsNothing);
      expect(vWidget3Finder, findsOneWidget);

      // Pop to '/user/team'
      // Tap the add button.
      // Doing a single Pop I expect to go back from 1 Stacked Route but instead I go back to "/"
      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      expect(vWidget1Finder, findsNothing);
      expect(vNesterFinder, findsOneWidget);
      expect(vWidget2Finder, findsOneWidget);
      expect(vWidget3Finder, findsNothing);
    });
  });
}